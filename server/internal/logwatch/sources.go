package logwatch

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"io"
	"slices"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/logsource"
	"agnts/internal/store/postgres"
)

// SourceInput is a source as the form sends it. Auth nil keeps the saved
// credentials.
type SourceInput struct {
	domain.LogSource
	Auth *domain.LogAuth
}

// Sources lists the workspace's sources.
func (s *Service) Sources(ctx context.Context) ([]domain.LogSource, error) {
	return s.store.LogSources(ctx)
}

// Source returns one source.
func (s *Service) Source(ctx context.Context, id int64) (domain.LogSource, error) {
	return s.store.LogSource(ctx, id, false)
}

// SaveSource checks and saves a source (ID 0 creates it). A pulling
// source must pass Test connection first.
func (s *Service) SaveSource(ctx context.Context, in SourceInput) (domain.LogSource, error) {
	x := in.LogSource
	keep := in.Auth == nil && x.ID != 0
	if in.Auth != nil {
		x.Auth = *in.Auth
	} else if x.ID != 0 {
		old, err := s.store.LogSource(ctx, x.ID, true)
		if err != nil {
			return x, err
		}
		x.Auth = old.Auth
		if old.Kind != x.Kind {
			return x, invalid("the kind of a source can't change: add a new source")
		}
	}
	if err := x.Normalize(); err != nil {
		return x, invalid("%v", err)
	}
	if x.Kind.Pulls() && x.Enabled {
		if _, err := s.test(ctx, x); err != nil {
			return x, invalid("test connection failed: %v", err)
		}
	}
	out, err := s.store.SaveLogSource(ctx, x, keep)
	if errors.Is(err, domain.ErrConflict) {
		return out, invalid("a source named %q already exists", x.Name)
	}
	s.Wake()
	return out, err
}

// DeleteSource removes a source; its findings stay.
func (s *Service) DeleteSource(ctx context.Context, id int64) error {
	err := s.store.DeleteLogSource(ctx, id)
	s.Wake()
	return err
}

// TestResult is Test connection's answer.
type TestResult struct {
	logsource.TestResult
	// Network is the private network the connection went through, "" for
	// a direct one.
	Network   string `json:"network"`
	LatencyMS int64  `json:"latencyMs"`
}

// Test checks an unsaved source (the form). Auth nil with an ID uses the
// saved credentials.
func (s *Service) Test(ctx context.Context, in SourceInput) (TestResult, error) {
	x := in.LogSource
	if in.Auth != nil {
		x.Auth = *in.Auth
	} else if x.ID != 0 {
		old, err := s.store.LogSource(ctx, x.ID, true)
		if err != nil {
			return TestResult{}, err
		}
		x.Auth = old.Auth
	}
	if err := x.Normalize(); err != nil {
		return TestResult{}, invalid("%v", err)
	}
	if !x.Kind.Pulls() {
		return TestResult{}, invalid("push sources are tested by sending to them")
	}
	return s.test(ctx, x)
}

func (s *Service) test(ctx context.Context, x domain.LogSource) (TestResult, error) {
	var out TestResult
	c, err := s.dialer.For(domain.WorkspaceOf(ctx), x)
	if err != nil {
		return out, err
	}
	p, err := s.newPuller(x, c)
	if err != nil {
		return out, err
	}
	start := time.Now()
	ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()
	res, err := p.Test(ctx)
	if err != nil {
		if logsource.Unauthorized(err) {
			return out, errors.New("the credentials were refused (" + err.Error() + ")")
		}
		return out, err
	}
	out.TestResult, out.LatencyMS = res, time.Since(start).Milliseconds()
	if c.NetworkID != nil && s.dialer.Router != nil {
		u := c.Base
		port := 443
		if u.Scheme == "http" {
			port = 80
		}
		if n, ok := s.dialer.Router.Pick(domain.WorkspaceOf(ctx), u.Hostname(), port); ok {
			out.Network = n.Name
		}
	}
	return out, nil
}

// Discover lists the services a saved source's logs hold, marking the
// ones already watched and suggesting a repository by name.
func (s *Service) Discover(ctx context.Context, id int64) ([]domain.LogService, error) {
	src, err := s.store.LogSource(ctx, id, true)
	if err != nil {
		return nil, err
	}
	if !src.Kind.Pulls() {
		return src.Services, nil
	}
	c, err := s.dialer.For(domain.WorkspaceOf(ctx), src)
	if err != nil {
		return nil, err
	}
	p, err := s.newPuller(src, c)
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()
	found, err := p.Discover(ctx)
	if err != nil {
		return nil, err
	}
	repos, _ := s.tickets.ListRepositories(ctx)
	have := map[string]domain.LogService{}
	for _, v := range src.Services {
		have[v.Name] = v
	}
	for i, v := range found {
		if h, ok := have[v.Name]; ok {
			found[i] = h
			continue
		}
		found[i].Enabled = false
		for _, r := range repos {
			if r.ArchivedAt == nil && strings.EqualFold(r.Name, v.Name) {
				found[i].RepoIDs = []int64{r.ID}
			}
		}
	}
	return found, nil
}

// SetServices replaces a source's watched services. Findings of a
// service whose repositories changed move to the new grouping.
func (s *Service) SetServices(ctx context.Context, sourceID int64, svcs []domain.LogService) ([]domain.LogService, error) {
	src, err := s.store.LogSource(ctx, sourceID, false)
	if err != nil {
		return nil, err
	}
	seen := map[string]bool{}
	for i := range svcs {
		v := &svcs[i]
		v.Name, v.Selector = strings.TrimSpace(v.Name), strings.TrimSpace(v.Selector)
		if v.Name == "" || len([]rune(v.Name)) > 120 {
			return nil, invalid("a service needs a name of at most 120 characters")
		}
		if seen[v.Name] {
			return nil, invalid("service %q is listed twice", v.Name)
		}
		seen[v.Name] = true
		if src.Kind == domain.LogLoki && v.Selector != "" && !strings.HasPrefix(v.Selector, "{") {
			return nil, invalid("a Loki selector looks like {app=\"api\"}")
		}
		v.RepoIDs = slices.Compact(v.RepoIDs)
		v.SourceID = sourceID
	}
	old := map[string]domain.LogService{}
	for _, v := range src.Services {
		old[v.Name] = v
	}
	out, err := s.store.SetLogServices(ctx, sourceID, svcs)
	if err != nil {
		return nil, err
	}
	for _, v := range out {
		prev, ok := old[v.Name]
		if !ok {
			prev = domain.LogService{SourceID: sourceID, Name: v.Name}
		}
		if from, to := prev.Scope(), v.Scope(); from != to {
			if err := s.store.MergeLogScope(ctx, from, to, v.RepoIDs); err != nil {
				s.log.Warn("log scope merge", "from", from, "to", to, "err", err)
			}
		}
	}
	return out, nil
}

// PushToken makes a push source's token (again); it is shown once.
func (s *Service) PushToken(ctx context.Context, id int64) (string, error) {
	src, err := s.store.LogSource(ctx, id, false)
	if err != nil {
		return "", err
	}
	if src.Kind != domain.LogPush {
		return "", invalid("only push sources have a token")
	}
	b := make([]byte, 24)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	token := "agl_" + base64.RawURLEncoding.EncodeToString(b)
	return token, s.store.SetLogPushToken(ctx, id, hashToken(token))
}

func hashToken(t string) []byte {
	h := sha256.Sum256([]byte(t))
	return h[:]
}

// ErrUnknownToken is a push with a token no source has.
var ErrUnknownToken = errors.New("unknown push token")

// Push formats.
const (
	PushPlain = ""     // NDJSON, a JSON array or text lines
	PushLoki  = "loki" // Loki's push API (Promtail, Grafana Alloy)
)

// Push takes a batch a log shipper sent with a token.
func (s *Service) Push(ctx context.Context, token string, body io.Reader, contentType, contentEncoding, format string) (IngestResult, error) {
	if !strings.HasPrefix(token, "agl_") {
		return IngestResult{}, ErrUnknownToken
	}
	src, err := s.store.LogSourceByPushToken(domain.System(ctx), hashToken(token))
	if errors.Is(err, domain.ErrNotFound) {
		return IngestResult{}, ErrUnknownToken
	}
	if err != nil {
		return IngestResult{}, err
	}
	ctx = domain.WithWorkspace(ctx, src.WorkspaceID)
	now := s.now()
	var entries []domain.LogEntry
	if format == PushLoki {
		entries, err = logsource.ParseLokiPush(body, contentType, contentEncoding, src.Name)
	} else {
		entries, err = logsource.ParsePush(body, contentType, contentEncoding, src.Name, now)
	}
	if err != nil {
		return IngestResult{}, invalid("%v", err)
	}
	res, err := s.Ingest(ctx, src, entries)
	if err != nil {
		return res, err
	}
	err = s.store.SaveLogRead(ctx, src.ID, postgres.LogReadState{Cursor: src.Cursor, Status: domain.LogSourceOK, ReadAt: &now})
	return res, err
}

// RotateKey replaces the workspace's secret-hash key.
func (s *Service) RotateKey(ctx context.Context) error { return s.store.RotateLogKey(ctx) }

// Findings lists findings.
func (s *Service) Findings(ctx context.Context, q domain.LogFindingFilter) ([]domain.LogFinding, error) {
	return s.store.ListLogFindings(ctx, q)
}

// Finding returns one finding with its sample.
func (s *Service) Finding(ctx context.Context, id int64) (domain.LogFinding, error) {
	return s.store.LogFinding(ctx, id)
}

// FindingByTicket returns the finding a ticket fixes.
func (s *Service) FindingByTicket(ctx context.Context, key string) (domain.LogFinding, error) {
	return s.store.LogFindingByTicket(ctx, key)
}
