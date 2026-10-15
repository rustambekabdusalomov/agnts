package apiclient

import (
	"bytes"
	"context"
	"encoding/base64"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"sort"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Auth modes of a request.
const (
	AuthDefault = "default" // the test's credential
	AuthOmit    = "none"    // no credential (the "no token" cases)
	AuthWrong   = "wrong"   // a fixed invalid credential (the "wrong token" cases)
)

// wrongValue is the invalid credential "wrong" cases send.
const wrongValue = "agnts-invalid-credential-0000"

// Client sends a Swagger test's requests.
type Client struct {
	cfg    TestConfig
	cred   Credential
	base   *url.URL
	files  Files
	http   *http.Client
	redact domain.Redactor
	now    func() time.Time
	sleep  func(time.Duration)
	last   time.Time // when the last request went out (rate limit)
}

// Request is one request to send.
type Request struct {
	Case    string
	Method  string
	Path    string // relative to the base URL (an absolute URL must be on its host)
	Query   url.Values
	Headers map[string]string
	Body    []byte
	Auth    string // AuthDefault, AuthOmit or AuthWrong
}

// Response is what came back, with the logged exchange.
type Response struct {
	Exchange domain.APIExchange
	Header   http.Header
	Body     []byte // the whole body as read (up to MaxBody), redacted
}

// Refusal is a request agnts-api would not send, and why: the caller
// marks the case skipped or blocked, it is never an API failure.
type Refusal struct {
	Verdict domain.APIVerdict
	Reason  string
}

func (r *Refusal) Error() string { return r.Reason }

// New returns a client for the test. transport is nil in a run: requests
// go through the egress proxy in HTTPS_PROXY.
func New(cfg TestConfig, cred Credential, files Files, transport http.RoundTripper) (*Client, error) {
	base, err := domain.ParseBaseURL(cfg.BaseURL)
	if err != nil {
		return nil, err
	}
	if transport == nil {
		transport = &http.Transport{Proxy: http.ProxyFromEnvironment, TLSHandshakeTimeout: 15 * time.Second,
			ResponseHeaderTimeout: 60 * time.Second, MaxIdleConns: 4}
	}
	c := &Client{cfg: cfg, cred: cred, base: base, files: files, redact: domain.NewRedactor(cred.Kind, cred.Value),
		now: time.Now, sleep: time.Sleep}
	c.http = &http.Client{Transport: transport, Timeout: 90 * time.Second, CheckRedirect: c.checkRedirect}
	return c, nil
}

// checkRedirect follows redirects on the base URL's host only: anything
// else would carry the credential, or the test, somewhere else.
func (c *Client) checkRedirect(req *http.Request, via []*http.Request) error {
	if len(via) >= 5 {
		return errors.New("stopped after 5 redirects")
	}
	if !c.sameHost(req.URL) {
		return fmt.Errorf("not following a redirect to %s: only %s is tested", req.URL.Host, c.base.Host)
	}
	return nil
}

func (c *Client) sameHost(u *url.URL) bool {
	h1, p1 := domain.HostPort(u)
	h2, p2 := domain.HostPort(c.base)
	return h1 == h2 && p1 == p2
}

// URL joins path with the base URL; an absolute URL must be on the base
// URL's host and port.
func (c *Client) URL(p string, q url.Values) (*url.URL, error) {
	var u *url.URL
	if strings.HasPrefix(p, "http://") || strings.HasPrefix(p, "https://") {
		x, err := url.Parse(p)
		if err != nil {
			return nil, err
		}
		if !c.sameHost(x) || x.Scheme != c.base.Scheme {
			return nil, &Refusal{domain.VerdictSkipped, fmt.Sprintf("agnts-api only calls %s://%s, the test's base URL", c.base.Scheme, c.base.Host)}
		}
		u = x
	} else {
		if !strings.HasPrefix(p, "/") {
			p = "/" + p
		}
		rel, err := url.Parse(p)
		if err != nil {
			return nil, err
		}
		if rel.Host != "" || rel.Scheme != "" {
			return nil, &Refusal{domain.VerdictSkipped, "give a path, not another host"}
		}
		u = &url.URL{Scheme: c.base.Scheme, Host: c.base.Host, Path: c.base.Path + rel.Path, RawQuery: rel.RawQuery}
		if rel.RawPath != "" {
			u.RawPath = c.base.EscapedPath() + rel.RawPath
		}
	}
	if len(q) > 0 {
		v := u.Query()
		for k, vs := range q {
			for _, x := range vs {
				v.Add(k, x)
			}
		}
		u.RawQuery = v.Encode()
	}
	return u, nil
}

// counters reads the log: requests sent, and sent without or with a wrong
// credential.
func (c *Client) counters() (sent, authFailures int, nextID string) {
	log := readLog(c.files.Log)
	for _, e := range log {
		if e.Auth == AuthOmit || e.Auth == AuthWrong {
			authFailures++
		}
	}
	return len(log), authFailures, fmt.Sprintf("r-%03d", len(log)+1)
}

// authProbe reports whether a request tests auth handling: one without the
// credential, or with a wrong one, against an API that has one.
func (c *Client) authProbe(mode string) bool {
	return c.cred.Kind != domain.AuthNone && c.cred.Kind != "" && (mode == AuthOmit || mode == AuthWrong)
}

// Check refuses what may not be sent: a write in a read-only test, more
// requests than the run may send, more auth-failure requests than the cap.
func (c *Client) Check(method, mode string) error {
	if !c.cfg.WriteEnabled && !domain.ReadOnlyMethod(method) {
		return &Refusal{domain.VerdictSkipped, "write requests are off for this test (only GET, HEAD and OPTIONS are sent)"}
	}
	sent, failures, _ := c.counters()
	budget := c.cfg.MaxRequests
	if budget <= 0 {
		budget = domain.DefaultAPIMaxRequests
	}
	if sent >= budget {
		return &Refusal{domain.VerdictSkipped, fmt.Sprintf("request cap: this run may send at most %d requests", budget)}
	}
	if c.authProbe(mode) && failures >= domain.MaxAuthFailures {
		return &Refusal{domain.VerdictSkipped, fmt.Sprintf("auth-failure cap: at most %d requests without or with a wrong credential per run, to avoid locking the account or tripping a firewall", domain.MaxAuthFailures)}
	}
	return nil
}

// Do sends one request and logs it.
func (c *Client) Do(ctx context.Context, r Request) (Response, error) {
	if r.Auth == "" {
		r.Auth = AuthDefault
	}
	if r.Auth != AuthDefault && r.Auth != AuthOmit && r.Auth != AuthWrong {
		return Response{}, fmt.Errorf("auth is %s, %s or %s", AuthDefault, AuthOmit, AuthWrong)
	}
	method := strings.ToUpper(r.Method)
	unlock := lockLog(c.files.Log)
	defer unlock()
	if err := c.Check(method, r.Auth); err != nil {
		return Response{}, err
	}
	q := url.Values{}
	for k, v := range r.Query {
		q[k] = v
	}
	if r.Auth != AuthOmit && c.cred.Kind == domain.AuthQuery {
		q.Set(c.cred.Name, c.value(r.Auth))
	}
	u, err := c.URL(r.Path, q)
	if err != nil {
		return Response{}, err
	}
	var body io.Reader
	if r.Body != nil {
		body = bytes.NewReader(r.Body)
	}
	req, err := http.NewRequestWithContext(ctx, method, u.String(), body)
	if err != nil {
		return Response{}, err
	}
	req.Header.Set("User-Agent", "agnts-api (Swagger test)")
	req.Header.Set("Accept", "application/json, */*;q=0.5")
	if r.Body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	for k, v := range r.Headers {
		if strings.EqualFold(k, "Host") || strings.EqualFold(k, "Authorization") && c.cred.Kind != domain.AuthNone {
			continue
		}
		req.Header.Set(k, v)
	}
	if r.Auth != AuthOmit && c.cred.Kind != domain.AuthQuery {
		SetAuth(req, Credential{Kind: c.cred.Kind, Name: c.cred.Name, Value: c.value(r.Auth)})
	}

	c.pace()
	_, _, id := c.counters()
	start := c.now()
	ex := domain.APIExchange{ID: id, Case: r.Case, Auth: r.Auth, Method: method, URL: u.String(), ReqHeaders: flat(req.Header),
		ReqBody: clipBody(r.Body), At: start.UTC()}
	resp, err := c.http.Do(req)
	c.last = c.now()
	var out Response
	if err != nil {
		ex.Error = err.Error()
	} else {
		b, rerr := io.ReadAll(io.LimitReader(resp.Body, MaxBody+1))
		_ = resp.Body.Close()
		if len(b) > MaxBody {
			b, ex.Truncated = b[:MaxBody], true
		}
		if rerr != nil {
			ex.Error = "reading the body: " + rerr.Error()
		}
		ex.Status = resp.StatusCode
		ex.RespHeaders = flat(resp.Header)
		ex.RespBody = string(b)
		out.Header = resp.Header
	}
	ex.MS = c.now().Sub(start).Milliseconds()
	ex = c.redact.Exchange(ex, c.headerName())
	out.Exchange = ex
	out.Body = []byte(ex.RespBody)
	if lerr := appendLog(c.files.Log, ex); lerr != nil {
		return out, fmt.Errorf("log the request: %w", lerr)
	}
	return out, nil
}

// SetAuth adds a credential to a request: a header, or a query parameter.
func SetAuth(req *http.Request, cred Credential) {
	switch cred.Kind {
	case domain.AuthBearer:
		v := cred.Value
		if !strings.HasPrefix(v, "Bearer ") {
			v = "Bearer " + v
		}
		req.Header.Set("Authorization", v)
	case domain.AuthHeader:
		req.Header.Set(cred.Name, cred.Value)
	case domain.AuthBasic:
		req.Header.Set("Authorization", "Basic "+base64.StdEncoding.EncodeToString([]byte(domain.BasicCredentials(cred.Value))))
	case domain.AuthQuery:
		q := req.URL.Query()
		q.Set(cred.Name, cred.Value)
		req.URL.RawQuery = q.Encode()
	}
}

func (c *Client) headerName() string {
	if c.cred.Kind == domain.AuthHeader {
		return c.cred.Name
	}
	return ""
}

func (c *Client) value(mode string) string {
	if mode == AuthWrong {
		if c.cred.Kind == domain.AuthBasic {
			return "agnts:" + wrongValue
		}
		return wrongValue
	}
	return c.cred.Value
}

// pace keeps to the test's requests per second.
func (c *Client) pace() {
	rate := c.cfg.Rate
	if rate <= 0 {
		rate = domain.DefaultAPIRate
	}
	gap := time.Second / time.Duration(rate)
	if c.last.IsZero() {
		// Another agnts-api call may have just sent one.
		if log := readLog(c.files.Log); len(log) > 0 {
			c.last = log[len(log)-1].At.Add(time.Duration(log[len(log)-1].MS) * time.Millisecond)
		}
	}
	if wait := gap - c.now().Sub(c.last); wait > 0 && wait <= gap {
		c.sleep(wait)
	}
}

func flat(h http.Header) map[string]string {
	if len(h) == 0 {
		return nil
	}
	out := make(map[string]string, len(h))
	keys := make([]string, 0, len(h))
	for k := range h {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	for _, k := range keys {
		out[k] = strings.Join(h[k], ", ")
	}
	return out
}

func clipBody(b []byte) string {
	if len(b) > MaxBody {
		return string(b[:MaxBody])
	}
	return string(b)
}

// writeFile writes an output file agnts reads after the run.
func writeFile(p string, b []byte) error {
	return os.WriteFile(p, b, 0o600)
}
