package ai

import (
	"encoding/json"
	"strings"

	"agnts/internal/domain"
)

// EnvValues returns the values of KEY=value pairs.
func EnvValues(env []string) []string {
	out := make([]string, 0, len(env))
	for _, kv := range env {
		if _, v, ok := strings.Cut(kv, "="); ok {
			out = append(out, v)
		}
	}
	return out
}

// MaskEvents wraps an event handler so the secrets r knows never reach it:
// in the text, the tool summary, and anywhere in the data (tool inputs and
// outputs included).
func MaskEvents(r domain.Redactor, onEvent func(Event)) func(Event) {
	if onEvent == nil || r.Empty() {
		return onEvent
	}
	return func(e Event) {
		onEvent(maskEvent(r, e))
	}
}

func maskEvent(r domain.Redactor, e Event) Event {
	e.Text = r.String(e.Text)
	e.Tool = r.String(e.Tool)
	if len(e.Data) == 0 {
		return e
	}
	b, err := json.Marshal(e.Data)
	if err != nil {
		return e
	}
	masked := r.Bytes(b)
	if string(masked) == string(b) {
		return e
	}
	var d map[string]any
	if json.Unmarshal(masked, &d) == nil {
		e.Data = d
	} else {
		e.Data = map[string]any{} // never pass on what could not be masked
	}
	return e
}
