package apispec

import (
	"encoding/json"
	"strings"

	"agnts/internal/domain"
)

// TrimCap is the size the run's spec is cut down to: a large spec would not
// fit in Claude's context.
const TrimCap = 200 << 10

// maxDescription shortens descriptions in the trimmed spec.
const maxDescription = 300

// Trim builds the run's spec: the ticked operations (path-level parameters
// kept), the components they refer to, descriptions shortened. Over
// maxBytes it returns the operation list only, and full is true: the run
// then also gets the whole spec, read one operation at a time with
// agnts-api describe.
func Trim(specJSON []byte, ops []string, maxBytes int) (out []byte, full bool, err error) {
	var doc map[string]any
	if err := json.Unmarshal(specJSON, &doc); err != nil {
		return nil, false, err
	}
	want := map[string]map[string]bool{}
	for _, s := range ops {
		if o, ok := domain.ParseOperation(s); ok {
			if want[o.Path] == nil {
				want[o.Path] = map[string]bool{}
			}
			want[o.Path][strings.ToLower(o.Method)] = true
		}
	}
	paths, _ := doc["paths"].(map[string]any)
	kept := map[string]any{}
	var list []map[string]any
	for p, raw := range paths {
		methods := want[p]
		item, _ := raw.(map[string]any)
		if methods == nil || item == nil {
			continue
		}
		ni := map[string]any{}
		for k, v := range item {
			if methods[k] {
				ni[k] = v
				o, _ := v.(map[string]any)
				entry := map[string]any{"operation": strings.ToUpper(k) + " " + p}
				for _, f := range []string{"operationId", "summary", "tags"} {
					if x, ok := o[f]; ok {
						entry[f] = x
					}
				}
				list = append(list, entry)
			} else if k == "parameters" || k == "servers" {
				ni[k] = v
			}
		}
		kept[p] = ni
	}
	trimmed := map[string]any{"openapi": doc["openapi"], "paths": kept}
	if info, ok := doc["info"].(map[string]any); ok {
		trimmed["info"] = map[string]any{"title": info["title"], "version": info["version"]}
	}
	if sec, ok := doc["security"]; ok {
		trimmed["security"] = sec
	}
	comps, _ := doc["components"].(map[string]any)
	used := map[string]any{}
	var queue []string
	collect(kept, &queue)
	if sec, ok := doc["security"]; ok {
		collect(sec, &queue)
	}
	seen := map[string]bool{}
	for len(queue) > 0 {
		r := queue[0]
		queue = queue[1:]
		if seen[r] {
			continue
		}
		seen[r] = true
		group, name, ok := strings.Cut(strings.TrimPrefix(r, "#/components/"), "/")
		if !ok {
			continue
		}
		g, _ := comps[group].(map[string]any)
		v, ok := g[unescape(name)]
		if !ok {
			continue
		}
		ug, _ := used[group].(map[string]any)
		if ug == nil {
			ug = map[string]any{}
			used[group] = ug
		}
		ug[unescape(name)] = v
		collect(v, &queue)
	}
	if ss, ok := comps["securitySchemes"]; ok {
		used["securitySchemes"] = ss
	}
	if len(used) > 0 {
		trimmed["components"] = used
	}
	shorten(trimmed)
	if out, err = json.Marshal(trimmed); err != nil {
		return nil, false, err
	}
	if len(out) <= maxBytes {
		return out, false, nil
	}
	out, err = json.Marshal(map[string]any{
		"note":       "The spec is too large to give whole: these are the operations to test. Read each one with `agnts-api describe <METHOD /path>`.",
		"operations": list,
	})
	return out, true, err
}

// collect adds the component refs under v to queue.
func collect(v any, queue *[]string) {
	walk(v, func(m map[string]any) {
		if r, ok := m["$ref"].(string); ok && strings.HasPrefix(r, "#/components/") {
			*queue = append(*queue, r)
		}
	})
}

// unescape reads a JSON pointer segment.
func unescape(s string) string {
	return strings.ReplaceAll(strings.ReplaceAll(s, "~1", "/"), "~0", "~")
}

// shorten cuts long descriptions and drops examples sets, in place.
func shorten(v any) {
	switch x := v.(type) {
	case map[string]any:
		for k, e := range x {
			if s, ok := e.(string); ok && k == "description" && len(s) > maxDescription {
				x[k] = strings.ToValidUTF8(s[:maxDescription], "") + "…"
				continue
			}
			if k == "examples" {
				delete(x, k)
				continue
			}
			shorten(e)
		}
	case []any:
		for _, e := range x {
			shorten(e)
		}
	}
}
