package security

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"agnts/internal/domain"
)

// The files in testdata/raw are what agnts-sec wrote for testdata/vulnapp
// (with a generated fake key in config/secrets.env, replaced here).
func readRaw(t *testing.T) Raw {
	t.Helper()
	raw := Raw{}
	for _, f := range Files {
		b, err := os.ReadFile(filepath.Join("testdata", "raw", f))
		if err != nil {
			t.Fatal(err)
		}
		raw[f] = b
	}
	return raw
}

func TestHitsFromVulnapp(t *testing.T) {
	hits, errs := Hits(readRaw(t), domain.SecDefaultExclude)
	if len(errs) > 0 {
		t.Fatalf("errs = %v", errs)
	}
	by := map[string][]domain.SecHit{}
	for i, h := range hits {
		if h.ID != "h"+string(rune('1'+i)) && i < 9 {
			t.Errorf("hit %d has id %s", i, h.ID)
		}
		by[h.Tool] = append(by[h.Tool], h)
	}
	if g := by[domain.ToolOpengrep]; len(g) != 2 || g[0].File != "handlers/orders.go" || g[0].CWE != "CWE-89" || !strings.HasPrefix(g[0].Rule, "agnts.go.sqli.") {
		t.Fatalf("opengrep = %+v", g)
	}
	sec := by[domain.ToolGitleaks]
	if len(sec) != 1 || sec[0].Source != domain.SecFromSecret || sec[0].File != "config/secrets.env" || sec[0].SecretHash == "" {
		t.Fatalf("gitleaks = %+v (the history copy of a secret still in the tree is not a second hit)", sec)
	}
	if strings.Contains(sec[0].SecretMask, "SECRET-VALUE") || sec[0].SecretMask != "FAKE************" {
		t.Fatalf("mask = %q", sec[0].SecretMask)
	}
	dep := by[domain.ToolOSV]
	if len(dep) != 1 || dep[0].Package != "lodash" || dep[0].Version != "4.17.20" || dep[0].FixedIn != "4.18.0" ||
		dep[0].File != "package-lock.json" || dep[0].Severity != domain.SecHigh || len(dep[0].Advisories) < 4 {
		t.Fatalf("osv = %+v", dep)
	}
	cfg := by[domain.ToolTrivy]
	if len(cfg) != 2 || cfg[0].File != "Dockerfile" || cfg[0].Rule != "DS-0002" {
		t.Fatalf("trivy = %+v", cfg)
	}
}

func TestHitsExcludeAndBadOutput(t *testing.T) {
	raw := readRaw(t)
	hits, _ := Hits(raw, append(domain.SecDefaultExclude, "handlers/**"))
	for _, h := range hits {
		if strings.HasPrefix(h.File, "handlers/") {
			t.Fatalf("excluded hit: %+v", h)
		}
	}
	raw["osv.json"] = []byte("not json")
	_, errs := Hits(raw, nil)
	if errs[domain.ToolOSV] == nil || len(errs) != 1 {
		t.Fatalf("errs = %v", errs)
	}
}

func TestHistoryOnlySecret(t *testing.T) {
	tree := []byte(`[]`)
	hist := []byte(`[{"RuleID":"stripe-access-token","File":"config/old.env","StartLine":2,"Secret":"FAKE-SECRET-VALUE-0002","Commit":"aa1d1657cef66e76"},
		{"RuleID":"stripe-access-token","File":"config/old.env","StartLine":2,"Secret":"FAKE-SECRET-VALUE-0002","Commit":"bb1d1657cef66e76"}]`)
	hs, err := gitleaks(tree, hist)
	if err != nil || len(hs) != 1 || hs[0].Source != domain.SecFromHistory || !strings.Contains(hs[0].Message, "aa1d165") {
		t.Fatalf("history = %+v %v", hs, err)
	}
}

func TestCompareVersions(t *testing.T) {
	for _, tc := range []struct {
		a, b string
		want int
	}{
		{"4.17.21", "4.17.9", 1}, {"1.2.0", "1.2", 1}, {"v2.0.0", "2.0.0", 0}, {"1.0.0-rc1", "1.0.0", 1}, {"0.9", "1.0", -1},
	} {
		if got := compareVersions(tc.a, tc.b); got != tc.want {
			t.Errorf("compareVersions(%s, %s) = %d", tc.a, tc.b, got)
		}
	}
}

func TestSymbol(t *testing.T) {
	gosrc, err := os.ReadFile("testdata/vulnapp/handlers/orders.go")
	if err != nil {
		t.Fatal(err)
	}
	cases := []struct {
		file string
		src  string
		line int
		want string
	}{
		{"handlers/orders.go", string(gosrc), 21, "Orders.Search"},
		{"handlers/orders.go", string(gosrc), 3, ""},
		{"api/merge.js", "const _ = require('lodash');\n\nfunction settings(defaults, body) {\n  return _.merge({}, defaults, JSON.parse(body));\n}\n", 4, "settings"},
		{"api/routes.ts", "class Users {\n  async show(req: Request): Promise<void> {\n    db.query(`x ${req.params.id}`);\n  }\n}\n", 3, "Users.show"},
		{"api/app.js", "app.get('/orders/:id', async (req, res) => {\n  res.send(req.query.q);\n});\n", 2, "GET /orders/:id"},
		{"svc/views.py", "class Orders:\n    def search(self, q):\n        if q:\n            cur.execute(f'{q}')\n\ndef other():\n    pass\n", 4, "Orders.search"},
		{"svc/views.py", "def a():\n    pass\ndef b():\n    eval(x)\n", 4, "b"},
		{"src/Repo.java", "public class Repo {\n    public List<User> find(String name) throws Exception {\n        st.executeQuery(\"x\" + name);\n        if (x) {\n          y();\n        }\n    }\n}\n", 3, "Repo.find"},
		{"src/Repo.java", "public class Repo {\n    public List<User> find(String name) throws Exception {\n        if (x) {\n          st.executeQuery(\"x\" + name);\n        }\n    }\n}\n", 4, "Repo.find"},
		{"web/a.php", "<?php\nclass Shop {\n  public function search($c) {\n    mysqli_query($c, $_GET['q']);\n  }\n}\n", 4, "Shop.search"},
		{"README.md", "# hi\n", 1, ""},
	}
	for _, tc := range cases {
		if got := Symbol(tc.file, []byte(tc.src), tc.line); got != tc.want {
			t.Errorf("Symbol(%s:%d) = %q, want %q", tc.file, tc.line, got, tc.want)
		}
	}
}
