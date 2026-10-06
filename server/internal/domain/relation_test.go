package domain

import (
	"slices"
	"testing"
	"time"
)

// patch builds a one-hunk diff of base lines from..to replaced by n new lines.
func patch(path string, start, removed int, added ...string) FileChange {
	d := "diff --git a/" + path + " b/" + path + "\n--- a/" + path + "\n+++ b/" + path + "\n@@ -1,100 +1,100 @@\n"
	for i := 1; i < start; i++ {
		d += " ctx\n"
	}
	for i := 0; i < removed; i++ {
		d += "-old\n"
	}
	for _, a := range added {
		d += "+" + a + "\n"
	}
	return FileChange{Path: path, Diff: d}
}

func TestDiffConflicts(t *testing.T) {
	cases := []struct {
		name string
		a, b FileChange
		want []FileConflict
	}{
		{"same line", patch("x.go", 5, 1, "a"), patch("x.go", 5, 1, "b"), []FileConflict{{"x.go", true}}},
		{"adjacent lines", patch("x.go", 5, 1, "a"), patch("x.go", 6, 1, "b"), []FileConflict{{"x.go", true}}},
		{"one line apart", patch("x.go", 5, 1, "a"), patch("x.go", 7, 1, "b"), []FileConflict{{"x.go", false}}},
		{"far apart", patch("x.go", 5, 1, "a"), patch("x.go", 40, 2, "b"), []FileConflict{{"x.go", false}}},
		{"insertions at the same place", patch("x.go", 9, 0, "a"), patch("x.go", 9, 0, "b"), []FileConflict{{"x.go", true}}},
		{"insertion right after an edit", patch("x.go", 5, 1, "a"), patch("x.go", 6, 0, "b"), []FileConflict{{"x.go", true}}},
		{"different files", patch("x.go", 5, 1, "a"), patch("y.go", 5, 1, "b"), nil},
		{"both add the file", FileChange{Path: "n.go", Diff: "--- /dev/null\n+++ b/n.go\n@@ -0,0 +1 @@\n+a\n"},
			FileChange{Path: "n.go", Diff: "--- /dev/null\n+++ b/n.go\n@@ -0,0 +1 @@\n+b\n"}, []FileConflict{{"n.go", true}}},
		{"truncated diff", patch("x.go", 5, 1, "a"), FileChange{Path: "x.go", Diff: "@@ -1 +1 @@\n… diff truncated …\n"}, []FileConflict{{"x.go", true}}},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			got := DiffConflicts([]FileChange{c.a}, []FileChange{c.b})
			if !slices.Equal(got, c.want) {
				t.Fatalf("got %+v, want %+v", got, c.want)
			}
		})
	}
}

func TestFootprintRules(t *testing.T) {
	f := Footprint{Files: []string{"/workspace/server/x.go", "./server/x.go", "server/", "server/**/*.go", " `api/openapi.yaml` ", ""}}.Clean()
	if !slices.Equal(f.Files, []string{"server/x.go", "api/openapi.yaml"}) {
		t.Fatalf("clean: %v", f.Files)
	}
	a := Footprint{Files: []string{"server/migrations/00018_x.sql", "server/a.go", "apps/admin/package-lock.json"}}
	b := Footprint{Files: []string{"db/migrations/0002.sql", "server/a.go", "shared/i18n/en/ticket.json"}}
	if got := SharedFiles(a, b); !slices.Equal(got, []string{"server/a.go"}) {
		t.Fatalf("shared: %v", got)
	}
	if got := HotSpots(a); !slices.Equal(got, []string{BasisLockfile, BasisMigrations}) {
		t.Fatalf("hot spots a: %v", got)
	}
	if got := HotSpots(b); !slices.Equal(got, []string{BasisI18n, BasisMigrations}) {
		t.Fatalf("hot spots b: %v", got)
	}
	if got := HotSpots(Footprint{Migrations: true, Files: []string{"web/src/api/schema.gen.ts"}}); !slices.Equal(got, []string{BasisCodegen, BasisMigrations}) {
		t.Fatalf("hot spots flag: %v", got)
	}
}

func TestReachableAndNormalize(t *testing.T) {
	g := map[string][]string{"A": {"B"}, "B": {"C"}}
	if !Reachable(g, "A", "C") || Reachable(g, "C", "A") {
		t.Fatal("reachability")
	}
	// Adding C -> A would close A -> B -> C -> A.
	if !Reachable(g, "A", "C") {
		t.Fatal("cycle not seen")
	}
	r := Relation{Type: RelConflicts, TicketKey: "PAY-9", OtherKey: "PAY-10"}.Normalize()
	if r.TicketKey != "PAY-10" || r.OtherKey != "PAY-9" || r.Other("PAY-9") != "PAY-10" {
		t.Fatalf("normalize: %+v", r)
	}
	d := Relation{Type: RelDependsOn, TicketKey: "PAY-9", OtherKey: "PAY-10"}.Normalize()
	if d.TicketKey != "PAY-9" {
		t.Fatal("a dependency keeps its direction")
	}
}

func TestReleases(t *testing.T) {
	now := time.Now()
	cases := []struct {
		t    Ticket
		want bool
	}{
		{Ticket{State: StateDone, Kind: KindCode, Source: SourceJira}, false},
		{Ticket{State: StateDone, Kind: KindCode, MergedAt: &now}, true},
		{Ticket{State: StateDone, Kind: KindCode, Source: SourceLocal, AfterApprove: "main"}, true},
		{Ticket{State: StateDone, Kind: KindPlan}, true},
		{Ticket{State: StateRejected}, true},
		{Ticket{State: StateWaitingForReview, MergedAt: &now}, false},
	}
	for i, c := range cases {
		if got := c.t.Releases(); got != c.want {
			t.Fatalf("case %d: %v", i, got)
		}
	}
}
