package plane

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Ingester receives tickets (the orchestrator).
type Ingester interface {
	Ingest(ctx context.Context, in orchestrator.Incoming, origin domain.Origin) (bool, error)
}

// Resolver hears how a known ticket's work item ended (the
// orchestrator). An Ingester may implement it.
type Resolver interface {
	TrackerResolved(ctx context.Context, source domain.TicketSource, key string, r domain.TrackerResolution) error
}

// Deduper remembers webhook delivery ids.
type Deduper interface {
	SeenDelivery(ctx context.Context, provider, id string) (bool, error)
}

// Projects returns the identifiers of the Plane projects linked to
// repositories that take new work.
type Projects func(ctx context.Context) ([]string, error)

// payload covers both webhook formats: v1 (Community Edition: event
// "issue", action create/update/delete) and v2 (event workitem.created,
// workitem.updated, ...).
type payload struct {
	Version string          `json:"version"`
	Event   string          `json:"event"`
	Action  string          `json:"action"`
	Data    json.RawMessage `json:"data"`
}

// workItemRef reads the work item and project ids, or ok=false when the
// delivery is not about a work item that still exists.
func (p payload) workItemRef() (projectID, id string, ok bool) {
	switch {
	case p.Event == "issue" && (p.Action == "create" || p.Action == "update"):
	case p.Event == "workitem.created" || p.Event == "workitem.updated":
	default:
		return "", "", false
	}
	var d struct {
		ID        string          `json:"id"`
		Project   json.RawMessage `json:"project"`
		ProjectID string          `json:"project_id"`
	}
	if json.Unmarshal(p.Data, &d) != nil || d.ID == "" {
		return "", "", false
	}
	projectID = d.ProjectID
	if projectID == "" {
		w := workItem{Project: d.Project}
		projectID, _ = w.projectRef()
	}
	return projectID, d.ID, projectID != ""
}

// WebhookHandler receives Plane webhooks at /webhooks/plane.
//
// In Plane: Workspace settings → Webhooks → Add webhook, URL
// https://<domain>/webhooks/plane, the "Issues" (work items) events. Plane
// shows a secret once; paste it into agnts. Plane signs each delivery with
// X-Plane-Signature: hex HMAC-SHA256 of the body.
//
// The payload only says which work item changed: the handler fetches it
// from the API, which is the same in every Plane version. Plane turns a
// webhook off after a few failed deliveries, so only a store error fails
// one; anything else is answered 204 and left to the reconcile.
func WebhookHandler(cfg ConfigSource, c *Client, ing Ingester, dedup Deduper, log *slog.Logger) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}
		ctx := r.Context()
		conf, ok, err := cfg(ctx)
		if err != nil {
			log.Error("plane webhook: load config", "err", err)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		if !ok || conf.WebhookSecret == "" {
			// Refuse unsigned deliveries rather than accept anything.
			w.WriteHeader(http.StatusServiceUnavailable)
			return
		}
		body, err := io.ReadAll(io.LimitReader(r.Body, 2<<20))
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		if !validSignature(conf.WebhookSecret, r.Header.Get("X-Plane-Signature"), body) {
			log.Warn("plane webhook: bad signature", "ip", r.RemoteAddr)
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		if id := r.Header.Get("X-Plane-Delivery"); id != "" {
			seen, err := dedup.SeenDelivery(ctx, "plane", id)
			if err != nil {
				log.Error("plane webhook: dedup", "err", err)
				w.WriteHeader(http.StatusInternalServerError)
				return
			}
			if seen {
				w.WriteHeader(http.StatusNoContent)
				return
			}
		}
		var p payload
		if err := json.Unmarshal(body, &p); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		projectID, id, ok := p.workItemRef()
		if !ok {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		it, err := c.fetch(ctx, conf, projectID, id)
		if err != nil {
			if !errors.Is(err, errNotFound) {
				log.Warn("plane webhook: fetch work item; the reconcile will retry", "work_item", id, "err", err)
			}
			w.WriteHeader(http.StatusNoContent)
			return
		}
		if rv, ok := ing.(Resolver); ok && it.state.Group != "" {
			res := domain.TrackerResolution{Closed: it.closed(), Resolution: it.state.Group}
			if err := rv.TrackerResolved(ctx, domain.SourcePlane, it.key, res); err != nil {
				log.Warn("plane webhook: record the resolution", "work_item", it.key, "err", err)
			}
		}
		if !it.forAgnts(conf.Label) || it.closed() {
			w.WriteHeader(http.StatusNoContent) // not for agnts (or the label was removed)
			return
		}
		created, err := ing.Ingest(ctx, it.incoming(conf.Label), domain.OriginWebhook)
		if err != nil {
			log.Error("plane webhook: ingest", "work_item", it.key, "err", err)
			w.WriteHeader(http.StatusInternalServerError) // Plane retries
			return
		}
		log.Info("plane webhook", "event", p.Event, "action", p.Action, "work_item", it.key, "created", created)
		w.WriteHeader(http.StatusNoContent)
	})
}

func validSignature(secret, header string, body []byte) bool {
	got, err := hex.DecodeString(strings.TrimPrefix(strings.TrimSpace(header), "sha256="))
	if err != nil || len(got) == 0 {
		return false
	}
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write(body)
	return hmac.Equal(got, mac.Sum(nil))
}

// Sync ingests every open labelled work item in the linked projects. It
// reports how many it found and how many were new.
func Sync(ctx context.Context, c *Client, projects Projects, ing Ingester, origin domain.Origin) (found, created int, err error) {
	ps, err := projects(ctx)
	if err != nil {
		return 0, 0, err
	}
	if len(ps) == 0 {
		return 0, 0, nil
	}
	items, err := c.Search(ctx, ps)
	for _, in := range items {
		ok, ierr := ing.Ingest(ctx, in, origin)
		if ierr != nil {
			return len(items), created, ierr
		}
		if ok {
			created++
		}
	}
	return len(items), created, err
}

// Reconcile syncs now and then every interval, catching webhook
// deliveries Plane dropped. Ingest is idempotent.
// each calls fn once per workspace, with a context acting in it.
func Reconcile(ctx context.Context, c *Client, projects Projects, ing Ingester, every time.Duration, each func(context.Context, func(context.Context)), log *slog.Logger) {
	run := func() {
		each(ctx, func(ctx context.Context) {
			_, n, err := Sync(ctx, c, projects, ing, domain.OriginSystem)
			if err != nil && !errors.Is(err, ErrNotConnected) && ctx.Err() == nil {
				log.Warn("plane reconcile", "workspace", domain.WorkspaceOf(ctx), "err", err)
			}
			if n > 0 {
				log.Info("plane reconcile picked up missed work items", "workspace", domain.WorkspaceOf(ctx), "count", n)
			}
		})
	}
	run()
	t := time.NewTicker(every)
	defer t.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-t.C:
			run()
		}
	}
}
