package apiclient

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

const specJSON = `{"openapi":"3.0.3","info":{"title":"t","version":"1"},"paths":{}}`

// site is a fake host: path -> body (404 for the rest).
func site(pages map[string]string) Getter {
	return func(_ context.Context, u string) (Page, error) {
		i := strings.Index(u, "://")
		p := u[i+3:]
		if j := strings.Index(p, "/"); j >= 0 {
			p = p[j:]
		} else {
			p = "/"
		}
		if b, ok := pages[p]; ok {
			return Page{URL: u, Status: 200, Body: []byte(b)}, nil
		}
		return Page{URL: u, Status: 404}, nil
	}
}

func TestDiscover(t *testing.T) {
	cases := map[string]struct {
		start   string
		pages   map[string]string
		wantURL string
		choices int
	}{
		"the spec itself": {"https://api.test/openapi.json", map[string]string{"/openapi.json": specJSON}, "https://api.test/openapi.json", 0},
		"yaml":            {"https://api.test/openapi.yaml", map[string]string{"/openapi.yaml": "openapi: 3.1.0\ninfo: {}\n"}, "https://api.test/openapi.yaml", 0},
		"old Swagger UI, config inline": {"https://api.test/docs/", map[string]string{
			"/docs/":            `<html><script>const ui = SwaggerUIBundle({ url: "/api/swagger.json", dom_id: '#swagger-ui' })</script>`,
			"/api/swagger.json": `{"swagger":"2.0","info":{},"paths":{}}`,
		}, "https://api.test/api/swagger.json", 0},
		"new Swagger UI, swagger-initializer.js": {"https://api.test/swagger/index.html", map[string]string{
			"/swagger/index.html":             `<html><div id="swagger-ui"></div><script src="./swagger-initializer.js" charset="UTF-8"></script>`,
			"/swagger/swagger-initializer.js": `window.onload = function() { window.ui = SwaggerUIBundle({ url: "/swagger/v1/swagger.json", dom_id: '#swagger-ui', deepLinking: true }); };`,
			"/swagger/v1/swagger.json":        specJSON,
		}, "https://api.test/swagger/v1/swagger.json", 0},
		"Springdoc swagger-config": {"https://api.test/swagger-ui/index.html", map[string]string{
			"/swagger-ui/index.html":             `<html><script src="./swagger-initializer.js"></script>`,
			"/swagger-ui/swagger-initializer.js": `window.ui = SwaggerUIBundle({ configUrl: "/v3/api-docs/swagger-config", dom_id: '#swagger-ui' })`,
			"/v3/api-docs/swagger-config":        `{"configUrl":"/v3/api-docs/swagger-config","url":"/v3/api-docs","validatorUrl":""}`,
			"/v3/api-docs":                       specJSON,
		}, "https://api.test/v3/api-docs", 0},
		"Springdoc without configUrl": {"https://api.test/swagger-ui/index.html", map[string]string{
			"/swagger-ui/index.html":      `<html><title>Swagger UI</title><div id="swagger-ui"></div>`,
			"/v3/api-docs/swagger-config": `{"url":"/v3/api-docs"}`,
			"/v3/api-docs":                specJSON,
		}, "https://api.test/v3/api-docs", 0},
		"Redoc": {"https://api.test/redoc", map[string]string{
			"/redoc":     `<redoc spec-url="/spec.yaml"></redoc>`,
			"/spec.yaml": "swagger: '2.0'\npaths: {}\n",
		}, "https://api.test/spec.yaml", 0},
		"several specs": {"https://api.test/docs", map[string]string{
			"/docs": `<script>SwaggerUIBundle({ urls: [{url: "/v1.json", name: "v1"}, {url: "/v2.json", name: "v2"}], dom_id: '#x' })</script>`,
		}, "", 2},
		"Swagger UI picking the URL in code": {"https://petstore3.test/", map[string]string{
			"/":                       `<html><script src="./swagger-ui-bundle.js"></script><script src="./swagger-initializer.js" charset="UTF-8"> </script>`,
			"/swagger-initializer.js": "window.onload = function() {\n const def = \"https://other.test/v2/swagger.json\";\n const services = `petstore3.test=https://petstore3.test/api/v3/openapi.json,x.test=https://x.test/openapi.json`;\n window.ui = SwaggerUIBundle({ url: definitionURL, \"dom_id\": \"#swagger-ui\" })\n};",
			"/api/v3/openapi.json":    specJSON,
		}, "https://petstore3.test/api/v3/openapi.json", 0},
		"swaggo": {"https://api.test/swagger/index.html", map[string]string{
			"/swagger/index.html": `<html>Swagger UI</html>`,
			"/swagger/doc.json":   `{"swagger":"2.0","info":{},"paths":{}}`,
		}, "https://api.test/swagger/doc.json", 0},
		"the usual paths": {"https://api.test/", map[string]string{
			"/":                        `<html>hello</html>`,
			"/swagger/v1/swagger.json": specJSON,
		}, "https://api.test/swagger/v1/swagger.json", 0},
		"FastAPI under a prefix": {"https://api.test/api/docs", map[string]string{
			"/api/docs":         `<html>FastAPI</html>`,
			"/api/openapi.json": specJSON,
		}, "https://api.test/api/openapi.json", 0},
	}
	for name, c := range cases {
		t.Run(name, func(t *testing.T) {
			f, err := Discover(context.Background(), site(c.pages), c.start)
			if err != nil {
				t.Fatal(err)
			}
			if len(f.Choices) != c.choices {
				t.Fatalf("choices = %+v", f.Choices)
			}
			if c.choices == 0 && (f.URL != c.wantURL || !IsSpec(f.Spec)) {
				t.Errorf("found %s (%d bytes)", f.URL, len(f.Spec))
			}
			if c.choices > 0 && (f.Choices[0].Name != "v1" || f.Choices[1].URL != "https://api.test/v2.json") {
				t.Errorf("choices = %+v", f.Choices)
			}
		})
	}
}

func TestDiscoverNothing(t *testing.T) {
	_, err := Discover(context.Background(), site(map[string]string{"/": "<html>no api</html>"}), "https://api.test/")
	if !errors.Is(err, ErrNoSpec) {
		t.Errorf("err = %v", err)
	}
	if _, err := Discover(context.Background(), site(nil), "file:///etc/passwd"); err == nil {
		t.Error("a file URL")
	}
}

func TestDiscoverStaysOnHost(t *testing.T) {
	g := site(map[string]string{"/docs": `<script>SwaggerUIBundle({ url: "https://evil.test/spec.json" })</script>`})
	if _, err := Discover(context.Background(), g, "https://api.test/docs"); err == nil || !strings.Contains(err.Error(), "another host") {
		t.Errorf("err = %v", err)
	}
}

func TestDiscoverHopLimit(t *testing.T) {
	d := &discovery{get: site(map[string]string{"/a": "x"}), ctx: context.Background()}
	for range maxFollows {
		if _, err := d.follow("https://api.test/", "/a"); err != nil {
			t.Fatal(err)
		}
	}
	if _, err := d.follow("https://api.test/", "/a"); err == nil {
		t.Error("a 4th hop was followed")
	}
}

func TestHTTPGetterLimits(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/big":
			_, _ = w.Write(make([]byte, MaxSpecBytes+10))
		case "/away":
			http.Redirect(w, r, "https://elsewhere.test/spec.json", http.StatusFound)
		default:
			_, _ = w.Write([]byte(specJSON))
		}
	}))
	defer srv.Close()
	get := HTTPGetter(srv.URL+"/", srv.Client().Transport, nil)
	if _, err := get(context.Background(), srv.URL+"/big"); err == nil {
		t.Error("a file over 5 MB")
	}
	if _, err := get(context.Background(), srv.URL+"/away"); err == nil {
		t.Error("a redirect to another host")
	}
	if p, err := get(context.Background(), srv.URL+"/ok"); err != nil || !IsSpec(p.Body) {
		t.Errorf("ok: %v", err)
	}
}

func TestDiscoverWithToken(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("X-Key") != "k-1" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		_, _ = w.Write([]byte(specJSON))
	}))
	defer srv.Close()
	_, err := Discover(context.Background(), HTTPGetter(srv.URL+"/", srv.Client().Transport, nil), srv.URL+"/openapi.json")
	var ae *AuthError
	if !errors.As(err, &ae) || ae.Status != 401 {
		t.Fatalf("without the token: %v", err)
	}
	cred := &Credential{Kind: "header", Name: "X-Key", Value: "k-1"}
	f, err := Discover(context.Background(), HTTPGetter(srv.URL+"/", srv.Client().Transport, cred), srv.URL+"/openapi.json")
	if err != nil || !IsSpec(f.Spec) {
		t.Fatalf("with the token: %v", err)
	}
}

func TestDiscoverBehindLogin(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if u, p, ok := r.BasicAuth(); !ok || u != "ann" || p != "pw:1" {
			w.Header().Set("WWW-Authenticate", `Basic realm="docs"`)
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		_, _ = w.Write([]byte(specJSON))
	}))
	defer srv.Close()
	_, err := Discover(context.Background(), HTTPGetter(srv.URL+"/", srv.Client().Transport, nil), srv.URL+"/openapi.json")
	var ae *AuthError
	if !errors.As(err, &ae) || !ae.Login {
		t.Fatalf("a login prompt: %v", err)
	}
	for _, v := range []string{"ann:pw:1", "YW5uOnB3OjE=", "Basic YW5uOnB3OjE="} { // as typed, or the encoded token
		cred := &Credential{Kind: "basic", Value: v}
		if f, err := Discover(context.Background(), HTTPGetter(srv.URL+"/", srv.Client().Transport, cred), srv.URL+"/openapi.json"); err != nil || !IsSpec(f.Spec) {
			t.Fatalf("with %q: %v", v, err)
		}
	}
}
