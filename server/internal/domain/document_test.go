package domain

import (
	"errors"
	"strings"
	"testing"
	"time"
)

func TestEffectiveAccess(t *testing.T) {
	const owner, wsOwner, alice = 1, 2, 3
	doc := func(ws AccessLevel) Document { return Document{OwnerID: owner, WorkspaceAccess: ws} }
	cases := []struct {
		name  string
		d     Document
		user  int64
		role  WorkspaceRole
		grant AccessLevel
		want  AccessLevel
	}{
		{"document owner", doc(AccessNone), owner, RoleUser, AccessNone, AccessOwner},
		{"document owner who is a viewer", doc(AccessNone), owner, RoleViewer, AccessNone, AccessOwner},
		{"workspace owner", doc(AccessNone), wsOwner, RoleOwner, AccessNone, AccessOwner},
		{"no grant, no default", doc(AccessNone), alice, RoleUser, AccessNone, AccessNone},
		{"view grant", doc(AccessNone), alice, RoleUser, AccessView, AccessView},
		{"edit grant", doc(AccessNone), alice, RoleUser, AccessEdit, AccessEdit},
		{"workspace default view", doc(AccessView), alice, RoleUser, AccessNone, AccessView},
		{"higher of grant and default", doc(AccessEdit), alice, RoleUser, AccessView, AccessEdit},
		{"higher of grant and default, other way", doc(AccessView), alice, RoleUser, AccessEdit, AccessEdit},
		{"viewer capped at view", doc(AccessNone), alice, RoleViewer, AccessEdit, AccessView},
		{"viewer capped, default edit", doc(AccessEdit), alice, RoleViewer, AccessNone, AccessView},
		{"viewer without access", doc(AccessNone), alice, RoleViewer, AccessNone, AccessNone},
		{"not a member", doc(AccessEdit), alice, "", AccessEdit, AccessNone},
		{"removed owner is not a member", doc(AccessNone), owner, "", AccessNone, AccessNone},
		{"a grant never reaches owner", doc(AccessNone), alice, RoleUser, AccessOwner, AccessEdit},
	}
	for _, c := range cases {
		if got := EffectiveAccess(c.d, c.user, c.role, c.grant); got != c.want {
			t.Errorf("%s: got %s, want %s", c.name, got, c.want)
		}
	}
}

func TestAccessLevelNames(t *testing.T) {
	for _, l := range []AccessLevel{AccessNone, AccessView, AccessEdit, AccessOwner} {
		if got, ok := ParseAccessLevel(l.String()); !ok || got != l {
			t.Errorf("%s does not round-trip", l)
		}
	}
	if _, ok := ParseAccessLevel("admin"); ok {
		t.Error("unknown level parsed")
	}
	if AccessOwner.Grantable() || AccessNone.Grantable() || !AccessEdit.Grantable() {
		t.Error("grantable levels are view and edit")
	}
}

func TestDocumentSourceValidate(t *testing.T) {
	from := time.Date(2026, 10, 1, 0, 0, 0, 0, time.UTC)
	to := from.AddDate(0, 0, 7)
	long := from.AddDate(2, 0, 0)
	cases := []struct {
		name string
		s    DocumentSource
		ok   bool
	}{
		{"report", DocumentSource{Kind: SourceReport, TicketKeys: []string{"A-1"}}, true},
		{"report without ticket", DocumentSource{Kind: SourceReport}, false},
		{"report with two", DocumentSource{Kind: SourceReport, TicketKeys: []string{"A-1", "A-2"}}, false},
		{"tickets chosen", DocumentSource{Kind: SourceTickets, TicketKeys: []string{"A-1", "A-2"}}, true},
		{"tickets by filter", DocumentSource{Kind: SourceTickets, Filter: &TicketFilter{States: []TicketState{StateDone}}}, true},
		{"tickets, bad state", DocumentSource{Kind: SourceTickets, Filter: &TicketFilter{States: []TicketState{"nope"}}}, false},
		{"tickets, nothing", DocumentSource{Kind: SourceTickets}, false},
		{"commits", DocumentSource{Kind: SourceCommits, RepoIDs: []int64{1}, From: &from, To: &to}, true},
		{"commits without start", DocumentSource{Kind: SourceCommits, RepoIDs: []int64{1}}, false},
		{"commits without repo", DocumentSource{Kind: SourceCommits, From: &from}, false},
		{"period backwards", DocumentSource{Kind: SourceCommits, RepoIDs: []int64{1}, From: &to, To: &from}, false},
		{"period too long", DocumentSource{Kind: SourceCommits, RepoIDs: []int64{1}, From: &from, To: &long}, false},
		{"pulls", DocumentSource{Kind: SourcePulls, RepoIDs: []int64{1}}, true},
		{"pulls by number, one repo", DocumentSource{Kind: SourcePulls, RepoIDs: []int64{1}, PRNumbers: []int{4, 5}}, true},
		{"pulls by number, two repos", DocumentSource{Kind: SourcePulls, RepoIDs: []int64{1, 2}, PRNumbers: []int{4}}, false},
		{"pulls, bad state", DocumentSource{Kind: SourcePulls, RepoIDs: []int64{1}, PRState: "closed"}, false},
		{"repo", DocumentSource{Kind: SourceRepo, RepoIDs: []int64{1}}, true},
		{"repo, two", DocumentSource{Kind: SourceRepo, RepoIDs: []int64{1, 2}}, false},
		{"blank template needs instruction", DocumentSource{Kind: SourceRepo, RepoIDs: []int64{1}, Template: TemplateBlank}, false},
		{"blank template with instruction", DocumentSource{Kind: SourceRepo, RepoIDs: []int64{1}, Template: TemplateBlank, Instruction: "list the TODOs"}, true},
		{"unknown template", DocumentSource{Kind: SourceRepo, RepoIDs: []int64{1}, Template: "poem"}, false},
		{"unknown kind", DocumentSource{Kind: "wiki"}, false},
		{"instruction too long", DocumentSource{Kind: SourceRepo, RepoIDs: []int64{1}, Instruction: strings.Repeat("x", DocMaxInstruction+1)}, false},
	}
	for _, c := range cases {
		err := c.s.Validate()
		if (err == nil) != c.ok {
			t.Errorf("%s: err %v, want ok=%v", c.name, err, c.ok)
		}
		if err != nil && !errors.Is(err, ErrDocInvalid) {
			t.Errorf("%s: error does not wrap ErrDocInvalid: %v", c.name, err)
		}
	}
	s := DocumentSource{Kind: SourcePulls, RepoIDs: []int64{1}}
	_ = s.Validate()
	if s.Template != TemplatePullReview || s.PRState != "merged" {
		t.Errorf("defaults: %+v", s)
	}
	s = DocumentSource{Kind: SourceTickets, TicketKeys: []string{" A-1 ", "A-1", "", "A-2"}}
	_ = s.Validate()
	if strings.Join(s.TicketKeys, ",") != "A-1,A-2" {
		t.Errorf("keys not cleaned: %v", s.TicketKeys)
	}
}

func TestCleanDocumentTitleAndBody(t *testing.T) {
	if got, err := CleanDocumentTitle("  Sprint   42 \n report "); err != nil || got != "Sprint 42 report" {
		t.Errorf("title: %q %v", got, err)
	}
	if _, err := CleanDocumentTitle("   "); err == nil {
		t.Error("empty title accepted")
	}
	if _, err := CleanDocumentTitle(strings.Repeat("я", DocMaxTitle+1)); err == nil {
		t.Error("long title accepted")
	}
	if got, _ := CleanDocumentBody("a\r\nb\rc"); got != "a\nb\nc" {
		t.Errorf("line endings: %q", got)
	}
	if _, err := CleanDocumentBody(strings.Repeat("x", DocMaxBody+1)); err == nil {
		t.Error("large body accepted")
	}
	if _, err := CleanDocumentBody(string([]byte{0xff, 0xfe})); err == nil {
		t.Error("invalid UTF-8 accepted")
	}
}

func TestPublicToken(t *testing.T) {
	a, err := NewPublicToken()
	if err != nil {
		t.Fatal(err)
	}
	b, _ := NewPublicToken()
	if a == b || !ValidPublicToken(a) || len(a) < 40 {
		t.Errorf("tokens %q %q", a, b)
	}
	for _, bad := range []string{"", "short", strings.Repeat("a", 65), "abc/def" + strings.Repeat("a", 20), "../../" + strings.Repeat("a", 20)} {
		if ValidPublicToken(bad) {
			t.Errorf("%q accepted", bad)
		}
	}
}

func TestScanSecrets(t *testing.T) {
	body := strings.Join([]string{
		"# Deploy notes",
		"The key is AKIAIOSFODNN7EXAMPLE for the bucket.",
		"Token: ghp_abcdefghijklmnopqrstuvwxyz0123456789",
		"DATABASE_URL=postgres://app:s3cretpass@db:5432/app",
		"Nothing here.",
		"-----BEGIN RSA PRIVATE KEY-----",
		"MIIEowIBAAKCAQEAx",
		"-----END RSA PRIVATE KEY-----",
		"Plain line with my-workspace-secret-value inside.",
	}, "\n")
	got := ScanSecrets(body, NewSecretRedactor("my-workspace-secret-value"))
	var lines []int
	for _, f := range got {
		lines = append(lines, f.Line)
		if strings.Contains(f.Excerpt, "AKIAIOSFODNN7EXAMPLE") || strings.Contains(f.Excerpt, "s3cretpass") || strings.Contains(f.Excerpt, "my-workspace-secret-value") {
			t.Errorf("excerpt shows the secret: %q", f.Excerpt)
		}
	}
	want := []int{2, 3, 4, 6, 7, 8, 9}
	if len(lines) != len(want) {
		t.Fatalf("lines %v, want %v", lines, want)
	}
	for i := range want {
		if lines[i] != want[i] {
			t.Fatalf("lines %v, want %v", lines, want)
		}
	}
	if f := ScanSecrets("# Status\n\nAll good, see AMANAT-12 and abc1234.", Redactor{}); len(f) != 0 {
		t.Errorf("clean text flagged: %+v", f)
	}
}

func TestDownloadName(t *testing.T) {
	cases := []struct{ title, want string }{
		{"Sprint 42 status report", "sprint-42-status-report-v7.md"},
		{"Отчёт по спринту", "otchyot-po-sprintu-v7.md"},
		{"Oʻzbekiston: gʻalaba hisoboti", "ozbekiston-galaba-hisoboti-v7.md"},
		{"Ўзбек тили қоидалари", "ozbek-tili-qoidalari-v7.md"},
		{"Café — résumé!", "cafe-resume-v7.md"},
		{"日本語", "document-9-v7.md"},
		{"!!!", "document-9-v7.md"},
	}
	for _, c := range cases {
		if got := DownloadName(c.title, 9, 7, "md"); got != c.want {
			t.Errorf("%q: got %q, want %q", c.title, got, c.want)
		}
	}
	if got := DownloadName(strings.Repeat("word ", 40), 1, 1, "pdf"); len(got) > 90 || !strings.HasSuffix(got, "-v1.pdf") || strings.Contains(got, "--") {
		t.Errorf("long title: %q", got)
	}
}

func TestMarkdownFile(t *testing.T) {
	if got := MarkdownFile("Report", "Body text\r\n"); got != "# Report\n\nBody text\n" {
		t.Errorf("heading added: %q", got)
	}
	if got := MarkdownFile("Report", "# Report\n\nBody\n\n\n"); got != "# Report\n\nBody\n" {
		t.Errorf("heading kept: %q", got)
	}
	if got := MarkdownFile("Report", "## Report\nx"); !strings.HasPrefix(got, "# Report\n\n## Report") {
		t.Errorf("a second-level heading is not the title: %q", got)
	}
}
