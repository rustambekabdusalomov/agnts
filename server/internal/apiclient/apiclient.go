// Package apiclient is agnts-api: the only way a Swagger test run calls the
// API under test. It is built into the agnts-guard binary (agnts copies that
// into every run) and runs as agnts-api through a link. It sends requests
// through the egress proxy, to the test's base URL host only, adds the
// credential Claude never sees, refuses writes in a read-only test, keeps
// to the rate, request and auth-failure caps, and logs every exchange for
// agnts to check after the run.
package apiclient

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"syscall"

	"agnts/internal/domain"
)

// Files of a Swagger test run. Inputs are in /agnts/context (the root file
// system is read-only); outputs in /agnts/out, which agnts reads back.
const (
	InDir = "/agnts/context/api"
	// SpecPath is the trimmed spec: the ticked operations and the schemas
	// they use (or, over the size cap, the operation list only).
	SpecPath = InDir + "/spec.json"
	// FullSpecPath is the whole spec, there only when SpecPath had to be
	// cut down to the operation list; describe reads it.
	FullSpecPath = InDir + "/full.json"
	TestPath     = InDir + "/test.json"
	// AuthPath holds the credential. Only agnts-api reads it; the guard
	// refuses every tool that touches it.
	AuthPath = InDir + "/.auth"

	OutDir      = "/agnts/out/api"
	PlanPath    = OutDir + "/plan.json"
	LogPath     = OutDir + "/log.jsonl"
	ResultsPath = OutDir + "/results.json"
	ReportPath  = OutDir + "/report.md"
	// LastRunPath is what the last `agnts-api run` did with each case.
	LastRunPath = OutDir + "/last-run.json"
	// FetchedPath is what fetch-spec found; FetchedSpecPath the spec.
	FetchedPath     = OutDir + "/fetched.json"
	FetchedSpecPath = OutDir + "/fetched-spec"
)

// BinaryPath is the agnts-guard binary in a run; `agnts-guard api ...` is
// agnts-api (a link named agnts-api on the PATH runs it too).
const BinaryPath = "/home/agent/.agnts/bin/agnts-guard"

// MaxBody caps a response body in output and in the log.
const MaxBody = 64 << 10

// TestConfig is test.json: what the run tests, without the credential.
type TestConfig struct {
	BaseURL      string         `json:"baseUrl"`
	Operations   []string       `json:"operations"`
	WriteEnabled bool           `json:"writeEnabled"`
	Auth         domain.APIAuth `json:"auth"`
	Rate         int            `json:"rate"`
	MaxRequests  int            `json:"maxRequests"`
	Notes        string         `json:"notes,omitempty"`
}

// Credential is the .auth file.
type Credential struct {
	Kind  domain.APIAuthKind `json:"kind"`
	Name  string             `json:"name,omitempty"`
	Value string             `json:"value,omitempty"`
}

// Files are where a client reads and writes; tests point them elsewhere.
type Files struct {
	Test, Auth, Log, LastRun, Spec, FullSpec string
}

// RunFiles are the paths in a run container.
var RunFiles = Files{Test: TestPath, Auth: AuthPath, Log: LogPath, LastRun: LastRunPath, Spec: SpecPath, FullSpec: FullSpecPath}

// LoadConfig reads test.json and the credential.
func LoadConfig(f Files) (TestConfig, Credential, error) {
	var cfg TestConfig
	b, err := os.ReadFile(f.Test)
	if err != nil {
		return cfg, Credential{}, fmt.Errorf("this run has no Swagger test (%s): %w", f.Test, err)
	}
	if err := json.Unmarshal(b, &cfg); err != nil {
		return cfg, Credential{}, fmt.Errorf("%s: %w", f.Test, err)
	}
	var cred Credential
	if b, err := os.ReadFile(f.Auth); err == nil {
		if err := json.Unmarshal(b, &cred); err != nil {
			return cfg, cred, errors.New("the credential file is unreadable")
		}
	} else if cfg.Auth.Kind != domain.AuthNone && cfg.Auth.Kind != "" {
		return cfg, cred, errors.New("the credential file is missing")
	}
	if cred.Kind == "" {
		cred.Kind = cfg.Auth.Kind
		cred.Name = cfg.Auth.Name
	}
	return cfg, cred, nil
}

// lockLog serialises agnts-api calls of one run: they share the log and
// its counters.
func lockLog(path string) func() {
	if err := os.MkdirAll(filepath.Dir(path), 0o750); err != nil {
		return func() {}
	}
	f, err := os.OpenFile(path+".lock", os.O_CREATE|os.O_RDWR, 0o600) //nolint:gosec // G304: the run's own log, a fixed path
	if err != nil {
		return func() {}
	}
	if err := syscall.Flock(int(f.Fd()), syscall.LOCK_EX); err != nil {
		_ = f.Close()
		return func() {}
	}
	return func() {
		_ = syscall.Flock(int(f.Fd()), syscall.LOCK_UN)
		_ = f.Close()
	}
}

// readLog returns the exchanges logged so far.
func readLog(path string) []domain.APIExchange {
	b, err := os.ReadFile(path) //nolint:gosec // G304: the run's own log, a fixed path
	if err != nil {
		return nil
	}
	return ReadLog(b)
}

// ReadLog parses a log.jsonl the run wrote.
func ReadLog(b []byte) []domain.APIExchange {
	var out []domain.APIExchange
	for _, l := range strings.Split(string(b), "\n") {
		var e domain.APIExchange
		if strings.TrimSpace(l) != "" && json.Unmarshal([]byte(l), &e) == nil && e.ID != "" {
			out = append(out, e)
		}
	}
	return out
}

func appendLog(path string, e domain.APIExchange) error {
	b, err := json.Marshal(e)
	if err != nil {
		return err
	}
	f, err := os.OpenFile(path, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o600) //nolint:gosec // G304: the run's own log, a fixed path
	if err != nil {
		return err
	}
	defer func() { _ = f.Close() }()
	_, err = f.Write(append(b, '\n'))
	return err
}
