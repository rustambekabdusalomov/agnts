package logsource

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"slices"
	"sort"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Loki reads Grafana Loki with query_range: a poll resumes exactly from
// its cursor and holds no tail slot.
type Loki struct {
	src domain.LogSource
	c   *Client
	now func() time.Time
}

// serviceLabels are tried, in order, as the label that names a service.
var serviceLabels = []string{"service_name", "app", "service", "container", "container_name", "job"}

func (l *Loki) clock() time.Time {
	if l.now != nil {
		return l.now()
	}
	return time.Now()
}

func (l *Loki) get(ctx context.Context, path string, q url.Values) ([]byte, error) {
	return call(ctx, l.c, l.src.Auth, http.MethodGet, path, q, nil, nil)
}

type lokiStreams struct {
	Status string `json:"status"`
	Data   struct {
		ResultType string `json:"resultType"`
		Result     []struct {
			Stream map[string]string `json:"stream"`
			Values [][2]string       `json:"values"`
		} `json:"result"`
	} `json:"data"`
}

type lokiList struct {
	Status string   `json:"status"`
	Data   []string `json:"data"`
}

// Test reads the label names and the newest entry.
func (l *Loki) Test(ctx context.Context) (TestResult, error) {
	var out TestResult
	now := l.clock()
	q := url.Values{"start": {nanos(now.Add(-6 * time.Hour))}, "end": {nanos(now)}}
	b, err := l.get(ctx, "/loki/api/v1/labels", q)
	if err != nil {
		return out, err
	}
	var labels lokiList
	if err := json.Unmarshal(b, &labels); err != nil || labels.Status != "success" {
		return out, fmt.Errorf("this doesn't look like Loki: %s", sampleOf(string(b)))
	}
	out.Labels = labels.Data
	for _, name := range serviceLabels {
		if slices.Contains(labels.Data, name) {
			out.Fields.Service = name
			break
		}
	}
	for _, name := range []string{"level", "detected_level", "severity"} {
		if slices.Contains(labels.Data, name) {
			out.Fields.Level = name
			break
		}
	}
	for _, name := range []string{"version", "revision", "commit"} {
		if slices.Contains(labels.Data, name) {
			out.Fields.Revision = name
			break
		}
	}
	if b, err := l.get(ctx, "/loki/api/v1/status/buildinfo", nil); err == nil {
		var bi struct {
			Version string `json:"version"`
		}
		if json.Unmarshal(b, &bi) == nil {
			out.Version = bi.Version
		}
	}
	sel := mergeSelectors(l.src.Scope.Selector, "")
	b, err = l.get(ctx, "/loki/api/v1/query_range", url.Values{"query": {sel}, "start": {nanos(now.Add(-6 * time.Hour))},
		"end": {nanos(now)}, "limit": {"1"}, "direction": {"backward"}})
	if err != nil {
		return out, err
	}
	var res lokiStreams
	if err := json.Unmarshal(b, &res); err != nil {
		return out, err
	}
	for _, s := range res.Data.Result {
		for _, v := range s.Values {
			out.Sample = sampleOf(v[1])
			if t, err := parseNanos(v[0]); err == nil {
				out.Newest = &t
			}
		}
	}
	return out, nil
}

// Discover lists the values of the service label.
func (l *Loki) Discover(ctx context.Context) ([]domain.LogService, error) {
	label := l.src.Fields.Service
	if label == "" {
		t, err := l.Test(ctx)
		if err != nil {
			return nil, err
		}
		if label = t.Fields.Service; label == "" {
			return nil, fmt.Errorf("no service label found (tried %s): set the service label on the source", strings.Join(serviceLabels, ", "))
		}
	}
	now := l.clock()
	q := url.Values{"start": {nanos(now.Add(-24 * time.Hour))}, "end": {nanos(now)}}
	if l.src.Scope.Selector != "" {
		q.Set("query", mergeSelectors(l.src.Scope.Selector, ""))
	}
	b, err := l.get(ctx, "/loki/api/v1/label/"+url.PathEscape(label)+"/values", q)
	if err != nil {
		return nil, err
	}
	var vals lokiList
	if err := json.Unmarshal(b, &vals); err != nil {
		return nil, err
	}
	out := make([]domain.LogService, 0, len(vals.Data))
	for _, v := range vals.Data {
		out = append(out, domain.LogService{Name: v, Selector: fmt.Sprintf(`{%s=%s}`, label, strconv.Quote(v)), Enabled: true})
	}
	return out, nil
}

// mergeSelectors joins a base selector ({env="prod"}) and a service's
// ({app="api"}) into one; Loki needs at least one non-empty matcher.
func mergeSelectors(base, svc string) string {
	inner := func(s string) string {
		return strings.TrimSpace(strings.TrimSuffix(strings.TrimPrefix(strings.TrimSpace(s), "{"), "}"))
	}
	var parts []string
	for _, s := range []string{base, svc} {
		if in := inner(s); in != "" {
			parts = append(parts, in)
		}
	}
	if len(parts) == 0 {
		return `{job=~".+"}`
	}
	return "{" + strings.Join(parts, ", ") + "}"
}

// Pull reads each enabled service's matching entries in [cur, now - Lag).
// When a service returns limit entries, the window ends at its last entry
// and the rest is read on the next pull.
func (l *Loki) Pull(ctx context.Context, svcs []domain.LogService, f Filter, cur domain.LogCursor, limit int) (Batch, error) {
	start := cur.Time
	end := l.clock().Add(-Lag)
	if !end.After(start) {
		return Batch{Cursor: cur}, nil
	}
	seen := map[string]bool{}
	for _, k := range cur.Seen {
		seen[k] = true
	}
	type got struct {
		e  domain.LogEntry
		ts time.Time
	}
	var all []got
	cut := end
	more := false
	active := enabled(svcs)
	if len(active) == 0 {
		active = []domain.LogService{{Name: "", Selector: ""}}
	}
	for _, svc := range active {
		query := mergeSelectors(l.src.Scope.Selector, svc.Selector)
		if f.Regex != "" {
			query += " |~ `" + strings.ReplaceAll(f.Regex, "`", "") + "`"
		}
		b, err := l.get(ctx, "/loki/api/v1/query_range", url.Values{"query": {query}, "start": {nanos(start)}, "end": {nanos(end)},
			"limit": {strconv.Itoa(limit)}, "direction": {"forward"}})
		if err != nil {
			return Batch{Cursor: cur}, err
		}
		var res lokiStreams
		if err := json.Unmarshal(b, &res); err != nil {
			return Batch{Cursor: cur}, fmt.Errorf("loki answer: %w", err)
		}
		n := 0
		var last time.Time
		for _, s := range res.Data.Result {
			stream := labelString(s.Stream)
			name := svc.Name
			if name == "" && l.src.Fields.Service != "" {
				name = s.Stream[l.src.Fields.Service]
			}
			for _, v := range s.Values {
				ts, err := parseNanos(v[0])
				if err != nil {
					continue
				}
				n++
				if ts.After(last) {
					last = ts
				}
				e := domain.LogEntry{Time: ts, Service: name, Stream: stream, Message: v[1], Key: keyOf(v[0], stream, v[1])}
				if l.src.Fields.Level != "" {
					e.Level = s.Stream[l.src.Fields.Level]
				}
				if l.src.Fields.Revision != "" {
					e.Revision = s.Stream[l.src.Fields.Revision]
				}
				all = append(all, got{e, ts})
			}
		}
		if n >= limit && last.Before(cut) {
			cut, more = last, true
		}
	}
	if more && !cut.After(start) {
		// More than limit entries share the start time: skip past it, so
		// the cursor moves; what was not read is counted by the caller.
		cut = start.Add(time.Nanosecond)
	}
	out := Batch{More: more}
	for _, g := range all {
		if g.ts.After(cut) || seen[g.e.Key] {
			continue
		}
		out.Entries = append(out.Entries, g.e)
	}
	// Context lines stay inside this window: the next pull reads what
	// comes after it.
	out.Entries = l.withContext(ctx, out.Entries, cut, seen)
	var atCut []string
	for _, e := range out.Entries {
		if e.Time.Equal(cut) {
			atCut = append(atCut, e.Key)
		}
	}
	sort.SliceStable(out.Entries, func(i, j int) bool { return out.Entries[i].Time.Before(out.Entries[j].Time) })
	if more {
		// The next window starts at the cut, inclusive: skip what was read
		// there.
		out.Cursor = domain.LogCursor{Time: cut, Seen: atCut}
	} else {
		out.Cursor = domain.LogCursor{Time: end}
	}
	return out, nil
}

func enabled(svcs []domain.LogService) []domain.LogService {
	var out []domain.LogService
	for _, s := range svcs {
		if s.Enabled {
			out = append(out, s)
		}
	}
	return out
}

func labelString(m map[string]string) string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	var b strings.Builder
	for _, k := range keys {
		b.WriteString(k + "=" + m[k] + ",")
	}
	return b.String()
}

func nanos(t time.Time) string { return strconv.FormatInt(t.UnixNano(), 10) }

func parseNanos(s string) (time.Time, error) {
	n, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		return time.Time{}, err
	}
	return time.Unix(0, n).UTC(), nil
}

// maxContext caps the context reads one pull makes.
const maxContext = 20

// withContext adds, for each entry that starts a multi-line error, the
// lines its stream wrote in the next two seconds: the stack frames a
// keyword filter drops when a trace is logged line by line.
func (l *Loki) withContext(ctx context.Context, entries []domain.LogEntry, until time.Time, seen map[string]bool) []domain.LogEntry {
	have := map[string]bool{}
	for k := range seen {
		have[k] = true
	}
	for _, e := range entries {
		have[e.Key] = true
	}
	n := 0
	out := entries
	for _, e := range entries {
		if n >= maxContext || strings.Contains(e.Message, "\n") || !domain.LogErrorStart(e.Message) {
			continue
		}
		n++
		query := "{" + selectorOf(e.Stream) + "}"
		end := e.Time.Add(2 * time.Second)
		if end.After(until) {
			end = until.Add(time.Nanosecond)
		}
		b, err := l.get(ctx, "/loki/api/v1/query_range", url.Values{"query": {query}, "start": {nanos(e.Time)},
			"end": {nanos(end)}, "limit": {"300"}, "direction": {"forward"}})
		if err != nil {
			continue // the error line alone still makes a finding
		}
		var res lokiStreams
		if json.Unmarshal(b, &res) != nil {
			continue
		}
		for _, s := range res.Data.Result {
			stream := labelString(s.Stream)
			for _, v := range s.Values {
				ts, err := parseNanos(v[0])
				if err != nil || ts.After(until) {
					continue
				}
				k := keyOf(v[0], stream, v[1])
				if have[k] {
					continue
				}
				have[k] = true
				c := e
				c.Time, c.Stream, c.Message, c.Key = ts, stream, v[1], k
				out = append(out, c)
			}
		}
	}
	return out
}

// selectorOf turns labelString's "a=1,b=2," back into matchers.
func selectorOf(stream string) string {
	var parts []string
	for _, kv := range strings.Split(strings.TrimSuffix(stream, ","), ",") {
		k, v, ok := strings.Cut(kv, "=")
		if ok && k != "" {
			parts = append(parts, k+"="+strconv.Quote(v))
		}
	}
	return strings.Join(parts, ", ")
}
