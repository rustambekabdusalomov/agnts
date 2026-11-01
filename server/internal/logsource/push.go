package logsource

import (
	"bufio"
	"bytes"
	"compress/gzip"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Push limits.
const (
	MaxPushBody    = 5 << 20  // compressed, as received
	MaxPushRaw     = 20 << 20 // after decompression
	MaxPushEntries = 20000
)

// ErrPushTooLarge is a push over the limits.
var ErrPushTooLarge = errors.New("push body too large")

var (
	pushMessageKeys = []string{"message", "msg", "log", "_msg", "short_message", "full_message"}
	pushTimeKeys    = []string{"@timestamp", "timestamp", "time", "ts", "date", "_time"}
	pushServiceKeys = []string{"service", "service.name", "container_name", "kubernetes.container_name", "app", "application", "source", "host"}
	pushStreamKeys  = []string{"container_id", "kubernetes.pod_name", "pod", "host", "hostname"}
)

// ParsePush reads what a log shipper sent: NDJSON, a JSON array, or plain
// text lines, maybe gzipped. defService names entries that don't.
func ParsePush(body io.Reader, contentType, contentEncoding, defService string, now time.Time) ([]domain.LogEntry, error) {
	raw, err := io.ReadAll(io.LimitReader(body, MaxPushBody+1))
	if err != nil {
		return nil, err
	}
	if len(raw) > MaxPushBody {
		return nil, ErrPushTooLarge
	}
	if strings.Contains(strings.ToLower(contentEncoding), "gzip") || (len(raw) > 2 && raw[0] == 0x1f && raw[1] == 0x8b) {
		zr, err := gzip.NewReader(bytes.NewReader(raw))
		if err != nil {
			return nil, fmt.Errorf("gzip: %w", err)
		}
		raw, err = io.ReadAll(io.LimitReader(zr, MaxPushRaw+1))
		if err != nil {
			return nil, fmt.Errorf("gzip: %w", err)
		}
		if len(raw) > MaxPushRaw {
			return nil, ErrPushTooLarge
		}
	}
	trimmed := bytes.TrimSpace(raw)
	if defService == "" {
		defService = "push"
	}
	var out []domain.LogEntry
	add := func(e domain.LogEntry) error {
		if len(out) >= MaxPushEntries {
			return ErrPushTooLarge
		}
		out = append(out, e)
		return nil
	}
	isText := strings.HasPrefix(strings.ToLower(contentType), "text/plain")
	switch {
	case !isText && len(trimmed) > 0 && trimmed[0] == '[':
		var arr []json.RawMessage
		if err := json.Unmarshal(trimmed, &arr); err != nil {
			return nil, fmt.Errorf("JSON array: %w", err)
		}
		for _, item := range arr {
			if err := add(pushEntry(item, defService, now)); err != nil {
				return nil, err
			}
		}
	case !isText && len(trimmed) > 0 && trimmed[0] == '{':
		sc := bufio.NewScanner(bytes.NewReader(trimmed))
		sc.Buffer(make([]byte, 64<<10), 4<<20)
		for sc.Scan() {
			line := bytes.TrimSpace(sc.Bytes())
			if len(line) == 0 {
				continue
			}
			if err := add(pushEntry(line, defService, now)); err != nil {
				return nil, err
			}
		}
		if err := sc.Err(); err != nil {
			return nil, err
		}
	default:
		for i, line := range strings.Split(string(trimmed), "\n") {
			line = strings.TrimRight(line, "\r")
			if line == "" {
				continue
			}
			if err := add(domain.LogEntry{Time: now.Add(time.Duration(i) * time.Microsecond), Service: defService, Stream: defService, Message: line}); err != nil {
				return nil, err
			}
		}
	}
	return out, nil
}

// pushEntry reads one JSON object. The message stays the whole object
// (domain.ParseLogEntry reads its fields), unless the message field is
// itself a JSON object a shipper wrapped (Docker's {"log": "{...}"}).
func pushEntry(raw []byte, defService string, now time.Time) domain.LogEntry {
	e := domain.LogEntry{Time: now, Service: defService, Message: string(raw)}
	var m map[string]any
	if json.Unmarshal(raw, &m) != nil {
		return e
	}
	str := func(keys []string) string {
		for _, k := range keys {
			if v, ok := pick(m, k); ok {
				if s, ok := v.(string); ok && s != "" {
					return s
				}
			}
		}
		return ""
	}
	if s := str(pushServiceKeys); s != "" {
		e.Service = s
	}
	e.Stream = e.Service + "/" + str(pushStreamKeys)
	for _, k := range pushTimeKeys {
		if v, ok := pick(m, k); ok {
			if t := parseTime(v); !t.IsZero() {
				e.Time = t
				break
			}
		}
	}
	for _, k := range pushMessageKeys {
		if s, ok := m[k].(string); ok && strings.HasPrefix(strings.TrimSpace(s), "{") && json.Valid([]byte(strings.TrimSpace(s))) {
			e.Message = strings.TrimSpace(s)
			break
		}
	}
	if lv := str([]string{"level", "severity", "log.level"}); lv != "" {
		e.Level = lv
	}
	return e
}

func pick(m map[string]any, key string) (any, bool) {
	if v, ok := m[key]; ok {
		return v, true
	}
	head, rest, ok := strings.Cut(key, ".")
	if !ok {
		return nil, false
	}
	sub, ok := m[head].(map[string]any)
	if !ok {
		return nil, false
	}
	return pick(sub, rest)
}
