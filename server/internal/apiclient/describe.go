package apiclient

import (
	"encoding/json"
	"fmt"
	"slices"
	"strings"

	"agnts/internal/domain"
)

// Describe returns one operation of an OpenAPI 3 document (JSON) with every
// component it refers to, directly or through other components.
func Describe(spec []byte, operation string) ([]byte, error) {
	op, ok := domain.ParseOperation(operation)
	if !ok {
		return nil, fmt.Errorf("give the operation as METHOD /path, e.g. GET /users/{id}")
	}
	var doc map[string]any
	if err := json.Unmarshal(spec, &doc); err != nil {
		return nil, fmt.Errorf("the spec: %w", err)
	}
	paths, _ := doc["paths"].(map[string]any)
	item, _ := paths[op.Path].(map[string]any)
	o, ok := item[strings.ToLower(op.Method)]
	if !ok {
		return nil, fmt.Errorf("%s is not in the spec", op)
	}
	out := map[string]any{"operation": op.String(), "definition": o}
	if params, ok := item["parameters"]; ok {
		out["pathParameters"] = params
	}
	components := map[string]any{}
	comps, _ := doc["components"].(map[string]any)
	var queue []string
	collectRefs(o, &queue)
	collectRefs(item["parameters"], &queue)
	seen := map[string]bool{}
	for len(queue) > 0 && len(seen) < 300 {
		r := queue[0]
		queue = queue[1:]
		if seen[r] {
			continue
		}
		seen[r] = true
		parts := strings.Split(strings.TrimPrefix(r, "#/components/"), "/")
		if len(parts) != 2 {
			continue
		}
		group, _ := comps[parts[0]].(map[string]any)
		v, ok := group[parts[1]]
		if !ok {
			continue
		}
		g, _ := components[parts[0]].(map[string]any)
		if g == nil {
			g = map[string]any{}
			components[parts[0]] = g
		}
		g[parts[1]] = v
		collectRefs(v, &queue)
	}
	if len(components) > 0 {
		out["components"] = components
	}
	return json.MarshalIndent(out, "", "  ")
}

func collectRefs(v any, out *[]string) {
	switch x := v.(type) {
	case map[string]any:
		if r, ok := x["$ref"].(string); ok && strings.HasPrefix(r, "#/components/") && !slices.Contains(*out, r) {
			*out = append(*out, r)
		}
		for _, e := range x {
			collectRefs(e, out)
		}
	case []any:
		for _, e := range x {
			collectRefs(e, out)
		}
	}
}
