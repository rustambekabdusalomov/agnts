// Package notify sends push notifications (Firebase Cloud Messaging) and
// runs the Telegram bot, both driven by the event log.
package notify

import (
	"bytes"
	"context"
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"sync"
	"time"
)

// FCM sends messages with the FCM HTTP v1 API using a service account.
type FCM struct {
	projectID   string
	clientEmail string
	tokenURI    string
	key         *rsa.PrivateKey
	api         string
	hc          *http.Client

	mu     sync.Mutex
	access string
	exp    time.Time
}

// LoadFCM reads a Firebase service account JSON file.
func LoadFCM(path string) (*FCM, error) {
	b, err := os.ReadFile(path) //nolint:gosec // G304: path comes from AGNTS_FCM_CREDENTIALS
	if err != nil {
		return nil, err
	}
	var sa struct {
		ProjectID   string `json:"project_id"`
		ClientEmail string `json:"client_email"`
		PrivateKey  string `json:"private_key"`
		TokenURI    string `json:"token_uri"`
	}
	if err := json.Unmarshal(b, &sa); err != nil {
		return nil, fmt.Errorf("fcm credentials: %w", err)
	}
	block, _ := pem.Decode([]byte(sa.PrivateKey))
	if block == nil {
		return nil, errors.New("fcm credentials: no private key")
	}
	k, err := x509.ParsePKCS8PrivateKey(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("fcm credentials: %w", err)
	}
	rk, ok := k.(*rsa.PrivateKey)
	if !ok {
		return nil, errors.New("fcm credentials: private key is not RSA")
	}
	if sa.TokenURI == "" {
		sa.TokenURI = "https://oauth2.googleapis.com/token"
	}
	return &FCM{projectID: sa.ProjectID, clientEmail: sa.ClientEmail, tokenURI: sa.TokenURI, key: rk,
		api: "https://fcm.googleapis.com", hc: &http.Client{Timeout: 20 * time.Second}}, nil
}

// accessToken returns a cached OAuth token, minting one from a signed JWT.
func (f *FCM) accessToken(ctx context.Context) (string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.access != "" && time.Until(f.exp) > time.Minute {
		return f.access, nil
	}
	now := time.Now()
	enc := base64.RawURLEncoding
	head := enc.EncodeToString([]byte(`{"alg":"RS256","typ":"JWT"}`))
	claims, _ := json.Marshal(map[string]any{
		"iss": f.clientEmail, "scope": "https://www.googleapis.com/auth/firebase.messaging",
		"aud": f.tokenURI, "iat": now.Unix(), "exp": now.Add(time.Hour).Unix(),
	})
	unsigned := head + "." + enc.EncodeToString(claims)
	sum := sha256.Sum256([]byte(unsigned))
	sig, err := rsa.SignPKCS1v15(rand.Reader, f.key, crypto.SHA256, sum[:])
	if err != nil {
		return "", err
	}
	form := url.Values{"grant_type": {"urn:ietf:params:oauth:grant-type:jwt-bearer"}, "assertion": {unsigned + "." + enc.EncodeToString(sig)}}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, f.tokenURI, strings.NewReader(form.Encode()))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	resp, err := f.hc.Do(req)
	if err != nil {
		return "", err
	}
	defer func() { _ = resp.Body.Close() }()
	var tok struct {
		AccessToken string `json:"access_token"`
		ExpiresIn   int    `json:"expires_in"`
	}
	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 2048))
		return "", fmt.Errorf("fcm token: %s: %s", resp.Status, b)
	}
	if err := json.NewDecoder(resp.Body).Decode(&tok); err != nil {
		return "", err
	}
	f.access, f.exp = tok.AccessToken, now.Add(time.Duration(tok.ExpiresIn)*time.Second)
	return f.access, nil
}

// Push is one notification.
type Push struct {
	Title  string
	Body   string
	Ticket string // deep link target
	Route  string // app route to open instead of the ticket, if set
}

// ErrUnregistered means the device token is no longer valid.
var ErrUnregistered = errors.New("device token is no longer registered")

// Send delivers a notification to one device token.
func (f *FCM) Send(ctx context.Context, token string, p Push) error {
	access, err := f.accessToken(ctx)
	if err != nil {
		return err
	}
	route := p.Route
	if route == "" {
		route = "/tickets/" + p.Ticket
	}
	msg := map[string]any{"message": map[string]any{
		"token":        token,
		"notification": map[string]string{"title": p.Title, "body": p.Body},
		"data":         map[string]string{"ticket": p.Ticket, "route": route},
		"android":      map[string]any{"priority": "high", "notification": map[string]string{"channel_id": "agnts"}},
		"apns":         map[string]any{"payload": map[string]any{"aps": map[string]any{"sound": "default"}}},
	}}
	b, _ := json.Marshal(msg)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost,
		f.api+"/v1/projects/"+url.PathEscape(f.projectID)+"/messages:send", bytes.NewReader(b))
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+access)
	req.Header.Set("Content-Type", "application/json")
	resp, err := f.hc.Do(req)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode == http.StatusOK {
		return nil
	}
	body, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
	if resp.StatusCode == http.StatusNotFound || strings.Contains(string(body), "UNREGISTERED") {
		return ErrUnregistered
	}
	return fmt.Errorf("fcm send: %s: %s", resp.Status, body)
}
