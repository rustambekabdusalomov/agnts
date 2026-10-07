package admin

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
	"agnts/internal/tracker/plane"
)

func TestValidatePlaneProject(t *testing.T) {
	cases := []struct {
		name, jira, plane, prefix, wantKind, wantErr string
	}{
		{name: "plane only", plane: " web ", prefix: "mka", wantKind: "plane"},
		{name: "jira and plane", jira: "KAN", plane: "WEB", prefix: "mka", wantKind: "jira"},
		{name: "same as jira", jira: "WEB", plane: "web", prefix: "mka", wantErr: "Jira project key and the Plane project identifier must differ"},
		{name: "same as task prefix", plane: "MKA", prefix: "mka", wantErr: "task prefix must differ from the Plane project"},
		{name: "bad identifier", plane: "WE-B", prefix: "mka", wantErr: "letters and digits"},
		{name: "too long", plane: "ABCDEFGHIJKLM", prefix: "mka", wantErr: "at most 12"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			x := domain.Repository{Name: "mkacademy", CloneURL: "https://github.com/me/mkacademy.git",
				JiraProject: c.jira, PlaneProject: c.plane, TaskPrefix: c.prefix}
			err := Validate(&x, "")
			if c.wantErr != "" {
				if err == nil || !strings.Contains(err.Error(), c.wantErr) {
					t.Fatalf("err = %v, want %q", err, c.wantErr)
				}
				return
			}
			if err != nil {
				t.Fatal(err)
			}
			if x.Kind != c.wantKind || x.PlaneProject != "WEB" {
				t.Fatalf("kind %q plane %q", x.Kind, x.PlaneProject)
			}
		})
	}
}

// Connecting Plane checks the key against the workspace; the webhook
// secret Plane generated is stored later and survives a reconnect.
func TestPlaneConnectAndWebhookSecret(t *testing.T) {
	url := os.Getenv("AGNTS_TEST_DATABASE_URL")
	if url == "" {
		t.Skip("AGNTS_TEST_DATABASE_URL not set")
	}
	ctx := context.Background()
	pool, err := postgres.Open(ctx, url)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	if err := postgres.Migrate(ctx, pool, "up", log); err != nil {
		t.Fatal(err)
	}
	if _, err := pool.Exec(ctx, `DELETE FROM integrations WHERE provider = 'plane'`); err != nil {
		t.Fatal(err)
	}
	box, _ := secret.NewBox(bytes.Repeat([]byte{3}, 32))

	fake := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("X-API-Key") != "plane_api_good" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		switch r.URL.Path {
		case "/api/v1/users/me/":
			_ = json.NewEncoder(w).Encode(map[string]string{"display_name": "rustam"})
		case "/api/v1/workspaces/acme/projects/":
			_ = json.NewEncoder(w).Encode(map[string]any{"results": []any{}})
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	t.Cleanup(fake.Close)

	store := postgres.NewIntegrations(pool, box)
	s := NewIntegrations(store, postgres.NewAgent(pool), map[string]Checker{"plane": PlaneCheck}, nil, nil, "https://agnts.example.com", log)
	settings := map[string]string{"base_url": fake.URL, "workspace": "acme"}

	if _, _, err := s.Connect(ctx, "plane", "plane_api_bad", settings, "", domain.OriginWeb); err == nil {
		t.Fatal("a bad key connected")
	}
	if _, err := s.SetPlaneWebhookSecret(ctx, "secret-from-plane", domain.OriginWeb); err == nil {
		t.Fatal("a secret was stored before connecting")
	}
	v, _, err := s.Connect(ctx, "plane", "plane_api_good", settings, "", domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if v.Account != "rustam" || v.WebhookSecretSet || v.WebhookURL != "https://agnts.example.com/webhooks/plane" || v.TokenHint != "good" || v.Settings["label"] != "agnts" {
		t.Fatalf("view after connect: %+v", v)
	}
	if v, err = s.SetPlaneWebhookSecret(ctx, " secret-from-plane ", domain.OriginWeb); err != nil || !v.WebhookSecretSet || v.Account != "rustam" {
		t.Fatalf("set secret: %+v %v", v, err)
	}
	// Reconnecting with a new key keeps the secret.
	if v, _, err = s.Connect(ctx, "plane", "plane_api_good", settings, "", domain.OriginWeb); err != nil || !v.WebhookSecretSet {
		t.Fatalf("reconnect: %+v %v", v, err)
	}
	in, err := store.Get(ctx, "plane")
	if err != nil {
		t.Fatal(err)
	}
	c, ok, err := plane.FromIntegration(in.Token, in.Settings, in.Connected)
	if err != nil || !ok || c.APIKey != "plane_api_good" || c.WebhookSecret != "secret-from-plane" || c.Workspace != "acme" {
		t.Fatalf("stored config: %+v ok=%v err=%v", c, ok, err)
	}
	if _, err := s.Update(ctx, "plane", map[string]string{"base_url": "ftp://x", "workspace": "acme"}, domain.OriginWeb); err == nil {
		t.Fatal("a non-http base URL was accepted")
	}
}
