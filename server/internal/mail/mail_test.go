package mail

import (
	"encoding/base64"
	"net/mail"
	"strings"
	"testing"
	"time"
)

func TestComposeAttachments(t *testing.T) {
	from, _ := mail.ParseAddress("agnts <noreply@agnts.uz>")
	to, _ := mail.ParseAddress("client@example.com")
	now := time.Unix(1_800_000_000, 0)
	plain := string(compose(from, to, Message{Subject: "Hello", Body: "line one\nline two"}, now))
	if !strings.Contains(plain, "Content-Type: text/plain; charset=utf-8") || !strings.Contains(plain, "line one\r\nline two") {
		t.Fatalf("plain:\n%s", plain)
	}
	ics := []byte(strings.Repeat("BEGIN:VCALENDAR\r\n", 10))
	out := string(compose(from, to, Message{Subject: "Planning", Body: "Join: https://x/m/abc",
		Attachments: []Attachment{{Name: "invite.ics", ContentType: "text/calendar; method=REQUEST; charset=utf-8", Data: ics}}}, now))
	for _, want := range []string{"multipart/mixed; boundary=", "Content-Type: text/calendar; method=REQUEST; charset=utf-8; name=\"invite.ics\"",
		"Content-Transfer-Encoding: base64", "Join: https://x/m/abc"} {
		if !strings.Contains(out, want) {
			t.Errorf("lacks %q:\n%s", want, out)
		}
	}
	// The attachment decodes back, lines at most 76 characters.
	part := out[strings.Index(out, "base64\r\n\r\n")+len("base64\r\n\r\n"):]
	part = part[:strings.Index(part, "\r\n--")]
	for _, l := range strings.Split(part, "\r\n") {
		if len(l) > 76 {
			t.Errorf("line of %d characters", len(l))
		}
	}
	dec, err := base64.StdEncoding.DecodeString(strings.ReplaceAll(part, "\r\n", ""))
	if err != nil || string(dec) != string(ics) {
		t.Errorf("decoded %q %v", dec, err)
	}
}
