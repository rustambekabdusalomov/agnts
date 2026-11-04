package logsource

import (
	"bytes"
	"compress/gzip"
	"encoding/binary"
	"encoding/hex"
	"strings"
	"testing"
	"time"
)

func pbFixed64(num int, n uint64) []byte {
	b := binary.AppendUvarint(nil, uint64(num<<3|1))
	return binary.LittleEndian.AppendUint64(b, n)
}

func pbStr(num int, s string) []byte { return pbBytes(num, []byte(s)) }

// otlpKVpb is a KeyValue with a string value.
func otlpKVpb(k, v string) []byte {
	return append(pbStr(1, k), pbBytes(2, pbStr(1, v))...)
}

func cat(parts ...[]byte) []byte { return bytes.Join(parts, nil) }

var (
	otlpTS    = time.Date(2026, 11, 3, 9, 0, 0, 123456789, time.UTC)
	otlpTrace = "4bf92f3577b34da6a3ce929d0e0e4736"
	otlpSpan  = "00f067aa0ba902b7"
)

// otlpRequest is an ExportLogsServiceRequest as a Collector sends it:
// a panic with a severity number only and an exception attribute, and
// a structured (kvlist) body.
func otlpRequest() []byte {
	trace, _ := hex.DecodeString(otlpTrace)
	span, _ := hex.DecodeString(otlpSpan)
	resource := cat(pbBytes(1, otlpKVpb("service.name", "api")), pbBytes(1, otlpKVpb("service.version", "3f9c1a2")),
		pbBytes(1, otlpKVpb("service.instance.id", "api-7d9")))
	panicRec := cat(
		pbFixed64(1, uint64(otlpTS.UnixNano())),
		pbVarint(2, 17), // SEVERITY_NUMBER_ERROR, no severity text
		pbBytes(5, pbStr(1, "request failed")),
		pbBytes(6, otlpKVpb("exception.type", "runtime.Error")),
		pbBytes(6, otlpKVpb("exception.message", "assignment to entry in nil map")),
		pbBytes(6, otlpKVpb("exception.stacktrace", "goroutine 1 [running]:\nmain.main()\n\t/app/main.go:12 +0x1d")),
		pbBytes(6, otlpKVpb("http.request.header.authorization", "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.c2lnbmF0dXJlLXZhbHVl")),
		pbBytes(9, trace), pbBytes(10, span),
	)
	kvlist := cat(pbBytes(1, otlpKVpb("msg", "db timeout")), pbBytes(1, append(pbStr(1, "attempt"), pbBytes(2, pbVarint(3, 3))...)))
	structured := cat(
		pbFixed64(11, uint64(otlpTS.Add(time.Second).UnixNano())), // observed time only
		pbStr(3, "WARN"),
		pbBytes(5, pbBytes(6, kvlist)),
	)
	scope := cat(pbBytes(1, pbStr(1, "app/handlers")), pbBytes(2, panicRec), pbBytes(2, structured))
	return pbBytes(1, cat(pbBytes(1, resource), pbBytes(2, scope)))
}

func TestParseOTLPProto(t *testing.T) {
	es, rejected, err := ParseOTLPLogs(bytes.NewReader(otlpRequest()), "application/x-protobuf", "", "src", time.Now())
	if err != nil || rejected != 0 || len(es) != 2 {
		t.Fatalf("%+v %d %v", es, rejected, err)
	}
	p := es[0]
	if p.Service != "api" || p.Revision != "3f9c1a2" || p.Level != "error" || !p.Time.Equal(otlpTS) {
		t.Errorf("panic entry %+v", p)
	}
	if p.TraceID != otlpTrace || p.SpanID != otlpSpan {
		t.Errorf("ids %q %q", p.TraceID, p.SpanID)
	}
	want := "request failed\nruntime.Error: assignment to entry in nil map\ngoroutine 1 [running]:\nmain.main()\n\t/app/main.go:12 +0x1d"
	if p.Message != want {
		t.Errorf("message %q", p.Message)
	}
	if p.Stream != "api/api-7d9/app/handlers" {
		t.Errorf("stream %q", p.Stream)
	}
	if len(p.Extra) != 1 || !strings.Contains(p.Extra[0], "Bearer eyJ") {
		t.Errorf("attributes for the detectors %q", p.Extra)
	}
	s := es[1]
	if s.Level != "WARN" || !s.Time.Equal(otlpTS.Add(time.Second)) || s.TraceID != "" {
		t.Errorf("structured entry %+v", s)
	}
	if s.Message != `{"attempt":3,"msg":"db timeout"}` {
		t.Errorf("kvlist body %q", s.Message)
	}
}

func TestParseOTLPJSONGzip(t *testing.T) {
	body := `{"resourceLogs":[{"resource":{"attributes":[{"key":"service.namespace","value":{"stringValue":"shop"}},{"key":"service.name","value":{"stringValue":"web"}}]},
	"scopeLogs":[{"scope":{"name":"x"},"logRecords":[
	  {"timeUnixNano":"1793696400000000000","severityNumber":"SEVERITY_NUMBER_FATAL","body":{"stringValue":"panic: boom"},"traceId":"4BF92F3577B34DA6A3CE929D0E0E4736","spanId":"zz"},
	  {"severityNumber":9,"body":{"arrayValue":{"values":[{"stringValue":"a"},{"intValue":"2"}]}},"traceId":"00000000000000000000000000000000"}
	]}]}]}`
	var gz bytes.Buffer
	zw := gzip.NewWriter(&gz)
	_, _ = zw.Write([]byte(body))
	_ = zw.Close()
	now := time.Date(2026, 11, 3, 12, 0, 0, 0, time.UTC)
	es, _, err := ParseOTLPLogs(&gz, "application/json", "gzip", "src", now)
	if err != nil || len(es) != 2 {
		t.Fatalf("%+v %v", es, err)
	}
	if es[0].Service != "shop/web" || es[0].Level != "fatal" || es[0].Time.Unix() != 1793696400 || es[0].TraceID != otlpTrace || es[0].SpanID != "" {
		t.Errorf("first %+v", es[0])
	}
	if es[1].Level != "info" || !es[1].Time.Equal(now) || es[1].Message != `["a",2]` || es[1].TraceID != "" {
		t.Errorf("second %+v", es[1])
	}
}

func TestParseOTLPDefaultsAndErrors(t *testing.T) {
	// No resource attributes: the source's name is the service.
	rec := pbBytes(2, pbBytes(5, pbStr(1, "hello")))
	es, _, err := ParseOTLPLogs(bytes.NewReader(pbBytes(1, pbBytes(2, rec))), "application/x-protobuf", "", "shipper", time.Now())
	if err != nil || len(es) != 1 || es[0].Service != "shipper" || es[0].Message != "hello" {
		t.Fatalf("%+v %v", es, err)
	}
	if _, _, err := ParseOTLPLogs(strings.NewReader("\x0a\xff\xff"), "application/x-protobuf", "", "", time.Now()); err == nil {
		t.Error("truncated protobuf must fail")
	}
	if _, _, err := ParseOTLPLogs(strings.NewReader("{"), "application/json", "", "", time.Now()); err == nil {
		t.Error("bad JSON must fail")
	}
	// A value nested deeper than the limit is refused, not recursed into.
	deep := pbStr(1, "x")
	for range otlpMaxDepth + 2 {
		deep = pbBytes(5, pbBytes(1, deep))
	}
	deepRec := pbBytes(2, pbBytes(5, deep))
	if _, _, err := ParseOTLPLogs(bytes.NewReader(pbBytes(1, pbBytes(2, deepRec))), "application/x-protobuf", "", "", time.Now()); err == nil {
		t.Error("too deep must fail")
	}
}

func TestParseOTLPCap(t *testing.T) {
	rec := pbBytes(2, pbBytes(5, pbStr(1, "x")))
	scope := bytes.Repeat(rec, MaxPushEntries+5)
	es, rejected, err := ParseOTLPLogs(bytes.NewReader(pbBytes(1, pbBytes(2, scope))), "application/x-protobuf", "", "", time.Now())
	if err != nil || len(es) != MaxPushEntries || rejected != 5 {
		t.Fatalf("%d %d %v", len(es), rejected, err)
	}
}

func TestOTLPResponse(t *testing.T) {
	if got := OTLPResponse(false, 0, ""); len(got) != 0 {
		t.Errorf("empty protobuf response %x", got)
	}
	if got := string(OTLPResponse(true, 0, "")); got != "{}" {
		t.Errorf("empty JSON response %s", got)
	}
	if got := string(OTLPResponse(true, 5, "cap")); got != `{"partialSuccess":{"errorMessage":"cap","rejectedLogRecords":"5"}}` {
		t.Errorf("JSON partial success %s", got)
	}
	// ExportLogsServiceResponse{ partial_success = 1 { rejected = 1; message = 2 } }
	var rejected uint64
	var msg string
	err := pbFields(OTLPResponse(false, 5, "cap"), func(num, wire int, v []byte, _ uint64) error {
		return pbFields(v, func(num, wire int, v []byte, n uint64) error {
			switch num {
			case 1:
				rejected = n
			case 2:
				msg = string(v)
			}
			return nil
		})
	})
	if err != nil || rejected != 5 || msg != "cap" {
		t.Errorf("protobuf partial success %d %q %v", rejected, msg, err)
	}
}
