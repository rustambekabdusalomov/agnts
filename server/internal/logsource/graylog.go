package logsource

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Graylog reads Graylog 5+ with its message search API
// (POST /api/search/messages), falling back to the legacy universal
// search on older servers.
type Graylog struct {
	src domain.LogSource
	c   *Client
	now func() time.Time
}

func (g *Graylog) clock() time.Time {
	if g.now != nil {
		return g.now()
	}
	return time.Now()
}

// Graylog wants this header on every call that changes or posts.
var graylogHeaders = map[string]string{"X-Requested-By": "agnts"}

// Graylog's access tokens are sent as the user name with the password
// "token".
func (g *Graylog) auth() domain.LogAuth {
	a := g.src.Auth
	if a.Kind == "bearer" || a.Kind == "apikey" {
		return domain.LogAuth{Kind: "basic", User: a.Token, Password: "token"}
	}
	return a
}

// Test reads the server's version and the newest message.
func (g *Graylog) Test(ctx context.Context) (TestResult, error) {
	var out TestResult
	b, err := call(ctx, g.c, g.auth(), http.MethodGet, "/api/system", nil, nil, graylogHeaders)
	if err != nil {
		return out, err
	}
	var sys struct {
		Version string `json:"version"`
	}
	if json.Unmarshal(b, &sys) != nil || sys.Version == "" {
		return out, fmt.Errorf("this doesn't look like Graylog: %s", sampleOf(string(b)))
	}
	out.Version = sys.Version
	out.Fields = domain.LogFields{Timestamp: "timestamp", Message: "message", Level: "level", Service: "source"}
	out.Labels = []string{"timestamp", "message", "full_message", "level", "source", "facility"}
	now := g.clock()
	rows, err := g.search(ctx, "*", nil, now.Add(-6*time.Hour), now, 1, "desc")
	if err != nil {
		return out, err
	}
	if len(rows) > 0 {
		out.Sample = sampleOf(rows[0].message)
		t := rows[0].ts
		out.Newest = &t
	}
	return out, nil
}

// Discover lists the streams; each is a service.
func (g *Graylog) Discover(ctx context.Context) ([]domain.LogService, error) {
	b, err := call(ctx, g.c, g.auth(), http.MethodGet, "/api/streams", nil, nil, graylogHeaders)
	if err != nil {
		return nil, err
	}
	var res struct {
		Streams []struct {
			ID       string `json:"id"`
			Title    string `json:"title"`
			Disabled bool   `json:"disabled"`
		} `json:"streams"`
	}
	if err := json.Unmarshal(b, &res); err != nil {
		return nil, err
	}
	var out []domain.LogService
	for _, s := range res.Streams {
		if s.Disabled {
			continue
		}
		out = append(out, domain.LogService{Name: s.Title, Selector: s.ID, Enabled: true})
	}
	return out, nil
}

type graylogRow struct {
	id, message, source, level string
	ts                         time.Time
}

// luceneQuery is Graylog's query for what the detectors may want.
func luceneQuery(f Filter) string {
	var terms []string
	for _, t := range f.Terms {
		t = strings.TrimSpace(strings.ReplaceAll(t, `"`, ""))
		if t != "" {
			terms = append(terms, `"`+t+`"`)
		}
	}
	return "level:<=3 OR message:(" + strings.Join(terms, " OR ") + ") OR full_message:(" + strings.Join(terms, " OR ") + ")"
}

// search runs the message search; streams narrows it.
func (g *Graylog) search(ctx context.Context, query string, streams []string, from, to time.Time, limit int, order string) ([]graylogRow, error) {
	fields := []string{"timestamp", "message", "full_message", "source", "level", "_id"}
	body := map[string]any{"query": query, "fields": fields, "size": limit, "sort": "timestamp", "sort_order": order,
		"timerange": map[string]any{"type": "absolute", "from": from.UTC().Format("2006-01-02T15:04:05.000Z"), "to": to.UTC().Format("2006-01-02T15:04:05.000Z")}}
	if len(streams) > 0 {
		body["streams"] = streams
	}
	b, err := call(ctx, g.c, g.auth(), http.MethodPost, "/api/search/messages", nil, body, graylogHeaders)
	var h *HTTPError
	if errors.As(err, &h) && (h.Status == http.StatusNotFound || h.Status == http.StatusMethodNotAllowed) {
		return g.legacy(ctx, query, streams, from, to, limit, order)
	}
	if err != nil {
		return nil, err
	}
	var res struct {
		Schema []struct {
			Field string `json:"field"`
		} `json:"schema"`
		Datarows [][]any `json:"datarows"`
	}
	if err := json.Unmarshal(b, &res); err != nil {
		return nil, err
	}
	col := map[string]int{}
	for i, s := range res.Schema {
		col[s.Field] = i
	}
	get := func(row []any, f string) string {
		i, ok := col[f]
		if !ok || i >= len(row) || row[i] == nil {
			return ""
		}
		return fmt.Sprint(row[i])
	}
	out := make([]graylogRow, 0, len(res.Datarows))
	for _, row := range res.Datarows {
		msg := get(row, "full_message")
		if msg == "" {
			msg = get(row, "message")
		}
		out = append(out, graylogRow{id: get(row, "_id"), message: msg, source: get(row, "source"), level: get(row, "level"), ts: parseTime(get(row, "timestamp"))})
	}
	return out, nil
}

// legacy is /api/search/universal/absolute (Graylog 4 and older).
func (g *Graylog) legacy(ctx context.Context, query string, streams []string, from, to time.Time, limit int, order string) ([]graylogRow, error) {
	q := url.Values{"query": {query}, "from": {from.UTC().Format("2006-01-02T15:04:05.000Z")}, "to": {to.UTC().Format("2006-01-02T15:04:05.000Z")},
		"limit": {strconv.Itoa(limit)}, "sort": {"timestamp:" + order}, "fields": {"timestamp,message,full_message,source,level"}}
	if len(streams) > 0 {
		var parts []string
		for _, s := range streams {
			parts = append(parts, "streams:"+s)
		}
		q.Set("filter", strings.Join(parts, " OR "))
	}
	b, err := call(ctx, g.c, g.auth(), http.MethodGet, "/api/search/universal/absolute", q, nil, graylogHeaders)
	if err != nil {
		return nil, err
	}
	var res struct {
		Messages []struct {
			Message map[string]any `json:"message"`
		} `json:"messages"`
	}
	if err := json.Unmarshal(b, &res); err != nil {
		return nil, err
	}
	out := make([]graylogRow, 0, len(res.Messages))
	for _, m := range res.Messages {
		s := func(k string) string {
			if v, ok := m.Message[k]; ok && v != nil {
				return fmt.Sprint(v)
			}
			return ""
		}
		msg := s("full_message")
		if msg == "" {
			msg = s("message")
		}
		out = append(out, graylogRow{id: s("_id"), message: msg, source: s("source"), level: s("level"), ts: parseTime(s("timestamp"))})
	}
	return out, nil
}

// Pull reads matching messages in [cur, now - Lag), one search per
// service (stream).
func (g *Graylog) Pull(ctx context.Context, svcs []domain.LogService, f Filter, cur domain.LogCursor, limit int) (Batch, error) {
	end := g.clock().Add(-Lag)
	if !end.After(cur.Time) {
		return Batch{Cursor: cur}, nil
	}
	seen := map[string]bool{}
	for _, k := range cur.Seen {
		seen[k] = true
	}
	active := enabled(svcs)
	if len(active) == 0 {
		active = []domain.LogService{{}}
	}
	cut, more := end, false
	var all []domain.LogEntry
	q := luceneQuery(f)
	for _, svc := range active {
		var streams []string
		if svc.Selector != "" {
			streams = []string{svc.Selector}
		}
		rows, err := g.search(ctx, q, streams, cur.Time, end, limit, "asc")
		if err != nil {
			return Batch{Cursor: cur}, err
		}
		for _, r := range rows {
			name := svc.Name
			if name == "" {
				name = r.source
			}
			key := r.id
			if key == "" {
				key = keyOf(r.ts.String(), r.source, r.message)
			}
			all = append(all, domain.LogEntry{Time: r.ts, Service: name, Stream: name + "/" + r.source, Level: r.level, Message: r.message, Key: key})
		}
		if len(rows) >= limit && rows[len(rows)-1].ts.Before(cut) {
			cut, more = rows[len(rows)-1].ts, true
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
	return out, nil
}
