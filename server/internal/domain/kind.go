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
)

// Kinds lists every kind in the order clients show them.
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
}

var kindSpecs = map[TicketKind]KindSpec{
	KindCode:     {Output: OutputChange, NeedsRepo: true, Learn: true},
	KindTest:     {Output: OutputChange, NeedsRepo: true, Learn: true},
	KindPlan:     {Output: OutputReport, Implementable: true},
	KindAnalysis: {Output: OutputReport},
	KindBug:      {Output: OutputReport, Implementable: true},
}

// Valid reports whether k is a known kind.
func (k TicketKind) Valid() bool {
	_, ok := kindSpecs[k]
	return ok
}

// Spec returns how agnts works k; unknown kinds are worked as code.
func (k TicketKind) Spec() KindSpec {
	if s, ok := kindSpecs[k]; ok {
		return s
	}
	return kindSpecs[KindCode]
}

// Report reports whether k produces a report instead of a change.
func (k TicketKind) Report() bool { return k.Spec().Output == OutputReport }
