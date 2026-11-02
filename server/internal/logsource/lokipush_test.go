package logsource

import (
	"encoding/binary"
	"strings"
	"testing"
	"time"
)

func pbVarint(num int, n uint64) []byte {
	b := binary.AppendUvarint(nil, uint64(num<<3))
	return binary.AppendUvarint(b, n)
}

func pbBytes(num int, v []byte) []byte {
	b := binary.AppendUvarint(nil, uint64(num<<3|2))
	b = binary.AppendUvarint(b, uint64(len(v)))
	return append(b, v...)
}

// snappyLiteral encodes src as one literal, then copies its first four
// bytes once (so both element kinds are decoded).
func snappyLiteral(src []byte) []byte {
	out := binary.AppendUvarint(nil, uint64(len(src)+4))
	l := len(src) - 1
	switch {
	case l < 60:
		out = append(out, byte(l<<2))
	case l < 256:
		out = append(out, 60<<2, byte(l))
	default:
		out = append(out, 61<<2, byte(l), byte(l>>8))
	}
	out = append(out, src...)
	// copy with a 2-byte offset: length 4, offset len(src)
	out = append(out, byte((4-1)<<2|2), byte(len(src)), byte(len(src)>>8))
	return out
}

func TestParseLokiPushProto(t *testing.T) {
	ts := time.Date(2026, 11, 2, 9, 0, 0, 500, time.UTC)
	stamp := append(pbVarint(1, uint64(ts.Unix())), pbVarint(2, uint64(ts.Nanosecond()))...)
	entry := append(pbBytes(1, stamp), pbBytes(2, []byte("panic: boom"))...)
	stream := append(pbBytes(1, []byte(`{service_name="api", level="error", note="a \"quoted\" one"}`)), pbBytes(2, entry)...)
	req := pbBytes(1, stream)
	es, err := ParseLokiPush(strings.NewReader(string(snappyOnly(req))), "application/x-protobuf", "snappy", "")
	if err != nil {
		t.Fatal(err)
	}
	if len(es) != 1 || es[0].Service != "api" || es[0].Level != "error" || es[0].Message != "panic: boom" || !es[0].Time.Equal(ts) {
		t.Fatalf("entries %+v", es)
	}
	if !strings.Contains(es[0].Stream, `note=a "quoted" one`) {
		t.Errorf("labels %q", es[0].Stream)
	}
	if _, err := ParseLokiPush(strings.NewReader("\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"), "application/x-protobuf", "snappy", ""); err == nil {
		t.Error("garbage must fail")
	}
}

// snappyOnly encodes src as literals only.
func snappyOnly(src []byte) []byte {
	out := binary.AppendUvarint(nil, uint64(len(src)))
	for len(src) > 0 {
		n := min(len(src), 256)
		l := n - 1
		if l < 60 {
			out = append(out, byte(l<<2))
		} else {
			out = append(out, 60<<2, byte(l))
		}
		out = append(out, src[:n]...)
		src = src[n:]
	}
	return out
}

func TestSnappyCopy(t *testing.T) {
	got, err := snappyDecode(snappyLiteral([]byte("abcdefgh")), 100)
	if err != nil || string(got) != "abcdefghabcd" {
		t.Fatalf("%q %v", got, err)
	}
	if _, err := snappyDecode(snappyLiteral([]byte("abcdefgh")), 5); err == nil {
		t.Error("over the size cap must fail")
	}
}

func TestParseLokiPushJSON(t *testing.T) {
	body := `{"streams":[{"stream":{"app":"web"},"values":[["1730538000000000000","ERROR boom"],["x","bad"]]}]}`
	es, err := ParseLokiPush(strings.NewReader(body), "application/json", "", "")
	if err != nil || len(es) != 1 || es[0].Service != "web" || es[0].Message != "ERROR boom" {
		t.Fatalf("%+v %v", es, err)
	}
}
