package httpapi

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

type fakeTickets struct {
	lastPost      bool
	lastKind      string
	lastTask      orchestrator.TaskInput
	lastImplement orchestrator.ImplementInput
	lastOrigin    domain.Origin
	lastAnswer    []domain.Answer
	lastAccept    []orchestrator.AcceptInput
	lastFollowUps *bool
	lastRelation  string
	lastCompare   *bool
	lastShots     []domain.ShotRef
}

func (f *fakeTickets) ListRelations(_ context.Context, key string) (orchestrator.Relations, error) {
	if _, err := f.ticket(key, domain.StateCoding); err != nil {
		return orchestrator.Relations{}, err
	}
	return orchestrator.Relations{
		All: []orchestrator.RelationRow{{
			Relation:   domain.Relation{ID: 3, TicketKey: key, OtherKey: "PAY-0", Type: domain.RelDependsOn, Source: domain.RelFromAgnts, Status: domain.RelProposed, Confidence: 0.4, Reason: "uses its endpoint"},
			OtherTitle: "Add the endpoint", OtherState: domain.StateWaitingForReview,
		}},
		Blockers: []domain.Blocker{{Key: "PAY-0", Title: "Add the endpoint", State: domain.StateWaitingForReview, Type: domain.RelDependsOn}},
	}, nil
}

func (f *fakeTickets) AddRelation(_ context.Context, key, other string, typ domain.RelationType, o domain.Origin) (domain.Relation, error) {
	f.lastOrigin, f.lastRelation = o, other+" "+string(typ)
	if other == key {
		return domain.Relation{}, fmt.Errorf("%w: a ticket cannot wait for itself", orchestrator.ErrInvalid)
	}
	return domain.Relation{ID: 3, TicketKey: key, OtherKey: other, Type: typ, Source: domain.RelFromUser, Status: domain.RelActive}, nil
}

func (f *fakeTickets) DecideRelation(_ context.Context, key string, id int64, accept bool, _ domain.Origin) (domain.Relation, error) {
	if id != 3 {
		return domain.Relation{}, domain.ErrNotFound
	}
	st := domain.RelDismissed
	if accept {
		st = domain.RelActive
	}
	return domain.Relation{ID: 3, TicketKey: key, OtherKey: "PAY-0", Type: domain.RelDependsOn, Status: st}, nil
}

func (f *fakeTickets) MarkMergedByHand(_ context.Context, key string, _ domain.Origin) (domain.Ticket, error) {
	return f.ticket(key, domain.StateDone)
}

func (f *fakeTickets) ListFollowUps(context.Context, string) (orchestrator.FollowUps, error) {
	return orchestrator.FollowUps{}, nil
}

func (f *fakeTickets) SetFollowUps(_ context.Context, key string, on *bool, _ domain.Origin) (domain.Ticket, error) {
	f.lastFollowUps = on
	t, err := f.ticket(key, domain.StateNew)
	t.SuggestFollowUps = on
	return t, err
}

func (f *fakeTickets) AcceptSuggestions(_ context.Context, key string, in []orchestrator.AcceptInput, _ domain.Origin) ([]orchestrator.AcceptResult, error) {
	f.lastAccept = in
	out := []orchestrator.AcceptResult{}
	for _, a := range in {
		if a.ID == 2 {
			out = append(out, orchestrator.AcceptResult{ID: 2, Err: fmt.Errorf("%w: create it once %s is done", orchestrator.ErrInvalid, key)})
			continue
		}
		t := domain.Ticket{Key: "VIS-5", Title: "Add a column", State: domain.StateNew, Source: domain.SourceLocal, Held: true, FollowUpOf: key, Kind: domain.KindCode}
		out = append(out, orchestrator.AcceptResult{ID: a.ID, Ticket: &t})
	}
	return out, nil
}

func (f *fakeTickets) DismissSuggestion(_ context.Context, _ string, id int64, _ domain.Origin) (domain.Suggestion, error) {
	if id == 7 {
		return domain.Suggestion{}, domain.ErrSuggestionDecided
	}
	return domain.Suggestion{ID: id, Source: "work", Type: "gap", Title: "x", Serves: "y", Kind: domain.KindCode, Priority: "low", Status: domain.SuggestionDismissed}, nil
}

func (f *fakeTickets) SuggestFromFinding(_ context.Context, _ string, index int, _ domain.Origin) (domain.Suggestion, error) {
	if index > 0 {
		return domain.Suggestion{}, fmt.Errorf("%w: the review has no finding %d", orchestrator.ErrInvalid, index)
	}
	return domain.Suggestion{ID: 11, Source: "manual", Type: "unfinished", Title: "untested", Serves: "review", Kind: domain.KindCode, Priority: "high", Status: domain.SuggestionOpen}, nil
}

func (f *fakeTickets) ticket(key string, s domain.TicketState) (domain.Ticket, error) {
	if key == "NOPE-1" {
		return domain.Ticket{}, domain.ErrNotFound
	}
	return domain.Ticket{Key: key, Title: "t", State: s, Source: domain.SourceJira}, nil
}

func (f *fakeTickets) List(_ context.Context, fl orchestrator.TicketFilter) ([]domain.Ticket, error) {
	t, _ := f.ticket("PAY-1", domain.StateNew)
	if len(fl.States) == 1 && fl.States[0] == domain.StateDone {
		return nil, nil
	}
	return []domain.Ticket{t}, nil
}

func (f *fakeTickets) View(_ context.Context, key string) (orchestrator.TicketView, error) {
	t, err := f.ticket(key, domain.StateWaitingForReview)
	ans := "half up"
	return orchestrator.TicketView{
		Ticket:    t,
		Settings:  domain.DefaultSettings(),
		Questions: []domain.Question{{ID: 9, Position: 1, Text: "Rounding?", Options: []string{"a"}, Answer: &ans}},
		Analysis:  &orchestrator.Analysis{Summary: "s", Plan: []string{"p"}, Footprint: &domain.Footprint{Files: []string{"./a.go"}, Migrations: true}},
		Result: &domain.Result{
			Summary: json.RawMessage(`{"summary":"did it","notes":["n"]}`),
			Tests:   json.RawMessage(`[{"name":"test","command":"go test","exit_code":0,"duration_ms":1200}]`),
			Files:   []domain.FileChange{{Path: "a.go", Add: 1, Diff: "+x"}},
			Report:  "# Plan",
		},
		Review: &domain.Review{Revision: 0, Model: "opus", ModelReason: "a large change", Verdict: domain.VerdictHasConcerns, Summary: "ok",
			Findings: []domain.Finding{{Severity: "major", Category: "tests", File: "a.go", Line: 3, Title: "untested"}}},
		Preview: &domain.Preview{RunID: 42, Revision: 0, Model: "sonnet", Status: domain.PreviewOK, Summary: "two pages",
			Shots:  []domain.Shot{{ID: "home-phone-after", Name: "Home", Route: "/", Viewport: "phone", Side: "after", Width: 390, Height: 844}},
			Issues: []domain.PreviewIssue{{Severity: "medium", Description: "button overlaps", ShotID: "home-phone-after"}}},
		CanPreview: true,
		Spend:      domain.TokenUsage{Input: 30, Output: 7, CacheRead: 500, CacheWrite: 60, CostUSD: 0.25},
		Stages: []domain.StageUsage{
			{ModelStage: domain.ModelCoding, Model: "opus", Calls: 1, Turns: 4, Usage: domain.TokenUsage{Input: 20, Output: 5, CacheRead: 500, CostUSD: 0.25}},
			{ModelStage: domain.ModelRetry, Model: "opus", Calls: 2, Turns: 3, Partial: true, Usage: domain.TokenUsage{Input: 10, Output: 2, CacheWrite: 60}},
		},
		FollowUps: orchestrator.FollowUps{
			Suggestions: []domain.Suggestion{{ID: 1, Source: "analyze", Type: "prerequisite", Title: "Add a column", Serves: "needed first",
				Kind: domain.KindCode, Priority: "high", Status: domain.SuggestionOpen}},
			Children: []domain.Ticket{{Key: "VIS-5", Title: "Earlier one", State: domain.StateNew, Source: domain.SourceLocal, Held: true}},
		},
		FollowUpsOn: true,
		Relations:   orchestrator.Relations{Blockers: []domain.Blocker{{Key: "PAY-0", Title: "Add the endpoint", State: domain.StateDone, Type: domain.RelDependsOn}}},
	}, err
}

func (f *fakeTickets) Events(context.Context, orchestrator.EventFilter) ([]domain.Event, error) {
	return []domain.Event{{ID: 5, TicketKey: "PAY-1", Type: "claude_tool", Level: domain.LevelInfo, Origin: domain.OriginSystem, Message: "Read: a.go"}}, nil
}

func (f *fakeTickets) Answer(_ context.Context, key string, as []domain.Answer, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin, f.lastAnswer = o, as
	return f.ticket(key, domain.StateCoding)
}

func (f *fakeTickets) Approve(_ context.Context, key string, _ []string, post bool, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin, f.lastPost = o, post
	if key == "DONE-1" {
		return domain.Ticket{}, &domain.TransitionError{Key: key, From: domain.StateDone, To: domain.StatePushing}
	}
	return f.ticket(key, domain.StatePushing)
}

func (f *fakeTickets) RequestChanges(_ context.Context, key, fb string, shots []domain.ShotRef, o domain.Origin) (domain.Ticket, error) {
	f.lastShots = shots
	f.lastOrigin = o
	if strings.TrimSpace(fb) == "" {
		return domain.Ticket{}, fmt.Errorf("%w: feedback is required", orchestrator.ErrInvalid)
	}
	return f.ticket(key, domain.StateCoding)
}

func (f *fakeTickets) Reject(_ context.Context, key, _ string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return f.ticket(key, domain.StateRejected)
}

func (f *fakeTickets) Retry(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) Start(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) Stop(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return f.ticket(key, domain.StateFailed)
}

func (f *fakeTickets) Translate(_ context.Context, key, lang string) ([]orchestrator.TranslatedText, error) {
	if _, err := f.ticket(key, domain.StateDone); err != nil {
		return nil, err
	}
	if lang == "ru" {
		return []orchestrator.TranslatedText{{Source: "Fix login", Text: "Исправить вход"}}, nil
	}
	return nil, orchestrator.ErrPlanLimit
}

func (f *fakeTickets) Review(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	t, err := f.ticket(key, domain.StateWaitingForReview)
	t.ReviewState = domain.ReviewPending
	return t, err
}

func (f *fakeTickets) Preview(_ context.Context, key string, compare *bool, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin, f.lastCompare = o, compare
	t, err := f.ticket(key, domain.StateWaitingForReview)
	t.PreviewState = domain.PreviewPending
	t.PreviewCompare = compare != nil && *compare
	return t, err
}

func (f *fakeTickets) OpenShot(_ context.Context, key string, runID int64, shotID string) (io.ReadCloser, error) {
	if key != "PAY-1" || runID != 42 || shotID != "home-phone-after" {
		return nil, domain.ErrNotFound
	}
	return io.NopCloser(strings.NewReader("\x89PNG fake")), nil
}

func (f *fakeTickets) Learn(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	t, err := f.ticket(key, domain.StateDone)
	t.LearnState = domain.LearnPending
	return t, err
}

func (f *fakeTickets) SetRepo(_ context.Context, key string, _ int64, _ domain.Origin) (domain.Ticket, error) {
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) SetKind(_ context.Context, key, kind string, _ domain.Origin) (domain.Ticket, error) {
	f.lastKind = kind
	t, err := f.ticket(key, domain.StateNew)
	t.Kind, t.KindAuto = domain.TicketKind(kind), kind == "auto"
	if t.KindAuto {
		t.Kind = domain.KindCode
	}
	return t, err
}

func (f *fakeTickets) Implement(_ context.Context, key string, in orchestrator.ImplementInput, _ domain.Origin) (domain.Ticket, error) {
	f.lastImplement = in
	if key == "DONE-1" {
		return domain.Ticket{}, fmt.Errorf("%w: DONE-1 is already implemented by VIS-2", orchestrator.ErrInvalid)
	}
	t, err := f.ticket("VIS-9", domain.StateNew)
	t.Kind, t.ParentKey = domain.KindCode, key
	return t, err
}

func (f *fakeTickets) SetModels(_ context.Context, key string, _ map[string]string, _ domain.Origin) (domain.Ticket, error) {
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) CreateTask(_ context.Context, in orchestrator.TaskInput, _ domain.Origin) (domain.Ticket, error) {
	f.lastTask = in
	return domain.Ticket{Key: "VIS-1", Title: in.Title, State: domain.StateNew, Source: domain.SourceLocal}, nil
}

func (f *fakeTickets) UpdateTask(_ context.Context, key string, _ orchestrator.TaskInput, _ domain.Origin) (domain.Ticket, error) {
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) DeleteTask(context.Context, string, domain.Origin) error { return nil }

func (f *fakeTickets) Rows(_ context.Context, ts []domain.Ticket) ([]orchestrator.TicketRow, error) {
	out := make([]orchestrator.TicketRow, len(ts))
	for i, t := range ts {
		out[i] = orchestrator.TicketRow{Ticket: t, RepoName: "api"}
		if t.Key == "PAY-1" {
			out[i].Spend = domain.TokenUsage{Input: 1, Output: 2, CostUSD: 0.5}
		}
	}
	return out, nil
}

func (f *fakeTickets) Wake() {}

func TestTicketEndpoints(t *testing.T) {
	h := newHarness(t, pinger{})
	if rec := h.do("GET", "/api/tickets", "", nil); rec.Code != http.StatusUnauthorized {
		t.Fatalf("tickets without session: %d", rec.Code)
	}
	rec := h.do("POST", "/api/auth/login", loginBody("rustam", password, h.code(t, 1), "web"), nil)
	cookie := map[string]string{"Cookie": rec.Result().Cookies()[0].String()}

	cases := []struct {
		method, path, body string
		want               int
		contains           string
	}{
		{"GET", "/api/tickets", "", 200, `"key":"PAY-1"`},
		{"GET", "/api/tickets?state=done", "", 200, `[]`},
		{"GET", "/api/tickets?state=bogus", "", 400, ``},
		{"GET", "/api/tickets/PAY-1", "", 200, `"checks":[{"command":"go test","durationMs":1200,"exitCode":0,"name":"test"}]`},
		{"GET", "/api/tickets", "", 200, `"spend":{"cacheRead":0,"cacheWrite":0,"costUsd":0.5,"input":1,"output":2,"total":3}`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"spend":{"cacheRead":500,"cacheWrite":60,"costUsd":0.25,"input":30,"output":7,"total":597}`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"spendByStage":[{"calls":1,"model":"opus","partial":false,"spend":{"cacheRead":500,"cacheWrite":0,"costUsd":0.25,"input":20,"output":5,"total":525},"stage":"coding","turns":4},{"calls":2,"model":"opus","partial":true,"spend":{"cacheRead":0,"cacheWrite":60,"costUsd":0,"input":10,"output":2,"total":72},"stage":"retry","turns":3}]`},
		{"GET", "/api/tickets/NOPE-1", "", 404, `not_found`},
		{"GET", "/api/tickets/PAY-1/events?after=4", "", 200, `"message":"Read: a.go"`},
		{"PUT", "/api/tickets/PAY-1/answers", `{"answers":[{"questionId":9,"answer":"half up","note":"n"}]}`, 200, `"state":"coding"`},
		{"POST", "/api/tickets/PAY-1/approve", "", 200, `"state":"pushing"`},
		{"POST", "/api/tickets/PAY-1/approve", `{"assignees":["alice"]}`, 200, `"state":"pushing"`},
		{"POST", "/api/tickets/PAY-1/approve", `{"assignees":"alice"}`, 400, `bad_request`},
		{"POST", "/api/tickets/DONE-1/approve", "", 409, `conflict`},
		{"POST", "/api/tickets/PAY-1/approve", `{"postReport":true}`, 200, `"kind":"code"`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"report":"# Plan"`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"findings":[{"category":"tests","file":"a.go","line":3,"severity":"major","title":"untested"}]`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"reviewState":"none"`},
		{"POST", "/api/tickets/PAY-1/review", "", 200, `"reviewState":"pending"`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"canPreview":true`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"shots":[{"height":844,"id":"home-phone-after","name":"Home","route":"/","side":"after","url":"/tickets/PAY-1/preview/42/shots/home-phone-after","viewport":"phone","width":390}]`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"issues":[{"description":"button overlaps","severity":"medium","shotId":"home-phone-after"}]`},
		{"POST", "/api/tickets/PAY-1/preview", "", 200, `"previewState":"pending"`},
		{"POST", "/api/tickets/PAY-1/preview", `{"compare":true}`, 200, `"previewCompare":true`},
		{"GET", "/api/tickets/PAY-1/preview/42/shots/home-phone-after", "", 200, `PNG`},
		{"GET", "/api/tickets/PAY-1/preview/41/shots/home-phone-after", "", 404, `not_found`},
		{"GET", "/api/tickets/PAY-1/preview/42/shots/..%2Fsecret", "", 404, `not_found`},
		{"POST", "/api/tickets/PAY-1/request-changes", `{"feedback":"fix it","shots":[{"runId":42,"shotId":"home-phone-after"}]}`, 200, `"state":"coding"`},
		{"POST", "/api/tickets/PAY-1/translate", `{"lang":"ru"}`, 200, `"items":[{"source":"Fix login","text":"Исправить вход"}],"lang":"ru"`},
		{"POST", "/api/tickets/PAY-1/translate", `{"lang":"xx"}`, 400, `unknown language`},
		{"POST", "/api/tickets/PAY-1/translate", `{"lang":"de"}`, 429, `plan_limit`},
		{"POST", "/api/tickets/NOPE-1/translate", `{"lang":"ru"}`, 404, `not_found`},
		{"PUT", "/api/tickets/PAY-1/kind", `{"kind":"plan"}`, 200, `"kind":"plan","kindAuto":false`},
		{"PUT", "/api/tickets/PAY-1/kind", `{"kind":"deploy"}`, 400, `bad_request`},
		{"POST", "/api/tickets/PAY-1/implement", ``, 201, `"parentKey":"PAY-1"`},
		{"POST", "/api/tickets/DONE-1/implement", ``, 400, `already implemented by VIS-2`},
		{"POST", "/api/tickets/PAY-1/implement", `{"repoId":3,"start":"queue"}`, 201, `"key":"VIS-9"`},
		{"POST", "/api/tasks", `{"title":"Plan auth","priority":"low","afterApprove":"pr","start":"ask","kind":"analysis"}`, 201, `"key":"VIS-1"`},
		{"POST", "/api/tickets/PAY-1/request-changes", `{"feedback":"  "}`, 400, `feedback is required`},
		{"POST", "/api/tickets/PAY-1/request-changes", `{"feedback":"more tests"}`, 200, `"state":"coding"`},
		{"POST", "/api/tickets/PAY-1/reject", "", 200, `"state":"rejected"`},
		{"POST", "/api/tickets/PAY-1/retry", "", 200, `"state":"new"`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"followUps":{"children":[{"held":true,"key":"VIS-5"`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"openSuggestions":1`},
		{"GET", "/api/tickets/PAY-1/follow-ups", "", 200, `"suggestions":[{"createdAt"`},
		{"PUT", "/api/tickets/PAY-1/follow-ups", `{"mode":"on"}`, 200, `"suggestFollowUps":"on"`},
		{"PUT", "/api/tickets/PAY-1/follow-ups", `{"mode":"maybe"}`, 400, `bad_request`},
		{"POST", "/api/tickets/PAY-1/follow-ups/accept", `{"items":[]}`, 400, `bad_request`},
		{"POST", "/api/tickets/PAY-1/follow-ups/accept", `{"items":[{"id":1,"target":"jira","title":"Add a column","kind":"test","priority":"low","repoId":3},{"id":2}]}`, 200,
			`"results":[{"id":1,"ticket":{`},
		{"POST", "/api/tickets/PAY-1/follow-ups/accept", `{"items":[{"id":2}]}`, 200, `"error":"invalid input: create it once PAY-1 is done"`},
		{"POST", "/api/tickets/PAY-1/follow-ups/4/dismiss", "", 200, `"status":"dismissed"`},
		{"POST", "/api/tickets/PAY-1/follow-ups/7/dismiss", "", 409, `already decided`},
		{"POST", "/api/tickets/PAY-1/review/findings/0/follow-up", "", 201, `"source":"manual"`},
		{"POST", "/api/tickets/PAY-1/review/findings/3/follow-up", "", 400, `no finding 3`},
		{"POST", "/api/tasks", `{"title":"x","priority":"low","afterApprove":"pr","start":"queue","kind":"analysis","followUps":"off"}`, 201, `"key":"VIS-1"`},
		{"GET", "/api/tickets/PAY-1/relations", "", 200, `"direction":"waits_for"`},
		{"GET", "/api/tickets/PAY-1/relations", "", 200, `"other":{"key":"PAY-0","landed":false,"state":"waiting_for_review","title":"Add the endpoint"}`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"blockedBy":[{"key":"PAY-0"`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"relations":{"blockedBy":[`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"footprint":{"files":["a.go"],"migrations":true}`},
		{"GET", "/api/tickets/NOPE-1/relations", "", 404, `not_found`},
		{"POST", "/api/tickets/PAY-1/relations", `{"otherKey":" pay-0 ","type":"depends_on"}`, 201, `"status":"proposed"`},
		{"POST", "/api/tickets/PAY-1/relations", `{"otherKey":"PAY-1","type":"depends_on"}`, 400, `cannot wait for itself`},
		{"POST", "/api/tickets/PAY-1/relations", `{"otherKey":"PAY-0","type":"before"}`, 400, `bad_request`},
		{"POST", "/api/tickets/PAY-1/relations/3/accept", "", 200, `"id":3`},
		{"POST", "/api/tickets/PAY-1/relations/9/dismiss", "", 404, `not_found`},
		{"POST", "/api/tickets/PAY-1/merged", "", 200, `"state":"done"`},
	}
	for _, c := range cases {
		rec := h.do(c.method, c.path, c.body, cookie)
		if rec.Code != c.want || !strings.Contains(rec.Body.String(), c.contains) {
			t.Errorf("%s %s: %d %s (want %d containing %q)", c.method, c.path, rec.Code, rec.Body, c.want, c.contains)
		}
	}
	if h.tickets.lastRelation != "PAY-1 depends_on" {
		t.Errorf("relation input: %q", h.tickets.lastRelation)
	}
	if a := h.tickets.lastAccept; len(a) != 1 || a[0].ID != 2 {
		t.Errorf("accept input: %+v", a)
	}
	if h.tickets.lastFollowUps == nil || !*h.tickets.lastFollowUps || h.tickets.lastTask.FollowUps == nil || *h.tickets.lastTask.FollowUps {
		t.Errorf("follow-up modes not passed: %v %+v", h.tickets.lastFollowUps, h.tickets.lastTask.FollowUps)
	}
	if h.tickets.lastImplement.RepoID != 3 || h.tickets.lastImplement.Start != "queue" {
		t.Errorf("implement input not passed: %+v", h.tickets.lastImplement)
	}
	if !h.tickets.lastPost || h.tickets.lastKind != "plan" || h.tickets.lastTask.Kind != "analysis" || h.tickets.lastTask.RepoID != 0 {
		t.Errorf("kind fields not passed: post=%v kind=%q task=%+v", h.tickets.lastPost, h.tickets.lastKind, h.tickets.lastTask)
	}
	if h.tickets.lastOrigin != domain.OriginWeb || len(h.tickets.lastAnswer) != 1 || h.tickets.lastAnswer[0].Note != "n" {
		t.Errorf("web origin/answers not passed: %v %+v", h.tickets.lastOrigin, h.tickets.lastAnswer)
	}

	// Mobile: a fresh harness, since each TOTP step signs in only once.
	h = newHarness(t, pinger{})
	rec = h.do("POST", "/api/auth/login", loginBody("rustam", password, h.code(t, 1), "mobile"), nil)
	var resp struct{ Token string }
	_ = json.Unmarshal(rec.Body.Bytes(), &resp)
	if rec := h.do("POST", "/api/tickets/PAY-1/approve", "", map[string]string{"Authorization": "Bearer " + resp.Token}); rec.Code != 200 {
		t.Fatalf("mobile approve: %d", rec.Code)
	}
	if h.tickets.lastOrigin != domain.OriginMobile {
		t.Errorf("mobile origin: %v", h.tickets.lastOrigin)
	}
}
