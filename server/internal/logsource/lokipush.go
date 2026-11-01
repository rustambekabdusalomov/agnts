package logsource

import (
	"bytes"
	"compress/gzip"
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
)

// ParseLokiPush reads Loki's push API as Promtail and Grafana Alloy send
// it: a snappy-compressed protobuf PushRequest, or its JSON form
// ({"streams":[{"stream":{labels},"values":[[ns, line]]}]}).
func ParseLokiPush(body io.Reader, contentType, contentEncoding, defService string) ([]domain.LogEntry, error) {
	raw, err := io.ReadAll(io.LimitReader(body, MaxPushBody+1))
	if err != nil {
		return nil, err
	}
	if len(raw) > MaxPushBody {
		return nil, ErrPushTooLarge
	}
	if defService == "" {
		defService = "push"
	}
	if strings.Contains(strings.ToLower(contentType), "json") {
		if strings.Contains(strings.ToLower(contentEncoding), "gzip") {
			zr, err := gzip.NewReader(bytes.NewReader(raw))
			if err != nil {
				return nil, fmt.Errorf("gzip: %w", err)
			}
			if raw, err = io.ReadAll(io.LimitReader(zr, MaxPushRaw+1)); err != nil {
				return nil, err
			}
			if len(raw) > MaxPushRaw {
				return nil, ErrPushTooLarge
			}
		}
		return lokiPushJSON(raw, defService)
	}
	plain, err := snappyDecode(raw, MaxPushRaw)
	if err != nil {
		return nil, fmt.Errorf("snappy: %w", err)
	}
	return lokiPushProto(plain, defService)
}

func lokiPushJSON(raw []byte, defService string) ([]domain.LogEntry, error) {
	var req struct {
		Streams []struct {
			Stream map[string]string   `json:"stream"`
			Values [][]json.RawMessage `json:"values"`
		} `json:"streams"`
	}
	if err := json.Unmarshal(raw, &req); err != nil {
		return nil, fmt.Errorf("loki push JSON: %w", err)
	}
	var out []domain.LogEntry
	for _, s := range req.Streams {
		svc, level, stream := lokiStream(s.Stream, defService)
		for _, v := range s.Values {
			if len(v) < 2 {
				continue
			}
			var ns, line string
			if json.Unmarshal(v[0], &ns) != nil || json.Unmarshal(v[1], &line) != nil {
				continue
			}
			t, err := parseNanos(ns)
			if err != nil {
				continue
			}
			if len(out) >= MaxPushEntries {
				return nil, ErrPushTooLarge
			}
			out = append(out, domain.LogEntry{Time: t, Service: svc, Stream: stream, Level: level, Message: line})
		}
	}
	return out, nil
}

// lokiStream names an entry's service and level from its stream labels.
func lokiStream(labels map[string]string, defService string) (svc, level, stream string) {
	svc = defService
	for _, k := range serviceLabels {
		if v := labels[k]; v != "" {
			svc = v
			break
		}
	}
	for _, k := range []string{"level", "detected_level", "severity"} {
		if v := labels[k]; v != "" {
			level = v
			break
		}
	}
	return svc, level, labelString(labels)
}

// parseLabels reads Loki's label string: {app="api", env="prod"}.
func parseLabels(s string) map[string]string {
	out := map[string]string{}
	s = strings.TrimSpace(strings.TrimSuffix(strings.TrimPrefix(strings.TrimSpace(s), "{"), "}"))
	for s != "" {
		eq := strings.Index(s, "=")
		if eq < 0 {
			break
		}
		key := strings.TrimSpace(s[:eq])
		rest := strings.TrimSpace(s[eq+1:])
		if !strings.HasPrefix(rest, `"`) {
			break
		}
		// Find the closing quote, honouring escapes.
		end := 1
		for end < len(rest) && rest[end] != '"' {
			if rest[end] == '\\' {
				end++
			}
			end++
		}
		if end >= len(rest) {
			break
		}
		if v, err := strconv.Unquote(rest[:end+1]); err == nil {
			out[key] = v
		}
		s = strings.TrimSpace(strings.TrimPrefix(strings.TrimSpace(rest[end+1:]), ","))
	}
	return out
}

// lokiPushProto reads a PushRequest:
//
//	PushRequest  { repeated StreamAdapter streams = 1; }
//	StreamAdapter{ string labels = 1; repeated EntryAdapter entries = 2; }
//	EntryAdapter { Timestamp timestamp = 1; string line = 2; }
//	Timestamp    { int64 seconds = 1; int32 nanos = 2; }
func lokiPushProto(b []byte, defService string) ([]domain.LogEntry, error) {
	var out []domain.LogEntry
	err := pbFields(b, func(num int, wire int, v []byte, _ uint64) error {
		if num != 1 || wire != 2 {
			return nil
		}
		var labels string
		var entries [][]byte
		if err := pbFields(v, func(num, wire int, v []byte, _ uint64) error {
			switch {
			case num == 1 && wire == 2:
				labels = string(v)
			case num == 2 && wire == 2:
				entries = append(entries, v)
			}
			return nil
		}); err != nil {
			return err
		}
		svc, level, stream := lokiStream(parseLabels(labels), defService)
		for _, e := range entries {
			var sec, nanos int64
			var line string
			if err := pbFields(e, func(num, wire int, v []byte, _ uint64) error {
				switch {
				case num == 1 && wire == 2:
					return pbFields(v, func(num, wire int, _ []byte, n uint64) error {
						if wire == 0 && num == 1 {
							sec = int64(n) //nolint:gosec // G115: protobuf int64 is sent as its two's complement
						} else if wire == 0 && num == 2 {
							nanos = int64(n) //nolint:gosec // G115: as above; time.Unix normalizes it
						}
						return nil
					})
				case num == 2 && wire == 2:
					line = string(v)
				}
				return nil
			}); err != nil {
				return err
			}
			if len(out) >= MaxPushEntries {
				return ErrPushTooLarge
			}
			out = append(out, domain.LogEntry{Time: time.Unix(sec, nanos).UTC(), Service: svc, Stream: stream, Level: level, Message: line})
		}
		return nil
	})
	return out, err
}

var errProto = errors.New("malformed protobuf")

// pbFields walks one protobuf message's fields: fn gets the field
// number, the wire type, the bytes of a length-delimited field and the
// value of a varint one.
func pbFields(b []byte, fn func(num, wire int, v []byte, n uint64) error) error {
	for len(b) > 0 {
		tag, k := binary.Uvarint(b)
		if k <= 0 {
			return errProto
		}
		b = b[k:]
		num, wire := int(tag>>3), int(tag&7)
		switch wire {
		case 0:
			n, k := binary.Uvarint(b)
			if k <= 0 {
				return errProto
			}
			b = b[k:]
			if err := fn(num, wire, nil, n); err != nil {
				return err
			}
		case 1:
			if len(b) < 8 {
				return errProto
			}
			b = b[8:]
		case 2:
			n, k := binary.Uvarint(b)
			if k <= 0 || n > uint64(len(b)-k) { //nolint:gosec // G115: len(b)-k >= 0 here
				return errProto
			}
			end := k + int(n) //nolint:gosec // G115: n <= len(b)-k, checked above
			v := b[k:end]
			b = b[end:]
			if err := fn(num, wire, v, 0); err != nil {
				return err
			}
		case 5:
			if len(b) < 4 {
				return errProto
			}
			b = b[4:]
		default:
			return errProto
		}
	}
	return nil
}

// snappyDecode decodes a snappy block (not the framed format), refusing
// output over max.
func snappyDecode(src []byte, max int) ([]byte, error) {
	n64, k := binary.Uvarint(src)
	if k <= 0 || max < 0 || n64 > uint64(max) {
		return nil, errors.New("bad or too large length")
	}
	n := int(n64) //nolint:gosec // G115: n64 <= max, an int
	src = src[k:]
	dst := make([]byte, 0, n)
	for len(src) > 0 {
		tag := src[0]
		switch tag & 3 {
		case 0: // literal
			l := int(tag >> 2)
			src = src[1:]
			if l >= 60 {
				w := l - 59
				if len(src) < w {
					return nil, errors.New("truncated literal")
				}
				l = 0
				for i := 0; i < w; i++ {
					l |= int(src[i]) << (8 * i)
				}
				src = src[w:]
			}
			l++
			if l > len(src) || len(dst)+l > n {
				return nil, errors.New("literal out of range")
			}
			dst = append(dst, src[:l]...)
			src = src[l:]
		default:
			var length, offset int
			switch tag & 3 {
			case 1:
				if len(src) < 2 {
					return nil, errors.New("truncated copy")
				}
				length, offset = int(tag>>2&7)+4, int(tag>>5)<<8|int(src[1])
				src = src[2:]
			case 2:
				if len(src) < 3 {
					return nil, errors.New("truncated copy")
				}
				length, offset = int(tag>>2)+1, int(binary.LittleEndian.Uint16(src[1:3]))
				src = src[3:]
			case 3:
				if len(src) < 5 {
					return nil, errors.New("truncated copy")
				}
				length, offset = int(tag>>2)+1, int(binary.LittleEndian.Uint32(src[1:5]))
				src = src[5:]
			}
			if offset <= 0 || offset > len(dst) || len(dst)+length > n {
				return nil, errors.New("copy out of range")
			}
			for i := 0; i < length; i++ {
				dst = append(dst, dst[len(dst)-offset])
			}
		}
	}
	if len(dst) != n {
		return nil, errors.New("length mismatch")
	}
	return dst, nil
}
