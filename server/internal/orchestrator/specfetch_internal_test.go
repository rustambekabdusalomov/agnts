package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"agnts/internal/apiclient"
	"agnts/internal/apispec"
	"agnts/internal/domain"
)

func TestSpecFetchLimits(t *testing.T) {
	o := &Orchestrator{specs: newSpecFetcher()}
	var running, peak, calls atomic.Int32
	release := make(chan struct{})
	o.specs.fetch = func(ctx context.Context, _ *Orchestrator, u string, _ *apiclient.Credential) (SpecResult, error) {
		calls.Add(1)
		n := running.Add(1)
		for {
			p := peak.Load()
			if n <= p || peak.CompareAndSwap(p, n) {
				break
			}
		}
		defer running.Add(-1)
		if u == "https://slow.test/a" || u == "https://slow.test/b" {
			<-release
		}
		return SpecResult{URL: u}, nil
	}
	ctx := domain.WithWorkspace(context.Background(), 1)

	// A second fetch in the same workspace waits for the first.
	var wg sync.WaitGroup
	for _, u := range []string{"https://slow.test/a", "https://slow.test/b"} {
		wg.Add(1)
		go func() {
			defer wg.Done()
			if _, err := o.FetchSpec(ctx, u, nil); err != nil {
				t.Error(err)
			}
		}()
	}
	time.Sleep(50 * time.Millisecond)
	if running.Load() != 1 {
		t.Errorf("%d fetches run at once in one workspace", running.Load())
	}
	close(release)
	wg.Wait()

	// The same URL within 10 minutes comes from the cache, without a container.
	before := calls.Load()
	if _, err := o.FetchSpec(ctx, "https://slow.test/a", nil); err != nil || calls.Load() != before {
		t.Errorf("cached fetch ran again: %v", err)
	}

	// 10 a minute: the 11th is refused.
	for i := range 8 {
		if _, err := o.FetchSpec(ctx, "https://x.test/"+string(rune('a'+i)), nil); err != nil {
			t.Fatal(err)
		}
	}
	if _, err := o.FetchSpec(ctx, "https://x.test/z", nil); !errors.Is(err, ErrSpecFetchLimit) {
		t.Errorf("11th fetch in a minute: %v", err)
	}
	// Another workspace has its own count.
	if _, err := o.FetchSpec(domain.WithWorkspace(context.Background(), 2), "https://x.test/z", nil); err != nil {
		t.Errorf("another workspace: %v", err)
	}
	if _, err := o.FetchSpec(ctx, "ftp://x.test/spec", nil); err == nil {
		t.Error("an ftp URL")
	}
}

func TestUploadedSpecs(t *testing.T) {
	o := &Orchestrator{specs: newSpecFetcher()}
	ctx := domain.WithWorkspace(context.Background(), 1)
	ref, res, err := o.UploadSpec(ctx, []byte(`{"openapi":"3.0.3","info":{"title":"t","version":"1"},"paths":{"/a":{"get":{"responses":{"200":{"description":"ok"}}}}}}`))
	if err != nil || res.Doc == nil || ref == "" {
		t.Fatal(err)
	}
	if _, _, ok := o.uploaded(ctx, ref); !ok {
		t.Error("the upload is not kept")
	}
	if _, _, ok := o.uploaded(domain.WithWorkspace(context.Background(), 2), ref); ok {
		t.Error("another workspace reads the upload")
	}
	if _, _, err := o.UploadSpec(ctx, []byte(`{"not":"a spec"}`)); err == nil {
		t.Error("not a spec")
	}
}

func TestPermissionSettingsOnlySwagger(t *testing.T) {
	s := domain.DefaultSettings()
	if got := permissionSettings(s, true); strings.Contains(got, ".auth") {
		t.Errorf("other kinds get the Swagger deny rules: %s", got)
	}
	if got := permissionSettings(s, true, swaggerDeny("api.test")...); !strings.Contains(got, "Read(//agnts/context/api/.auth)") || !strings.Contains(got, "Bash(curl *api.test*)") {
		t.Errorf("Swagger deny rules: %s", got)
	}
}

func TestSpecFetchWithToken(t *testing.T) {
	o := &Orchestrator{specs: newSpecFetcher()}
	spec := []byte(`{"openapi":"3.0.3","info":{"title":"Private","version":"1"},"servers":[{"url":"/api"}],"paths":{"/a":{"get":{"responses":{"200":{"description":"ok"}}}}}}`)
	var got []*apiclient.Credential
	o.specs.fetch = func(_ context.Context, _ *Orchestrator, u string, cred *apiclient.Credential) (SpecResult, error) {
		got = append(got, cred)
		if cred == nil {
			return SpecResult{}, ErrSpecNeedsAuth
		}
		doc, err := apispec.Parse(spec, u)
		return SpecResult{URL: u, Doc: doc, raw: spec}, err
	}
	ctx := domain.WithWorkspace(context.Background(), 1)
	if _, err := o.FetchSpec(ctx, "https://private.test/openapi.json", nil); !errors.Is(err, ErrSpecNeedsAuth) {
		t.Fatalf("without a token: %v", err)
	}
	cred := &apiclient.Credential{Kind: domain.AuthBearer, Value: "tok-1"}
	res, err := o.FetchSpec(ctx, "https://private.test/openapi.json", cred)
	if err != nil || res.Ref == "" || got[len(got)-1] != cred {
		t.Fatalf("with a token: %+v %v", res, err)
	}
	// Another token is not served the cached spec; the same one is.
	n := len(got)
	if _, err := o.FetchSpec(ctx, "https://private.test/openapi.json", &apiclient.Credential{Kind: domain.AuthBearer, Value: "tok-2"}); err != nil || len(got) != n+1 {
		t.Errorf("another token used the cache: %v", err)
	}
	if _, err := o.FetchSpec(ctx, "https://private.test/openapi.json", cred); err != nil || len(got) != n+1 {
		t.Errorf("the same token fetched again: %v", err)
	}
	// The kept spec stands in for the token at create time, with its URL.
	st, sr, err := o.checkSwaggerInput(ctx, SwaggerTestInput{SpecRef: res.Ref, BaseURL: "https://private.test/api", Operations: []string{"GET /a"},
		Auth: domain.APIAuth{Kind: domain.AuthBearer}, Credential: "tok-1"})
	if err != nil || st.SpecURL != "https://private.test/openapi.json" || sr.Doc.Servers[0].URL != "https://private.test/api" {
		t.Fatalf("create from the kept spec: %+v %v", st, err)
	}
	if _, err := o.FetchSpec(ctx, "https://private.test/x", &apiclient.Credential{Kind: domain.AuthHeader, Value: "v"}); err == nil {
		t.Error("a header key without a name")
	}
}

func TestSpecLoginError(t *testing.T) {
	err := fmt.Errorf("%w: it answered 401", ErrSpecNeedsLogin)
	if !errors.Is(err, ErrSpecNeedsLogin) || !errors.Is(err, ErrSpecNeedsAuth) {
		t.Error("a login error is also an auth error")
	}
	if errors.Is(fmt.Errorf("%w", ErrSpecNeedsAuth), ErrSpecNeedsLogin) {
		t.Error("a token error is not a login error")
	}
}
