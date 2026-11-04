package httpapi

import (
	"context"
	"errors"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/logsource"
	"agnts/internal/logwatch"
)

// Logs is the log watcher (logwatch.Service).
type Logs interface {
	Sources(ctx context.Context) ([]domain.LogSource, error)
	Source(ctx context.Context, id int64) (domain.LogSource, error)
	SaveSource(ctx context.Context, in logwatch.SourceInput) (domain.LogSource, error)
	DeleteSource(ctx context.Context, id int64) error
	Test(ctx context.Context, in logwatch.SourceInput) (logwatch.TestResult, error)
	Discover(ctx context.Context, id int64) ([]domain.LogService, error)
	SetServices(ctx context.Context, sourceID int64, svcs []domain.LogService) ([]domain.LogService, error)
	PushToken(ctx context.Context, id int64) (string, error)
	Push(ctx context.Context, token string, body io.Reader, contentType, contentEncoding, format string) (logwatch.IngestResult, error)
	RotateKey(ctx context.Context) error
	Findings(ctx context.Context, q domain.LogFindingFilter) ([]domain.LogFinding, error)
	Finding(ctx context.Context, id int64) (domain.LogFinding, error)
	FindingByTicket(ctx context.Context, key string) (domain.LogFinding, error)
	Fix(ctx context.Context, id int64, origin domain.Origin) (domain.Ticket, error)
	Mute(ctx context.Context, id int64, mute bool) (domain.LogFinding, error)
	Notify(ctx context.Context, id int64) (domain.LogFinding, error)
}

var _ Logs = (*logwatch.Service)(nil)

func (s *Server) logsReady(w http.ResponseWriter) bool {
	if s.opt.Logs == nil {
		writeError(w, http.StatusNotImplemented, "not_implemented", "the log watcher is not available")
		return false
	}
	return true
}

func (s *Server) writeLogsError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such log source or finding")
	case errors.Is(err, logwatch.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", strings.TrimPrefix(err.Error(), "invalid: "))
	case errors.Is(err, logsource.ErrPrivateAddress), errors.Is(err, logsource.ErrPlainHTTP):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	default:
		var h *logsource.HTTPError
		if errors.As(err, &h) || isNetError(err) {
			writeError(w, http.StatusBadRequest, "bad_request", "the source answered: "+err.Error())
			return
		}
		s.writeUseCaseError(w, r, err)
	}
}

// isNetError: the source could not be reached (DNS, refused, TLS,
// timeout); the user's address, not an agnts failure.
func isNetError(err error) bool {
	msg := err.Error()
	for _, s := range []string{"dial tcp", "no such host", "connection refused", "certificate", "tls:", "timeout", "deadline exceeded", "doesn't look like"} {
		if strings.Contains(msg, s) {
			return true
		}
	}
	return false
}

func strOr(p *string) string {
	if p == nil {
		return ""
	}
	return *p
}

func toLogFields(f domain.LogFields) gen.LogFields {
	return gen.LogFields{Message: optStr(f.Message), Timestamp: optStr(f.Timestamp), Level: optStr(f.Level), Service: optStr(f.Service), Revision: optStr(f.Revision), TraceUrl: optStr(f.TraceURL)}
}

func fromLogFields(f *gen.LogFields) domain.LogFields {
	if f == nil {
		return domain.LogFields{}
	}
	return domain.LogFields{Message: strOr(f.Message), Timestamp: strOr(f.Timestamp), Level: strOr(f.Level), Service: strOr(f.Service), Revision: strOr(f.Revision), TraceURL: strOr(f.TraceUrl)}
}

func toLogService(v domain.LogService) gen.LogService {
	id := v.ID
	ids := v.RepoIDs
	if ids == nil {
		ids = []int64{}
	}
	out := gen.LogService{Name: v.Name, Selector: v.Selector, RepoIds: ids, GroupId: v.GroupID, Enabled: v.Enabled}
	if id != 0 {
		out.Id = &id
	}
	return out
}

func (s *Server) pushURL() string {
	if s.opt.PublicURL == nil {
		return "/webhooks/logs"
	}
	return strings.TrimRight(s.opt.PublicURL.String(), "/") + "/webhooks/logs"
}

func (s *Server) toLogSource(x domain.LogSource) gen.LogSource {
	streams := append([]string{}, x.Scope.Streams...)
	out := gen.LogSource{Id: x.ID, Name: x.Name, Kind: gen.LogSourceKind(x.Kind), Environment: x.Environment, Address: x.Address,
		AuthKind: x.Auth.Kind, AuthUser: optStr(x.Auth.User), AuthTenant: optStr(x.Auth.Tenant), HasAuth: x.HasAuth, CaPem: x.CAPEM,
		Scope:  gen.LogScope{Selector: optStr(x.Scope.Selector), Index: optStr(x.Scope.Index), Streams: &streams},
		Fields: toLogFields(x.Fields), PollSeconds: x.PollSeconds, Enabled: x.Enabled, Status: gen.LogSourceStatus(x.Status),
		LastError: x.LastError, LastReadAt: x.LastReadAt, GapFrom: x.GapFrom, GapTo: x.GapTo, Dropped: x.Dropped, NetworkId: x.NetworkID,
		HasPushToken: x.HasPushToken, Services: make([]gen.LogService, len(x.Services)), CreatedAt: x.CreatedAt}
	for i, v := range x.Services {
		out.Services[i] = toLogService(v)
	}
	if x.Kind == domain.LogPush {
		u := s.pushURL()
		out.PushUrl = &u
	}
	return out
}

func fromLogSourceInput(in gen.LogSourceInput) logwatch.SourceInput {
	x := domain.LogSource{Name: in.Name, Kind: domain.LogKind(in.Kind), Environment: string(in.Environment), Address: strOr(in.Address),
		CAPEM: strOr(in.CaPem), Fields: fromLogFields(in.Fields), Enabled: in.Enabled}
	if in.Id != nil {
		x.ID = *in.Id
	}
	if in.PollSeconds != nil {
		x.PollSeconds = *in.PollSeconds
	}
	if sc := in.Scope; sc != nil {
		x.Scope = domain.LogScope{Selector: strOr(sc.Selector), Index: strOr(sc.Index)}
		if sc.Streams != nil {
			x.Scope.Streams = *sc.Streams
		}
	}
	out := logwatch.SourceInput{LogSource: x}
	if a := in.Auth; a != nil {
		out.Auth = &domain.LogAuth{Kind: string(a.Kind), User: strOr(a.User), Password: strOr(a.Password), Token: strOr(a.Token), Tenant: strOr(a.Tenant)}
	}
	return out
}

func (s *Server) toLogFinding(ctx context.Context, f domain.LogFinding) gen.LogFinding {
	out := gen.LogFinding{Id: f.ID, Service: f.Service, RepoIds: f.RepoIDs, Repos: f.RepoNames, Category: gen.LogFindingCategory(f.Category),
		Detector: f.Detector, Class: string(f.Class), Severity: gen.LogSeverity(f.Severity), Title: f.Title, Remediation: f.Remediation,
		Status: gen.LogFindingStatus(f.Status), Reason: f.Reason, Count: f.Count, HourCount: f.HourCount, FirstSeenAt: f.FirstSeenAt,
		LastSeenAt: f.LastSeenAt, Revision: f.Revision, Route: f.Route, SecretMask: f.SecretMask,
		Occurrences: make([]gen.LogOccurrence, len(f.Occurrences)), ReportedAt: f.ReportedAt, TicketKey: f.TicketKey,
		FixedSha: optStr(f.FixedSHA), FixedAt: f.FixedAt, Sample: optStr(f.Sample)}
	if id, link := domain.SampleTrace(f.Sample); id != "" {
		out.TraceId = &id
		if link != "" {
			out.TraceUrl = &link
		}
	}
	if out.RepoIds == nil {
		out.RepoIds = []int64{}
	}
	if out.Repos == nil {
		out.Repos = []string{}
	}
	for i, o := range f.Occurrences {
		out.Occurrences[i] = gen.LogOccurrence{At: o.At, SourceId: o.SourceID, Service: o.Service, Revision: optStr(o.Revision), Count: o.Count}
	}
	if f.TicketKey != "" && s.opt.Tickets != nil {
		if v, err := s.opt.Tickets.View(ctx, f.TicketKey); err == nil {
			st := gen.TicketState(v.Ticket.State)
			out.TicketState = &st
		}
	}
	return out
}

// ListLogSources implements gen.ServerInterface.
func (s *Server) ListLogSources(w http.ResponseWriter, r *http.Request) {
	if !s.logsReady(w) {
		return
	}
	xs, err := s.opt.Logs.Sources(r.Context())
	if err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	out := make([]gen.LogSource, len(xs))
	for i, x := range xs {
		out[i] = s.toLogSource(x)
	}
	writeJSON(w, http.StatusOK, out)
}

// CreateLogSource implements gen.ServerInterface.
func (s *Server) CreateLogSource(w http.ResponseWriter, r *http.Request) {
	if !s.logsReady(w) {
		return
	}
	var in gen.LogSourceInput
	if err := decodeJSON(r, &in); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	src := fromLogSourceInput(in)
	src.ID = 0
	x, err := s.opt.Logs.SaveSource(r.Context(), src)
	if err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, s.toLogSource(x))
}

// TestLogSource implements gen.ServerInterface.
func (s *Server) TestLogSource(w http.ResponseWriter, r *http.Request) {
	if !s.logsReady(w) {
		return
	}
	var in gen.LogSourceInput
	if err := decodeJSON(r, &in); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	res, err := s.opt.Logs.Test(r.Context(), fromLogSourceInput(in))
	if err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	labels := res.Labels
	if labels == nil {
		labels = []string{}
	}
	writeJSON(w, http.StatusOK, gen.LogSourceTest{Version: res.Version, Fields: toLogFields(res.Fields), Labels: labels, Sample: res.Sample,
		Newest: res.Newest, Network: res.Network, LatencyMs: res.LatencyMS})
}

// RotateLogKey implements gen.ServerInterface.
func (s *Server) RotateLogKey(w http.ResponseWriter, r *http.Request) {
	if !s.logsReady(w) {
		return
	}
	if err := s.opt.Logs.RotateKey(r.Context()); err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// GetLogSource implements gen.ServerInterface.
func (s *Server) GetLogSource(w http.ResponseWriter, r *http.Request, id gen.LogSourceID) {
	if !s.logsReady(w) {
		return
	}
	x, err := s.opt.Logs.Source(r.Context(), id)
	if err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, s.toLogSource(x))
}

// UpdateLogSource implements gen.ServerInterface.
func (s *Server) UpdateLogSource(w http.ResponseWriter, r *http.Request, id gen.LogSourceID) {
	if !s.logsReady(w) {
		return
	}
	var in gen.LogSourceInput
	if err := decodeJSON(r, &in); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	src := fromLogSourceInput(in)
	src.ID = id
	x, err := s.opt.Logs.SaveSource(r.Context(), src)
	if err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, s.toLogSource(x))
}

// DeleteLogSource implements gen.ServerInterface.
func (s *Server) DeleteLogSource(w http.ResponseWriter, r *http.Request, id gen.LogSourceID) {
	if !s.logsReady(w) {
		return
	}
	if err := s.opt.Logs.DeleteSource(r.Context(), id); err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// DiscoverLogServices implements gen.ServerInterface.
func (s *Server) DiscoverLogServices(w http.ResponseWriter, r *http.Request, id gen.LogSourceID) {
	if !s.logsReady(w) {
		return
	}
	svcs, err := s.opt.Logs.Discover(r.Context(), id)
	if err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	out := make([]gen.LogService, len(svcs))
	for i, v := range svcs {
		out[i] = toLogService(v)
	}
	writeJSON(w, http.StatusOK, out)
}

// SetLogServices implements gen.ServerInterface.
func (s *Server) SetLogServices(w http.ResponseWriter, r *http.Request, id gen.LogSourceID) {
	if !s.logsReady(w) {
		return
	}
	var in []gen.LogService
	if err := decodeJSON(r, &in); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	svcs := make([]domain.LogService, len(in))
	for i, v := range in {
		svcs[i] = domain.LogService{Name: v.Name, Selector: v.Selector, RepoIDs: v.RepoIds, GroupID: v.GroupId, Enabled: v.Enabled}
	}
	out, err := s.opt.Logs.SetServices(r.Context(), id, svcs)
	if err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	res := make([]gen.LogService, len(out))
	for i, v := range out {
		res[i] = toLogService(v)
	}
	writeJSON(w, http.StatusOK, res)
}

// CreateLogPushToken implements gen.ServerInterface.
func (s *Server) CreateLogPushToken(w http.ResponseWriter, r *http.Request, id gen.LogSourceID) {
	if !s.logsReady(w) {
		return
	}
	tok, err := s.opt.Logs.PushToken(r.Context(), id)
	if err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, gen.LogPushToken{Token: tok, Url: s.pushURL()})
}

// ListLogFindings implements gen.ServerInterface.
func (s *Server) ListLogFindings(w http.ResponseWriter, r *http.Request, p gen.ListLogFindingsParams) {
	if !s.logsReady(w) {
		return
	}
	var q domain.LogFindingFilter
	if p.Category != nil {
		q.Category = domain.LogCategory(*p.Category)
	}
	if p.Status != nil {
		q.Status = domain.LogStatus(*p.Status)
	}
	if p.Severity != nil {
		q.Severity = domain.LogSeverity(*p.Severity)
	}
	if p.RepoId != nil {
		q.RepoID = *p.RepoId
	}
	if p.SourceId != nil {
		q.SourceID = *p.SourceId
	}
	if p.Active != nil {
		q.Active = *p.Active
	}
	fs, err := s.opt.Logs.Findings(r.Context(), q)
	if err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	out := make([]gen.LogFinding, len(fs))
	for i, f := range fs {
		out[i] = s.toLogFinding(r.Context(), f)
	}
	writeJSON(w, http.StatusOK, out)
}

func (s *Server) writeLogFinding(w http.ResponseWriter, r *http.Request, f domain.LogFinding, err error) {
	if err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, s.toLogFinding(r.Context(), f))
}

// GetLogFinding implements gen.ServerInterface.
func (s *Server) GetLogFinding(w http.ResponseWriter, r *http.Request, id gen.LogFindingID) {
	if !s.logsReady(w) {
		return
	}
	f, err := s.opt.Logs.Finding(r.Context(), id)
	s.writeLogFinding(w, r, f, err)
}

// GetTicketLogFinding implements gen.ServerInterface.
func (s *Server) GetTicketLogFinding(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.logsReady(w) {
		return
	}
	f, err := s.opt.Logs.FindingByTicket(r.Context(), key)
	s.writeLogFinding(w, r, f, err)
}

// FixLogFinding implements gen.ServerInterface.
func (s *Server) FixLogFinding(w http.ResponseWriter, r *http.Request, id gen.LogFindingID) {
	if !s.logsReady(w) {
		return
	}
	t, err := s.opt.Logs.Fix(r.Context(), id, origin(r))
	if err != nil {
		s.writeLogsError(w, r, err)
		return
	}
	s.writeTicket(w, r, http.StatusOK, t)
}

// MuteLogFinding implements gen.ServerInterface.
func (s *Server) MuteLogFinding(w http.ResponseWriter, r *http.Request, id gen.LogFindingID) {
	if !s.logsReady(w) {
		return
	}
	f, err := s.opt.Logs.Mute(r.Context(), id, true)
	s.writeLogFinding(w, r, f, err)
}

// UnmuteLogFinding implements gen.ServerInterface.
func (s *Server) UnmuteLogFinding(w http.ResponseWriter, r *http.Request, id gen.LogFindingID) {
	if !s.logsReady(w) {
		return
	}
	f, err := s.opt.Logs.Mute(r.Context(), id, false)
	s.writeLogFinding(w, r, f, err)
}

// NotifyLogFinding implements gen.ServerInterface.
func (s *Server) NotifyLogFinding(w http.ResponseWriter, r *http.Request, id gen.LogFindingID) {
	if !s.logsReady(w) {
		return
	}
	f, err := s.opt.Logs.Notify(r.Context(), id)
	s.writeLogFinding(w, r, f, err)
}

// logsPush takes what a log shipper sends: POST /webhooks/logs with
// "Authorization: Bearer <token>", or /webhooks/logs/{token} for shippers
// that can't set headers; under .../loki/api/v1/push it speaks Loki's
// push API, so Promtail and Grafana Alloy can send to agnts, and under
// .../v1/logs OTLP/HTTP, for OpenTelemetry Collectors and SDKs. 202 on
// accept (200 with an ExportLogsServiceResponse for OTLP), 429 with
// Retry-After when over the rate, so shippers buffer and retry.
func (s *Server) logsPush(w http.ResponseWriter, r *http.Request) {
	if s.opt.Logs == nil {
		writeError(w, http.StatusNotImplemented, "not_implemented", "the log watcher is not available")
		return
	}
	token := chi.URLParam(r, "token")
	if token == "" {
		token = strings.TrimSpace(strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer "))
	}
	if _, pass, ok := r.BasicAuth(); ok {
		token = pass // Promtail's basic_auth: any user, the token as the password
	}
	format := logwatch.PushPlain
	switch {
	case strings.HasSuffix(r.URL.Path, "/loki/api/v1/push"):
		format = logwatch.PushLoki
	case strings.HasSuffix(r.URL.Path, "/v1/logs"):
		format = logwatch.PushOTLP
	}
	if token == "" {
		writeError(w, http.StatusUnauthorized, "unauthorized", "send the push token as Authorization: Bearer <token>")
		return
	}
	key := token
	if len(key) > 16 {
		key = key[:16]
	}
	if ok, retry := s.pushLimiter.allow(key, time.Now()); !ok {
		w.Header().Set("Retry-After", strconv.Itoa(int(retry.Seconds())+1))
		writeError(w, http.StatusTooManyRequests, "too_many_requests", "too many pushes: slow down")
		return
	}
	ctx, cancel := context.WithTimeout(r.Context(), 60*time.Second)
	defer cancel()
	res, err := s.opt.Logs.Push(ctx, token, http.MaxBytesReader(w, r.Body, logsource.MaxPushBody+1), r.Header.Get("Content-Type"), r.Header.Get("Content-Encoding"), format)
	switch {
	case errors.Is(err, logwatch.ErrUnknownToken):
		writeError(w, http.StatusUnauthorized, "unauthorized", "unknown or revoked push token")
	case errors.Is(err, logsource.ErrPushTooLarge):
		writeError(w, http.StatusRequestEntityTooLarge, "too_large", "push at most 5 MB and 20,000 entries at a time")
	case errors.Is(err, logwatch.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", strings.TrimPrefix(err.Error(), "invalid: "))
	case err != nil:
		s.writeInternal(w, r, err)
	case format == logwatch.PushOTLP:
		writeOTLP(w, r.Header.Get("Content-Type"), res.Rejected)
	default:
		writeJSON(w, http.StatusAccepted, res)
	}
}

// writeOTLP answers an OTLP/HTTP export in the encoding it came in.
func writeOTLP(w http.ResponseWriter, contentType string, rejected int) {
	asJSON := logsource.OTLPIsJSON(contentType)
	msg := ""
	if rejected > 0 {
		msg = "agnts reads at most " + strconv.Itoa(logsource.MaxPushEntries) + " records per request"
	}
	if asJSON {
		w.Header().Set("Content-Type", "application/json")
	} else {
		w.Header().Set("Content-Type", "application/x-protobuf")
	}
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(logsource.OTLPResponse(asJSON, rejected, msg)) //nolint:gosec // G705: protobuf or JSON agnts builds from a count and a constant, sent with its content type
}

func toLogWatch(l domain.LogWatchSettings) gen.LogWatchSettings {
	out := gen.LogWatchSettings{Errors: gen.LogMode(l.Errors), Security: gen.LogMode(l.Security), AlwaysNotifyLeaks: l.AlwaysNotifyLeaks,
		MinSeverity: gen.LogSeverity(l.MinSeverity), Threshold: l.Threshold, MaxAutoPerDay: l.MaxAutoPerDay, AttackTicketAfter: l.AttackTicketAfter,
		ResolveAfterDays: l.ResolveAfterDays, Digest: l.Digest, TriagePerDay: l.TriagePerDay,
		Patterns: make([]gen.LogPattern, len(l.Patterns)), Overrides: make([]gen.LogOverride, len(l.Overrides))}
	for i, p := range l.Patterns {
		out.Patterns[i] = gen.LogPattern{Name: p.Name, Pattern: p.Pattern, Category: gen.LogPatternCategory(p.Category), Severity: gen.LogSeverity(p.Severity)}
	}
	for i, o := range l.Overrides {
		x := gen.LogOverride{Service: optStr(o.Service)}
		if o.RepoID != 0 {
			id := o.RepoID
			x.RepoId = &id
		}
		if o.Errors != "" {
			m := gen.LogMode(o.Errors)
			x.Errors = &m
		}
		if o.Security != "" {
			m := gen.LogMode(o.Security)
			x.Security = &m
		}
		out.Overrides[i] = x
	}
	return out
}

func fromLogWatch(l gen.LogWatchSettings) domain.LogWatchSettings {
	out := domain.LogWatchSettings{Errors: domain.LogMode(l.Errors), Security: domain.LogMode(l.Security), AlwaysNotifyLeaks: l.AlwaysNotifyLeaks,
		MinSeverity: domain.LogSeverity(l.MinSeverity), Threshold: l.Threshold, MaxAutoPerDay: l.MaxAutoPerDay, AttackTicketAfter: l.AttackTicketAfter,
		ResolveAfterDays: l.ResolveAfterDays, Digest: l.Digest, TriagePerDay: l.TriagePerDay,
		Patterns: make([]domain.LogPattern, len(l.Patterns)), Overrides: make([]domain.LogOverride, len(l.Overrides))}
	for i, p := range l.Patterns {
		out.Patterns[i] = domain.LogPattern{Name: p.Name, Pattern: p.Pattern, Category: domain.LogCategory(p.Category), Severity: domain.LogSeverity(p.Severity)}
	}
	for i, o := range l.Overrides {
		x := domain.LogOverride{Service: strOr(o.Service)}
		if o.RepoId != nil {
			x.RepoID = *o.RepoId
		}
		if o.Errors != nil {
			x.Errors = domain.LogMode(*o.Errors)
		}
		if o.Security != nil {
			x.Security = domain.LogMode(*o.Security)
		}
		out.Overrides[i] = x
	}
	return out
}
