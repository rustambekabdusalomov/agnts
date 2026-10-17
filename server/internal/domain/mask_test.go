package domain

import (
	"encoding/json"
	"strings"
	"testing"
)

func TestMaskCredentials(t *testing.T) {
	ghp := "ghp_" + strings.Repeat("a1B2", 9)
	for _, tc := range []struct{ in, gone, kept string }{
		{"token " + ghp + " end", ghp, "token "},
		{"Authorization: Bearer abcdefghijklmnopqrstuvwxyz012345", "abcdefghijklmnopqrstuvwxyz012345", "Bearer "},
		{"authorization: token abcdef0123456789", "abcdef0123456789", "authorization: token "},
		{"postgres://app:s3cretpass@db:5432/x", "s3cretpass", "postgres://app:"},
		{"key sk-ant-" + strings.Repeat("x", 30), "sk-ant-" + strings.Repeat("x", 30), "key "},
		{"-----BEGIN RSA PRIVATE KEY-----\nMIIEow\nabc\n-----END RSA PRIVATE KEY-----", "MIIEow", "PRIVATE KEY"},
		{"AKIAABCDEFGHIJKLMNOP is the id", "AKIAABCDEFGHIJKLMNOP", " is the id"},
	} {
		got := MaskCredentials(tc.in)
		if strings.Contains(got, tc.gone) || !strings.Contains(got, tc.kept) || !strings.Contains(got, Masked) {
			t.Errorf("MaskCredentials(%q) = %q", tc.in, got)
		}
	}
	if got := MaskCredentials("go test ./... passed in 3.2s"); got != "go test ./... passed in 3.2s" {
		t.Errorf("plain text changed: %q", got)
	}
}

// Masking runs over JSON lines: the result must stay valid JSON.
func TestMaskCredentialsKeepsJSONValid(t *testing.T) {
	b, _ := json.Marshal(map[string]string{"output": "curl -H \"Authorization: Bearer abcdefghijklmnopqrstuvwxyz0123\" https://x\n-----BEGIN PRIVATE KEY-----\nAAA\n-----END PRIVATE KEY-----"})
	got := MaskCredentials(string(b))
	var v map[string]string
	if err := json.Unmarshal([]byte(got), &v); err != nil {
		t.Fatalf("masked JSON is invalid: %v\n%s", err, got)
	}
	if strings.Contains(v["output"], "abcdefghijklmnop") || strings.Contains(v["output"], "AAA") {
		t.Fatalf("not masked: %q", v["output"])
	}
}

func TestNewSecretRedactor(t *testing.T) {
	r := NewSecretRedactor("sk-ant-oat01-abc/def+ghi", "short", "")
	got := r.String("CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-abc/def+ghi url=sk-ant-oat01-abc%2Fdef%2Bghi short")
	if strings.Contains(got, "abc/def") || strings.Contains(got, "abc%2Fdef") || !strings.Contains(got, "short") {
		t.Fatalf("redacted: %q", got)
	}
	if !NewSecretRedactor("", "1234567").Empty() {
		t.Fatal("values under 8 characters are masked")
	}
}
