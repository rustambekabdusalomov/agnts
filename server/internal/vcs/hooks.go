package vcs

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/hex"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"strings"

	"hiro/internal/domain"
)

// DeriveSecret derives a webhook secret from the server key, so no extra
// secret needs storing; it changes only if HIRO_ENC_KEY changes.
func DeriveSecret(encKey []byte, provider string) string {
	m := hmac.New(sha256.New, encKey)
	m.Write([]byte("hiro-webhook:" + provider))
	return hex.EncodeToString(m.Sum(nil))[:40]
}

// HookSink receives what the webhooks report.
type HookSink interface {
	MarkMerged(ctx context.Context, prURL, branch string, origin domain.Origin) (bool, error)
}

// HookStore deduplicates deliveries and records pipeline activity.
type HookStore interface {
	SeenDelivery(ctx context.Context, provider, id string) (bool, error)
	AppendEvent(ctx context.Context, ev domain.Event) error
}

func readBody(w http.ResponseWriter, r *http.Request) ([]byte, bool) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return nil, false
	}
	b, err := io.ReadAll(io.LimitReader(r.Body, 5<<20))
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return nil, false
	}
	return b, true
}

// GitHubWebhook handles pull_request (merged) and workflow_run events.
// Configure it in the repository (or organisation) settings with content
// type application/json and the secret from the Integrations page.
func GitHubWebhook(secret string, sink HookSink, store HookStore, onPipeline func(), log *slog.Logger) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		body, ok := readBody(w, r)
		if !ok {
			return
		}
		sig, _ := strings.CutPrefix(r.Header.Get("X-Hub-Signature-256"), "sha256=")
		got, _ := hex.DecodeString(sig)
		m := hmac.New(sha256.New, []byte(secret))
		m.Write(body)
		if !hmac.Equal(got, m.Sum(nil)) {
			log.Warn("github webhook: bad signature", "ip", r.RemoteAddr)
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		ctx := r.Context()
		if seen, err := store.SeenDelivery(ctx, "github", r.Header.Get("X-GitHub-Delivery")); err != nil || seen {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		switch r.Header.Get("X-GitHub-Event") {
		case "pull_request":
			var p struct {
				Action string `json:"action"`
				PR     struct {
					Merged  bool   `json:"merged"`
					HTMLURL string `json:"html_url"`
					Head    struct {
						Ref string `json:"ref"`
					} `json:"head"`
				} `json:"pull_request"`
			}
			if json.Unmarshal(body, &p) == nil && p.Action == "closed" && p.PR.Merged {
				if _, err := sink.MarkMerged(ctx, p.PR.HTMLURL, p.PR.Head.Ref, domain.OriginWebhook); err != nil {
					log.Error("github webhook: merged", "err", err)
					w.WriteHeader(http.StatusInternalServerError)
					return
				}
			}
		case "workflow_run", "check_suite", "push", "deployment_status":
			var p struct {
				Repository struct {
					FullName string `json:"full_name"`
				} `json:"repository"`
			}
			_ = json.Unmarshal(body, &p)
			_ = store.AppendEvent(ctx, domain.Event{Type: domain.EventPipeline, Origin: domain.OriginWebhook, Level: domain.LevelDebug,
				Message: r.Header.Get("X-GitHub-Event") + " on " + p.Repository.FullName, Data: map[string]any{"repo": p.Repository.FullName}})
			if onPipeline != nil {
				onPipeline()
			}
		}
		w.WriteHeader(http.StatusNoContent)
	})
}

// GitLabWebhook handles merge request (merged) and pipeline events.
// Configure it in the project's Webhooks settings with the secret token
// from the Integrations page.
func GitLabWebhook(secret string, sink HookSink, store HookStore, onPipeline func(), log *slog.Logger) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		body, ok := readBody(w, r)
		if !ok {
			return
		}
		if subtle.ConstantTimeCompare([]byte(r.Header.Get("X-Gitlab-Token")), []byte(secret)) != 1 {
			log.Warn("gitlab webhook: bad token", "ip", r.RemoteAddr)
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		ctx := r.Context()
		id := r.Header.Get("X-Gitlab-Event-UUID")
		if id == "" {
			id = r.Header.Get("Idempotency-Key")
		}
		if id != "" {
			if seen, err := store.SeenDelivery(ctx, "gitlab", id); err != nil || seen {
				w.WriteHeader(http.StatusNoContent)
				return
			}
		}
		var p struct {
			Kind  string `json:"object_kind"`
			Attrs struct {
				Action       string `json:"action"`
				URL          string `json:"url"`
				SourceBranch string `json:"source_branch"`
			} `json:"object_attributes"`
			Project struct {
				Path string `json:"path_with_namespace"`
			} `json:"project"`
		}
		if json.Unmarshal(body, &p) != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		switch p.Kind {
		case "merge_request":
			if p.Attrs.Action == "merge" {
				if _, err := sink.MarkMerged(ctx, p.Attrs.URL, p.Attrs.SourceBranch, domain.OriginWebhook); err != nil {
					log.Error("gitlab webhook: merged", "err", err)
					w.WriteHeader(http.StatusInternalServerError)
					return
				}
			}
		case "pipeline", "deployment", "build":
			_ = store.AppendEvent(ctx, domain.Event{Type: domain.EventPipeline, Origin: domain.OriginWebhook, Level: domain.LevelDebug,
				Message: p.Kind + " on " + p.Project.Path, Data: map[string]any{"repo": p.Project.Path}})
			if onPipeline != nil {
				onPipeline()
			}
		}
		w.WriteHeader(http.StatusNoContent)
	})
}
