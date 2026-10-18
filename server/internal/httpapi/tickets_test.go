package httpapi

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

type fakeTickets struct {
	lastWS            int64 // the workspace the last List acted in
	lastPost          bool
	lastKind          string
	lastTask          orchestrator.TaskInput
	lastImplement     orchestrator.ImplementInput
	lastOrigin        domain.Origin
	lastAnswer        []domain.Answer
	lastAccept        []orchestrator.AcceptInput
	lastFollowUps     *bool
	lastSkipChecks    *bool
	lastRelation      string
	lastCompare       *bool
	lastShots         []domain.ShotRef
	lastNote          string
	lastFiles         []int64
	lastFeedbackFiles []int64
	lastUpload        string
	lastGroup         orchestrator.GroupInput
	lastChoice        domain.RepoChoice
}

func (f *fakeTickets) Groups(context.Context) ([]domain.RepoGroup, error) {
	return []domain.RepoGroup{{ID: 4, Name: "Shop", TaskPrefix: "SHOP", Members: []domain.GroupMember{{RepoID: 3, RepoName: "api", Role: "backend"}, {RepoID: 5, RepoName: "web"}}}}, nil
}

func (f *fakeTickets) Group(_ context.Context, id int64) (orchestrator.GroupView, error) {
	if id != 4 {
		return orchestrator.GroupView{}, domain.ErrNotFound
	}
	return orchestrator.GroupView{RepoGroup: domain.RepoGroup{ID: 4, Name: "Shop"}, Warnings: []string{"build variable X is set in api and web"}}, nil
}

func (f *fakeTickets) SaveGroup(_ context.Context, id int64, in orchestrator.GroupInput, _ domain.Origin) (orchestrator.GroupView, error) {
	f.lastGroup = in
	if len(in.Members) == 0 {
		return orchestrator.GroupView{}, fmt.Errorf("%w: a group needs at least one repository", orchestrator.ErrInvalid)
	}
	if id == 0 {
		id = 8
	}
	return orchestrator.GroupView{RepoGroup: domain.RepoGroup{ID: id, Name: in.Name}}, nil
}

func (f *fakeTickets) DeleteGroup(_ context.Context, id int64, _ domain.Origin) error {
	if id != 4 {
		return domain.ErrNotFound
	}
	return nil
}

func (f *fakeTickets) SetRepos(_ context.Context, key string, c domain.RepoChoice, _ domain.Origin) (domain.Ticket, error) {
	f.lastChoice = c
	api, web, g := int64(3), int64(5), int64(4)
	n := 7
	return domain.Ticket{Key: key, Title: "t", State: domain.StateNew, Source: domain.SourceLocal, RepoID: &api, GroupID: &g, GroupName: "Shop",
		Repos: []domain.TicketRepo{{RepoID: api, RepoName: "api", Folder: "api", Role: "backend"},
			{RepoID: web, RepoName: "web", Folder: "web", PRNumber: &n, PRURL: "https://github.com/acme/web/pull/7", State: domain.RepoPushed}}}, nil
}

func (f *fakeTickets) Upload(_ context.Context, name string, data []byte) (domain.Attachment, error) {
	f.lastUpload = name + ":" + string(data)
	return domain.Attachment{ID: 9, Name: name, ContentType: "image/png", Size: int64(len(data)), Purpose: domain.AttachPending}, nil
}

func (f *fakeTickets) OpenAttachment(_ context.Context, id int64) (domain.Attachment, []byte, error) {
	switch id {
	case 9:
		return domain.Attachment{ID: 9, Name: "shot.png", ContentType: "image/png"}, []byte("PNGDATA"), nil
	case 10:
		return domain.Attachment{ID: 10, Name: "page.html", ContentType: "text/html"}, []byte("<script>"), nil
	}
	return domain.Attachment{}, nil, domain.ErrNotFound
}

func (f *fakeTickets) DeleteUpload(_ context.Context, id int64) error {
	switch id {
	case 9:
		return nil
	case 10:
		return fmt.Errorf("page.html is attached to a ticket: %w", domain.ErrConflict)
	}
	return domain.ErrNotFound
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

func (f *fakeTickets) SetMember(_ context.Context, key string, _ int64, _ string, _ domain.Origin) (domain.Ticket, error) {
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) List(ctx context.Context, fl orchestrator.TicketFilter) ([]domain.Ticket, error) {
	f.lastWS = domain.WorkspaceOf(ctx)
	t, _ := f.ticket("PAY-1", domain.StateNew)
	if len(fl.States) == 1 && fl.States[0] == domain.StateDone {
		return nil, nil
	}
	return []domain.Ticket{t}, nil
}

func (f *fakeTickets) View(_ context.Context, key string) (orchestrator.TicketView, error) {
	t, err := f.ticket(key, domain.StateWaitingForReview)
	ans := "half up"
	qid := int64(9)
	return orchestrator.TicketView{
		Ticket:      t,
		Settings:    domain.DefaultSettings(),
		Questions:   []domain.Question{{ID: 9, Position: 1, Text: "Rounding?", Options: []string{"a", "b"}, Multiple: true, Answer: &ans}},
		Attachments: []domain.Attachment{{ID: 4, TicketID: &t.ID, QuestionID: &qid, Purpose: domain.AttachAnswer, Name: "a.png", ContentType: "image/png", Size: 3}},
		Analysis:    &orchestrator.Analysis{Summary: "s", Plan: []string{"p"}, Footprint: &domain.Footprint{Files: []string{"./a.go"}, Migrations: true}},
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

func (f *fakeTickets) AcknowledgeSecrets(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return f.ticket(key, domain.StateWaitingForReview)
}

func (f *fakeTickets) RequestChanges(_ context.Context, key, fb string, shots []domain.ShotRef, files []int64, o domain.Origin) (domain.Ticket, error) {
	f.lastShots, f.lastFeedbackFiles = shots, files
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

func (f *fakeTickets) RetryWithNote(_ context.Context, key, note string, files []int64, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin, f.lastNote, f.lastFiles = o, note, files
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) SetSkipChecks(_ context.Context, key string, skip bool, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin, f.lastSkipChecks = o, &skip
	return f.ticket(key, domain.StateFailed)
}

func (f *fakeTickets) Continue(_ context.Context, key, note string, files []int64, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin, f.lastNote, f.lastFiles = o, note, files
	return f.ticket(key, domain.StateWaitingForReview)
}

func (f *fakeTickets) StartOver(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) RenameBranch(_ context.Context, key string, repoID int64, name string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	if name == "taken" {
		return domain.Ticket{}, fmt.Errorf("%w: the branch taken already exists on the git host", domain.ErrConflict)
	}
	t, err := f.ticket(key, domain.StateWaitingForReview)
	t.Branch = name
	return t, err
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

func (f *fakeTickets) RestartWithUpdate(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) KeepCurrentVersion(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return f.ticket(key, domain.StateCoding)
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

func (f *fakeTickets) Replay(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return domain.Ticket{Key: key + "-R", Source: domain.SourceLocal, ReplayOf: key}, nil
}

func (f *fakeTickets) ReplayReport(context.Context) (orchestrator.ReplayReport, error) {
	return orchestrator.ReplayReport{}, nil
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
		{"PUT", "/api/tickets/PAY-1/answers", `{"answers":[{"questionId":9,"answer":"half up","note":"n","attachments":[4]}]}`, 200, `"state":"coding"`},
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
		{"POST", "/api/tickets/PAY-1/request-changes", `{"feedback":"fix it","shots":[{"runId":42,"shotId":"home-phone-after"}],"attachments":[5]}`, 200, `"state":"coding"`},
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
		{"POST", "/api/tickets/PAY-1/request-changes", `{"feedback":"more tests","attachments":[5,6]}`, 200, `"state":"coding"`},
		{"POST", "/api/tickets/PAY-1/reject", "", 200, `"state":"rejected"`},
		{"POST", "/api/tickets/PAY-1/continue", "", 200, `"state":"waiting_for_review"`},
		{"POST", "/api/tickets/PAY-1/continue", `{"note":"keep the old API","attachments":[7]}`, 200, `"state":"waiting_for_review"`},
		{"POST", "/api/tickets/PAY-1/continue", `{"reason":"x"}`, 400, `unknown field`},
		{"POST", "/api/tickets/PAY-1/start-over", "", 200, `"state":"new"`},
		{"PUT", "/api/tickets/PAY-1/branch", `{"branch":"feature/PAY-1-login"}`, 200, `"branch":"feature/PAY-1-login"`},
		{"PUT", "/api/tickets/PAY-1/branch", `{"branch":"taken","repoId":3}`, 409, `already exists on the git host`},
		{"PUT", "/api/tickets/PAY-1/branch", `{"name":"x"}`, 400, `unknown field`},
		{"POST", "/api/tickets/PAY-1/retry", "", 200, `"state":"new"`},
		{"POST", "/api/tickets/PAY-1/retry", `{"skipChecks":true}`, 200, `"state":"new"`},
		{"POST", "/api/tickets/PAY-1/retry", `{"note":"skip the symlink","attachments":[9,9]}`, 200, `"state":"new"`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"multiple":true`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"attachments":[{"contentType":"image/png","createdAt":"0001-01-01T00:00:00Z","id":4,"image":true,"name":"a.png","purpose":"answer","questionId":9,"size":3,"url":"/attachments/4"}]`},
		{"GET", "/api/attachments/9", "", 200, `PNGDATA`},
		{"GET", "/api/attachments/11", "", 404, `no such file`},
		{"DELETE", "/api/attachments/9", "", 204, ``},
		{"DELETE", "/api/attachments/10", "", 409, `attached to a ticket`},
		{"DELETE", "/api/attachments/11", "", 404, `no such file`},
		{"POST", "/api/attachments", `{"file":"x"}`, 400, `multipart/form-data`},
		{"POST", "/api/tickets/PAY-1/retry", `{"reason":"x"}`, 400, `unknown field`},
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
		{"POST", "/api/tickets/PAY-1/replay", "", 200, `"replayOf":"PAY-1"`},
		{"GET", "/api/eval/replays", "", 200, `{"replays":[],"versions":[]}`},
		{"GET", "/api/repo-groups", "", 200, `"members":[{"archived":false,"repoId":3,"repoName":"api","role":"backend"}`},
		{"GET", "/api/repo-groups/4", "", 200, `"warnings":["build variable X is set in api and web"]`},
		{"GET", "/api/repo-groups/9", "", 404, `not_found`},
		{"POST", "/api/repo-groups", `{"name":"Shop","taskPrefix":"shop","members":[{"repoId":3,"role":"backend"},{"repoId":5}]}`, 201, `"id":8`},
		{"POST", "/api/repo-groups", `{"name":"Shop","members":[]}`, 400, `at least one repository`},
		{"PUT", "/api/repo-groups/4", `{"name":"Shop","members":[{"repoId":3}]}`, 200, `"id":4`},
		{"DELETE", "/api/repo-groups/4", "", 204, ``},
		{"PUT", "/api/tickets/PAY-1/repos", `{"groupId":4}`, 200, `"group":{"id":4,"name":"Shop"}`},
		{"PUT", "/api/tickets/PAY-1/repos", `{"repoIds":[3,5]}`, 200, `"repos":[{"branch":"","ciFixes":0,"files":0,"folder":"api","headSha":"","prUrl":"","repoId":3,"repoName":"api","role":"backend","state":"pending"},{"branch":"","ciFixes":0,"files":0,"folder":"web"`},
		{"PUT", "/api/tickets/PAY-1/repos", `{}`, 400, `give repoIds or groupId`},
		{"GET", "/api/tickets/PAY-1", "", 200, `"skipChecks":false`},
	}
	for _, c := range cases {
		rec := h.do(c.method, c.path, c.body, cookie)
		if rec.Code != c.want || !strings.Contains(rec.Body.String(), c.contains) {
			t.Errorf("%s %s: %d %s (want %d containing %q)", c.method, c.path, rec.Code, rec.Body, c.want, c.contains)
		}
	}
	if h.tickets.lastSkipChecks == nil || !*h.tickets.lastSkipChecks {
		t.Errorf("retry skipChecks: %v", h.tickets.lastSkipChecks)
	}
	if g := h.tickets.lastGroup; g.Name != "Shop" || len(g.Members) != 1 {
		t.Errorf("group input: %+v", g)
	}
	if c := h.tickets.lastChoice; len(c.RepoIDs) != 2 || c.RepoIDs[1] != 5 {
		t.Errorf("ticket repositories input: %+v", c)
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
	if f := h.tickets.lastFeedbackFiles; len(f) != 2 || f[0] != 5 || f[1] != 6 {
		t.Errorf("feedback files not passed: %v", f)
	}
	if len(h.tickets.lastFiles) != 2 || h.tickets.lastFiles[0] != 9 {
		t.Errorf("retry files not passed: %v", h.tickets.lastFiles)
	}
	if h.tickets.lastOrigin != domain.OriginWeb || len(h.tickets.lastAnswer) != 1 || h.tickets.lastAnswer[0].Note != "n" || len(h.tickets.lastAnswer[0].Attachments) != 1 {
		t.Errorf("web origin/answers not passed: %v %+v", h.tickets.lastOrigin, h.tickets.lastAnswer)
	}
	if rec := h.do("POST", "/api/tasks", `{"title":"x","priority":"low","afterApprove":"pr","start":"queue","repoIds":[5,3]}`, cookie); rec.Code != 201 ||
		len(h.tickets.lastTask.RepoIDs) != 2 || h.tickets.lastTask.RepoIDs[0] != 5 {
		t.Errorf("task repositories not passed: %d %+v", rec.Code, h.tickets.lastTask)
	}
	if rec := h.do("POST", "/api/tasks", `{"title":"x","priority":"low","afterApprove":"pr","start":"queue","groupId":4}`, cookie); rec.Code != 201 || h.tickets.lastTask.GroupID != 4 {
		t.Errorf("task group not passed: %d %+v", rec.Code, h.tickets.lastTask)
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

func TestUploadAttachment(t *testing.T) {
	h := newHarness(t, pinger{})
	rec := h.do("POST", "/api/auth/login", loginBody("rustam", password, h.code(t, 1), "web"), nil)
	cookie := rec.Result().Cookies()[0].String()
	upload := func(size int) *httptest.ResponseRecorder {
		var body bytes.Buffer
		mw := multipart.NewWriter(&body)
		fw, _ := mw.CreateFormFile("file", "screen shot.png")
		_, _ = fw.Write(bytes.Repeat([]byte("x"), size))
		_ = mw.Close()
		req := httptest.NewRequest("POST", "/api/attachments", &body)
		req.Header.Set("Content-Type", mw.FormDataContentType())
		req.Header.Set("Cookie", cookie)
		rec := httptest.NewRecorder()
		h.h.ServeHTTP(rec, req)
		return rec
	}
	if rec := upload(3); rec.Code != http.StatusCreated || !strings.Contains(rec.Body.String(), `"purpose":"pending"`) || h.tickets.lastUpload != "screen shot.png:xxx" {
		t.Fatalf("upload: %d %s (%q)", rec.Code, rec.Body, h.tickets.lastUpload)
	}
	if rec := upload(domain.MaxAttachmentBytes + 1); rec.Code != http.StatusRequestEntityTooLarge {
		t.Fatalf("large upload: %d %s", rec.Code, rec.Body)
	}
	// A picture shows in place; anything else downloads, even HTML.
	rec = h.do("GET", "/api/attachments/9", "", map[string]string{"Cookie": cookie})
	if rec.Header().Get("Content-Type") != "image/png" || !strings.HasPrefix(rec.Header().Get("Content-Disposition"), "inline") {
		t.Fatalf("picture headers: %v", rec.Header())
	}
	rec = h.do("GET", "/api/attachments/10", "", map[string]string{"Cookie": cookie})
	if rec.Header().Get("Content-Type") != "application/octet-stream" || !strings.HasPrefix(rec.Header().Get("Content-Disposition"), "attachment") ||
		rec.Header().Get("X-Content-Type-Options") != "nosniff" {
		t.Fatalf("html headers: %v", rec.Header())
	}
}
