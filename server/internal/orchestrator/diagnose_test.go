package orchestrator

import (
	"strings"
	"testing"

	"agnts/internal/domain"
)

// The AMANAT-1 output: go fetching private modules with no git token.
const goNoTokenOutput = `go: downloading gitlab.iman.uz/core-service/grpc_contracts v1.0.0
go: downloading gitlab.iman.uz/iman-invest/protos v1.63.0
internal/infrastructure/grpc_service_client/services.go:8:2: reading gitlab.iman.uz/core-service/grpc_contracts/go.mod at revision v1.0.0: git ls-remote -q origin in /home/agent/.cache/go-mod/cache/vcs/2c0a: exit status 128:
    fatal: could not read Username for 'https://gitlab.iman.uz': terminal prompts disabled
Confirm the import path was entered correctly.
internal/infrastructure/grpc_service_client/services.go:9:2: reading gitlab.iman.uz/iman-invest/protos/go.mod at revision v1.63.0: git ls-remote -q origin in /home/agent/.cache/go-mod/cache/vcs/52e6: exit status 128:
    fatal: could not read Username for 'https://gitlab.iman.uz': terminal prompts disabled`

func TestDiagnose(t *testing.T) {
	repo := domain.Repository{Name: "gateway"}
	cases := []struct {
		name, output, reason string
		want                 []string
		not                  []string
	}{
		{"go private modules without a token", goNoTokenOutput, "git_auth",
			[]string{"log in to gitlab.iman.uz", "network is fine", "gitlab.iman.uz/core-service/grpc_contracts, gitlab.iman.uz/iman-invest/protos",
				"Repositories → gateway → Advanced → Build environment", "GOPRIVATE=gitlab.iman.uz\n",
				"GIT_CONFIG_KEY_0=url.https://oauth2:<TOKEN>@gitlab.iman.uz/.insteadOf", "GIT_CONFIG_VALUE_0=https://gitlab.iman.uz/"}, nil},
		{"plain git without a token", "fatal: could not read Username for 'https://github.com': terminal prompts disabled", "git_auth",
			[]string{"x-access-token:<TOKEN>@github.com"}, []string{"GOPRIVATE", "deploy token"}},
		{"token rejected", "remote: HTTP Basic: Access denied\nfatal: Authentication failed for 'https://gitlab.corp.local/a/b.git/'", "git_auth",
			[]string{"gitlab.corp.local"}, nil},
		{"egress refused", "fatal: unable to access 'https://gitlab.corp.local/a/b.git/': Received HTTP code 403 from proxy after CONNECT", "egress_blocked",
			[]string{"may not reach gitlab.corp.local", "Settings → Private networks"}, nil},
		{"go through the proxy refused", `go: gitlab.corp.local/a/b@v1.0.0: unrecognized import path "gitlab.corp.local/a/b": https fetch: Get "https://gitlab.corp.local/a/b?go-get=1": Forbidden`, "egress_blocked",
			[]string{"may not reach gitlab.corp.local"}, nil},
		{"private network down", "fatal: unable to access 'https://gitlab.corp.local/a/b.git/': Received HTTP code 502 from proxy after CONNECT", "host_unreachable",
			[]string{"could not connect to gitlab.corp.local", "VPN"}, nil},
		{"token without access", "go: gitlab.iman.uz/imandev/common_package@v1.2.15: reading gitlab.iman.uz/imandev/common_package/go.mod at revision v1.2.15: git ls-remote -q origin in /x: exit status 128:\n" +
			"    remote: The project you were looking for could not be found or you don't have permission to view it.\n" +
			"    fatal: repository 'https://gitlab.iman.uz/imandev/common_package.git/' not found\n" +
			"    fatal: repository 'https://oauth2:secret@gitlab.iman.uz/imandev/common_package.git/' not found", "git_no_access",
			[]string{"no access to it", "says gitlab.iman.uz/imandev/common_package does not exist", "Repositories → gateway"}, []string{"secret", "common_package, "}},
		{"npm registry token", "npm error code E401\nnpm error 401 Unauthorized - GET https://npm.corp.local/@corp%2fui - authentication token not provided", "registry_auth",
			[]string{"npm.corp.local", "//npm.corp.local/:_authToken=${NPM_TOKEN}"}, nil},
		{"checksum database", "verifying gitlab.corp.local/a/b@v1.2.0: gitlab.corp.local/a/b@v1.2.0: reading https://sum.golang.org/lookup/gitlab.corp.local/a/b@v1.2.0: 404 Not Found", "go_private_module",
			[]string{"GOPRIVATE=gitlab.corp.local"}, nil},
		{"a failing test is the code", "--- FAIL: TestLogin (0.00s)\n    login_test.go:12: could not read Username for user 7", "", nil, nil},
		{"a test about DNS is the code", "--- FAIL: TestResolve\n    resolve_test.go:9: dial tcp: lookup nowhere.invalid: no such host", "", nil, nil},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			msg, reason := diagnose(repo, c.output)
			if reason != c.reason {
				t.Fatalf("reason = %q, want %q\n%s", reason, c.reason, msg)
			}
			for _, w := range c.want {
				if !strings.Contains(msg, w) {
					t.Errorf("message lacks %q:\n%s", w, msg)
				}
			}
			for _, n := range c.not {
				if strings.Contains(msg, n) {
					t.Errorf("message has %q:\n%s", n, msg)
				}
			}
		})
	}
}

// With git credentials in the build environment already, the advice is
// about the token, not how to add one.
func TestDiagnoseTokenSet(t *testing.T) {
	repo := domain.Repository{Name: "gateway", BuildEnvNames: []string{"GOPRIVATE", "GIT_CONFIG_COUNT", "GIT_CONFIG_KEY_0", "GIT_CONFIG_VALUE_0"}}
	msg, reason := diagnose(repo, goNoTokenOutput)
	if reason != "git_auth" || !strings.Contains(msg, "refused the git credentials") || strings.Contains(msg, "GIT_CONFIG_KEY_0=") {
		t.Fatalf("%s: %s", reason, msg)
	}
}
