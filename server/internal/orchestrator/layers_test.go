package orchestrator

import (
	"strconv"
	"strings"
	"testing"

	"agnts/internal/domain"
)

func TestLayerFlags(t *testing.T) {
	arch, err := domain.ParseArchitecture(`{"layers":[
		{"name":"handler","paths":["internal/httpapi/**","web/src/pages/**","app/views/**","src/main/java/com/acme/web/**"],"mayImport":["service"]},
		{"name":"service","paths":["internal/service/**","app/services/**"]},
		{"name":"store","paths":["internal/store/**","web/src/api/**","app/db/**","src/main/java/com/acme/db/**"],"mayImport":[]}]}`)
	if err != nil {
		t.Fatal(err)
	}
	files := []domain.FileChange{
		{Path: "internal/httpapi/refunds.go", Diff: "@@ -1,3 +1,5 @@\n import (\n+\t\"acme/internal/store/postgres\"\n+\tsvc \"acme/internal/service\"\n \t\"fmt\"\n )"},
		{Path: "web/src/pages/Cart.tsx", Diff: "@@ -10,2 +10,3 @@\n import x from 'react'\n+import { get } from '../api/client'\n const a = 1"},
		{Path: "app/views/refunds.py", Diff: "@@ -1 +1,3 @@\n+from app.db.models import Refund\n+from ..services.money import round_cents\n x = 1"},
		{Path: "src/main/java/com/acme/web/RefundController.java", Diff: "@@ -1 +1,2 @@\n+import com.acme.db.RefundRepository;\n package x;"},
		{Path: "internal/service/refunds.go", Diff: "@@ -1 +1,2 @@\n+\t\"acme/internal/store\"\n x"}, // services may import anything
	}
	flags := layerFlags(files, arch, "acme")
	var got []string
	for _, f := range flags {
		got = append(got, f.Path+":"+strconv.Itoa(f.Line))
		if !IsLayerFlag(f) || !strings.Contains(f.Text, "(handler) imports") || !strings.Contains(f.Text, "(store)") {
			t.Fatalf("flag: %+v", f)
		}
	}
	want := "internal/httpapi/refunds.go:2 web/src/pages/Cart.tsx:11 app/views/refunds.py:1 src/main/java/com/acme/web/RefundController.java:1"
	if strings.Join(got, " ") != want {
		t.Fatalf("flags: %s\n%+v", strings.Join(got, " "), flags)
	}
	if fs := layerFindings(flags); len(fs) != 4 || fs[0].Severity != "blocker" || fs[0].Category != "architecture" {
		t.Fatalf("findings: %+v", fs)
	}
}

func TestNewNames(t *testing.T) {
	files := []domain.FileChange{
		{Path: "money/round.go", Diff: "@@ -1 +1,4 @@\n+func RoundCents(x float64) float64 {\n+func helper() {}\n+type Money struct{}\n x"},
		{Path: "money/round_test.go", Diff: "@@ -1 +1 @@\n+func TestRound(t *testing.T) {}"},
		{Path: "web/src/format.ts", Diff: "@@ -1 +1 @@\n+export function formatCents(n: number) {"},
		{Path: "app/money.py", Diff: "@@ -1 +1,2 @@\n+def round_cents(x):\n+    def inner(): pass"},
	}
	got := strings.Join(newNames(files, 10), "; ")
	if got != "RoundCents (money/round.go); Money (money/round.go); formatCents (web/src/format.ts); round_cents (app/money.py)" {
		t.Fatalf("names: %s", got)
	}
}
