package logsource

import (
	"bufio"
	"bytes"
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"sort"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
)

// ---------------------------------------------------------------------
// Datadog: Logs Search API v2. Auth: the API key as the token, the
// application key as the password.

// Datadog reads Datadog Logs.
type Datadog struct {
	src domain.LogSource
	c   *Client
	now func() time.Time
}

func (d *Datadog) clock() time.Time {
	if d.now != nil {
		return d.now()
	}
	return time.Now()
}

func (d *Datadog) headers() map[string]string {
	return map[string]string{"DD-API-KEY": d.src.Auth.Token, "DD-APPLICATION-KEY": d.src.Auth.Password}
}

func (d *Datadog) post(ctx context.Context, path string, body any) ([]byte, error) {
	return call(ctx, d.c, domain.LogAuth{Kind: "none"}, http.MethodPost, path, nil, body, d.headers())
}

type ddEvents struct {
	Data []struct {
		ID         string `json:"id"`
		Attributes struct {
			Timestamp  string         `json:"timestamp"`
			Message    string         `json:"message"`
			Service    string         `json:"service"`
			Status     string         `json:"status"`
			Host       string         `json:"host"`
			Attributes map[string]any `json:"attributes"`
		} `json:"attributes"`
	} `json:"data"`
}

// Test reads the newest log.
func (d *Datadog) Test(ctx context.Context) (TestResult, error) {
	out := TestResult{Version: "Datadog", Fields: domain.LogFields{Service: "service", Level: "status", Message: "message", Timestamp: "timestamp"}}
	b, err := d.post(ctx, "/api/v2/logs/events/search", map[string]any{"filter": map[string]any{"query": d.base("*"), "from": "now-6h", "to": "now"},
		"page": map[string]any{"limit": 1}, "sort": "-timestamp"})
	if err != nil {
		return out, err
	}
	var res ddEvents
	if err := json.Unmarshal(b, &res); err != nil {
		return out, fmt.Errorf("this doesn't look like Datadog: %s", sampleOf(string(b)))
	}
	if len(res.Data) > 0 {
		out.Sample = sampleOf(res.Data[0].Attributes.Message)
		if t, err := time.Parse(time.RFC3339Nano, res.Data[0].Attributes.Timestamp); err == nil {
			out.Newest = &t
		}
	}
	return out, nil
}

func (d *Datadog) base(q string) string {
	if s := strings.TrimSpace(d.src.Scope.Selector); s != "" {
		return s + " " + q
	}
	return q
}

// Discover lists the services that logged in the last day.
func (d *Datadog) Discover(ctx context.Context) ([]domain.LogService, error) {
	b, err := d.post(ctx, "/api/v2/logs/analytics/aggregate", map[string]any{"compute": []any{map[string]any{"aggregation": "count"}},
		"filter": map[string]any{"query": d.base("*"), "from": "now-24h", "to": "now"}, "group_by": []any{map[string]any{"facet": "service", "limit": 200}}})
	if err != nil {
		return nil, err
	}
	var res struct {
		Data struct {
			Buckets []struct {
				By map[string]any `json:"by"`
			} `json:"buckets"`
		} `json:"data"`
	}
	if err := json.Unmarshal(b, &res); err != nil {
		return nil, err
	}
	var out []domain.LogService
	for _, bk := range res.Data.Buckets {
		if name, ok := bk.By["service"].(string); ok && name != "" {
			out = append(out, domain.LogService{Name: name, Selector: name, Enabled: true})
		}
	}
	return out, nil
}

// ddQuery is Datadog's query for what the detectors may want.
func ddQuery(svcs []domain.LogService, f Filter) string {
	var terms []string
	for _, t := range f.Terms {
		t = strings.TrimSpace(strings.ReplaceAll(t, `"`, ""))
		if t != "" {
			terms = append(terms, strconv.Quote(t))
		}
	}
	q := "(status:(error OR critical OR alert OR emergency) OR @http.status_code:>=500 OR @http.status_code:(401 OR 403) OR " + strings.Join(terms, " OR ") + ")"
	var names []string
	for _, s := range enabled(svcs) {
		sel := s.Selector
		if sel == "" {
			sel = s.Name
		}
		names = append(names, strconv.Quote(sel))
	}
	if len(names) > 0 {
		q = "service:(" + strings.Join(names, " OR ") + ") " + q
	}
	return q
}

// Pull reads matching logs in [cur, now - Lag), oldest first.
func (d *Datadog) Pull(ctx context.Context, svcs []domain.LogService, f Filter, cur domain.LogCursor, limit int) (Batch, error) {
	end := d.clock().Add(-Lag)
	if !end.After(cur.Time) {
		return Batch{Cursor: cur}, nil
	}
	limit = min(limit, 1000) // Datadog's page cap
	b, err := d.post(ctx, "/api/v2/logs/events/search", map[string]any{
		"filter": map[string]any{"query": d.base(ddQuery(svcs, f)), "from": cur.Time.UTC().Format(time.RFC3339Nano), "to": end.UTC().Format(time.RFC3339Nano)},
		"page":   map[string]any{"limit": limit}, "sort": "timestamp"})
	if err != nil {
		return Batch{Cursor: cur}, err
	}
	var res ddEvents
	if err := json.Unmarshal(b, &res); err != nil {
		return Batch{Cursor: cur}, fmt.Errorf("datadog answer: %w", err)
	}
	seen := map[string]bool{}
	for _, k := range cur.Seen {
		seen[k] = true
	}
	out := Batch{Cursor: domain.LogCursor{Time: end}}
	var last time.Time
	var atLast []string
	for _, e := range res.Data {
		if seen[e.ID] {
			continue
		}
		ts, _ := time.Parse(time.RFC3339Nano, e.Attributes.Timestamp)
		a := e.Attributes
		msg := a.Message
		if len(a.Attributes) > 0 {
			// Keep the structured attributes: detectors look at every field.
			obj := map[string]any{"message": a.Message, "status": a.Status}
			for k, v := range a.Attributes {
				obj[k] = v
			}
			if raw, err := json.Marshal(obj); err == nil {
				msg = string(raw)
			}
		}
		out.Entries = append(out.Entries, domain.LogEntry{Time: ts.UTC(), Service: serviceName(svcs, a.Service), Stream: a.Service + "/" + a.Host,
			Level: a.Status, Message: msg, Key: e.ID})
		if !ts.Equal(last) {
			last, atLast = ts, nil
		}
		atLast = append(atLast, e.ID)
	}
	if len(res.Data) >= limit && !last.IsZero() {
		out.More = true
		if last.Equal(cur.Time) {
			atLast = append(append([]string{}, cur.Seen...), atLast...)
		}
		out.Cursor = domain.LogCursor{Time: last.UTC(), Seen: atLast}
	}
	return out, nil
}

// serviceName maps a backend's service value to the watched service.
func serviceName(svcs []domain.LogService, value string) string {
	for _, s := range svcs {
		if s.Selector == value || s.Name == value {
			return s.Name
		}
	}
	return value
}

// ---------------------------------------------------------------------
// CloudWatch Logs: FilterLogEvents, signed with AWS Signature V4. Auth:
// the access key id as the user, the secret as the password, a session
// token (optional) as the tenant. Services are log groups.

// CloudWatch reads Amazon CloudWatch Logs.
type CloudWatch struct {
	src domain.LogSource
	c   *Client
	now func() time.Time
}

func (w *CloudWatch) clock() time.Time {
	if w.now != nil {
		return w.now()
	}
	return time.Now()
}

// region is the endpoint's region: logs.<region>.amazonaws.com.
func (w *CloudWatch) region() string {
	parts := strings.Split(w.c.Base.Hostname(), ".")
	if len(parts) >= 3 && parts[0] == "logs" {
		return parts[1]
	}
	return "us-east-1"
}

func (w *CloudWatch) call(ctx context.Context, target string, body any, out any) error {
	raw, err := json.Marshal(body)
	if err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, w.c.Base.String()+"/", bytes.NewReader(raw))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/x-amz-json-1.1")
	req.Header.Set("X-Amz-Target", "Logs_20140328."+target)
	signV4(req, raw, w.src.Auth.User, w.src.Auth.Password, w.src.Auth.Tenant, w.region(), "logs", w.clock())
	resp, err := w.c.HTTP.Do(req)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()
	b, err := ReadBody(resp.Body)
	if err != nil {
		return err
	}
	if resp.StatusCode/100 != 2 {
		status := resp.StatusCode
		if strings.Contains(string(b), "UnrecognizedClient") || strings.Contains(string(b), "InvalidSignature") || strings.Contains(string(b), "AccessDenied") {
			status = http.StatusUnauthorized
		}
		return &HTTPError{Status: status, Body: strings.TrimSpace(string(b))}
	}
	return json.Unmarshal(b, out)
}

// signV4 signs req with AWS Signature Version 4.
func signV4(req *http.Request, body []byte, keyID, secret, token, region, service string, now time.Time) {
	now = now.UTC()
	amzDate := now.Format("20060102T150405Z")
	day := now.Format("20060102")
	sum := sha256.Sum256(body)
	payload := hex.EncodeToString(sum[:])
	req.Header.Set("X-Amz-Date", amzDate)
	if token != "" {
		req.Header.Set("X-Amz-Security-Token", token)
	}
	host := req.URL.Host
	names := []string{"host"}
	for k := range req.Header {
		if lk := strings.ToLower(k); strings.HasPrefix(lk, "x-amz-") || lk == "content-type" {
			names = append(names, lk)
		}
	}
	sort.Strings(names)
	var canonHeaders strings.Builder
	for _, n := range names {
		v := host
		if n != "host" {
			v = strings.TrimSpace(req.Header.Get(n))
		}
		canonHeaders.WriteString(n + ":" + v + "\n")
	}
	signed := strings.Join(names, ";")
	path := req.URL.EscapedPath()
	if path == "" {
		path = "/"
	}
	canon := strings.Join([]string{req.Method, path, req.URL.RawQuery, canonHeaders.String(), signed, payload}, "\n")
	scope := day + "/" + region + "/" + service + "/aws4_request"
	ch := sha256.Sum256([]byte(canon))
	toSign := "AWS4-HMAC-SHA256\n" + amzDate + "\n" + scope + "\n" + hex.EncodeToString(ch[:])
	mac := func(key []byte, s string) []byte {
		h := hmac.New(sha256.New, key)
		h.Write([]byte(s))
		return h.Sum(nil)
	}
	k := mac(mac(mac(mac([]byte("AWS4"+secret), day), region), service), "aws4_request")
	sig := hex.EncodeToString(mac(k, toSign))
	req.Header.Set("Authorization", "AWS4-HMAC-SHA256 Credential="+keyID+"/"+scope+", SignedHeaders="+signed+", Signature="+sig)
}

type cwEvents struct {
	Events []struct {
		EventID       string `json:"eventId"`
		Timestamp     int64  `json:"timestamp"`
		Message       string `json:"message"`
		LogStreamName string `json:"logStreamName"`
	} `json:"events"`
	NextToken string `json:"nextToken"`
}

// Test lists log groups and reads the newest event of the first.
func (w *CloudWatch) Test(ctx context.Context) (TestResult, error) {
	out := TestResult{Version: "CloudWatch Logs (" + w.region() + ")", Fields: domain.LogFields{Message: "message", Timestamp: "timestamp"}}
	groups, err := w.groups(ctx, 5)
	if err != nil {
		return out, err
	}
	out.Labels = groups
	if len(groups) > 0 {
		now := w.clock()
		var res cwEvents
		if err := w.call(ctx, "FilterLogEvents", map[string]any{"logGroupName": groups[0], "startTime": now.Add(-6 * time.Hour).UnixMilli(),
			"endTime": now.UnixMilli(), "limit": 1}, &res); err == nil && len(res.Events) > 0 {
			out.Sample = sampleOf(res.Events[0].Message)
			t := time.UnixMilli(res.Events[0].Timestamp).UTC()
			out.Newest = &t
		}
	}
	return out, nil
}

func (w *CloudWatch) groups(ctx context.Context, limit int) ([]string, error) {
	body := map[string]any{"limit": limit}
	if p := strings.TrimSpace(w.src.Scope.Index); p != "" {
		body["logGroupNamePrefix"] = p
	}
	var res struct {
		LogGroups []struct {
			Name string `json:"logGroupName"`
		} `json:"logGroups"`
	}
	if err := w.call(ctx, "DescribeLogGroups", body, &res); err != nil {
		return nil, err
	}
	var out []string
	for _, g := range res.LogGroups {
		out = append(out, g.Name)
	}
	return out, nil
}

// Discover lists log groups (under the scope's prefix).
func (w *CloudWatch) Discover(ctx context.Context) ([]domain.LogService, error) {
	groups, err := w.groups(ctx, 50)
	if err != nil {
		return nil, err
	}
	out := make([]domain.LogService, 0, len(groups))
	for _, g := range groups {
		name := g[strings.LastIndex(g, "/")+1:]
		out = append(out, domain.LogService{Name: name, Selector: g, Enabled: true})
	}
	return out, nil
}

// cwPattern is CloudWatch's filter pattern for what the detectors may
// want: any of the terms (?term), in the cases logs usually write them,
// since CloudWatch matches case-sensitively.
func cwPattern(f Filter) string {
	seen := map[string]bool{}
	var parts []string
	add := func(t string) {
		if t = strings.TrimSpace(t); t == "" || seen[t] {
			return
		}
		seen[t] = true
		parts = append(parts, "?"+strconv.Quote(t))
	}
	for _, t := range f.Terms {
		if t = strings.TrimSpace(t); t == "" {
			continue
		}
		add(t)
		add(strings.ToUpper(t[:1]) + t[1:])
		add(strings.ToUpper(t))
	}
	return strings.Join(parts, " ")
}

// Pull reads each log group's matching events in [cur, now - Lag).
func (w *CloudWatch) Pull(ctx context.Context, svcs []domain.LogService, f Filter, cur domain.LogCursor, limit int) (Batch, error) {
	end := w.clock().Add(-Lag)
	if !end.After(cur.Time) {
		return Batch{Cursor: cur}, nil
	}
	seen := map[string]bool{}
	for _, k := range cur.Seen {
		seen[k] = true
	}
	limit = min(limit, 10000)
	cut, more := end, false
	var all []domain.LogEntry
	pattern := cwPattern(f)
	for _, svc := range enabled(svcs) {
		group := svc.Selector
		if group == "" {
			continue
		}
		var res cwEvents
		if err := w.call(ctx, "FilterLogEvents", map[string]any{"logGroupName": group, "startTime": cur.Time.UnixMilli(),
			"endTime": end.UnixMilli(), "filterPattern": pattern, "limit": limit}, &res); err != nil {
			return Batch{Cursor: cur}, err
		}
		for _, e := range res.Events {
			all = append(all, domain.LogEntry{Time: time.UnixMilli(e.Timestamp).UTC(), Service: svc.Name, Stream: group + "/" + e.LogStreamName,
				Message: strings.TrimRight(e.Message, "\n"), Key: e.EventID})
		}
		if res.NextToken != "" && len(res.Events) > 0 {
			if t := time.UnixMilli(res.Events[len(res.Events)-1].Timestamp).UTC(); t.Before(cut) {
				cut, more = t, true
			}
		}
	}
	out := Batch{More: more, Cursor: domain.LogCursor{Time: end}}
	var atCut []string
	for _, e := range all {
		if (more && e.Time.After(cut)) || seen[e.Key] {
			continue
		}
		out.Entries = append(out.Entries, e)
		if e.Time.Equal(cut) {
			atCut = append(atCut, e.Key)
		}
	}
	if more {
		out.Cursor = domain.LogCursor{Time: cut, Seen: atCut}
	}
	sort.SliceStable(out.Entries, func(i, j int) bool { return out.Entries[i].Time.Before(out.Entries[j].Time) })
	return out, nil
}

// ---------------------------------------------------------------------
// Splunk: the REST search export (port 8089). Auth: a Splunk token
// (bearer) or a user and password.

// Splunk reads Splunk Enterprise or Cloud.
type Splunk struct {
	src domain.LogSource
	c   *Client
	now func() time.Time
}

func (s *Splunk) clock() time.Time {
	if s.now != nil {
		return s.now()
	}
	return time.Now()
}

func (s *Splunk) index() string {
	if i := strings.TrimSpace(s.src.Scope.Index); i != "" {
		return i
	}
	return "*"
}

func (s *Splunk) field() string {
	if f := s.src.Fields.Service; f != "" {
		return f
	}
	return "sourcetype"
}

// export runs a search and calls fn for each result.
func (s *Splunk) export(ctx context.Context, search string, fn func(map[string]any)) error {
	form := url.Values{"search": {search}, "output_mode": {"json"}}
	u := *s.c.Base
	u.Path = strings.TrimRight(u.Path, "/") + "/services/search/jobs/export"
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, u.String(), strings.NewReader(form.Encode()))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	Auth(req, s.src.Auth)
	resp, err := s.c.HTTP.Do(req)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode/100 != 2 {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
		return &HTTPError{Status: resp.StatusCode, Body: strings.TrimSpace(string(b))}
	}
	sc := bufio.NewScanner(io.LimitReader(resp.Body, MaxBody))
	sc.Buffer(make([]byte, 64<<10), 4<<20)
	for sc.Scan() {
		var line struct {
			Result map[string]any `json:"result"`
		}
		if json.Unmarshal(sc.Bytes(), &line) == nil && line.Result != nil {
			fn(line.Result)
		}
	}
	return sc.Err()
}

// Test reads the server's version and the newest event.
func (s *Splunk) Test(ctx context.Context) (TestResult, error) {
	out := TestResult{Fields: domain.LogFields{Service: s.field(), Message: "_raw", Timestamp: "_time"}}
	b, err := call(ctx, s.c, s.src.Auth, http.MethodGet, "/services/server/info", url.Values{"output_mode": {"json"}}, nil, nil)
	if err != nil {
		return out, err
	}
	var info struct {
		Entry []struct {
			Content struct {
				Version string `json:"version"`
			} `json:"content"`
		} `json:"entry"`
	}
	if json.Unmarshal(b, &info) != nil || len(info.Entry) == 0 {
		return out, fmt.Errorf("this doesn't look like Splunk's management API (port 8089): %s", sampleOf(string(b)))
	}
	out.Version = "Splunk " + info.Entry[0].Content.Version
	_ = s.export(ctx, fmt.Sprintf("search index=%s earliest=-6h | head 1", s.index()), func(r map[string]any) {
		out.Sample = sampleOf(fmt.Sprint(r["_raw"]))
		if t := parseSplunkTime(r["_time"]); !t.IsZero() {
			out.Newest = &t
		}
	})
	return out, nil
}

// Discover lists the service field's values of the last day.
func (s *Splunk) Discover(ctx context.Context) ([]domain.LogService, error) {
	var out []domain.LogService
	field := s.field()
	err := s.export(ctx, fmt.Sprintf("search index=%s earliest=-24h | stats count by %s | sort -count | head 200", s.index(), field), func(r map[string]any) {
		if v, ok := r[field].(string); ok && v != "" {
			out = append(out, domain.LogService{Name: v, Selector: v, Enabled: true})
		}
	})
	return out, err
}

// spl quotes a value for SPL.
func spl(v string) string { return strconv.Quote(v) }

// Pull reads matching events in [cur, now - Lag), oldest first.
func (s *Splunk) Pull(ctx context.Context, svcs []domain.LogService, f Filter, cur domain.LogCursor, limit int) (Batch, error) {
	end := s.clock().Add(-Lag)
	if !end.After(cur.Time) {
		return Batch{Cursor: cur}, nil
	}
	var terms []string
	for _, t := range f.Terms {
		if t = strings.TrimSpace(strings.ReplaceAll(t, `"`, "")); t != "" {
			terms = append(terms, spl(t))
		}
	}
	field := s.field()
	q := fmt.Sprintf("search index=%s earliest=%.3f latest=%.3f (%s)", s.index(), float64(cur.Time.UnixMilli())/1000, float64(end.UnixMilli())/1000, strings.Join(terms, " OR "))
	if active := enabled(svcs); len(active) > 0 {
		var ors []string
		for _, v := range active {
			ors = append(ors, field+"="+spl(v.Selector))
		}
		q += " (" + strings.Join(ors, " OR ") + ")"
	}
	q += fmt.Sprintf(" | sort 0 _time | head %d | fields _time _raw _cd host source sourcetype %s", limit, field)
	seen := map[string]bool{}
	for _, k := range cur.Seen {
		seen[k] = true
	}
	out := Batch{Cursor: domain.LogCursor{Time: end}}
	var last time.Time
	var atLast []string
	n := 0
	err := s.export(ctx, q, func(r map[string]any) {
		n++
		t := parseSplunkTime(r["_time"])
		key := fmt.Sprint(r["_cd"]) + "@" + fmt.Sprint(r["_time"])
		if seen[key] {
			return
		}
		svc := serviceName(svcs, fmt.Sprint(valueOr(r[field], "")))
		out.Entries = append(out.Entries, domain.LogEntry{Time: t, Service: svc, Stream: fmt.Sprint(r["host"]) + "/" + fmt.Sprint(r["source"]),
			Message: fmt.Sprint(r["_raw"]), Key: key})
		if !t.Equal(last) {
			last, atLast = t, nil
		}
		atLast = append(atLast, key)
	})
	if err != nil {
		return Batch{Cursor: cur}, err
	}
	if n >= limit && !last.IsZero() {
		out.More = true
		if last.Equal(cur.Time) {
			atLast = append(append([]string{}, cur.Seen...), atLast...)
		}
		out.Cursor = domain.LogCursor{Time: last, Seen: atLast}
	}
	return out, nil
}

// parseSplunkTime reads _time: RFC 3339 with milliseconds, or epoch
// seconds.
func parseSplunkTime(v any) time.Time {
	sv := fmt.Sprint(v)
	for _, layout := range []string{"2006-01-02T15:04:05.000-07:00", time.RFC3339Nano} {
		if t, err := time.Parse(layout, sv); err == nil {
			return t.UTC()
		}
	}
	if f, err := strconv.ParseFloat(sv, 64); err == nil {
		return time.UnixMilli(int64(f * 1000)).UTC()
	}
	return time.Time{}
}

