// Package google verifies the ID tokens that "Sign in with Google" (Google
// Identity Services) hands to the website.
package google

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"slices"
	"strconv"
	"strings"
	"time"
)

// TokenInfoURL is Google's endpoint that checks an ID token's signature and
// expiry and returns its claims.
const TokenInfoURL = "https://oauth2.googleapis.com/tokeninfo" //nolint:gosec // G101: a public endpoint, not a credential

// ErrInvalid means the token is not a valid sign-in for this app.
var ErrInvalid = errors.New("google: invalid ID token")

// Identity is the person a valid ID token names.
type Identity struct {
	Subject string // Google's stable account id
	Email   string // verified by Google
	Name    string
}

// Verifier checks ID tokens issued for the app's OAuth clients.
type Verifier struct {
	ClientID string
	// Also are more clients whose tokens count: the mobile app's.
	Also []string
	// Endpoint is TokenInfoURL; tests point it at a fake.
	Endpoint string
	HTTP     *http.Client
	Now      func() time.Time
}

// New returns a Verifier for the OAuth client clientID and, optionally, more
// clients of the same app.
func New(clientID string, also ...string) *Verifier {
	return &Verifier{ClientID: clientID, Also: also, Endpoint: TokenInfoURL, HTTP: &http.Client{Timeout: 10 * time.Second}, Now: time.Now}
}

// claims are the tokeninfo fields agnts reads. Google returns booleans and
// numbers as strings here.
type claims struct {
	Iss           string `json:"iss"`
	Aud           string `json:"aud"`
	Sub           string `json:"sub"`
	Email         string `json:"email"`
	EmailVerified string `json:"email_verified"`
	Name          string `json:"name"`
	Exp           string `json:"exp"`
}

// Verify returns the identity in token, or ErrInvalid when Google rejects
// it, it was issued for another app, it expired or its email is not
// verified.
func (v *Verifier) Verify(ctx context.Context, token string) (Identity, error) {
	if token == "" || len(token) > 4096 {
		return Identity{}, ErrInvalid
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, v.Endpoint+"?id_token="+url.QueryEscape(token), nil)
	if err != nil {
		return Identity{}, err
	}
	resp, err := v.HTTP.Do(req)
	if err != nil {
		return Identity{}, fmt.Errorf("google: tokeninfo: %w", err)
	}
	defer func() { _ = resp.Body.Close() }()
	switch {
	case resp.StatusCode == http.StatusBadRequest:
		return Identity{}, ErrInvalid // malformed, badly signed or expired
	case resp.StatusCode != http.StatusOK:
		return Identity{}, fmt.Errorf("google: tokeninfo answered %s", resp.Status)
	}
	var c claims
	if err := json.NewDecoder(http.MaxBytesReader(nil, resp.Body, 64<<10)).Decode(&c); err != nil {
		return Identity{}, fmt.Errorf("google: tokeninfo: %w", err)
	}
	exp, err := strconv.ParseInt(c.Exp, 10, 64)
	switch {
	case c.Aud != v.ClientID && !slices.Contains(v.Also, c.Aud),
		c.Iss != "accounts.google.com" && c.Iss != "https://accounts.google.com",
		c.Sub == "" || c.Email == "" || c.EmailVerified != "true",
		err != nil || !v.Now().Before(time.Unix(exp, 0)):
		return Identity{}, ErrInvalid
	}
	return Identity{Subject: c.Sub, Email: strings.TrimSpace(c.Email), Name: strings.TrimSpace(c.Name)}, nil
}
