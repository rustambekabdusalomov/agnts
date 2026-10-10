package jira

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

// Deduper remembers webhook delivery ids.
type Deduper interface {
	SeenDelivery(ctx context.Context, provider, id string) (bool, error)
}

// WebhookHandler receives Jira issue webhooks at /webhooks/jira.
//
// In Jira: Settings → System → WebHooks, URL https://<domain>/webhooks/jira,
// events "Issue created" and "Issue updated", and the same secret as in
// agnts. Jira signs each delivery with X-Hub-Signature: sha256=<hmac>.
//
// With AssignedOnly, an issue assigned to someone else creates no ticket
// (one agnts has still gets its updates); me returns the connected
// account's id.
func WebhookHandler(cfg ConfigSource, me func(context.Context) (string, error), ing Ingester, dedup Deduper, log *slog.Logger) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}
		ctx := r.Context()
		c, ok, err := cfg(ctx)
		if err != nil {
			log.Error("jira webhook: load config", "err", err)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		if !ok || c.WebhookSecret == "" {
			// Refuse unsigned deliveries rather than accept anything.
			w.WriteHeader(http.StatusServiceUnavailable)
			return
		}
		body, err := io.ReadAll(io.LimitReader(r.Body, 2<<20))
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		if !validSignature(c.WebhookSecret, r.Header.Get("X-Hub-Signature"), body) {
			log.Warn("jira webhook: bad signature", "ip", r.RemoteAddr)
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		if id := r.Header.Get("X-Atlassian-Webhook-Identifier"); id != "" {
			seen, err := dedup.SeenDelivery(ctx, "jira", id)
			if err != nil {
				log.Error("jira webhook: dedup", "err", err)
				w.WriteHeader(http.StatusInternalServerError)
				return
			}
			if seen {
				w.WriteHeader(http.StatusNoContent)
				return
			}
		}

		var p struct {
			WebhookEvent string `json:"webhookEvent"`
			Issue        *issue `json:"issue"`
		}
		if err := json.Unmarshal(body, &p); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		if p.Issue == nil || !strings.HasPrefix(p.WebhookEvent, "jira:issue_") || p.WebhookEvent == "jira:issue_deleted" {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		if !p.Issue.forAgnts(c.Label) {
			w.WriteHeader(http.StatusNoContent) // not for agnts (or the label was removed)
			return
		}
		in := p.Issue.incoming(c.Label)
		if c.AssignedOnly {
			id, err := me(ctx)
			if err != nil {
				log.Warn("jira webhook: find the connected account", "err", err) // the reconcile query still finds it
			}
			in.NoCreate = err != nil || p.Issue.Fields.Assignee == nil || p.Issue.Fields.Assignee.AccountID != id
		}
		created, err := ing.Ingest(ctx, in, domain.OriginWebhook)
		if err != nil {
			log.Error("jira webhook: ingest", "issue", p.Issue.Key, "err", err)
			w.WriteHeader(http.StatusInternalServerError) // Jira retries
			return
		}
		log.Info("jira webhook", "event", p.WebhookEvent, "issue", p.Issue.Key, "created", created)
		w.WriteHeader(http.StatusNoContent)
	})
}

func validSignature(secret, header string, body []byte) bool {
	sig, ok := strings.CutPrefix(header, "sha256=")
	if !ok {
		return false
	}
	got, err := hex.DecodeString(sig)
	if err != nil {
		return false
	}
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write(body)
	return hmac.Equal(got, mac.Sum(nil))
}

// Reconcile ingests every open labelled issue now and then every interval,
// catching webhook deliveries Jira dropped, in every workspace: each calls
// fn once per workspace with a context acting in it. Ingest is idempotent.
func Reconcile(ctx context.Context, c *Client, ing Ingester, every time.Duration, each func(context.Context, func(context.Context)), log *slog.Logger) {
	run := func() { each(ctx, func(ctx context.Context) { reconcileOnce(ctx, c, ing, log) }) }
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

func reconcileOnce(ctx context.Context, c *Client, ing Ingester, log *slog.Logger) {
	issues, err := c.Search(ctx)
	if err != nil {
		if !errors.Is(err, ErrNotConnected) && ctx.Err() == nil {
			log.Warn("jira reconcile", "workspace", domain.WorkspaceOf(ctx), "err", err)
		}
		return
	}
	n := 0
	for _, in := range issues {
		created, err := ing.Ingest(ctx, in, domain.OriginSystem)
		if err != nil {
			log.Warn("jira reconcile: ingest", "issue", in.Key, "err", err)
			continue
		}
		if created {
			n++
		}
	}
	if n > 0 {
		log.Info("jira reconcile picked up missed issues", "workspace", domain.WorkspaceOf(ctx), "count", n)
	}
}
