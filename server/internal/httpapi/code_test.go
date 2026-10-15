package httpapi

import (
	"net/http/httptest"
	"testing"
)

func TestCodeParams(t *testing.T) {
	str := func(s string) *string { return &s }
	for _, c := range []struct {
		ref      *string
		path     string
		ok       bool
		wantRef  string
		wantPath string
	}{
		{nil, "", true, "", ""},
		{str("feature/x"), "/src/main.go/", true, "feature/x", "src/main.go"},
		{str(" main "), "a b/c.go", true, "main", "a b/c.go"},
		{str("a..b"), "", false, "", ""},
		{str("main:x"), "", false, "", ""},
		{str("main"), "src/../etc", false, "", ""},
		{str("main"), "src//x", false, "", ""},
		{str("main"), "./x", false, "", ""},
		{str("main"), "x\ny", false, "", ""},
	} {
		w := httptest.NewRecorder()
		ref, path, ok := codeParams(w, c.ref, c.path)
		if ok != c.ok || ref != c.wantRef || path != c.wantPath {
			t.Errorf("codeParams(%v, %q) = %q, %q, %v", c.ref, c.path, ref, path, ok)
		}
		if !ok && w.Code != 400 {
			t.Errorf("codeParams(%q): status %d", c.path, w.Code)
		}
	}
}
