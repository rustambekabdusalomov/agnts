package google

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestVerify(t *testing.T) {
	now := time.Date(2026, 10, 8, 12, 0, 0, 0, time.UTC)
	exp := now.Add(time.Hour).Unix()
	valid := map[string]string{
		"iss": "https://accounts.google.com", "aud": "client-1", "sub": "1234", "email": "dev@gmail.com",
		"email_verified": "true", "name": "Dev Person", "exp": jsonNum(exp),
	}
	tokens := map[string]map[string]string{
		"good":       valid,
		"other-app":  with(valid, "aud", "client-2"),
		"ios-app":    with(valid, "aud", "client-ios"),
		"other-iss":  with(valid, "iss", "evil.example.com"),
		"unverified": with(valid, "email_verified", "false"),
		"expired":    with(valid, "exp", jsonNum(now.Add(-time.Minute).Unix())),
	}
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		c, ok := tokens[r.URL.Query().Get("id_token")]
		if !ok {
			http.Error(w, `{"error":"invalid_token"}`, http.StatusBadRequest)
			return
		}
		_ = json.NewEncoder(w).Encode(c)
	}))
	defer srv.Close()
	v := New("client-1", "client-ios")
	v.Endpoint, v.Now = srv.URL, func() time.Time { return now }

	id, err := v.Verify(context.Background(), "good")
	if err != nil || id != (Identity{Subject: "1234", Email: "dev@gmail.com", Name: "Dev Person"}) {
		t.Fatalf("good token: %+v %v", id, err)
	}
	// The mobile app's own client counts too.
	if _, err := v.Verify(context.Background(), "ios-app"); err != nil {
		t.Fatalf("app client: %v", err)
	}
	for _, tok := range []string{"", "forged", "other-app", "other-iss", "unverified", "expired"} {
		if _, err := v.Verify(context.Background(), tok); !errors.Is(err, ErrInvalid) {
			t.Errorf("%q: got %v, want ErrInvalid", tok, err)
		}
	}
}

func with(m map[string]string, k, v string) map[string]string {
	out := map[string]string{}
	for kk, vv := range m {
		out[kk] = vv
	}
	out[k] = v
	return out
}

func jsonNum(n int64) string {
	b, _ := json.Marshal(n)
	return string(b)
}
