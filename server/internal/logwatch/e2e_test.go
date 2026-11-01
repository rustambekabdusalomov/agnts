package logwatch

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"
	"strconv"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/logsource"
	"agnts/internal/orchestrator"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
)

// fakeWork records the tickets the log watcher asks for.
type fakeWork struct{ inputs []orchestrator.LogTicketInput }

func (w *fakeWork) CreateLogTicket(_ context.Context, in orchestrator.LogTicketInput, _ domain.Origin) (domain.Ticket, error) {
	w.inputs = append(w.inputs, in)
	return domain.Ticket{Key: fmt.Sprintf("LOG-%d", len(w.inputs))}, nil
}

// TestEndToEnd runs the log watcher on a real database and a real Loki:
// a source is saved after Test connection, its services are discovered,
// the supervisor reads what a service logs, and the findings are stored,
// reported and (in ticket mode) ticketed. Run with
// AGNTS_TEST_DATABASE_URL and AGNTS_TEST_LOKI_URL set.
func TestEndToEnd(t *testing.T) {
	dbURL, lokiURL := os.Getenv("AGNTS_TEST_DATABASE_URL"), os.Getenv("AGNTS_TEST_LOKI_URL")
	if dbURL == "" || lokiURL == "" {
		t.Skip("AGNTS_TEST_DATABASE_URL and AGNTS_TEST_LOKI_URL not set")
	}
	sys := domain.System(context.Background())
	pool, err := postgres.Open(sys, dbURL)
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	if err := postgres.Migrate(sys, pool, "up", log); err != nil {
		t.Fatal(err)
	}
	// As the server does: scoped connections use the tenant role, so the
	// workspace policies hold.
	if _, err := postgres.DetectTenantRole(sys, pool); err != nil {
		t.Fatal(err)
	}
	users := postgres.NewUsers(pool)
	run := strconv.FormatInt(time.Now().UnixNano(), 36)
	owner, err := users.Create(sys, domain.User{Username: "e2e-" + run, PasswordHash: "h"})
	if err != nil {
		t.Fatal(err)
	}
	w, err := postgres.NewWorkspaces(pool).Create(sys, postgres.NewWorkspace{Name: "e2e-" + run, OwnerID: owner.ID})
	if err != nil {
		t.Fatal(err)
	}
	ctx := domain.WithWorkspace(context.Background(), w.ID)
	agent := postgres.NewAgent(pool)
	repo, err := agent.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api-" + run + ".git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	box, _ := secret.NewBox(make([]byte, 32))
	settings := postgres.NewSettings(pool, domain.DefaultSettings())
	work := &fakeWork{}
	svc := New(postgres.NewLogs(pool, box), agent, work, settings, nil, logsource.Dialer{Allow: []string{"127.0.0.1", "localhost"}}, log)

	// 1. Save a Loki source: it must pass Test connection.
	service := "api-" + run
	push(t, lokiURL, service, []string{"level=info msg=boot"}) // so the label exists
	src, err := svc.SaveSource(ctx, SourceInput{LogSource: domain.LogSource{Name: "loki-" + run, Kind: domain.LogLoki, Address: lokiURL,
		Environment: "production", Enabled: true, PollSeconds: 5}, Auth: &domain.LogAuth{Kind: "none"}})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := svc.SaveSource(ctx, SourceInput{LogSource: domain.LogSource{Name: "bad-" + run, Kind: domain.LogLoki, Address: "http://10.255.255.1:3100",
		Environment: "production", Enabled: true}}); err == nil {
		t.Fatal("a private address outside the allow list must not save")
	}

	// 2. Discover the service and give it the repository.
	var found []domain.LogService
	for range 20 {
		if found, err = svc.Discover(ctx, src.ID); err == nil && hasService(found, service) {
			break
		}
		time.Sleep(time.Second)
	}
	if !hasService(found, service) {
		t.Fatalf("discover %+v %v", found, err)
	}
	if _, err := svc.SetServices(ctx, src.ID, []domain.LogService{{Name: service, Selector: `{service_name="` + service + `"}`, RepoIDs: []int64{repo.ID}, Enabled: true}}); err != nil {
		t.Fatal(err)
	}
	// Ticket mode for errors, so the panic opens one.
	st, _ := settings.Get(ctx)
	st.LogWatch.Errors = domain.LogModeTicket
	if _, err := settings.Put(ctx, st, domain.OriginSystem); err != nil {
		t.Fatal(err)
	}

	// 3. The supervisor reads what the service logs from now on.
	runCtx, stop := context.WithCancel(sys)
	defer stop()
	go svc.Run(runCtx)
	time.Sleep(2 * time.Second) // the first read sets the cursor
	push(t, lokiURL, service, []string{
		"panic: assignment to entry in nil map", "", "goroutine 1 [running]:", "main.applyCoupon(0xc000123456)", "\t/app/billing/coupon.go:88 +0x1d",
		`{"level":"info","msg":"incoming","caller":"auth/mw.go:31","authorization":"Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U"}`,
	})
	var fs []domain.LogFinding
	deadline := time.Now().Add(45 * time.Second)
	settled := func() bool {
		fixing, reported := false, false
		for _, f := range fs {
			fixing = fixing || (f.Detector == "panic" && f.Status == domain.LogFixing)
			reported = reported || (f.Detector == "secret" && f.Status == domain.LogReported)
		}
		return fixing && reported
	}
	for time.Now().Before(deadline) {
		fs, _ = svc.Findings(ctx, domain.LogFindingFilter{})
		if settled() {
			break
		}
		time.Sleep(time.Second)
	}
	stop()
	if len(fs) != 2 {
		t.Fatalf("findings %+v", fs)
	}
	var panicF, leak domain.LogFinding
	for _, f := range fs {
		switch f.Detector {
		case "panic":
			panicF = f
		case "secret":
			leak = f
		}
	}
	if panicF.Status != domain.LogFixing || panicF.TicketKey != "LOG-1" || len(work.inputs) != 1 || work.inputs[0].RepoIDs[0] != repo.ID {
		t.Fatalf("the panic must open a ticket: %+v %+v", panicF, work.inputs)
	}
	if leak.Status != domain.LogReported || leak.SecretMask != "eyJh…8U" {
		t.Fatalf("the leak must be reported (security is report): %+v", leak)
	}
	full, _ := svc.Finding(ctx, panicF.ID)
	if !strings.Contains(full.Sample, "main.applyCoupon") {
		t.Errorf("the sample must hold the whole trace: %q", full.Sample)
	}
	full, _ = svc.Finding(ctx, leak.ID)
	if strings.Contains(full.Sample, "dozjgNry") {
		t.Error("the secret reached the stored sample")
	}
	got, _ := svc.Source(ctx, src.ID)
	if got.Status != domain.LogSourceOK || got.LastReadAt == nil {
		t.Errorf("source health %+v", got)
	}
}

func hasService(svcs []domain.LogService, name string) bool {
	for _, s := range svcs {
		if s.Name == name {
			return true
		}
	}
	return false
}

func push(t *testing.T, lokiURL, service string, lines []string) {
	t.Helper()
	now := time.Now()
	var values [][2]string
	for i, l := range lines {
		values = append(values, [2]string{strconv.FormatInt(now.Add(time.Duration(i)*time.Millisecond).UnixNano(), 10), l})
	}
	body, _ := json.Marshal(map[string]any{"streams": []any{map[string]any{"stream": map[string]string{"service_name": service}, "values": values}}})
	resp, err := http.Post(lokiURL+"/loki/api/v1/push", "application/json", bytes.NewReader(body))
	if err != nil {
		t.Fatal(err)
	}
	_ = resp.Body.Close()
	if resp.StatusCode/100 != 2 {
		t.Fatalf("loki push: %d", resp.StatusCode)
	}
}
