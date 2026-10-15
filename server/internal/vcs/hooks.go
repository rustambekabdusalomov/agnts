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
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
)

// DeriveSecret derives a webhook secret from the server key, so no extra
// secret needs storing; it changes only if AGNTS_ENC_KEY changes.
func DeriveSecret(encKey []byte, provider string) string {
	m := hmac.New(sha256.New, encKey)
	m.Write([]byte("agnts-webhook:" + provider))
	return hex.EncodeToString(m.Sum(nil))[:40]
}

// HookSecret is a workspace's webhook secret for provider: derived from
// the server key and the workspace's hook id, so each workspace has its
// own. The URLs from before workspaces (hook id "") keep the old secret.
func HookSecret(encKey []byte, provider, hookID string) string {
	if hookID == "" {
		return DeriveSecret(encKey, provider)
	}
	return DeriveSecret(encKey, provider+":"+hookID)
}

// SecretSource returns the webhook secret for a delivery's context.
type SecretSource func(ctx context.Context) string

// HookSink receives what the webhooks report.
type HookSink interface {
	MarkMerged(ctx context.Context, ref domain.PRRef, origin domain.Origin) (bool, error)
}

// CloseSink records pull requests closed without a merge, or reopened. A
// HookSink may implement it.
type CloseSink interface {
	MarkPRClosed(ctx context.Context, ref domain.PRRef, closed bool, origin domain.Origin) (bool, error)
}

// prClosed hands a close or reopen to the sink when it takes them.
func prClosed(ctx context.Context, sink HookSink, ref domain.PRRef, closed bool) error {
	cs, ok := sink.(CloseSink)
	if !ok {
		return nil
	}
	_, err := cs.MarkPRClosed(ctx, ref, closed, domain.OriginWebhook)
	return err
}

// CISink receives finished CI runs. A HookSink may implement it.
type CISink interface {
	CIRunFinished(ctx context.Context, run domain.CIRun) error
}

// ciRun hands a finished run to the sink when it takes CI runs. Errors are
// logged, not returned: the host would only redeliver the same run.
func ciRun(ctx context.Context, sink HookSink, run domain.CIRun, log *slog.Logger) {
	ci, ok := sink.(CISink)
	if !ok || run.RunID == 0 {
		return
	}
	if err := ci.CIRunFinished(ctx, run); err != nil {
		log.Error("ci run", "repo", run.Repo, "run", run.RunID, "err", err)
	}
}

// CommentSink hears about changes to pull request conversations. A
// HookSink may implement it.
type CommentSink interface {
	PRCommentChanged(ctx context.Context, ev domain.PRCommentEvent) error
}

// prComment hands a conversation change to the sink when it takes them.
// Errors are logged: the host would only redeliver the same change.
func prComment(ctx context.Context, sink HookSink, ev domain.PRCommentEvent, log *slog.Logger) {
	cs, ok := sink.(CommentSink)
	if !ok || ev.Number <= 0 || ev.Repo == "" {
		return
	}
	if err := cs.PRCommentChanged(ctx, ev); err != nil {
		log.Error("pull request comment", "repo", ev.Repo, "number", ev.Number, "err", err)
	}
}

// githubComment reads the comment events of GitHub's pull requests:
// issue_comment (on a pull request), pull_request_review,
// pull_request_review_comment and pull_request_review_thread.
func githubComment(event string, body []byte) (domain.PRCommentEvent, bool) {
	var p struct {
		Action string `json:"action"`
		Issue  struct {
			Number      int             `json:"number"`
			PullRequest json.RawMessage `json:"pull_request"`
		} `json:"issue"`
		PullRequest struct {
			Number int `json:"number"`
		} `json:"pull_request"`
		Comment struct {
			Body string `json:"body"`
			User struct {
				Login string `json:"login"`
			} `json:"user"`
		} `json:"comment"`
		Review struct {
			Body  string `json:"body"`
			State string `json:"state"`
			User  struct {
				Login string `json:"login"`
			} `json:"user"`
		} `json:"review"`
		Sender struct {
			Login string `json:"login"`
		} `json:"sender"`
		Repository struct {
			FullName string `json:"full_name"`
		} `json:"repository"`
	}
	if json.Unmarshal(body, &p) != nil {
		return domain.PRCommentEvent{}, false
	}
	ev := domain.PRCommentEvent{Provider: "github", Repo: p.Repository.FullName, Action: p.Action, Number: p.PullRequest.Number}
	switch event {
	case "issue_comment":
		if len(p.Issue.PullRequest) == 0 || string(p.Issue.PullRequest) == "null" {
			return ev, false // a comment on an issue, not a pull request
		}
		ev.Number, ev.Author, ev.Body = p.Issue.Number, p.Comment.User.Login, p.Comment.Body
	case "pull_request_review_comment":
		ev.Author, ev.Body, ev.Inline = p.Comment.User.Login, p.Comment.Body, true
	case "pull_request_review":
		ev.Author, ev.Body, ev.ReviewState = p.Review.User.Login, p.Review.Body, strings.ToLower(p.Review.State)
	case "pull_request_review_thread":
		ev.Author, ev.Inline = p.Sender.Login, true
	default:
		return ev, false
	}
	return ev, ev.Number > 0
}

// gitlabNote reads a note event on a merge request.
func gitlabNote(body []byte) (domain.PRCommentEvent, bool) {
	var p struct {
		User struct {
			Username string `json:"username"`
		} `json:"user"`
		Attrs struct {
			NoteableType string          `json:"noteable_type"` //nolint:misspell // GitLab's field
			Note         string          `json:"note"`
			Action       string          `json:"action"`
			Type         string          `json:"type"`
			Position     json.RawMessage `json:"position"`
			System       bool            `json:"system"`
		} `json:"object_attributes"`
		MR struct {
			IID int `json:"iid"`
		} `json:"merge_request"`
		Project struct {
			Path string `json:"path_with_namespace"`
		} `json:"project"`
	}
	if json.Unmarshal(body, &p) != nil || p.Attrs.NoteableType != "MergeRequest" || p.Attrs.System {
		return domain.PRCommentEvent{}, false
	}
	action := "created"
	if p.Attrs.Action == "update" {
		action = "edited"
	}
	inline := p.Attrs.Type == "DiffNote" || (len(p.Attrs.Position) > 0 && string(p.Attrs.Position) != "null")
	return domain.PRCommentEvent{Provider: "gitlab", Repo: p.Project.Path, Number: p.MR.IID, Author: p.User.Username,
		Body: p.Attrs.Note, Action: action, Inline: inline}, p.MR.IID > 0
}

// githubRun is the workflow_run webhook's payload, as much as CI needs.
type githubRun struct {
	Action string `json:"action"`
	Run    struct {
		ID           int64     `json:"id"`
		Name         string    `json:"name"`
		Path         string    `json:"path"`
		DisplayTitle string    `json:"display_title"`
		HeadBranch   string    `json:"head_branch"`
		HeadSHA      string    `json:"head_sha"`
		Event        string    `json:"event"`
		Status       string    `json:"status"`
		Conclusion   string    `json:"conclusion"`
		RunAttempt   int       `json:"run_attempt"`
		HTMLURL      string    `json:"html_url"`
		UpdatedAt    time.Time `json:"updated_at"`
		PullRequests []struct {
			Number int `json:"number"`
		} `json:"pull_requests"`
		HeadCommit struct {
			Message string `json:"message"`
			Author  struct {
				Name string `json:"name"`
			} `json:"author"`
		} `json:"head_commit"`
		HeadRepository struct {
			FullName string `json:"full_name"`
		} `json:"head_repository"`
	} `json:"workflow_run"`
	Repository struct {
		FullName string `json:"full_name"`
	} `json:"repository"`
}

func (p githubRun) run() (domain.CIRun, bool) {
	r := p.Run
	if p.Action != "completed" || r.ID == 0 {
		return domain.CIRun{}, false
	}
	wf := r.Path
	if wf == "" {
		wf = r.Name
	}
	if i := strings.LastIndex(wf, "/"); i >= 0 {
		wf = wf[i+1:]
	}
	msg, _, _ := strings.Cut(strings.TrimSpace(r.HeadCommit.Message), "\n")
	if msg == "" {
		msg = r.DisplayTitle
	}
	out := domain.CIRun{Provider: "github", Repo: p.Repository.FullName, RunID: r.ID, Attempt: max(r.RunAttempt, 1), Workflow: wf,
		Name: r.Name, Branch: r.HeadBranch, SHA: r.HeadSHA, Event: r.Event, Conclusion: r.Conclusion, URL: r.HTMLURL,
		Author: r.HeadCommit.Author.Name, Message: msg, Finished: r.UpdatedAt,
		Fork: r.HeadRepository.FullName != "" && !strings.EqualFold(r.HeadRepository.FullName, p.Repository.FullName)}
	for _, pr := range r.PullRequests {
		out.PRNumbers = append(out.PRNumbers, pr.Number)
	}
	return out, true
}

// gitlabPipeline is the pipeline webhook's payload, as much as CI needs.
type gitlabPipeline struct {
	Attrs struct {
		ID         int64  `json:"id"`
		Ref        string `json:"ref"`
		SHA        string `json:"sha"`
		Status     string `json:"status"`
		Source     string `json:"source"`
		FinishedAt string `json:"finished_at"`
		URL        string `json:"url"`
	} `json:"object_attributes"`
	MR *struct {
		IID             int    `json:"iid"`
		SourceProjectID int64  `json:"source_project_id"`
		TargetProjectID int64  `json:"target_project_id"`
		SourceBranch    string `json:"source_branch"`
	} `json:"merge_request"`
	Project struct {
		Path   string `json:"path_with_namespace"`
		WebURL string `json:"web_url"`
	} `json:"project"`
	Commit struct {
		Message string `json:"message"`
		Author  struct {
			Name string `json:"name"`
		} `json:"author"`
	} `json:"commit"`
}

func (p gitlabPipeline) run() (domain.CIRun, bool) {
	a := p.Attrs
	switch a.Status {
	case "success", "failed", "canceled", "skipped":
	default:
		return domain.CIRun{}, false // still running
	}
	url := a.URL
	if url == "" && p.Project.WebURL != "" {
		url = p.Project.WebURL + "/-/pipelines/" + strconv.FormatInt(a.ID, 10)
	}
	msg, _, _ := strings.Cut(strings.TrimSpace(p.Commit.Message), "\n")
	out := domain.CIRun{Provider: "gitlab", Repo: p.Project.Path, RunID: a.ID, Attempt: 1, Workflow: "pipeline", Name: "pipeline",
		Branch: a.Ref, SHA: a.SHA, Event: a.Source, Conclusion: a.Status, URL: url, Author: p.Commit.Author.Name, Message: msg, Finished: time.Now()}
	if t, err := time.Parse("2006-01-02 15:04:05 MST", a.FinishedAt); err == nil {
		out.Finished = t
	}
	if p.MR != nil && p.MR.IID > 0 {
		out.PRNumbers = []int{p.MR.IID}
		out.Fork = p.MR.SourceProjectID != 0 && p.MR.SourceProjectID != p.MR.TargetProjectID
		if p.MR.SourceBranch != "" {
			out.Branch = p.MR.SourceBranch // merge request pipelines run on refs/merge-requests/n/head
		}
	}
	return out, true
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

// GitHubWebhook handles pull_request (merged), workflow_run and the pull
// request comment events (issue_comment, pull_request_review,
// pull_request_review_comment, pull_request_review_thread).
// Configure it in the repository (or organisation) settings with content
// type application/json and the secret from the Integrations page.
func GitHubWebhook(secretOf SecretSource, sink HookSink, store HookStore, onPipeline func(), log *slog.Logger) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		body, ok := readBody(w, r)
		if !ok {
			return
		}
		sig, _ := strings.CutPrefix(r.Header.Get("X-Hub-Signature-256"), "sha256=")
		got, _ := hex.DecodeString(sig)
		m := hmac.New(sha256.New, []byte(secretOf(r.Context())))
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
				Repository struct {
					FullName string `json:"full_name"`
				} `json:"repository"`
			}
			if json.Unmarshal(body, &p) == nil {
				var err error
				ref := domain.PRRef{URL: p.PR.HTMLURL, Branch: p.PR.Head.Ref, Repo: p.Repository.FullName}
				switch {
				case p.Action == "closed" && p.PR.Merged:
					_, err = sink.MarkMerged(ctx, ref, domain.OriginWebhook)
				case p.Action == "closed" || p.Action == "reopened":
					err = prClosed(ctx, sink, ref, p.Action == "closed")
				}
				if err != nil {
					log.Error("github webhook: pull request", "action", p.Action, "err", err)
					w.WriteHeader(http.StatusInternalServerError)
					return
				}
			}
		case "issue_comment", "pull_request_review", "pull_request_review_comment", "pull_request_review_thread":
			if ev, ok := githubComment(r.Header.Get("X-GitHub-Event"), body); ok {
				prComment(ctx, sink, ev, log)
			}
		case "workflow_run", "check_suite", "push", "deployment_status":
			if r.Header.Get("X-GitHub-Event") == "workflow_run" {
				var wr githubRun
				if json.Unmarshal(body, &wr) == nil {
					if run, ok := wr.run(); ok {
						ciRun(ctx, sink, run, log)
					}
				}
			}
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

// GitLabWebhook handles merge request (merged), pipeline and note
// (comment) events.
// Configure it in the project's Webhooks settings with the secret token
// from the Integrations page.
func GitLabWebhook(secretOf SecretSource, sink HookSink, store HookStore, onPipeline func(), log *slog.Logger) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		body, ok := readBody(w, r)
		if !ok {
			return
		}
		if subtle.ConstantTimeCompare([]byte(r.Header.Get("X-Gitlab-Token")), []byte(secretOf(r.Context()))) != 1 {
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
			var err error
			ref := domain.PRRef{URL: p.Attrs.URL, Branch: p.Attrs.SourceBranch, Repo: p.Project.Path}
			switch p.Attrs.Action {
			case "merge":
				_, err = sink.MarkMerged(ctx, ref, domain.OriginWebhook)
			case "close", "reopen":
				err = prClosed(ctx, sink, ref, p.Attrs.Action == "close")
			}
			if err != nil {
				log.Error("gitlab webhook: merge request", "action", p.Attrs.Action, "err", err)
				w.WriteHeader(http.StatusInternalServerError)
				return
			}
		case "note":
			if ev, ok := gitlabNote(body); ok {
				prComment(ctx, sink, ev, log)
			}
		case "pipeline", "deployment", "build":
			if p.Kind == "pipeline" {
				var pl gitlabPipeline
				if json.Unmarshal(body, &pl) == nil {
					if run, ok := pl.run(); ok {
						ciRun(ctx, sink, run, log)
					}
				}
			}
			_ = store.AppendEvent(ctx, domain.Event{Type: domain.EventPipeline, Origin: domain.OriginWebhook, Level: domain.LevelDebug,
				Message: p.Kind + " on " + p.Project.Path, Data: map[string]any{"repo": p.Project.Path}})
			if onPipeline != nil {
				onPipeline()
			}
		}
		w.WriteHeader(http.StatusNoContent)
	})
}
