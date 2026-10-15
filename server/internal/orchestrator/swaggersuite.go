package orchestrator

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"math"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

// lastSuitePlan is the plan a suite's last run sent, to reuse: repeat runs
// then cost far fewer turns.
func (o *Orchestrator) lastSuitePlan(ctx context.Context, suiteID int64) ([]byte, time.Time, bool) {
	if o.swagger == nil {
		return nil, time.Time{}, false
	}
	prev, err := o.swagger.SuiteResultsBefore(ctx, suiteID, math.MaxInt64)
	if err != nil || len(prev.Plan) == 0 {
		return nil, time.Time{}, false
	}
	return prev.Plan, prev.CreatedAt, true
}

// compareSuiteRun compares a suite's run with its last one: the new
// failures lead the notification.
func (o *Orchestrator) compareSuiteRun(ctx context.Context, st domain.SwaggerTest, runID int64, now domain.SwaggerResults) (string, bool) {
	if st.SuiteID == nil || o.swagger == nil {
		return "", false
	}
	prev, err := o.swagger.SuiteResultsBefore(ctx, *st.SuiteID, runID)
	if err != nil {
		return "", false
	}
	nf := NewFailures(prev.Results, now)
	if len(nf) == 0 {
		return fmt.Sprintf(" (no new failures since %s)", prev.CreatedAt.Format("Jan 2 15:04")), true
	}
	return fmt.Sprintf(" — %d new since %s: %s", len(nf), prev.CreatedAt.Format("Jan 2 15:04"), truncate(strings.Join(nf, "; "), 300)), true
}

// SwaggerSuites stores saved Swagger test suites.
type SwaggerSuites interface {
	SaveSuite(ctx context.Context, s domain.SwaggerSuite, cred *string) (domain.SwaggerSuite, error)
	Suite(ctx context.Context, id int64) (domain.SwaggerSuite, error)
	Suites(ctx context.Context) ([]domain.SwaggerSuite, error)
	DeleteSuite(ctx context.Context, id int64) error
	SuiteAuth(ctx context.Context, id int64) (string, error)
	SetSuiteHook(ctx context.Context, id int64, hash string) error
	SuiteByHook(ctx context.Context, hash string) (domain.SwaggerSuite, int64, error)
	DueSuites(ctx context.Context, now time.Time) ([]DueSuite, error)
	MarkSuiteRun(ctx context.Context, id int64, ticketKey string, at time.Time) error
}

// DueSuite is a suite whose scheduled run is due, and its workspace.
type DueSuite struct {
	ID, Workspace int64
}

// SetSwaggerSuites turns saved suites on.
func (o *Orchestrator) SetSwaggerSuites(s SwaggerSuites) { o.suites = s }

// SuiteInput saves a suite: from a Swagger test ticket's test (FromTicket),
// or edits an existing one.
type SuiteInput struct {
	FromTicket string
	Name       string
	Schedule   domain.SuiteSchedule
	Hour       int
	Enabled    bool
	// Credential replaces the suite's token; nil keeps it (a new suite then
	// takes the ticket's, while the ticket still has one).
	Credential *string
}

// errNoSuites refuses suite calls on a server without them.
var errNoSuites = invalid("Swagger test suites are not available on this server")

// SaveSuiteFromTicket keeps a Swagger test ticket's test as a suite.
func (o *Orchestrator) SaveSuiteFromTicket(ctx context.Context, in SuiteInput) (domain.SwaggerSuite, error) {
	if o.suites == nil || o.swagger == nil {
		return domain.SwaggerSuite{}, errNoSuites
	}
	t, err := o.store.TicketByKey(ctx, in.FromTicket)
	if err != nil {
		return domain.SwaggerSuite{}, err
	}
	if t.Kind != domain.KindSwaggerTest {
		return domain.SwaggerSuite{}, invalid("%s is not a Swagger test", t.Key)
	}
	st, err := o.swagger.SwaggerTest(ctx, t.ID)
	if err != nil {
		return domain.SwaggerSuite{}, err
	}
	if err := checkSuiteInput(&in, t.Title); err != nil {
		return domain.SwaggerSuite{}, err
	}
	cred := in.Credential
	if cred == nil && st.Auth.Kind != domain.AuthNone {
		v, err := o.swagger.SwaggerTestAuth(ctx, t.ID)
		if err != nil {
			return domain.SwaggerSuite{}, err
		}
		if v == "" {
			return domain.SwaggerSuite{}, invalid("%s has no token stored any more: give one for the suite", t.Key)
		}
		cred = &v
	}
	if cred != nil && *cred != "" {
		if err := st.Auth.Validate(*cred); err != nil {
			return domain.SwaggerSuite{}, invalid("%s", err.Error())
		}
	}
	su := domain.SwaggerSuite{Name: in.Name, SpecURL: st.SpecURL, Spec: st.Spec, BaseURL: st.BaseURL, Operations: st.Operations,
		WriteEnabled: st.WriteEnabled, Auth: st.Auth, RateLimit: st.RateLimit, MaxRequests: st.MaxRequests, RepoID: t.RepoID,
		Notes: t.Description, Schedule: in.Schedule, Hour: in.Hour, Enabled: in.Enabled}
	out, err := o.suites.SaveSuite(ctx, su, cred)
	if err != nil {
		return out, err
	}
	// The ticket's own run counts as the suite's first: the next is compared with it.
	if err := o.swagger.SaveSwaggerTest(ctx, withSuite(st, out.ID), nil); err != nil {
		o.log.Warn("link a test to its suite", "ticket", t.Key, "err", err)
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, Type: domain.EventTicketUpdated, Origin: domain.OriginWeb,
		Message: fmt.Sprintf("saved as the Swagger test suite %q (%s)", out.Name, out.Schedule)})
	return out, nil
}

func withSuite(st domain.SwaggerTest, id int64) domain.SwaggerTest {
	st.SuiteID = &id
	return st
}

func checkSuiteInput(in *SuiteInput, fallback string) error {
	in.Name = strings.TrimSpace(in.Name)
	if in.Name == "" {
		in.Name = truncate(fallback, 100)
	}
	if len(in.Name) > 100 {
		return invalid("the name is at most 100 characters")
	}
	if in.Schedule == "" {
		in.Schedule = domain.ScheduleOff
	}
	if !in.Schedule.Valid() {
		return invalid("schedule is off, hourly, daily or weekly")
	}
	if in.Hour < 0 || in.Hour > 23 {
		return invalid("hour is 0 to 23 (UTC)")
	}
	return nil
}

// UpdateSuite changes a suite's name, schedule, switch and token.
func (o *Orchestrator) UpdateSuite(ctx context.Context, id int64, in SuiteInput) (domain.SwaggerSuite, error) {
	if o.suites == nil {
		return domain.SwaggerSuite{}, errNoSuites
	}
	su, err := o.suites.Suite(ctx, id)
	if err != nil {
		return su, err
	}
	if err := checkSuiteInput(&in, su.Name); err != nil {
		return su, err
	}
	if in.Credential != nil && *in.Credential != "" {
		if err := su.Auth.Validate(*in.Credential); err != nil {
			return su, invalid("%s", err.Error())
		}
	}
	su.Name, su.Schedule, su.Hour, su.Enabled = in.Name, in.Schedule, in.Hour, in.Enabled
	return o.suites.SaveSuite(ctx, su, in.Credential)
}

// Suites lists the workspace's suites.
func (o *Orchestrator) Suites(ctx context.Context) ([]domain.SwaggerSuite, error) {
	if o.suites == nil {
		return nil, errNoSuites
	}
	return o.suites.Suites(ctx)
}

// Suite returns one suite.
func (o *Orchestrator) Suite(ctx context.Context, id int64) (domain.SwaggerSuite, error) {
	if o.suites == nil {
		return domain.SwaggerSuite{}, errNoSuites
	}
	return o.suites.Suite(ctx, id)
}

// DeleteSuite deletes a suite; its past tickets stay.
func (o *Orchestrator) DeleteSuite(ctx context.Context, id int64) error {
	if o.suites == nil {
		return errNoSuites
	}
	return o.suites.DeleteSuite(ctx, id)
}

// ErrSuiteBusy refuses a run while the suite's last run is still going.
var ErrSuiteBusy = errors.New("the suite's last run is still going")

// RunSuite starts a suite's test as a new ticket. A run is refused while
// the last one is still queued or running, so deploys in a row do not pile
// up runs.
func (o *Orchestrator) RunSuite(ctx context.Context, id int64, origin domain.Origin) (domain.Ticket, error) {
	if o.suites == nil || o.swagger == nil {
		return domain.Ticket{}, errNoSuites
	}
	su, err := o.suites.Suite(ctx, id)
	if err != nil {
		return domain.Ticket{}, err
	}
	if su.LastTicketKey != "" {
		if last, err := o.store.TicketByKey(ctx, su.LastTicketKey); err == nil && last.State == domain.StateCoding {
			return last, ErrSuiteBusy
		}
	}
	cred, err := o.suites.SuiteAuth(ctx, id)
	if err != nil {
		return domain.Ticket{}, err
	}
	if su.Auth.Kind != domain.AuthNone && cred == "" {
		return domain.Ticket{}, invalid("the suite %q has no token: set one and run it again", su.Name)
	}
	t := domain.Ticket{
		Source: domain.SourceLocal, Title: truncate("Swagger suite: "+su.Name, 200), Description: su.Notes, Priority: "medium",
		State: domain.StateCoding, ResumeState: domain.StateCoding, AfterApprove: "pr", Held: true, Kind: domain.KindSwaggerTest,
	}
	prefix := NoRepoTaskPrefix
	if su.RepoID != nil {
		if res, err := o.resolveRepos(ctx, domain.RepoChoice{RepoID: *su.RepoID}, domain.KindSwaggerTest, false); err == nil {
			prefix = res.Prefix
			res.apply(&t)
		}
	}
	out, err := o.createTask(ctx, t, prefix, nil, origin)
	if err != nil {
		return out, err
	}
	st := su.Test()
	st.TicketID = out.ID
	if err := o.swagger.SaveSwaggerTest(ctx, st, &cred); err != nil {
		return out, err
	}
	if err := o.suites.MarkSuiteRun(ctx, id, out.Key, time.Now()); err != nil {
		o.log.Warn("record a suite run", "suite", id, "err", err)
	}
	o.event(ctx, domain.Event{TicketKey: out.Key, Type: domain.EventTicketUpdated, Origin: origin,
		Message: fmt.Sprintf("run of the Swagger test suite %q (%s)", su.Name, origin)})
	if out, err = o.store.UpdateTicket(ctx, out.Key, nil, func(x *domain.Ticket) { x.Held = false }); err != nil {
		return out, err
	}
	o.Wake()
	return out, nil
}

// RunDueSuites starts every scheduled suite run that is due, in every
// workspace. A suite whose last run is still going skips this one.
func (o *Orchestrator) RunDueSuites(ctx context.Context) {
	if o.suites == nil {
		return
	}
	now := time.Now()
	due, err := o.suites.DueSuites(ctx, now)
	if err != nil {
		o.log.Warn("due Swagger suites", "err", err)
		return
	}
	for _, d := range due {
		wctx := domain.WithWorkspace(ctx, d.Workspace)
		if _, err := o.RunSuite(wctx, d.ID, domain.OriginSystem); err != nil {
			o.log.Info("scheduled Swagger suite run skipped", "workspace", d.Workspace, "suite", d.ID, "err", err)
			if merr := o.suites.MarkSuiteRun(wctx, d.ID, "", now); merr != nil {
				o.log.Warn("move a suite's next run", "suite", d.ID, "err", merr)
			}
		}
	}
}

// RotateSuiteHook makes a new deploy hook token for a suite, returned once;
// the old one stops working.
func (o *Orchestrator) RotateSuiteHook(ctx context.Context, id int64) (string, error) {
	if o.suites == nil {
		return "", errNoSuites
	}
	tok, err := secret.NewToken()
	if err != nil {
		return "", err
	}
	tok = SuiteHookPrefix + tok
	if err := o.suites.SetSuiteHook(ctx, id, HashHook(tok)); err != nil {
		return "", err
	}
	return tok, nil
}

// SuiteHookPrefix marks deploy hook tokens.
const SuiteHookPrefix = "agnts_sh_"

// HashHook is how a deploy hook token is stored.
func HashHook(tok string) string {
	sum := sha256.Sum256([]byte(tok))
	return hex.EncodeToString(sum[:])
}

// RunSuiteByHook runs the suite a deploy hook token belongs to.
func (o *Orchestrator) RunSuiteByHook(ctx context.Context, tok string) (domain.Ticket, error) {
	if o.suites == nil || !strings.HasPrefix(tok, SuiteHookPrefix) {
		return domain.Ticket{}, domain.ErrNotFound
	}
	su, ws, err := o.suites.SuiteByHook(ctx, HashHook(tok))
	if err != nil {
		return domain.Ticket{}, err
	}
	if !su.Enabled {
		return domain.Ticket{}, invalid("the suite %q is paused", su.Name)
	}
	return o.RunSuite(domain.WithWorkspace(ctx, ws), su.ID, domain.OriginWebhook)
}
