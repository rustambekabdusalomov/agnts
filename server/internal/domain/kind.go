package domain

// TicketKind is the kind of work a ticket asks for. It decides what a run
// produces and what happens after review.
type TicketKind string

// Ticket kinds.
const (
	KindCode     TicketKind = "code"     // implement a change
	KindTest     TicketKind = "test"     // write or fix tests
	KindPlan     TicketKind = "plan"     // write an implementation plan
	KindAnalysis TicketKind = "analysis" // research a question and report
	KindBug      TicketKind = "bug"      // find a bug's root cause, change nothing
	// KindReview reviews a pull request someone else wrote. Its tickets
	// come from the git host, never from a form or a label.
	KindReview TicketKind = "review"
	// KindSwaggerTest tests an HTTP API against its Swagger/OpenAPI spec.
	// Its tickets come from the Swagger test form only: the form carries
	// the spec, base URL and token a label or the analysis cannot give.
	KindSwaggerTest TicketKind = "swaggertest"
)

// Kinds lists every kind people can pick, in the order clients show them.
var Kinds = []TicketKind{KindCode, KindTest, KindPlan, KindAnalysis, KindBug}

// Output is what a kind's work run produces.
type Output string

// Outputs.
const (
	// OutputChange is a diff: checks, review of the diff, push or pull request.
	OutputChange Output = "change"
	// OutputReport is a Markdown report: review of the report, then it is
	// kept in agnts and, if the reviewer asks, posted to the tracker.
	OutputReport Output = "report"
)

// KindSpec says how agnts works a kind.
type KindSpec struct {
	Output Output
	// NeedsRepo is false when the work can run on an empty workspace.
	NeedsRepo bool
	// Learn queues the learn stage after the work is pushed.
	Learn bool
	// Implementable reports end in a change agnts can be asked to make.
	Implementable bool
	// MultiRepo: the work may span several repositories at once.
	MultiRepo bool
}

var kindSpecs = map[TicketKind]KindSpec{
	KindCode:     {Output: OutputChange, NeedsRepo: true, Learn: true, MultiRepo: true},
	KindTest:     {Output: OutputChange, NeedsRepo: true, Learn: true, MultiRepo: true},
	KindPlan:     {Output: OutputReport, Implementable: true, MultiRepo: true},
	KindAnalysis: {Output: OutputReport, MultiRepo: true},
	KindBug:      {Output: OutputReport, Implementable: true, MultiRepo: true},
	// A review is a report about someone else's change; approving it
	// merges the pull request. It is one pull request, in one repository.
	KindReview: {Output: OutputReport, NeedsRepo: true},
	// A Swagger test reports on an API; a repository is optional (to
	// explain failures), and failures can become a Bug or Code ticket.
	KindSwaggerTest: {Output: OutputReport, Implementable: true},
}

// Valid reports whether k is a known kind.
func (k TicketKind) Valid() bool {
	_, ok := kindSpecs[k]
	return ok
}

// Selectable reports whether people (a form, a label, the analysis) may
// give a ticket kind k: every kind but review and Swagger test, which have
// forms of their own.
func (k TicketKind) Selectable() bool { return k.Valid() && k != KindReview && k != KindSwaggerTest }

// Spec returns how agnts works k; unknown kinds are worked as code.
func (k TicketKind) Spec() KindSpec {
	if s, ok := kindSpecs[k]; ok {
		return s
	}
	return kindSpecs[KindCode]
}

// Report reports whether k produces a report instead of a change.
func (k TicketKind) Report() bool { return k.Spec().Output == OutputReport }
