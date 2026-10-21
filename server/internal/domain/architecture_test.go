package domain

import "testing"

func TestMatchGlob(t *testing.T) {
	for _, c := range []struct {
		glob, path string
		want       bool
	}{
		{"internal/httpapi/**", "internal/httpapi/tickets.go", true},
		{"internal/httpapi/**", "internal/httpapi/gen/api.go", true},
		{"internal/httpapi/**", "internal/httpapi2/x.go", false},
		{"internal/store", "internal/store/postgres/x.go", true},
		{"src/*/api/*.ts", "src/web/api/client.ts", true},
		{"src/*/api/*.ts", "src/web/x/api/client.ts", false},
		{"**/components/**", "apps/admin/src/components/ticket/X.vue", true},
	} {
		if got := MatchGlob(c.glob, c.path); got != c.want {
			t.Errorf("MatchGlob(%q, %q) = %v", c.glob, c.path, got)
		}
	}
}

func TestParseArchitecture(t *testing.T) {
	a, err := ParseArchitecture(`{"layers":[
		{"name":"handler","paths":["./internal/httpapi/**"],"owns":"requests","mayImport":["service","nonsense"]},
		{"name":"store","paths":["internal/store/**"],"mayImport":[]},
		{"name":"service","paths":["internal/service/**"]},
		{"name":"","paths":["x/**"]}],
		"helpers":[{"name":"money.Round","path":"/workspace/internal/money/round.go","for":"cents"},{"name":"","path":"a.go"}],
		"recipes":[{"kind":"endpoint","copy":["internal/httpapi/tickets.go"],"steps":["spec"," "]}]}`)
	if err != nil || a == nil {
		t.Fatal(err)
	}
	if len(a.Layers) != 3 || a.Layers[0].Paths[0] != "internal/httpapi/**" || len(a.Layers[0].MayImport) != 1 || a.Layers[2].MayImport != nil ||
		a.Layers[1].MayImport == nil {
		t.Fatalf("layers: %+v", a.Layers)
	}
	if len(a.Helpers) != 1 || a.Helpers[0].Path != "internal/money/round.go" || len(a.Recipes[0].Steps) != 1 {
		t.Fatalf("helpers %+v recipes %+v", a.Helpers, a.Recipes)
	}
	h := a.LayerOf("internal/httpapi/refunds.go")
	if h == nil || h.Name != "handler" || h.Allows("store") || !h.Allows("service") || !h.Allows("handler") {
		t.Fatalf("handler: %+v", h)
	}
	if s := a.LayerOfDir("internal/service/refunds"); s == nil || !s.Allows("store") {
		t.Fatalf("service may import anything: %+v", s)
	}
	if x := a.Without([]string{"internal/money/round.go"}); len(x.Helpers) != 0 || len(a.Helpers) != 1 {
		t.Fatalf("without: %+v", x.Helpers)
	}
	if a, err := ParseArchitecture(""); a != nil || err != nil {
		t.Fatalf("empty: %v %v", a, err)
	}
	if _, err := ParseArchitecture("{"); err == nil {
		t.Fatal("bad JSON accepted")
	}
}
