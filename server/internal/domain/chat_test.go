package domain

import "testing"

func TestExplicitRefs(t *testing.T) {
	isTicket := func(k string) bool { return k == "PAY-214" }
	refs := ExplicitRefs("pay-214 broke UTF-8 again, see https://github.com/acme/api/pull/131 and the api repo (#9)", isTicket, []string{"api"})
	want := []string{"ticket:PAY-214", "pr:api#131", "pr:api#9", "repo:api"}
	if len(refs) != len(want) {
		t.Fatalf("refs %+v", refs)
	}
	for i, r := range refs {
		if r.Key() != want[i] || r.Source != RefExplicit {
			t.Fatalf("ref %d = %+v, want %s", i, r, want[i])
		}
	}
	if refs := ExplicitRefs("the rapid api_gateway", isTicket, []string{"api", "web"}); len(refs) != 0 {
		t.Fatalf("api inside a word: %+v", refs)
	}
}

func TestChatChannelName(t *testing.T) {
	for in, want := range map[string]string{"#Payments Team": "payments-team", " ops ": "ops"} {
		if got, ok := ChatChannelName(in); !ok || got != want {
			t.Errorf("ChatChannelName(%q) = %q %v", in, got, ok)
		}
	}
	for _, in := range []string{"", "#", "Ünïcode", "-x"} {
		if _, ok := ChatChannelName(in); ok {
			t.Errorf("ChatChannelName(%q) is valid", in)
		}
	}
}

func TestMentionsAgent(t *testing.T) {
	for in, want := range map[string]bool{"@agnts why?": true, "hey @AGNTS": true, "mail me@agnts.uz": false, "@agntsbot": false} {
		if MentionsAgent(in) != want {
			t.Errorf("MentionsAgent(%q) != %v", in, want)
		}
	}
}

func TestParseCitation(t *testing.T) {
	if typ, id, ok := ParseCitation("[pr:api#14]"); !ok || typ != "pr" || id != "api#14" {
		t.Fatal(typ, id, ok)
	}
	if _, _, ok := ParseCitation("msg:x"); ok {
		t.Fatal("msg ids are numbers")
	}
}
