package coverage

import (
	"os"
	"testing"

	"agnts/internal/domain"
)

func TestGoProfile(t *testing.T) {
	profile := `mode: set
agnts/internal/pay/refund.go:10.30,12.2 2 1
agnts/internal/pay/refund.go:14.20,16.3 1 0
agnts/internal/pay/refund.go:17.2,17.10 1 1
`
	lines, err := Parse([]byte(profile), "/workspace", map[string]string{"agnts": "server"})
	if err != nil {
		t.Fatal(err)
	}
	m := lines["server/internal/pay/refund.go"]
	if m[11] != 1 || m[15] != 0 || m[17] != 1 {
		t.Fatalf("lines: %v", m)
	}
	diff := "@@ -9,2 +9,9 @@\n func a() {}\n+func Refund() {\n+\tx := 1\n+\t_ = x\n+// a comment\n+\tif bad {\n+\t\treturn\n+\t}\n+\tdone()\n"
	c := Measure([]domain.FileChange{{Path: "server/internal/pay/refund.go", Diff: diff}, {Path: "README.md", Diff: "@@ -1 +1,2 @@\n x\n+y\n"}}, lines, 80)
	// Added lines 10..17: executable 10,11,12 (covered), 14,15,16 (not), 17 (covered); 13 is a comment.
	if c.Total != 7 || c.Covered != 4 || c.Percent != 57.1 || len(c.Files) != 1 {
		t.Fatalf("coverage: %+v", c)
	}
	if u := c.Files[0].Uncovered; len(u) != 1 || u[0].From != 14 || u[0].To != 16 {
		t.Fatalf("uncovered: %+v", u)
	}
}

func TestLcov(t *testing.T) {
	report := "TN:\nSF:/workspace/web/src/cart.ts\nDA:3,1\nDA:4,0\nDA:5,2\nend_of_record\n"
	lines, err := Parse([]byte(report), "/workspace", nil)
	if err != nil {
		t.Fatal(err)
	}
	c := Measure([]domain.FileChange{{Path: "web/src/cart.ts", Diff: "@@ -2,1 +2,4 @@\n a\n+b\n+c\n+d\n"}}, lines, 0)
	if c.Total != 3 || c.Covered != 2 {
		t.Fatalf("coverage: %+v", c)
	}
	if _, err := Parse([]byte("garbage"), "", nil); err == nil {
		t.Fatal("garbage parsed")
	}
}

// testdata/real.out is what go test -coverprofile wrote for a module "x"
// whose pay/pay.go line 5 is a one-line function.
func TestRealGoProfile(t *testing.T) {
	raw, err := os.ReadFile("testdata/real.out")
	if err != nil {
		t.Fatal(err)
	}
	lines, err := Parse(raw, "/workspace", map[string]string{"x": ""})
	if err != nil {
		t.Fatal(err)
	}
	c := Measure([]domain.FileChange{{Path: "pay/pay.go", Diff: "@@ -4,2 +4,2 @@\n \n-func Round(x float64) float64 { return float64(int(x*100)) / 100 }\n+func Round(x float64) float64 { return math.Round(x*100) / 100 }\n"}}, lines, 0)
	if c.Total != 1 || c.Covered != 1 {
		t.Fatalf("coverage: %+v (lines %v)", c, lines)
	}
}
