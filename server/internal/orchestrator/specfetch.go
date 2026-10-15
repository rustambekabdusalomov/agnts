package orchestrator

import (
	"archive/tar"
	"bytes"
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"net/url"
	"strings"
	"sync"
	"time"

	"agnts/internal/apiclient"
	"agnts/internal/apispec"
	"agnts/internal/domain"
)

// Spec fetch limits: a form cannot be used to start containers in a loop.
const (
	specFetchPerMinute = 10
	specCacheFor       = 10 * time.Minute
	// specFetchSlots are the spec fetches the server runs at once: a slot
	// of their own, so they never wait behind a run or take its slot.
	specFetchSlots   = 2
	specFetchTimeout = 3 * time.Minute
)

// ErrSpecFetchLimit refuses a workspace's 11th spec fetch in a minute.
var ErrSpecFetchLimit = errors.New("too many spec fetches: wait a minute and try again")

// SpecResult is what a spec URL holds: a parsed spec, or the specs a docs
// page offers to choose from.
type SpecResult struct {
	URL     string
	Doc     *apispec.Doc
	Choices []apiclient.Choice
	// Ref stands for the spec in CreateSwaggerTest (kept an hour): an
	// upload, or a spec fetched with a token, which is not given again.
	Ref string
	raw []byte
}

// ErrSpecNeedsAuth is the spec URL answering 401 or 403; ErrSpecNeedsLogin
// (which is also ErrSpecNeedsAuth) when it asked for a login and password.
var (
	ErrSpecNeedsAuth        = errors.New("the spec URL needs a token")
	ErrSpecNeedsLogin error = specLoginError{}
)

type specLoginError struct{}

func (specLoginError) Error() string        { return "the spec URL needs a login and password" }
func (specLoginError) Is(target error) bool { return target == ErrSpecNeedsAuth }

type specFetcher struct {
	mu    sync.Mutex
	ws    map[int64]*wsFetches
	cache map[string]cachedSpec
	// uploads keeps uploaded specs an hour, by workspace and hash, so the
	// form sends a large file once.
	uploads map[string]cachedUpload
	slots   chan struct{}
	// fetch is how one fetch runs; tests replace it.
	fetch func(ctx context.Context, o *Orchestrator, u string, cred *apiclient.Credential) (SpecResult, error)
}

type wsFetches struct {
	busy  sync.Mutex // one fetch at a time per workspace
	times []time.Time
}

type cachedSpec struct {
	res SpecResult
	at  time.Time
}

type cachedUpload struct {
	raw []byte
	url string // where a fetched spec came from ("" for an upload)
	at  time.Time
}

// Uploaded specs: kept this long, at most this many on the server.
const (
	uploadKeepFor = time.Hour
	maxUploads    = 50
)

func newSpecFetcher() *specFetcher {
	return &specFetcher{ws: map[int64]*wsFetches{}, cache: map[string]cachedSpec{}, uploads: map[string]cachedUpload{}, slots: make(chan struct{}, specFetchSlots),
		fetch: fetchInContainer}
}

// FetchSpec downloads and parses the spec at rawURL (or a docs page in
// front of it). It never runs on the agnts server: a short container from
// the runner image, with no Claude in it, fetches it through the egress
// proxy under the rules a Swagger test run gets.
//
// cred is the token the spec URL needs, if any: it goes with the fetch to
// the spec's host only and is not kept; the spec it fetched is kept an hour
// under Ref, so creating the test does not need it again.
func (o *Orchestrator) FetchSpec(ctx context.Context, rawURL string, cred *apiclient.Credential) (SpecResult, error) {
	if cred != nil && cred.Value == "" {
		cred = nil
	}
	if cred != nil {
		if err := (domain.APIAuth{Kind: cred.Kind, Name: cred.Name}).Validate(cred.Value); err != nil || cred.Kind == domain.AuthNone {
			why := "pick how it is sent"
			if err != nil {
				why = err.Error()
			}
			return SpecResult{}, invalid("the spec's token: %s", why)
		}
	}
	u, err := url.Parse(strings.TrimSpace(rawURL))
	if err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Hostname() == "" || u.User != nil {
		return SpecResult{}, invalid("the spec URL must be an http:// or https:// URL")
	}
	f := o.specs
	ws := domain.WorkspaceOf(ctx)
	key := fmt.Sprintf("%d %s", ws, u.String())
	if cred != nil {
		sum := sha256.Sum256([]byte(string(cred.Kind) + "\x00" + cred.Name + "\x00" + cred.Value))
		key += " " + hex.EncodeToString(sum[:8])
	}
	f.mu.Lock()
	if c, ok := f.cache[key]; ok && time.Since(c.at) < specCacheFor {
		f.mu.Unlock()
		return c.res, nil
	}
	w := f.ws[ws]
	if w == nil {
		w = &wsFetches{}
		f.ws[ws] = w
	}
	f.mu.Unlock()

	w.busy.Lock()
	defer w.busy.Unlock()
	f.mu.Lock()
	if c, ok := f.cache[key]; ok && time.Since(c.at) < specCacheFor {
		f.mu.Unlock()
		return c.res, nil // fetched while this one waited
	}
	recent := w.times[:0]
	for _, t := range w.times {
		if time.Since(t) < time.Minute {
			recent = append(recent, t)
		}
	}
	w.times = recent
	if len(w.times) >= specFetchPerMinute {
		f.mu.Unlock()
		return SpecResult{}, ErrSpecFetchLimit
	}
	w.times = append(w.times, time.Now())
	f.mu.Unlock()

	select {
	case f.slots <- struct{}{}:
	case <-ctx.Done():
		return SpecResult{}, ctx.Err()
	}
	defer func() { <-f.slots }()
	fctx, cancel := context.WithTimeout(ctx, specFetchTimeout)
	defer cancel()
	res, err := f.fetch(fctx, o, u.String(), cred)
	if err != nil {
		return SpecResult{}, err
	}
	if cred != nil && res.Doc != nil {
		res.Ref = o.keepSpec(ctx, res.raw, res.URL)
	}
	f.mu.Lock()
	for k, c := range f.cache {
		if time.Since(c.at) >= specCacheFor {
			delete(f.cache, k)
		}
	}
	f.cache[key] = cachedSpec{res: res, at: time.Now()}
	f.mu.Unlock()
	return res, nil
}

// fetchInContainer runs agnts-api fetch-spec in a container granted the
// spec URL's host and port.
func fetchInContainer(ctx context.Context, o *Orchestrator, rawURL string, cred *apiclient.Credential) (SpecResult, error) {
	u, _ := url.Parse(rawURL)
	h, p := domain.HostPort(u)
	var empty bytes.Buffer
	_ = tar.NewWriter(&empty).Close()
	id := make([]byte, 4)
	_, _ = rand.Read(id)
	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: "spec-fetch-" + hex.EncodeToString(id), Image: o.cfg.Image, Repo: &empty,
		Grants: []Grant{{Host: h, Port: p}}})
	if err != nil {
		return SpecResult{}, fmt.Errorf("start the spec fetch: %w", err)
	}
	defer func() { _ = ws.Close(context.WithoutCancel(ctx)) }()
	cmd := apiclient.BinaryPath + " api fetch-spec " + shellQuote(rawURL)
	if cred != nil {
		// A file, not an argument: arguments show in the process list.
		b, _ := json.Marshal(cred)
		if err := ws.WriteFile(ctx, specAuthPath, b); err != nil {
			return SpecResult{}, fmt.Errorf("fetch the spec: %w", err)
		}
		cmd += " --auth-file " + specAuthPath
	}
	res, err := ws.Exec(ctx, cmd, 2*time.Minute)
	if err != nil {
		return SpecResult{}, fmt.Errorf("fetch the spec: %w", err)
	}
	raw, rerr := ws.ReadFile(ctx, apiclient.FetchedPath)
	if rerr != nil {
		if strings.Contains(res.Output, "No such file") || strings.Contains(res.Output, "not found") {
			return SpecResult{}, errors.New("agnts-api is missing from the runs: agnts-guard must be installed on the server (make dev-guard)")
		}
		return SpecResult{}, fmt.Errorf("fetch the spec: %s", truncate(strings.TrimSpace(res.Output), 300))
	}
	var found struct {
		URL     string             `json:"url"`
		Choices []apiclient.Choice `json:"choices"`
		Error   string             `json:"error"`
		Status  int                `json:"status"`
		Login   bool               `json:"login"`
	}
	if err := json.Unmarshal(raw, &found); err != nil {
		return SpecResult{}, fmt.Errorf("fetch the spec: %w", err)
	}
	if found.Status == 401 || found.Status == 403 {
		switch {
		case cred != nil && cred.Kind == domain.AuthBasic:
			return SpecResult{}, fmt.Errorf("%w: it answered %d to the login and password given", ErrSpecNeedsLogin, found.Status)
		case cred != nil:
			return SpecResult{}, fmt.Errorf("%w: it answered %d to the token given (wrong token, or sent the wrong way)", ErrSpecNeedsAuth, found.Status)
		case found.Login:
			return SpecResult{}, fmt.Errorf("%w: it answered %d; give the login and password that open it", ErrSpecNeedsLogin, found.Status)
		}
		return SpecResult{}, fmt.Errorf("%w: it answered %d; give the token it needs", ErrSpecNeedsAuth, found.Status)
	}
	if found.Error != "" {
		return SpecResult{}, invalid("%s", found.Error)
	}
	if len(found.Choices) > 0 {
		return SpecResult{URL: rawURL, Choices: found.Choices}, nil
	}
	spec, err := ws.ReadFile(ctx, apiclient.FetchedSpecPath)
	if err != nil {
		return SpecResult{}, fmt.Errorf("fetch the spec: %w", err)
	}
	doc, err := apispec.Parse(spec, found.URL)
	if err != nil {
		return SpecResult{}, invalid("%s", err.Error())
	}
	return SpecResult{URL: found.URL, Doc: doc, raw: spec}, nil
}

// specAuthPath is where a spec fetch's token is put, in its own short-lived
// container (no Claude runs there).
const specAuthPath = "/agnts/context/api/.spec-auth"

// ParseSpec reads an uploaded or pasted spec.
func (o *Orchestrator) ParseSpec(raw []byte) (SpecResult, error) {
	doc, err := apispec.Parse(raw, "")
	if err != nil {
		return SpecResult{}, invalid("%s", err.Error())
	}
	return SpecResult{Doc: doc}, nil
}

// UploadSpec reads an uploaded spec and keeps it an hour: the returned
// reference stands for it in CreateSwaggerTest.
func (o *Orchestrator) UploadSpec(ctx context.Context, raw []byte) (string, SpecResult, error) {
	res, err := o.ParseSpec(raw)
	if err != nil {
		return "", res, err
	}
	res.Ref = o.keepSpec(ctx, raw, "")
	return res.Ref, res, nil
}

// keepSpec keeps a spec an hour and returns its reference.
func (o *Orchestrator) keepSpec(ctx context.Context, raw []byte, specURL string) string {
	sum := sha256.Sum256(append([]byte(specURL+"\x00"), raw...))
	ref := "up-" + hex.EncodeToString(sum[:12])
	key := fmt.Sprintf("%d %s", domain.WorkspaceOf(ctx), ref)
	f := o.specs
	f.mu.Lock()
	defer f.mu.Unlock()
	for k, u := range f.uploads {
		if time.Since(u.at) >= uploadKeepFor {
			delete(f.uploads, k)
		}
	}
	for len(f.uploads) >= maxUploads {
		oldest := ""
		for k, u := range f.uploads {
			if oldest == "" || u.at.Before(f.uploads[oldest].at) {
				oldest = k
			}
		}
		delete(f.uploads, oldest)
	}
	f.uploads[key] = cachedUpload{raw: raw, url: specURL, at: time.Now()}
	return ref
}

// uploaded returns a spec keepSpec kept, and where it came from.
func (o *Orchestrator) uploaded(ctx context.Context, ref string) ([]byte, string, bool) {
	f := o.specs
	f.mu.Lock()
	defer f.mu.Unlock()
	u, ok := f.uploads[fmt.Sprintf("%d %s", domain.WorkspaceOf(ctx), ref)]
	if !ok || time.Since(u.at) >= uploadKeepFor {
		return nil, "", false
	}
	return u.raw, u.url, true
}
