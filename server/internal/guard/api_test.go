package guard

import (
	"testing"
)

func TestAPIGuard(t *testing.T) {
	cfg := Config{Profile: Standard, API: &APIGuard{Host: "staging.iman.uz", AuthPath: "/agnts/context/api/.auth", InDir: "/agnts/context/api"},
		Disabled: []string{HookAPI}} // cannot be turned off
	bash := func(c string) Input { return toolInput("Bash", map[string]string{"command": c}) }
	cases := []struct {
		name  string
		in    Input
		block bool
	}{
		{"Read the credential", toolInput("Read", map[string]string{"file_path": "/agnts/context/api/.auth"}), true},
		{"Grep the folder", toolInput("Grep", map[string]string{"pattern": "Bearer", "path": "/agnts/context/api"}), true},
		{"Grep above it", toolInput("Grep", map[string]string{"pattern": "token", "path": "/agnts"}), true},
		{"Grep the root", toolInput("Grep", map[string]string{"pattern": "token", "path": "/"}), true},
		{"Glob the folder", toolInput("Glob", map[string]string{"pattern": "**/*", "path": "/agnts/context"}), true},
		{"Edit it", toolInput("Edit", map[string]string{"file_path": "/agnts/context/api/.auth", "old_string": "a", "new_string": "b"}), true},
		{"cat it", bash("cat /agnts/context/api/.auth"), true},
		{"base64 it", bash("cd /agnts/context/api && base64 .auth"), true},
		{"glob the folder", bash("cat /agnts/context/api/*"), true},
		{"dotfiles in the folder", bash("head /agnts/context/api/.*"), true},
		{"recursive grep above", bash("grep -r token /agnts/context"), true},
		{"tar the folder", bash("tar czf /tmp/x.tgz /agnts/context/api"), true},
		{"curl the API", bash("curl -s https://staging.iman.uz/api/v1/users"), true},
		{"python the API", bash(`python3 -c "import urllib.request; urllib.request.urlopen('https://staging.iman.uz/x')"`), true},
		{"wget after cd", bash("cd /tmp && wget staging.iman.uz/x"), true},

		{"Read the spec", toolInput("Read", map[string]string{"file_path": "/agnts/context/api/spec.json"}), false},
		{"Grep the workspace", toolInput("Grep", map[string]string{"pattern": "handler", "path": "/workspace"}), false},
		{"agnts-api", bash("agnts-api GET /api/v1/users"), false},
		{"agnts-api with the URL", bash("cd /tmp && agnts-api GET https://staging.iman.uz/api/v1/users | head"), false},
		{"jq the log", bash("jq -c . /agnts/out/api/log.jsonl | head"), false},
		{"list results", bash("ls /agnts/out/api/*.json"), false},
		{"cat the test", bash("cat /agnts/context/api/test.json"), false},
		{"curl elsewhere", bash("echo staging.iman.uz"), false},
	}
	for _, c := range cases {
		res, _ := Handle("pre", c.in, cfg, &State{}, &fakeEnv{})
		if got := res.Exit == 2; got != c.block {
			t.Errorf("%s: blocked=%v (%s)", c.name, got, res.Stderr)
		}
	}
	// Other runs: no API guard.
	res, _ := Handle("pre", bash("curl -s https://staging.iman.uz/x"), Config{Profile: Standard}, &State{}, &fakeEnv{})
	if res.Exit == 2 {
		t.Error("the API guard runs outside a Swagger test")
	}
}
