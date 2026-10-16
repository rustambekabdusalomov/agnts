package domain

import "testing"

func TestBranchName(t *testing.T) {
	v := BranchVars{Prefix: "agnts/", Type: KindCode.BranchType(), Key: "PAY-42", Title: "Add login page (OAuth)!", User: "Jane.Doe"}
	for _, c := range []struct{ tmpl, want string }{
		{"", "agnts/PAY-42"},
		{"{prefix}{key}", "agnts/PAY-42"},
		{"{type}/{key}-{slug}", "feature/PAY-42-add-login-page-oauth"},
		{"{user}/{type}/{key}", "jane-doe/feature/PAY-42"},
		{"{prefix}{type}/{key}_{slug}", "agnts/feature/PAY-42_add-login-page-oauth"},
	} {
		if got := BranchName(c.tmpl, v); got != c.want {
			t.Errorf("BranchName(%q) = %q, want %q", c.tmpl, got, c.want)
		}
	}
	// Empty parts leave no stray separators; no user falls back to agnts.
	if got := BranchName("{type}/{key}-{slug}/{user}", BranchVars{Type: "feature", Key: "X-1", Title: "!!!"}); got != "feature/X-1/agnts" {
		t.Errorf("empty parts: %q", got)
	}
	// Characters git forbids are cleaned out.
	if got := BranchName("{prefix}..{key}.lock", BranchVars{Prefix: "a b~^:/", Key: "X-1"}); got != "a-b/X-1" {
		t.Errorf("clean: %q", got)
	}
}

func TestSlug(t *testing.T) {
	for _, c := range []struct{ in, want string }{
		{"Fix the  NULL avatar -- crash", "fix-the-null-avatar-crash"},
		{"Café crème", "cafe-creme"},
		{"Добавить вход", "dobavit-vxod"},
		{"Ёлка и йогурт", "yolka-i-yogurt"},
		{"Ўзбекча қўшиш", "ozbekcha-qoshish"},
		{"Bo‘lim qo'shish", "bolim-qoshish"},
		{"a very long title that keeps going well past the forty byte cap", "a-very-long-title-that-keeps-going-well"},
	} {
		if got := Slug(c.in, slugMax); got != c.want {
			t.Errorf("Slug(%q) = %q, want %q", c.in, got, c.want)
		}
	}
}

func TestValidateBranchTemplate(t *testing.T) {
	for _, ok := range []string{"", "{prefix}{key}", "{type}/{key}-{slug}", "{user}/{key}"} {
		if err := ValidateBranchTemplate(ok); err != nil {
			t.Errorf("%q: %v", ok, err)
		}
	}
	for _, bad := range []string{"{type}/{slug}", "{key}-{title}", "{key", "key}", "{key}}"} {
		if err := ValidateBranchTemplate(bad); err == nil {
			t.Errorf("%q: want an error", bad)
		}
	}
}
