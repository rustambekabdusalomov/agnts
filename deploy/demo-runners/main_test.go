package main

import (
	"bytes"
	"math/rand/v2"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func services(t *testing.T) []*service {
	t.Helper()
	var out []*service
	for _, name := range []string{"shop-api", "billing-worker", "auth-gateway"} {
		s, err := serviceNamed(name)
		if err != nil {
			t.Fatal(err)
		}
		out = append(out, s)
	}
	return out
}

func printed(s *service, in *incident) string {
	var buf bytes.Buffer
	e := newEmitter(s.name, rand.New(rand.NewPCG(1, 2)))
	e.fast, e.out, e.errOut = true, &buf, &buf
	e.json = newEmitterJSON(&buf)
	in.run(e)
	return buf.String()
}

// Each incident prints the line agnts's detector keys on.
func TestIncidentLines(t *testing.T) {
	want := map[string][]string{
		"api-1":    {"panic: assignment to entry in nil map", "internal/coupon/coupon.go:107", `"path":"/api/checkout"`, `"status":500`},
		"api-2":    {`"msg":"search failed"`, "' UNION SELECT email FROM auth.users --", "SQLSTATE 42601"},
		"api-3":    {"failed to load product: no rows in result set", `"caller":"catalog/handler.go:94"`},
		"api-4":    {`"msg":"request headers"`, `"Authorization":["Bearer eyJ`},
		"zero-qty": {`"path":"/api/cart/items"`, `"status":201`},
		"bw-1":     {"panic: runtime error: integer divide by zero", "/src/internal/jobs/charge.go:105", "connecting to postgres://billing:"},
		"bw-2":     {"charge declined for order", `\"number\": \"4000000000000002\"`, "job is dead kind=charge_order"},
		"bw-3":     {"INFO billing.main: connecting to postgres://billing:Sup3rS3cret-2026@postgres:5432/shop"},
		"bw-4":     {"total is 0", "currency=UZS", `total="0.00 UZS"`},
		"gw-1":     {`"POST /auth/login HTTP/1.1" 401 37`, "login failed for shopper-"},
		"gw-2":     {"login failed for shopper-", "wrong password"},
		"scan":     {`"GET /.git/config HTTP/1.1" 404`, `"GET /.env HTTP/1.1" 200 110`},
		"gw-4":     {`[GIN-debug] [WARNING] Running in "debug" mode`},
	}
	seen := 0
	for _, s := range services(t) {
		for _, in := range s.incidents {
			out := printed(s, in)
			w, ok := want[in.id]
			if !ok {
				t.Errorf("%s: no expectations", in.id)
				continue
			}
			seen++
			for _, sub := range w {
				if !strings.Contains(out, sub) {
					t.Errorf("%s: output lacks %q:\n%s", in.id, sub, out)
				}
			}
		}
	}
	if seen != len(want) {
		t.Errorf("checked %d incidents, want %d", seen, len(want))
	}
}

// The brute-force burst must beat agnts's limit (20 failed logins a minute)
// and the scan its limit (10 probes).
func TestBurstSizes(t *testing.T) {
	gw, _ := serviceNamed("auth-gateway")
	if n := strings.Count(printed(gw, gw.incident("gw-1")), `"POST /auth/login HTTP/1.1" 401`); n < 21 {
		t.Errorf("gw-1 sends %d failed logins, want more than 20", n)
	}
	if n := strings.Count(printed(gw, gw.incident("scan")), `HTTP/1.1" 404`); n < 11 {
		t.Errorf("scan sends %d probes, want more than 10", n)
	}
}

// With DEMO_BUGGY_REPOS (the repositories with their planted bugs) and
// DEMO_FIXED_REPOS (the same after their fixes), every bug check must see
// its bug in the first and, for the bugs listed, not in the second.
func TestBugChecksOnRealCode(t *testing.T) {
	buggy, fixed := os.Getenv("DEMO_BUGGY_REPOS"), os.Getenv("DEMO_FIXED_REPOS")
	if buggy == "" {
		t.Skip("DEMO_BUGGY_REPOS is not set")
	}
	fixedNow := map[string]bool{"api-2": true, "api-4": true, "bw-1": true, "bw-2": true, "bw-3": true, "gw-1": true}
	read := func(root string, b *bug) string {
		src, err := os.ReadFile(filepath.Join(root, b.repo, b.file))
		if err != nil {
			t.Fatalf("%s/%s: %v", b.repo, b.file, err)
		}
		return string(src)
	}
	for _, s := range services(t) {
		for _, in := range s.incidents {
			if in.bug == nil {
				continue
			}
			if !in.bug.in(read(buggy, in.bug)) {
				t.Errorf("%s: bug not found in %s/%s with the bugs in place", in.id, in.bug.repo, in.bug.file)
			}
			if fixed != "" && fixedNow[in.id] && in.bug.in(read(fixed, in.bug)) {
				t.Errorf("%s: bug still found in %s/%s after its fix", in.id, in.bug.repo, in.bug.file)
			}
		}
	}
}
