package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"slices"
	"strings"

	"agnts/internal/apispec"
	"agnts/internal/domain"
)

// SwaggerTestInput is the Swagger test form.
type SwaggerTestInput struct {
	Title string // "" for one made from the spec and host
	// SpecURL is fetched (from the cache the form filled), unless Spec
	// holds an uploaded or pasted spec.
	SpecURL string
	Spec    []byte
	// SpecRef is an uploaded spec UploadSpec kept.
	SpecRef      string
	BaseURL      string
	Operations   []string
	WriteEnabled bool
	// NotProduction confirms the base URL is not production; required
	// with WriteEnabled.
	NotProduction bool
	Auth          domain.APIAuth
	Credential    string
	RepoID        int64
	Notes         string
	RateLimit     int
	MaxRequests   int
	Priority      string
	Start         string // code (now) or queue (held until started)
	// SuiteID is the saved suite the test runs for (set by suites).
	SuiteID *int64
}

// CreateSwaggerTest creates a Swagger test ticket. It skips the analysis:
// the form says everything a run needs, so it goes straight to work.
func (o *Orchestrator) CreateSwaggerTest(ctx context.Context, in SwaggerTestInput, origin domain.Origin) (domain.Ticket, error) {
	if o.swagger == nil {
		return domain.Ticket{}, invalid("Swagger tests are not available on this server")
	}
	st, doc, err := o.checkSwaggerInput(ctx, in)
	if err != nil {
		return domain.Ticket{}, err
	}
	if in.Priority == "" {
		in.Priority = "medium"
	}
	if !slices.Contains([]string{"low", "medium", "high"}, in.Priority) {
		return domain.Ticket{}, invalid("priority must be low, medium or high")
	}
	if in.Start == "" {
		in.Start = "code"
	}
	if in.Start != "code" && in.Start != "queue" {
		return domain.Ticket{}, invalid("start must be code or queue")
	}
	prefix := NoRepoTaskPrefix
	var res resolvedRepos
	if in.RepoID > 0 {
		if res, err = o.resolveRepos(ctx, domain.RepoChoice{RepoID: in.RepoID}, domain.KindSwaggerTest, false); err != nil {
			return domain.Ticket{}, err
		}
		prefix = res.Prefix
	}
	title := strings.TrimSpace(in.Title)
	if title == "" {
		u, _ := domain.ParseBaseURL(st.BaseURL)
		title = fmt.Sprintf("Swagger test: %s on %s", firstNonEmpty(doc.Doc.Title, "API"), u.Host)
	}
	mode := "read-only"
	if st.WriteEnabled {
		mode = "write requests on"
	}
	// Held until its test is stored: a run must never start without it.
	t := domain.Ticket{
		Source: domain.SourceLocal, Title: truncate(title, 200), Description: strings.TrimSpace(in.Notes), Priority: in.Priority,
		State: domain.StateCoding, ResumeState: domain.StateCoding, AfterApprove: "pr", Held: true,
		Kind: domain.KindSwaggerTest,
	}
	res.apply(&t)
	out, err := o.createTask(ctx, t, prefix, nil, origin)
	if err != nil {
		return out, err
	}
	st.TicketID = out.ID
	cred := in.Credential
	if err := o.swagger.SaveSwaggerTest(ctx, st, &cred); err != nil {
		_ = o.store.DeleteTicket(context.WithoutCancel(ctx), out.Key, domain.Event{TicketKey: out.Key, Type: domain.EventTaskChanged, Origin: origin, Message: "task deleted: its Swagger test could not be stored"})
		return domain.Ticket{}, err
	}
	scope := fmt.Sprintf("%d endpoints", len(st.Operations))
	if st.ByInstructions() {
		scope = "the endpoints the task names"
	}
	o.event(ctx, domain.Event{TicketKey: out.Key, Type: domain.EventTicketUpdated, Origin: origin,
		Message: fmt.Sprintf("Swagger test of %s on %s, %s", scope, st.BaseURL, mode)})
	if in.Start == "code" {
		if out, err = o.store.UpdateTicket(ctx, out.Key, nil, func(x *domain.Ticket) { x.Held = false }); err != nil {
			return out, err
		}
		o.Wake()
	}
	return out, nil
}

// checkSwaggerInput validates the form and gets its spec.
func (o *Orchestrator) checkSwaggerInput(ctx context.Context, in SwaggerTestInput) (domain.SwaggerTest, *SpecResult, error) {
	var spec SpecResult
	var err error
	from := ""
	if in.SpecRef != "" && len(in.Spec) == 0 {
		raw, u, ok := o.uploaded(ctx, in.SpecRef)
		if !ok {
			return domain.SwaggerTest{}, nil, invalid("the spec has expired (kept for an hour): read it again")
		}
		in.Spec, from = raw, u
	}
	switch {
	case len(in.Spec) > 0:
		var doc *apispec.Doc
		if doc, err = apispec.Parse(in.Spec, from); err != nil {
			err = invalid("%s", err.Error())
		}
		spec = SpecResult{URL: from, Doc: doc}
	case strings.TrimSpace(in.SpecURL) != "":
		spec, err = o.FetchSpec(ctx, in.SpecURL, nil)
	default:
		return domain.SwaggerTest{}, nil, invalid("give the spec's URL or upload the spec")
	}
	if err != nil {
		return domain.SwaggerTest{}, nil, err
	}
	if spec.Doc == nil {
		return domain.SwaggerTest{}, nil, invalid("the page offers %d specs: pick one", len(spec.Choices))
	}
	base, err := domain.ParseBaseURL(in.BaseURL)
	if err != nil {
		return domain.SwaggerTest{}, nil, invalid("%s", err.Error())
	}
	st := domain.SwaggerTest{SpecURL: spec.URL, Spec: spec.Doc.JSON, BaseURL: base.String(), Operations: dedupe(in.Operations),
		WriteEnabled: in.WriteEnabled, Auth: in.Auth, RateLimit: in.RateLimit, MaxRequests: in.MaxRequests, SuiteID: in.SuiteID}
	if st.Auth.Kind == "" {
		st.Auth.Kind = domain.AuthNone
	}
	if st.Auth.Kind != domain.AuthHeader && st.Auth.Kind != domain.AuthQuery {
		st.Auth.Name = ""
	}
	if err := st.Validate(spec.Doc.Ops()); err != nil {
		return st, nil, invalid("%s", err.Error())
	}
	if st.ByInstructions() && strings.TrimSpace(in.Notes) == "" {
		return st, nil, invalid("write which endpoints to test under \"What to test\", or tick them in the list")
	}
	if err := st.Auth.Validate(in.Credential); err != nil {
		return st, nil, invalid("%s", err.Error())
	}
	if st.WriteEnabled && !in.NotProduction {
		return st, nil, invalid("write requests need confirming that %s is not production", st.BaseURL)
	}
	return st, &spec, nil
}

func dedupe(ss []string) []string {
	var out []string
	for _, s := range ss {
		if op, ok := domain.ParseOperation(s); ok && !slices.Contains(out, op.String()) {
			out = append(out, op.String())
		}
	}
	return out
}

func firstNonEmpty(ss ...string) string {
	for _, s := range ss {
		if strings.TrimSpace(s) != "" {
			return strings.TrimSpace(s)
		}
	}
	return ""
}

// RerunSwaggerTest runs a Swagger test again. An open ticket (in review
// or failed) runs again in place, with a new credential if one is given.
// A closed one stays closed: the same test runs as a new ticket, which
// needs a credential again (closing deleted the sealed one). It returns
// the ticket that runs.
func (o *Orchestrator) RerunSwaggerTest(ctx context.Context, key string, cred *string, origin domain.Origin) (domain.Ticket, error) {
	if o.swagger == nil {
		return domain.Ticket{}, invalid("Swagger tests are not available on this server")
	}
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	if t.Kind != domain.KindSwaggerTest {
		return t, invalid("%s is not a Swagger test", key)
	}
	st, err := o.swagger.SwaggerTest(ctx, t.ID)
	if err != nil {
		return t, err
	}
	fresh := cred != nil && *cred != ""
	if fresh {
		if err := st.Auth.Validate(*cred); err != nil {
			return t, invalid("%s", err.Error())
		}
	}
	if t.State.Terminal() {
		if st.Auth.Kind != domain.AuthNone && !fresh {
			return t, invalid("the token was deleted when %s closed: give a new one to run the test again", key)
		}
		c := ""
		if fresh {
			c = *cred
		}
		return o.copySwaggerTest(ctx, t, st, c, origin)
	}
	switch t.State {
	case domain.StateWaitingForReview, domain.StateFailed:
	default:
		return t, &domain.TransitionError{Key: key, From: t.State, To: domain.StateCoding}
	}
	if !fresh && st.Auth.Kind != domain.AuthNone && !st.HasSecret {
		return t, invalid("%s has no token stored: give one to run it again", key)
	}
	if fresh {
		if err := o.swagger.SetSwaggerTestAuth(ctx, t.ID, *cred); err != nil {
			return t, err
		}
	}
	nt, err := o.store.Transition(ctx, key, domain.StateCoding, domain.Event{TicketKey: key, Type: domain.EventStateChanged, Origin: origin,
		Message: "Swagger test started again"}, func(x *domain.Ticket) {
		x.ResumeState, x.Held, x.ReviewState = domain.StateCoding, false, domain.ReviewNone
	})
	if err != nil {
		return nt, err
	}
	o.Wake()
	return nt, nil
}

// copySwaggerTest starts a closed ticket's test again as a new ticket,
// from the spec it stored (not fetched again).
func (o *Orchestrator) copySwaggerTest(ctx context.Context, t domain.Ticket, st domain.SwaggerTest, cred string, origin domain.Origin) (domain.Ticket, error) {
	nt := domain.Ticket{
		Source: domain.SourceLocal, Title: t.Title, Description: t.Description, Priority: t.Priority,
		State: domain.StateCoding, ResumeState: domain.StateCoding, AfterApprove: "pr", Held: true, Kind: domain.KindSwaggerTest,
		RepoID: t.RepoID, Repos: t.Repos, FollowUpOf: t.Key,
	}
	for i := range nt.Repos {
		nt.Repos[i].Branch, nt.Repos[i].State = "", domain.RepoPending
	}
	prefix := NoRepoTaskPrefix
	if t.RepoID != nil {
		if repo, err := o.store.RepositoryByID(ctx, *t.RepoID); err == nil {
			res, err := o.resolveRepos(ctx, domain.RepoChoice{RepoID: repo.ID}, domain.KindSwaggerTest, false)
			if err == nil {
				prefix = res.Prefix
				res.apply(&nt)
			}
		}
	}
	out, err := o.createTask(ctx, nt, prefix, nil, origin)
	if err != nil {
		return out, err
	}
	st.TicketID = out.ID
	if err := o.swagger.SaveSwaggerTest(ctx, st, &cred); err != nil {
		return out, err
	}
	o.event(ctx, domain.Event{TicketKey: out.Key, Type: domain.EventTicketUpdated, Origin: origin, Message: "the Swagger test of " + t.Key + " run again"})
	if out, err = o.store.UpdateTicket(ctx, out.Key, nil, func(x *domain.Ticket) { x.Held = false }); err != nil {
		return out, err
	}
	o.Wake()
	return out, nil
}

// SwaggerView is a ticket's test and latest results.
type SwaggerView struct {
	Test domain.SwaggerTest
	Run  *domain.SwaggerRun
	// Previous are the counts of the run before (nil when none), and
	// NewFailures the cases failing now that passed then.
	Previous    *domain.APICounts
	NewFailures []string
}

// SwaggerResultsOf returns a Swagger test ticket's test and its latest
// results.
func (o *Orchestrator) SwaggerResultsOf(ctx context.Context, key string) (SwaggerView, error) {
	if o.swagger == nil {
		return SwaggerView{}, domain.ErrNotFound
	}
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return SwaggerView{}, err
	}
	if t.Kind != domain.KindSwaggerTest {
		return SwaggerView{}, domain.ErrNotFound
	}
	st, err := o.swagger.SwaggerTest(ctx, t.ID)
	if err != nil {
		return SwaggerView{}, err
	}
	st.Spec = nil // the form has it; the results page does not need it
	v := SwaggerView{Test: st}
	run, err := o.swagger.SwaggerResults(ctx, t.ID)
	switch {
	case errors.Is(err, domain.ErrNotFound):
		return v, nil
	case err != nil:
		return v, err
	}
	v.Run = &run
	// The run before: this ticket's, or for a suite run the suite's last.
	prev, err := o.swagger.SwaggerResultsBefore(ctx, t.ID, run.RunID)
	if errors.Is(err, domain.ErrNotFound) && st.SuiteID != nil {
		prev, err = o.swagger.SuiteResultsBefore(ctx, *st.SuiteID, run.RunID)
	}
	if err == nil {
		v.Previous = &prev.Counts
		v.NewFailures = NewFailures(prev.Results, run.Results)
	}
	return v, nil
}

// SwaggerExchange returns one logged request of a ticket's latest run.
func (o *Orchestrator) SwaggerExchange(ctx context.Context, key, id string) (domain.APIExchange, error) {
	v, err := o.SwaggerResultsOf(ctx, key)
	if err != nil {
		return domain.APIExchange{}, err
	}
	if v.Run == nil {
		return domain.APIExchange{}, domain.ErrNotFound
	}
	for _, e := range v.Run.Log {
		if e.ID == id {
			return e, nil
		}
	}
	return domain.APIExchange{}, domain.ErrNotFound
}

// NewFailures are the cases failing in now that did not fail in before,
// by operation and case (ids may change between runs).
func NewFailures(before, now domain.SwaggerResults) []string {
	failed := map[string]bool{}
	for _, c := range before.Cases {
		if c.Verdict == domain.VerdictFail {
			failed[c.Operation+" · "+c.Case] = true
		}
	}
	var out []string
	for _, c := range now.Cases {
		k := c.Operation + " · " + c.Case
		if c.Verdict == domain.VerdictFail && !failed[k] && !slices.Contains(out, k) {
			out = append(out, k)
		}
	}
	return out
}
