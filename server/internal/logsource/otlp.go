package logsource

import (
	"bytes"
	"compress/gzip"
	"encoding/base64"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"math"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
)

// ParseOTLPLogs reads an OTLP/HTTP logs export as an OpenTelemetry
// Collector or SDK sends it: an ExportLogsServiceRequest in protobuf
// (the default) or JSON, maybe gzipped. Records over MaxPushEntries are
// not read; rejected counts them, for the response's partial_success.
func ParseOTLPLogs(body io.Reader, contentType, contentEncoding, defService string, now time.Time) (entries []domain.LogEntry, rejected int, err error) {
	raw, err := io.ReadAll(io.LimitReader(body, MaxPushBody+1))
	if err != nil {
		return nil, 0, err
	}
	if len(raw) > MaxPushBody {
		return nil, 0, ErrPushTooLarge
	}
	if strings.Contains(strings.ToLower(contentEncoding), "gzip") || (len(raw) > 2 && raw[0] == 0x1f && raw[1] == 0x8b) {
		zr, err := gzip.NewReader(bytes.NewReader(raw))
		if err != nil {
			return nil, 0, fmt.Errorf("gzip: %w", err)
		}
		if raw, err = io.ReadAll(io.LimitReader(zr, MaxPushRaw+1)); err != nil {
			return nil, 0, fmt.Errorf("gzip: %w", err)
		}
		if len(raw) > MaxPushRaw {
			return nil, 0, ErrPushTooLarge
		}
	}
	if defService == "" {
		defService = "push"
	}
	var res []otlpResource
	if OTLPIsJSON(contentType) {
		res, err = otlpJSON(raw)
	} else {
		res, err = otlpProto(raw)
	}
	if err != nil {
		return nil, 0, err
	}
	for _, r := range res {
		for _, rec := range r.records {
			if len(entries) >= MaxPushEntries {
				rejected++
				continue
			}
			entries = append(entries, otlpEntry(r, rec, defService, now))
		}
	}
	return entries, rejected, nil
}

// OTLPIsJSON reports whether an OTLP/HTTP body is JSON rather than
// protobuf; the response goes back in the same encoding.
func OTLPIsJSON(contentType string) bool {
	return strings.Contains(strings.ToLower(contentType), "json")
}

// otlpKV is one attribute. A value is a string, bool, int64, float64,
// []byte, []any (an array) or []otlpKV (a key-value list).
type otlpKV struct {
	Key string
	Val any
}

type otlpRecord struct {
	time, observed uint64 // unix nanoseconds
	severity       int
	severityText   string
	body           any
	attrs          []otlpKV
	traceID        string // hex
	spanID         string
}

// otlpResource is one ResourceLogs flattened: the resource's attributes,
// and its records with the scope each came from.
type otlpResource struct {
	attrs   []otlpKV
	records []otlpScoped
}

type otlpScoped struct {
	otlpRecord
	scope string
}

func otlpEntry(r otlpResource, rec otlpScoped, defService string, now time.Time) domain.LogEntry {
	attr := func(kvs []otlpKV, keys ...string) string {
		for _, k := range keys {
			for _, kv := range kvs {
				if kv.Key == k {
					if s := otlpText(kv.Val); s != "" {
						return s
					}
				}
			}
		}
		return ""
	}
	e := domain.LogEntry{Service: attr(r.attrs, "service.name"), TraceID: rec.traceID, SpanID: rec.spanID}
	if ns := attr(r.attrs, "service.namespace"); ns != "" && e.Service != "" {
		e.Service = ns + "/" + e.Service
	}
	if e.Service == "" {
		e.Service = defService
	}
	e.Revision = attr(r.attrs, "service.version", "deployment.version", "vcs.revision", "vcs.ref.head.revision")
	switch {
	case rec.time != 0:
		e.Time = otlpTime(rec.time)
	case rec.observed != 0:
		e.Time = otlpTime(rec.observed)
	default:
		e.Time = now
	}
	e.Level = rec.severityText
	if e.Level == "" {
		e.Level = otlpSeverity(rec.severity)
	}
	instance := attr(r.attrs, "service.instance.id", "k8s.pod.name", "container.id", "host.name")
	e.Stream = e.Service + "/" + instance + "/" + rec.scope

	// The message: a string body as it is, a structured one as JSON (the
	// detectors read its fields). An exception recorded as attributes is
	// added the way a log line would carry it, so the framers see it.
	excType, excMsg, excStack := attr(rec.attrs, "exception.type"), attr(rec.attrs, "exception.message"), attr(rec.attrs, "exception.stacktrace")
	if m, ok := rec.body.([]otlpKV); ok {
		obj := otlpPlain(m).(map[string]any)
		if excMsg != "" && obj["exception.message"] == nil {
			obj["exception.message"] = excType + ": " + excMsg
		}
		if excStack != "" && obj["exception.stacktrace"] == nil {
			obj["exception.stacktrace"] = excStack
		}
		b, _ := json.Marshal(obj)
		e.Message = string(b)
	} else {
		lines := []string{}
		if s := otlpText(rec.body); s != "" {
			lines = append(lines, s)
		}
		if excMsg != "" && !strings.Contains(strings.Join(lines, "\n"), excMsg) && !strings.Contains(excStack, excMsg) {
			if excType != "" {
				lines = append(lines, excType+": "+excMsg)
			} else {
				lines = append(lines, excMsg)
			}
		}
		if excStack != "" {
			lines = append(lines, excStack)
		}
		e.Message = strings.Join(lines, "\n")
	}
	// The other attributes aren't kept, but the detectors look at them:
	// a token in http.request.header.authorization is still a leak.
	if len(rec.attrs) > 0 {
		b, _ := json.Marshal(otlpPlain(rec.attrs))
		e.Extra = []string{string(b)}
	}
	return e
}

func otlpTime(ns uint64) time.Time {
	if ns > math.MaxInt64 {
		return time.Time{}
	}
	return time.Unix(0, int64(ns)).UTC()
}

// otlpSeverity names an OTLP severity number's level.
func otlpSeverity(n int) string {
	switch {
	case n >= 21:
		return "fatal"
	case n >= 17:
		return "error"
	case n >= 13:
		return "warn"
	case n >= 9:
		return "info"
	case n >= 5:
		return "debug"
	case n >= 1:
		return "trace"
	}
	return ""
}

// otlpText is a value as one string: arrays and lists as JSON.
func otlpText(v any) string {
	switch x := v.(type) {
	case nil:
		return ""
	case string:
		return x
	case []byte:
		return base64.StdEncoding.EncodeToString(x)
	case bool:
		return strconv.FormatBool(x)
	case int64:
		return strconv.FormatInt(x, 10)
	case float64:
		return strconv.FormatFloat(x, 'f', -1, 64)
	}
	b, _ := json.Marshal(otlpPlain(v))
	return string(b)
}

// otlpPlain turns a value into plain JSON-able Go values.
func otlpPlain(v any) any {
	switch x := v.(type) {
	case []otlpKV:
		m := make(map[string]any, len(x))
		for _, kv := range x {
			m[kv.Key] = otlpPlain(kv.Val)
		}
		return m
	case []any:
		out := make([]any, len(x))
		for i, y := range x {
			out[i] = otlpPlain(y)
		}
		return out
	case []byte:
		return base64.StdEncoding.EncodeToString(x)
	}
	return v
}

// ---------------------------------------------------------------------
// Protobuf
//
//	ExportLogsServiceRequest { repeated ResourceLogs resource_logs = 1; }
//	ResourceLogs  { Resource resource = 1; repeated ScopeLogs scope_logs = 2; }
//	Resource      { repeated KeyValue attributes = 1; }
//	ScopeLogs     { InstrumentationScope scope = 1; repeated LogRecord log_records = 2; }
//	InstrumentationScope { string name = 1; }
//	LogRecord     { fixed64 time_unix_nano = 1; SeverityNumber severity_number = 2;
//	                string severity_text = 3; AnyValue body = 5; repeated KeyValue attributes = 6;
//	                bytes trace_id = 9; bytes span_id = 10; fixed64 observed_time_unix_nano = 11; }
//	KeyValue      { string key = 1; AnyValue value = 2; }
//	AnyValue      { oneof: string 1, bool 2, int64 3, double 4, ArrayValue 5, KeyValueList 6, bytes 7 }
//	ArrayValue    { repeated AnyValue values = 1; }
//	KeyValueList  { repeated KeyValue values = 1; }

func otlpProto(b []byte) ([]otlpResource, error) {
	var out []otlpResource
	err := pbFields(b, func(num, wire int, v []byte, _ uint64) error {
		if num != 1 || wire != 2 {
			return nil
		}
		var r otlpResource
		err := pbFields(v, func(num, wire int, v []byte, _ uint64) error {
			switch {
			case num == 1 && wire == 2:
				return pbFields(v, func(num, wire int, v []byte, _ uint64) error {
					if num == 1 && wire == 2 {
						kv, err := pbKV(v, 0)
						if err != nil {
							return err
						}
						r.attrs = append(r.attrs, kv)
					}
					return nil
				})
			case num == 2 && wire == 2:
				return pbScopeLogs(v, &r)
			}
			return nil
		})
		out = append(out, r)
		return err
	})
	if err != nil {
		return nil, fmt.Errorf("OTLP protobuf: %w", err)
	}
	return out, nil
}

func pbScopeLogs(b []byte, r *otlpResource) error {
	var scope string
	var recs [][]byte
	if err := pbFields(b, func(num, wire int, v []byte, _ uint64) error {
		switch {
		case num == 1 && wire == 2:
			return pbFields(v, func(num, wire int, v []byte, _ uint64) error {
				if num == 1 && wire == 2 {
					scope = string(v)
				}
				return nil
			})
		case num == 2 && wire == 2:
			recs = append(recs, v)
		}
		return nil
	}); err != nil {
		return err
	}
	for _, v := range recs {
		var rec otlpRecord
		if err := pbFields(v, func(num, wire int, v []byte, n uint64) error {
			switch {
			case num == 1 && wire == 1:
				rec.time = n
			case num == 11 && wire == 1:
				rec.observed = n
			case num == 2 && wire == 0:
				rec.severity = int(n & 0xff) //nolint:gosec // G115: severity numbers are 0 to 24
			case num == 3 && wire == 2:
				rec.severityText = string(v)
			case num == 5 && wire == 2:
				val, err := pbAny(v, 0)
				rec.body = val
				return err
			case num == 6 && wire == 2:
				kv, err := pbKV(v, 0)
				rec.attrs = append(rec.attrs, kv)
				return err
			case num == 9 && wire == 2:
				rec.traceID = hexID(v)
			case num == 10 && wire == 2:
				rec.spanID = hexID(v)
			}
			return nil
		}); err != nil {
			return err
		}
		r.records = append(r.records, otlpScoped{otlpRecord: rec, scope: scope})
	}
	return nil
}

// otlpMaxDepth bounds nested values, so a crafted body can't recurse deep.
const otlpMaxDepth = 16

func pbKV(b []byte, depth int) (otlpKV, error) {
	var kv otlpKV
	err := pbFields(b, func(num, wire int, v []byte, _ uint64) error {
		switch {
		case num == 1 && wire == 2:
			kv.Key = string(v)
		case num == 2 && wire == 2:
			val, err := pbAny(v, depth+1)
			kv.Val = val
			return err
		}
		return nil
	})
	return kv, err
}

func pbAny(b []byte, depth int) (any, error) {
	if depth > otlpMaxDepth {
		return nil, errProto
	}
	var out any
	err := pbFields(b, func(num, wire int, v []byte, n uint64) error {
		switch {
		case num == 1 && wire == 2:
			out = string(v)
		case num == 2 && wire == 0:
			out = n != 0
		case num == 3 && wire == 0:
			out = int64(n) //nolint:gosec // G115: protobuf int64 is sent as its two's complement
		case num == 4 && wire == 1:
			out = math.Float64frombits(n)
		case num == 5 && wire == 2:
			arr := []any{}
			err := pbFields(v, func(num, wire int, v []byte, _ uint64) error {
				if num == 1 && wire == 2 {
					x, err := pbAny(v, depth+1)
					arr = append(arr, x)
					return err
				}
				return nil
			})
			out = arr
			return err
		case num == 6 && wire == 2:
			list := []otlpKV{}
			err := pbFields(v, func(num, wire int, v []byte, _ uint64) error {
				if num == 1 && wire == 2 {
					kv, err := pbKV(v, depth+1)
					list = append(list, kv)
					return err
				}
				return nil
			})
			out = list
			return err
		case num == 7 && wire == 2:
			out = append([]byte(nil), v...)
		}
		return nil
	})
	return out, err
}

// hexID is a trace or span id as lowercase hex; all-zero means none.
func hexID(b []byte) string {
	if len(b) == 0 || bytes.Count(b, []byte{0}) == len(b) {
		return ""
	}
	return hex.EncodeToString(b)
}

// ---------------------------------------------------------------------
// JSON (the protobuf JSON mapping: camelCase names, 64-bit integers as
// strings, ids as hex)

type otlpJSONAny struct {
	StringValue *string         `json:"stringValue"`
	BoolValue   *bool           `json:"boolValue"`
	IntValue    json.RawMessage `json:"intValue"`
	DoubleValue *float64        `json:"doubleValue"`
	ArrayValue  *struct {
		Values []otlpJSONAny `json:"values"`
	} `json:"arrayValue"`
	KvlistValue *struct {
		Values []otlpJSONKV `json:"values"`
	} `json:"kvlistValue"`
	BytesValue *string `json:"bytesValue"`
}

type otlpJSONKV struct {
	Key   string      `json:"key"`
	Value otlpJSONAny `json:"value"`
}

func otlpJSON(raw []byte) ([]otlpResource, error) {
	var req struct {
		ResourceLogs []struct {
			Resource struct {
				Attributes []otlpJSONKV `json:"attributes"`
			} `json:"resource"`
			ScopeLogs []struct {
				Scope struct {
					Name string `json:"name"`
				} `json:"scope"`
				LogRecords []struct {
					TimeUnixNano         json.RawMessage `json:"timeUnixNano"`
					ObservedTimeUnixNano json.RawMessage `json:"observedTimeUnixNano"`
					SeverityNumber       json.RawMessage `json:"severityNumber"`
					SeverityText         string          `json:"severityText"`
					Body                 *otlpJSONAny    `json:"body"`
					Attributes           []otlpJSONKV    `json:"attributes"`
					TraceID              string          `json:"traceId"`
					SpanID               string          `json:"spanId"`
				} `json:"logRecords"`
			} `json:"scopeLogs"`
		} `json:"resourceLogs"`
	}
	if err := json.Unmarshal(raw, &req); err != nil {
		return nil, fmt.Errorf("OTLP JSON: %w", err)
	}
	var out []otlpResource
	for _, rl := range req.ResourceLogs {
		r := otlpResource{attrs: jsonKVs(rl.Resource.Attributes, 0)}
		for _, sl := range rl.ScopeLogs {
			for _, lr := range sl.LogRecords {
				rec := otlpRecord{time: jsonUint(lr.TimeUnixNano), observed: jsonUint(lr.ObservedTimeUnixNano),
					severity: jsonSeverity(lr.SeverityNumber), severityText: lr.SeverityText,
					attrs: jsonKVs(lr.Attributes, 0), traceID: jsonHexID(lr.TraceID), spanID: jsonHexID(lr.SpanID)}
				if lr.Body != nil {
					rec.body = jsonAny(*lr.Body, 0)
				}
				r.records = append(r.records, otlpScoped{otlpRecord: rec, scope: sl.Scope.Name})
			}
		}
		out = append(out, r)
	}
	return out, nil
}

func jsonKVs(kvs []otlpJSONKV, depth int) []otlpKV {
	out := make([]otlpKV, 0, len(kvs))
	for _, kv := range kvs {
		out = append(out, otlpKV{Key: kv.Key, Val: jsonAny(kv.Value, depth+1)})
	}
	return out
}

func jsonAny(v otlpJSONAny, depth int) any {
	if depth > otlpMaxDepth {
		return nil
	}
	switch {
	case v.StringValue != nil:
		return *v.StringValue
	case v.BoolValue != nil:
		return *v.BoolValue
	case len(v.IntValue) > 0:
		n, err := strconv.ParseInt(strings.Trim(string(v.IntValue), `"`), 10, 64)
		if err != nil {
			return strings.Trim(string(v.IntValue), `"`)
		}
		return n
	case v.DoubleValue != nil:
		return *v.DoubleValue
	case v.ArrayValue != nil:
		out := make([]any, 0, len(v.ArrayValue.Values))
		for _, x := range v.ArrayValue.Values {
			out = append(out, jsonAny(x, depth+1))
		}
		return out
	case v.KvlistValue != nil:
		return jsonKVs(v.KvlistValue.Values, depth)
	case v.BytesValue != nil:
		if b, err := base64.StdEncoding.DecodeString(*v.BytesValue); err == nil {
			return b
		}
		return *v.BytesValue
	}
	return nil
}

// jsonUint reads a 64-bit integer sent as a string (the mapping) or a
// number (what some senders do).
func jsonUint(raw json.RawMessage) uint64 {
	n, _ := strconv.ParseUint(strings.Trim(string(raw), `"`), 10, 64)
	return n
}

// jsonSeverity reads a severity number, or the enum's name
// ("SEVERITY_NUMBER_ERROR"), which the JSON mapping also allows.
func jsonSeverity(raw json.RawMessage) int {
	s := strings.Trim(string(raw), `"`)
	if n, err := strconv.Atoi(s); err == nil {
		return n
	}
	return severityNames[s]
}

var severityNames = func() map[string]int {
	m := map[string]int{}
	names := []string{"TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"}
	for i, n := range names {
		m["SEVERITY_NUMBER_"+n] = i*4 + 1
		for j := 2; j <= 4; j++ {
			m["SEVERITY_NUMBER_"+n+strconv.Itoa(j)] = i*4 + j
		}
	}
	return m
}()

// jsonHexID checks a hex id from JSON; anything else is dropped.
func jsonHexID(s string) string {
	b, err := hex.DecodeString(s)
	if err != nil {
		return ""
	}
	return hexID(b)
}

// OTLPResponse is the body an OTLP/HTTP exporter expects back: an
// ExportLogsServiceResponse, empty when every record was taken, with
// partial_success { rejected_log_records = 1; error_message = 2 } when
// some were not.
func OTLPResponse(asJSON bool, rejected int, message string) []byte {
	if asJSON {
		if rejected == 0 {
			return []byte("{}")
		}
		b, _ := json.Marshal(map[string]any{"partialSuccess": map[string]any{
			"rejectedLogRecords": strconv.Itoa(rejected), "errorMessage": message}})
		return b
	}
	if rejected == 0 {
		return nil
	}
	ps := binary.AppendUvarint([]byte{1 << 3}, uint64(rejected)) //nolint:gosec // G115: rejected > 0; field 1, varint
	ps = append(ps, pbLen(2, []byte(message))...)
	return pbLen(1, ps)
}

// pbLen encodes a length-delimited protobuf field.
func pbLen(num int, v []byte) []byte {
	b := binary.AppendUvarint(nil, uint64(num)<<3|2) //nolint:gosec // G115: field numbers are small
	b = binary.AppendUvarint(b, uint64(len(v)))
	return append(b, v...)
}
