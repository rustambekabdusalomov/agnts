package httpapi

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"agnts/internal/apiclient"
	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// Swagger runs Swagger tests (the orchestrator).
type Swagger interface {
	FetchSpec(ctx context.Context, rawURL string, cred *apiclient.Credential) (orchestrator.SpecResult, error)
	UploadSpec(ctx context.Context, raw []byte) (string, orchestrator.SpecResult, error)
	CreateSwaggerTest(ctx context.Context, in orchestrator.SwaggerTestInput, origin domain.Origin) (domain.Ticket, error)
	RerunSwaggerTest(ctx context.Context, key string, cred *string, origin domain.Origin) (domain.Ticket, error)
	SwaggerResultsOf(ctx context.Context, key string) (orchestrator.SwaggerView, error)
	SwaggerExchange(ctx context.Context, key, id string) (domain.APIExchange, error)
}

// maxSpecBody caps the spec upload: 5 MB of spec, JSON-escaped.
const maxSpecBody = 8 << 20

func (s *Server) swaggerReady(w http.ResponseWriter) bool {
	if s.opt.Swagger == nil {
		writeError(w, http.StatusNotImplemented, "not_implemented", "Swagger tests are not available on this server")
		return false
	}
	return true
}

// ReadSwaggerSpec implements gen.ServerInterface.
func (s *Server) ReadSwaggerSpec(w http.ResponseWriter, r *http.Request) {
	if !s.swaggerReady(w) {
		return
	}
	var req gen.SwaggerSpecInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var (
		res orchestrator.SpecResult
		ref string
		err error
	)
	switch {
	case req.Spec != nil && strings.TrimSpace(*req.Spec) != "":
		ref, res, err = s.opt.Swagger.UploadSpec(r.Context(), []byte(*req.Spec))
	case req.Url != nil && strings.TrimSpace(*req.Url) != "":
		var cred *apiclient.Credential
		switch {
		case req.Login != nil && (req.Login.Username != "" || deref(req.Login.Password) != ""):
			if strings.Contains(req.Login.Username, ":") {
				writeError(w, http.StatusBadRequest, "bad_request", "the login cannot contain a colon")
				return
			}
			cred = &apiclient.Credential{Kind: domain.AuthBasic, Value: req.Login.Username + ":" + deref(req.Login.Password)}
		case req.Auth != nil && req.Auth.Value != nil && *req.Auth.Value != "":
			cred = &apiclient.Credential{Kind: domain.APIAuthKind(req.Auth.Kind), Name: deref(req.Auth.Name), Value: *req.Auth.Value}
		}
		res, err = s.opt.Swagger.FetchSpec(r.Context(), *req.Url, cred)
		ref = res.Ref
	default:
		writeError(w, http.StatusBadRequest, "bad_request", "give the spec's url, or upload the spec")
		return
	}
	if errors.Is(err, orchestrator.ErrSpecFetchLimit) {
		writeError(w, http.StatusTooManyRequests, "too_many_requests", err.Error())
		return
	}
	if errors.Is(err, orchestrator.ErrSpecNeedsLogin) {
		writeError(w, http.StatusBadRequest, "spec_needs_login", err.Error())
		return
	}
	if errors.Is(err, orchestrator.ErrSpecNeedsAuth) {
		// 400, not 401: a 401 would sign the person out of agnts.
		writeError(w, http.StatusBadRequest, "spec_needs_auth", err.Error())
		return
	}
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toSwaggerSpec(res, ref))
}

func toSwaggerSpec(res orchestrator.SpecResult, ref string) gen.SwaggerSpec {
	out := gen.SwaggerSpec{Operations: []gen.SwaggerOperation{}, Servers: []gen.SwaggerServer{}, SecuritySchemes: []gen.SwaggerSecurityScheme{},
		Choices: []struct {
			Name *string `json:"name,omitempty"`
			Url  string  `json:"url"`
		}{}}
	if ref != "" {
		out.SpecRef = &ref
	}
	if res.URL != "" {
		out.Url = &res.URL
	}
	for _, c := range res.Choices {
		out.Choices = append(out.Choices, struct {
			Name *string `json:"name,omitempty"`
			Url  string  `json:"url"`
		}{Name: nonEmpty(c.Name), Url: c.URL})
	}
	d := res.Doc
	if d == nil {
		return out
	}
	out.Title, out.Version, out.Format = nonEmpty(d.Title), nonEmpty(d.Version), nonEmpty(d.Format)
	for _, sv := range d.Servers {
		g := gen.SwaggerServer{Url: sv.URL, Description: nonEmpty(sv.Description)}
		if len(sv.Variables) > 0 {
			vars := make([]struct {
				Default string    `json:"default"`
				Enum    *[]string `json:"enum,omitempty"`
				Name    string    `json:"name"`
			}, 0, len(sv.Variables))
			for _, v := range sv.Variables {
				e := v.Enum
				vars = append(vars, struct {
					Default string    `json:"default"`
					Enum    *[]string `json:"enum,omitempty"`
					Name    string    `json:"name"`
				}{Default: v.Default, Enum: &e, Name: v.Name})
			}
			g.Variables = &vars
		}
		out.Servers = append(out.Servers, g)
	}
	for _, o := range d.Operations {
		op := gen.SwaggerOperation{Method: o.Method, Path: o.Path, Default: o.Default, OperationId: nonEmpty(o.OperationID),
			Summary: nonEmpty(o.Summary), SideEffect: nonEmpty(o.SideEffect)}
		if o.Deprecated {
			op.Deprecated = &o.Deprecated
		}
		if len(o.Tags) > 0 {
			op.Tags = &o.Tags
		}
		if len(o.Security) > 0 {
			op.Security = &o.Security
		}
		out.Operations = append(out.Operations, op)
	}
	for _, sc := range d.SecuritySchemes {
		g := gen.SwaggerSecurityScheme{Name: sc.Name, Type: sc.Type, Scheme: nonEmpty(sc.Scheme), In: nonEmpty(sc.In), Param: nonEmpty(sc.Param)}
		if sc.AuthKind != "" {
			k := gen.ApiAuthKind(sc.AuthKind)
			g.AuthKind = &k
		}
		out.SecuritySchemes = append(out.SecuritySchemes, g)
	}
	return out
}

func nonEmpty(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}

// CreateSwaggerTest implements gen.ServerInterface.
func (s *Server) CreateSwaggerTest(w http.ResponseWriter, r *http.Request) {
	if !s.swaggerReady(w) {
		return
	}
	var req gen.SwaggerTestCreate
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	in := orchestrator.SwaggerTestInput{BaseURL: req.BaseUrl}
	if req.Operations != nil {
		in.Operations = *req.Operations
	}
	in.Title = deref(req.Title)
	in.SpecURL = deref(req.SpecUrl)
	in.SpecRef = deref(req.SpecRef)
	in.Notes = deref(req.Notes)
	in.WriteEnabled = req.WriteEnabled != nil && *req.WriteEnabled
	in.NotProduction = req.NotProduction != nil && *req.NotProduction
	if req.Auth != nil {
		in.Auth = domain.APIAuth{Kind: domain.APIAuthKind(req.Auth.Kind), Name: deref(req.Auth.Name)}
		in.Credential = deref(req.Auth.Value)
	}
	if req.RepoId != nil {
		in.RepoID = *req.RepoId
	}
	if req.RateLimit != nil {
		in.RateLimit = *req.RateLimit
	}
	if req.MaxRequests != nil {
		in.MaxRequests = *req.MaxRequests
	}
	if req.Priority != nil {
		in.Priority = string(*req.Priority)
	}
	if req.Start != nil {
		in.Start = string(*req.Start)
	}
	t, err := s.opt.Swagger.CreateSwaggerTest(r.Context(), in, origin(r))
	if errors.Is(err, orchestrator.ErrSpecFetchLimit) {
		writeError(w, http.StatusTooManyRequests, "too_many_requests", err.Error())
		return
	}
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	s.writeTicket(w, r, http.StatusCreated, t)
}

// GetApiResults implements gen.ServerInterface.
func (s *Server) GetApiResults(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.swaggerReady(w) {
		return
	}
	v, err := s.opt.Swagger.SwaggerResultsOf(r.Context(), key)
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toSwaggerResults(v))
}

func toSwaggerResults(v orchestrator.SwaggerView) gen.SwaggerResults {
	st := v.Test
	out := gen.SwaggerResults{
		Test: gen.SwaggerTestView{BaseUrl: st.BaseURL, Operations: st.Operations, WriteEnabled: st.WriteEnabled,
			AuthKind: gen.ApiAuthKind(st.Auth.Kind), AuthName: nonEmpty(st.Auth.Name), HasToken: st.HasSecret,
			RateLimit: st.Rate(), MaxRequests: st.Budget(), SpecUrl: nonEmpty(st.SpecURL), SuiteId: st.SuiteID},
		Cases: []gen.ApiCase{}, Requests: []gen.ApiRequestRow{}, Notes: []string{}, NewFailures: []string{},
	}
	if out.Test.Operations == nil {
		out.Test.Operations = []string{}
	}
	if v.NewFailures != nil {
		out.NewFailures = v.NewFailures
	}
	if v.Previous != nil {
		out.Previous = toCounts(*v.Previous)
	}
	run := v.Run
	if run == nil {
		return out
	}
	out.RunId, out.CreatedAt = &run.RunID, &run.CreatedAt
	out.Status, out.Summary = nonEmpty(run.Results.Status), nonEmpty(run.Results.Summary)
	out.Counts = toCounts(run.Results.Counts())
	if run.Results.Notes != nil {
		out.Notes = run.Results.Notes
	}
	for _, c := range run.Results.Cases {
		reqs := c.Requests
		if reqs == nil {
			reqs = []string{}
		}
		out.Cases = append(out.Cases, gen.ApiCase{Id: c.ID, Operation: c.Operation, Case: c.Case, Expected: nonEmpty(c.Expected),
			Verdict: gen.ApiCaseVerdict(c.Verdict), Reason: nonEmpty(c.Reason), Requests: reqs, Source: gen.ApiCaseSource(c.Source)})
	}
	for _, e := range run.Log {
		out.Requests = append(out.Requests, toRequestRow(e))
	}
	return out
}

func toCounts(c domain.APICounts) *gen.ApiCounts {
	return &gen.ApiCounts{Passed: c.Passed, Failed: c.Failed, Skipped: c.Skipped, Blocked: c.Blocked}
}

func toRequestRow(e domain.APIExchange) gen.ApiRequestRow {
	row := gen.ApiRequestRow{Id: e.ID, Method: e.Method, Url: e.URL, Status: e.Status, Ms: e.MS, Case: nonEmpty(e.Case),
		Auth: nonEmpty(e.Auth), Error: nonEmpty(e.Error)}
	if e.Truncated {
		row.Truncated = &e.Truncated
	}
	return row
}

// GetApiRequest implements gen.ServerInterface.
func (s *Server) GetApiRequest(w http.ResponseWriter, r *http.Request, key gen.TicketKey, requestID string) {
	if !s.swaggerReady(w) {
		return
	}
	e, err := s.opt.Swagger.SwaggerExchange(r.Context(), key, requestID)
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			writeError(w, http.StatusNotFound, "not_found", "no such request")
			return
		}
		s.writeUseCaseError(w, r, err)
		return
	}
	row := toRequestRow(e)
	out := gen.ApiExchange{Id: row.Id, Method: row.Method, Url: row.Url, Status: row.Status, Ms: row.Ms, Case: row.Case, Auth: row.Auth,
		Error: row.Error, Truncated: row.Truncated, RequestBody: nonEmpty(e.ReqBody), ResponseBody: nonEmpty(e.RespBody)}
	if len(e.ReqHeaders) > 0 {
		out.RequestHeaders = &e.ReqHeaders
	}
	if len(e.RespHeaders) > 0 {
		out.ResponseHeaders = &e.RespHeaders
	}
	if !e.At.IsZero() {
		out.At = &e.At
	}
	writeJSON(w, http.StatusOK, out)
}

// RerunSwaggerTest implements gen.ServerInterface.
func (s *Server) RerunSwaggerTest(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.swaggerReady(w) {
		return
	}
	var req gen.SwaggerRerunInput
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Swagger.RerunSwaggerTest(ctx, key, req.Token, origin(r))
	})
}
