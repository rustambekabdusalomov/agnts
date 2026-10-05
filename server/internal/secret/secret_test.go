package secret

import (
	"bytes"
	"testing"
)

func TestPasswordRoundTrip(t *testing.T) {
	h, err := HashPassword("correct horse")
	if err != nil {
		t.Fatal(err)
	}
	if ok, err := VerifyPassword(h, "correct horse"); err != nil || !ok {
		t.Fatalf("valid password rejected: ok=%v err=%v", ok, err)
	}
	if ok, _ := VerifyPassword(h, "wrong horse"); ok {
		t.Fatal("wrong password accepted")
	}
	if _, err := VerifyPassword("$bcrypt$x", "x"); err == nil {
		t.Fatal("expected error for unknown hash format")
	}
}

func TestBox(t *testing.T) {
	box, err := NewBox(bytes.Repeat([]byte{7}, 32))
	if err != nil {
		t.Fatal(err)
	}
	ct, err := box.Seal([]byte("ghp_token"), []byte("integration:github"))
	if err != nil {
		t.Fatal(err)
	}
	pt, err := box.Open(ct, []byte("integration:github"))
	if err != nil || string(pt) != "ghp_token" {
		t.Fatalf("round trip failed: %q %v", pt, err)
	}
	if _, err := box.Open(ct, []byte("integration:jira")); err == nil {
		t.Fatal("ciphertext opened with a different aad")
	}
	ct[len(ct)-1] ^= 1
	if _, err := box.Open(ct, []byte("integration:github")); err == nil {
		t.Fatal("tampered ciphertext opened")
	}
}

func TestToken(t *testing.T) {
	a, _ := NewToken()
	b, _ := NewToken()
	if a == b || len(a) != 43 {
		t.Fatalf("tokens not unique or wrong length: %q %q", a, b)
	}
	if !bytes.Equal(HashToken(a), HashToken(a)) || bytes.Equal(HashToken(a), HashToken(b)) {
		t.Fatal("hash not deterministic or collides")
	}
}
