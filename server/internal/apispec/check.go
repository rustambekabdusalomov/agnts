package apispec

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"net/http"
	"sort"
	"strings"

	"github.com/getkin/kin-openapi/openapi3"
	"github.com/getkin/kin-openapi/openapi3filter"
	"github.com/getkin/kin-openapi/routers"
	"github.com/getkin/kin-openapi/routers/legacy"

	"agnts/internal/domain"
)

// Finding is a response that does not match the spec, with the requests
// that showed it.
type Finding struct {
	Operation string
	Problem   string
	Requests  []string
}

// maxPerFinding caps the requests listed for one finding.
const maxPerFinding = 10

// Check validates every logged response against the spec. The router
// matches requests against the spec's servers, which usually point at
// production, so they are replaced with the test's base URL first:
// otherwise nothing matches and the check passes everything. A logged
// request that matches no operation is reported, not ignored.
func Check(specJSON []byte, baseURL string, log []domain.APIExchange) ([]Finding, error) {
	t, err := load(specJSON)
	if err != nil {
		return nil, err
	}
	t.Servers = openapi3.Servers{{URL: strings.TrimSuffix(baseURL, "/")}}
	router, err := legacy.NewRouter(t)
	if err != nil {
		return nil, fmt.Errorf("route the spec: %w", err)
	}
	byKey := map[string]*Finding{}
	var order []string
	add := func(op, problem, id string) {
		k := op + "\x00" + problem
		f, ok := byKey[k]
		if !ok {
			f = &Finding{Operation: op, Problem: problem}
			byKey[k] = f
			order = append(order, k)
		}
		if len(f.Requests) < maxPerFinding {
			f.Requests = append(f.Requests, id)
		}
	}
	ctx := context.Background()
	for _, e := range log {
		if e.Status == 0 || e.Error != "" {
			continue // no response to check
		}
		req, err := http.NewRequestWithContext(ctx, e.Method, e.URL, nil)
		if err != nil {
			continue
		}
		route, params, err := router.FindRoute(req)
		if err != nil {
			problem := "the request matches no operation in the spec"
			if errors.Is(err, routers.ErrMethodNotAllowed) {
				problem = "the method is not in the spec for this path"
			}
			add(e.Method+" "+req.URL.Path, problem, e.ID)
			continue
		}
		op := e.Method + " " + route.Path
		opts := &openapi3filter.Options{IncludeResponseStatus: true, MultiError: true, AuthenticationFunc: openapi3filter.NoopAuthenticationFunc}
		if e.Truncated {
			opts.ExcludeResponseBody = true
		}
		h := http.Header{}
		for k, v := range e.RespHeaders {
			h.Set(k, v)
		}
		in := &openapi3filter.ResponseValidationInput{
			RequestValidationInput: &openapi3filter.RequestValidationInput{Request: req, PathParams: params, Route: route, Options: opts},
			Status:                 e.Status,
			Header:                 h,
			Body:                   io.NopCloser(bytes.NewReader([]byte(e.RespBody))),
			Options:                opts,
		}
		if err := openapi3filter.ValidateResponse(ctx, in); err != nil {
			for _, p := range problems(err, e.Status) {
				add(op, p, e.ID)
			}
		}
	}
	out := make([]Finding, 0, len(order))
	for _, k := range order {
		out = append(out, *byKey[k])
	}
	sort.SliceStable(out, func(i, j int) bool { return out[i].Operation < out[j].Operation })
	return out, nil
}

// problems turns a validation error into short lines.
func problems(err error, status int) []string {
	var me openapi3.MultiError
	var errs []error
	if errors.As(err, &me) {
		errs = me
	} else {
		errs = []error{err}
	}
	var out []string
	for _, e := range errs {
		var re *openapi3filter.ResponseError
		msg := e.Error()
		if errors.As(e, &re) {
			msg = re.Reason
			if re.Err != nil {
				msg += ": " + re.Err.Error()
			}
		}
		if strings.Contains(msg, "status is not supported") || strings.Contains(msg, "status code") && strings.Contains(msg, "not") {
			msg = fmt.Sprintf("status %d is not documented for this operation", status)
		}
		msg = strings.Join(strings.Fields(msg), " ")
		if len(msg) > 400 {
			msg = strings.ToValidUTF8(msg[:400], "") + "…"
		}
		out = append(out, msg)
	}
	return out
}

// Cases turns findings into cases ("schema-1", ...) for the results.
func Cases(fs []Finding) []domain.APICase {
	out := make([]domain.APICase, 0, len(fs))
	for i, f := range fs {
		out = append(out, domain.APICase{
			ID: fmt.Sprintf("schema-%d", i+1), Operation: f.Operation, Case: "response matches the spec",
			Expected: "the response the spec documents", Verdict: domain.VerdictFail, Reason: f.Problem,
			Requests: f.Requests, Source: domain.CaseBySchema,
		})
	}
	return out
}
