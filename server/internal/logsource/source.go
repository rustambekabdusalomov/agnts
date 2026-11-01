package logsource

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Puller reads new log entries from a logging system.
type Puller interface {
	// Test checks the address, the credentials and the permissions, and
	// reads the newest entry to detect the field names.
	Test(ctx context.Context) (TestResult, error)
	// Discover lists the services the logs hold, for the user to pick.
	Discover(ctx context.Context) ([]domain.LogService, error)
	// Pull returns entries in [cur, now - Lag) that match the filter,
	// oldest first, at most limit per service, and the cursor to go on
	// from.
	Pull(ctx context.Context, svcs []domain.LogService, f Filter, cur domain.LogCursor, limit int) (Batch, error)
}

// Lag is how far behind now a read stops: entries a shipper sends a
// little late still land inside the next window.
const Lag = 5 * time.Second

// Filter is what the detectors may want, in the backends' forms.
type Filter struct {
	Regex string   // RE2, case-insensitive (Loki |~)
	Terms []string // literals (Elasticsearch, Graylog)
}

// DefaultFilter is the filter of the built-in detectors plus the
// workspace's patterns.
func DefaultFilter(patterns []domain.LogPattern) Filter {
	extra := make([]string, 0, len(patterns))
	for _, p := range patterns {
		extra = append(extra, p.Pattern)
	}
	return Filter{Regex: domain.LogFilterRegex(extra), Terms: domain.LogFilterTerms()}
}

// Batch is what one pull returned.
type Batch struct {
	Entries []domain.LogEntry
	Cursor  domain.LogCursor
	// More: a service hit the limit; the cursor stops at the last entry
	// read, and the caller may pull again at once.
	More bool
}

// TestResult is what Test found.
type TestResult struct {
	Version string           `json:"version"`
	Fields  domain.LogFields `json:"fields"`
	// Labels are the field or label names seen, to pick from.
	Labels []string `json:"labels"`
	// Sample is the newest entry, redacted.
	Sample string     `json:"sample"`
	Newest *time.Time `json:"newest,omitempty"`
}

// New returns the puller for a source.
func New(src domain.LogSource, c *Client) (Puller, error) {
	switch src.Kind {
	case domain.LogLoki:
		return &Loki{src: src, c: c}, nil
	case domain.LogElasticsearch, domain.LogOpenSearch:
		return &Elastic{src: src, c: c}, nil
	case domain.LogGraylog:
		return &Graylog{src: src, c: c}, nil
	case domain.LogDatadog:
		return &Datadog{src: src, c: c}, nil
	case domain.LogCloudWatch:
		return &CloudWatch{src: src, c: c}, nil
	case domain.LogSplunk:
		return &Splunk{src: src, c: c}, nil
	}
	return nil, fmt.Errorf("%s sources are not read by agnts", src.Kind)
}

// call sends a request to the source and returns the body of a 2xx
// answer.
func call(ctx context.Context, c *Client, a domain.LogAuth, method, path string, q url.Values, body any, hdr map[string]string) ([]byte, error) {
	u := *c.Base
	u.Path = strings.TrimRight(u.Path, "/") + path
	if q != nil {
		u.RawQuery = q.Encode()
	}
	var rd io.Reader
	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			return nil, err
		}
		rd = bytes.NewReader(b)
	}
	req, err := http.NewRequestWithContext(ctx, method, u.String(), rd)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/json")
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	for k, v := range hdr {
		req.Header.Set(k, v)
	}
	Auth(req, a)
	resp, err := c.HTTP.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	b, err := ReadBody(resp.Body)
	if err != nil {
		return nil, err
	}
	if resp.StatusCode/100 != 2 {
		return nil, &HTTPError{Status: resp.StatusCode, Body: strings.TrimSpace(string(b))}
	}
	return b, nil
}

// sampleOf is a short, redacted sample line.
func sampleOf(s string) string {
	s = domain.RedactLog(strings.TrimSpace(s))
	if r := []rune(s); len(r) > 400 {
		s = string(r[:399]) + "…"
	}
	return s
}

// keyOf identifies an entry for the cursor's de-duplication.
func keyOf(parts ...string) string {
	h := sha256.New()
	for _, p := range parts {
		h.Write([]byte(p))
		h.Write([]byte{0})
	}
	return hex.EncodeToString(h.Sum(nil))[:24]
}
