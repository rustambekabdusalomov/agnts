package rulepacks

import (
	"io/fs"
	"strings"
	"testing"

	"agnts/internal/domain"
)

func TestEveryPackLoadsAndIsValid(t *testing.T) {
	entries, err := fs.ReadDir(files, "packs")
	if err != nil {
		t.Fatal(err)
	}
	n := 0
	for _, e := range entries {
		if !strings.HasSuffix(e.Name(), ".json") {
			continue
		}
		p, err := Get(strings.TrimSuffix(e.Name(), ".json"))
		if err != nil {
			t.Fatal(err)
		}
		if p.Name == "" || len(p.Rules) < 4 {
			t.Errorf("%s: %d rules", p.ID, len(p.Rules))
		}
		for _, r := range p.Rules {
			x := domain.Rule{Title: r.Title, Body: r.Body}
			if err := x.Validate(); err != nil {
				t.Errorf("%s: %q: %v", p.ID, r.Title, err)
			}
			if r.Enforce != nil {
				if err := r.Enforce.Validate(); err != nil {
					t.Errorf("%s: %q: %v", p.ID, r.Title, err)
				}
			}
		}
		n++
	}
	if n < 10 {
		t.Fatalf("%d packs", n)
	}
	got := For([]domain.Toolchain{{Tool: "node"}, {Tool: "go"}, {Tool: "gradle"}})
	if strings.Join(got, ",") != "go,java,kotlin,typescript" {
		t.Fatalf("For: %v", got)
	}
}
