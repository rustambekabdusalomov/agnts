package logsource

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"sort"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Elastic reads Elasticsearch and OpenSearch (the same search API): new
// documents by timestamp, sorted, resuming from the last one read.
type Elastic struct {
	src domain.LogSource
	c   *Client
	now func() time.Time
}

func (e *Elastic) clock() time.Time {
	if e.now != nil {
		return e.now()
	}
	return time.Now()
}

func (e *Elastic) index() string {
	if i := strings.TrimSpace(e.src.Scope.Index); i != "" {
		return i
	}
	return "logs-*,filebeat-*,logstash-*"
}

// Candidate field names, in order, for what Test detects.
var (
	esTimeFields    = []string{"@timestamp", "timestamp", "time", "date"}
	esMessageFields = []string{"message", "log", "msg", "event.original"}
	esLevelFields   = []string{"log.level", "level", "severity", "log_level"}
	esServiceFields = []string{"service.name", "kubernetes.container.name", "container.name", "app", "fields.service", "service", "host.name"}
	esRevFields     = []string{"service.version", "labels.version", "version", "revision"}
	esLevels        = []string{"error", "ERROR", "Error", "err", "ERR", "fatal", "FATAL", "Fatal", "critical", "CRITICAL", "panic", "PANIC", "emerg", "alert", "crit"}
)

func (e *Elastic) post(ctx context.Context, path string, body any) ([]byte, error) {
	return call(ctx, e.c, e.src.Auth, http.MethodPost, path, nil, body, nil)
}

func (e *Elastic) fields() domain.LogFields {
	f := e.src.Fields
	if f.Timestamp == "" {
		f.Timestamp = "@timestamp"
	}
	if f.Message == "" {
		f.Message = "message"
	}
	return f
}

type esHits struct {
	Hits struct {
		Hits []struct {
			ID     string          `json:"_id"`
			Index  string          `json:"_index"`
			Source json.RawMessage `json:"_source"`
			Sort   []any           `json:"sort"`
		} `json:"hits"`
	} `json:"hits"`
	Aggregations map[string]struct {
		Buckets []struct {
			Key      any `json:"key"`
			DocCount int `json:"doc_count"`
		} `json:"buckets"`
	} `json:"aggregations"`
}

// Test reads the version and the newest document and detects its fields.
func (e *Elastic) Test(ctx context.Context) (TestResult, error) {
	var out TestResult
	b, err := call(ctx, e.c, e.src.Auth, http.MethodGet, "/", nil, nil, nil)
	if err != nil {
		return out, err
	}
	var info struct {
		Version struct {
			Number       string `json:"number"`
			Distribution string `json:"distribution"`
		} `json:"version"`
	}
	if err := json.Unmarshal(b, &info); err != nil || info.Version.Number == "" {
		return out, fmt.Errorf("this doesn't look like Elasticsearch or OpenSearch: %s", sampleOf(string(b)))
	}
	out.Version = info.Version.Number
	if info.Version.Distribution != "" {
		out.Version = info.Version.Distribution + " " + out.Version
	}
	b, err = e.post(ctx, "/"+e.index()+"/_search", map[string]any{"size": 1, "sort": []any{map[string]any{"@timestamp": map[string]any{"order": "desc", "unmapped_type": "date"}}}})
	if err != nil {
		return out, err
	}
	var res esHits
	if err := json.Unmarshal(b, &res); err != nil {
		return out, err
	}
	if len(res.Hits.Hits) == 0 {
		out.Fields = e.fields()
		return out, nil
	}
	var doc map[string]any
	_ = json.Unmarshal(res.Hits.Hits[0].Source, &doc)
	flat := map[string]any{}
	flatten("", doc, flat)
	for k := range flat {
		out.Labels = append(out.Labels, k)
	}
	sort.Strings(out.Labels)
	pick := func(cands []string) string {
		for _, c := range cands {
			if _, ok := flat[c]; ok {
				return c
			}
		}
		return ""
	}
	out.Fields = domain.LogFields{Timestamp: pick(esTimeFields), Message: pick(esMessageFields), Level: pick(esLevelFields),
		Service: pick(esServiceFields), Revision: pick(esRevFields)}
	if out.Fields.Message != "" {
		out.Sample = sampleOf(fmt.Sprint(flat[out.Fields.Message]))
	}
	if ts, ok := flat[out.Fields.Timestamp].(string); ok {
		if t, err := time.Parse(time.RFC3339Nano, ts); err == nil {
			out.Newest = &t
		}
	}
	return out, nil
}

func flatten(prefix string, m map[string]any, out map[string]any) {
	for k, v := range m {
		key := k
		if prefix != "" {
			key = prefix + "." + k
		}
		if sub, ok := v.(map[string]any); ok {
			flatten(key, sub, out)
			continue
		}
		out[key] = v
	}
}

// Discover lists the most frequent values of the service field.
func (e *Elastic) Discover(ctx context.Context) ([]domain.LogService, error) {
	f := e.fields()
	if f.Service == "" {
		t, err := e.Test(ctx)
		if err != nil {
			return nil, err
		}
		if f.Service = t.Fields.Service; f.Service == "" {
			return nil, fmt.Errorf("no service field found (tried %s): set the service field on the source", strings.Join(esServiceFields, ", "))
		}
	}
	var out []domain.LogService
	for _, field := range []string{f.Service, f.Service + ".keyword"} {
		b, err := e.post(ctx, "/"+e.index()+"/_search", map[string]any{"size": 0,
			"query": map[string]any{"range": map[string]any{f.Timestamp: map[string]any{"gte": "now-24h"}}},
			"aggs":  map[string]any{"services": map[string]any{"terms": map[string]any{"field": field, "size": 200}}}})
		if err != nil {
			continue // a text field can't be aggregated: try .keyword
		}
		var res esHits
		if json.Unmarshal(b, &res) != nil {
			continue
		}
		for _, bk := range res.Aggregations["services"].Buckets {
			name := fmt.Sprint(bk.Key)
			out = append(out, domain.LogService{Name: name, Selector: name, Enabled: true})
		}
		if len(out) > 0 {
			break
		}
	}
	return out, nil
}

// query builds the search for [from, to) after the cursor's last hit.
func (e *Elastic) query(svcs []domain.LogService, f Filter, from, to time.Time, after []any, skip []string, limit int) map[string]any {
	fl := e.fields()
	filters := []any{map[string]any{"range": map[string]any{fl.Timestamp: map[string]any{"gte": from.Format(time.RFC3339Nano), "lt": to.Format(time.RFC3339Nano), "format": "strict_date_optional_time_nanos"}}}}
	if active := enabled(svcs); len(active) > 0 && fl.Service != "" {
		var should []any
		for _, s := range active {
			sel := s.Selector
			if sel == "" {
				sel = s.Name
			}
			should = append(should, map[string]any{"term": map[string]any{fl.Service: sel}},
				map[string]any{"term": map[string]any{fl.Service + ".keyword": sel}})
		}
		filters = append(filters, map[string]any{"bool": map[string]any{"should": should, "minimum_should_match": 1}})
	}
	// What the detectors may want: an error level, one of the literals in
	// the message, or an HTTP status worth a look.
	var quoted []string
	for _, t := range f.Terms {
		quoted = append(quoted, `"`+strings.ReplaceAll(strings.TrimSpace(t), `"`, ``)+`"`)
	}
	want := []any{
		map[string]any{"simple_query_string": map[string]any{"query": strings.Join(quoted, " | "), "fields": []string{fl.Message, "error.message", "error.stack_trace"}, "default_operator": "or", "lenient": true}},
		map[string]any{"range": map[string]any{"http.response.status_code": map[string]any{"gte": 500}}},
		map[string]any{"terms": map[string]any{"http.response.status_code": []int{401, 403}}},
	}
	if fl.Level != "" {
		want = append(want, map[string]any{"terms": map[string]any{fl.Level: esLevels}}, map[string]any{"terms": map[string]any{fl.Level + ".keyword": esLevels}})
	}
	filters = append(filters, map[string]any{"bool": map[string]any{"should": want, "minimum_should_match": 1}})
	q := map[string]any{"bool": map[string]any{"filter": filters}}
	if len(skip) > 0 {
		q["bool"].(map[string]any)["must_not"] = []any{map[string]any{"ids": map[string]any{"values": skip}}}
	}
	body := map[string]any{"size": limit, "query": q, "track_total_hits": false,
		"sort": []any{map[string]any{fl.Timestamp: map[string]any{"order": "asc", "unmapped_type": "date"}}}}
	if len(after) > 0 {
		body["search_after"] = after
	}
	return body
}

// Pull reads matching documents in [cur, now - Lag), oldest first.
func (e *Elastic) Pull(ctx context.Context, svcs []domain.LogService, f Filter, cur domain.LogCursor, limit int) (Batch, error) {
	end := e.clock().Add(-Lag)
	if !end.After(cur.Time) {
		return Batch{Cursor: cur}, nil
	}
	b, err := e.post(ctx, "/"+e.index()+"/_search?ignore_unavailable=true&allow_no_indices=true", e.query(svcs, f, cur.Time, end, nil, cur.Seen, limit))
	if err != nil {
		return Batch{Cursor: cur}, err
	}
	var res esHits
	if err := json.Unmarshal(b, &res); err != nil {
		return Batch{Cursor: cur}, fmt.Errorf("search answer: %w", err)
	}
	fl := e.fields()
	out := Batch{Cursor: domain.LogCursor{Time: end}}
	var lastT time.Time
	var atLast []string
	for _, h := range res.Hits.Hits {
		var doc map[string]any
		if json.Unmarshal(h.Source, &doc) != nil {
			continue
		}
		flat := map[string]any{}
		flatten("", doc, flat)
		ts := parseTime(flat[fl.Timestamp])
		if ts.IsZero() && len(h.Sort) > 0 {
			ts = parseTime(h.Sort[0])
		}
		svc := ""
		if fl.Service != "" {
			svc = fmt.Sprint(valueOr(flat[fl.Service], ""))
		}
		for _, s := range enabled(svcs) {
			if s.Selector == svc || s.Name == svc {
				svc = s.Name
			}
		}
		entry := domain.LogEntry{Time: ts, Service: svc, Stream: svc + "/" + fmt.Sprint(valueOr(flat["host.name"], "")) + "/" + fmt.Sprint(valueOr(flat["container.id"], "")),
			Message: string(h.Source), Key: h.ID}
		if fl.Level != "" {
			entry.Level = fmt.Sprint(valueOr(flat[fl.Level], ""))
		}
		if fl.Revision != "" {
			entry.Revision = fmt.Sprint(valueOr(flat[fl.Revision], ""))
		}
		out.Entries = append(out.Entries, entry)
		if !ts.Equal(lastT) {
			lastT, atLast = ts, nil
		}
		atLast = append(atLast, h.ID)
	}
	if len(res.Hits.Hits) >= limit && !lastT.IsZero() {
		out.More = true
		seen := atLast
		if lastT.Equal(cur.Time) {
			seen = append(append([]string{}, cur.Seen...), atLast...)
		}
		out.Cursor = domain.LogCursor{Time: lastT, Seen: seen}
	}
	return out, nil
}

func valueOr(v any, def any) any {
	if v == nil {
		return def
	}
	return v
}

// parseTime reads a timestamp as Elasticsearch returns it: RFC 3339, or
// epoch milliseconds.
func parseTime(v any) time.Time {
	switch x := v.(type) {
	case string:
		for _, layout := range []string{time.RFC3339Nano, "2006-01-02 15:04:05.000", "2006-01-02T15:04:05.000Z0700"} {
			if t, err := time.Parse(layout, x); err == nil {
				return t.UTC()
			}
		}
		if n, err := strconv.ParseInt(x, 10, 64); err == nil {
			return time.UnixMilli(n).UTC()
		}
	case float64:
		if x > 1e9 && x < 1e11 { // epoch seconds (Fluent Bit's date)
			return time.Unix(int64(x), int64((x-float64(int64(x)))*1e9)).UTC()
		}
		return time.UnixMilli(int64(x)).UTC()
	case json.Number:
		n, _ := x.Int64()
		return time.UnixMilli(n).UTC()
	}
	return time.Time{}
}
