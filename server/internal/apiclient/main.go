package apiclient

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/url"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"time"

	"agnts/internal/domain"
)

const usage = `usage:
  agnts-api run <plan.json>                  run every case in the plan, in order
  agnts-api <METHOD> <path> [--json '<body>' | --body-file f] [--header 'K: V'] [--query k=v]
            [--no-auth | --auth wrong] [--id <case-id>]   one request, to look into a result
  agnts-api describe <METHOD /path>          one operation from the spec, with its schemas
  agnts-api fetch-spec <url>                 download a spec (agnts runs this, not Claude)`

// Main is the agnts-api command; it returns the exit code.
func Main(args []string, stdout, stderr io.Writer) int {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	return run(ctx, args, RunFiles, stdout, stderr)
}

func run(ctx context.Context, args []string, files Files, stdout, stderr io.Writer) int {
	fail := func(code int, format string, a ...any) int {
		_, _ = fmt.Fprintf(stderr, "agnts-api: "+format+"\n", a...)
		return code
	}
	if len(args) == 0 {
		return fail(2, "%s", usage)
	}
	switch args[0] {
	case "fetch-spec":
		var cred *Credential
		switch {
		case len(args) == 4 && args[2] == "--auth-file":
			b, err := os.ReadFile(args[3]) //nolint:gosec // G304: the file agnts wrote for this fetch
			if err != nil {
				return fail(1, "the spec credential: %v", err)
			}
			cred = &Credential{}
			if err := json.Unmarshal(b, cred); err != nil {
				return fail(1, "the spec credential is unreadable")
			}
		case len(args) != 2:
			return fail(2, "usage: agnts-api fetch-spec <url> [--auth-file f]")
		}
		return fetchSpec(ctx, args[1], cred, stdout, stderr)
	case "describe":
		if len(args) < 2 {
			return fail(2, "usage: agnts-api describe <METHOD /path>")
		}
		spec, err := os.ReadFile(files.FullSpec)
		if err != nil {
			spec, err = os.ReadFile(files.Spec)
		}
		if err != nil {
			return fail(1, "no spec in this run: %v", err)
		}
		out, err := Describe(spec, strings.Join(args[1:], " "))
		if err != nil {
			return fail(1, "%v", err)
		}
		_, _ = stdout.Write(append(out, '\n'))
		return 0
	case "-h", "--help", "help":
		_, _ = fmt.Fprintln(stdout, usage)
		return 0
	}

	cfg, cred, err := LoadConfig(files)
	if err != nil {
		return fail(1, "%v", err)
	}
	c, err := New(cfg, cred, files, nil)
	if err != nil {
		return fail(1, "%v", err)
	}
	if args[0] == "run" {
		if len(args) != 2 {
			return fail(2, "usage: agnts-api run <plan.json>")
		}
		b, err := os.ReadFile(args[1])
		if err != nil {
			return fail(1, "%v", err)
		}
		p, err := ParsePlan(b)
		if err != nil {
			return fail(1, "%v", err)
		}
		out := c.Run(ctx, p)
		PrintTable(stdout, out)
		if b, err := json.MarshalIndent(out, "", "  "); err == nil && files.LastRun != "" {
			_ = writeFile(files.LastRun, b)
			_, _ = fmt.Fprintf(stdout, "\nEvery case's outcome is in %s; each exchange (status, headers, body) is in %s by request id.\n", files.LastRun, files.Log)
		}
		return 0
	}

	req, err := parseSingle(args)
	if err != nil {
		return fail(2, "%v\n%s", err, usage)
	}
	resp, err := c.Do(ctx, req)
	var refusal *Refusal
	if errors.As(err, &refusal) {
		return fail(3, "refused: %s", refusal.Reason)
	}
	if err != nil && resp.Exchange.ID == "" {
		return fail(1, "%v", err)
	}
	ex := resp.Exchange
	view := map[string]any{"request": ex.ID, "method": ex.Method, "url": ex.URL, "status": ex.Status, "ms": ex.MS, "headers": ex.RespHeaders}
	if ex.Error != "" {
		view["error"] = ex.Error
	}
	var body any
	if json.Unmarshal(resp.Body, &body) == nil {
		view["body"] = body
	} else {
		view["body"] = string(resp.Body)
	}
	if ex.Truncated {
		view["truncated"] = fmt.Sprintf("the body was cut at %d KB", MaxBody>>10)
	}
	b, _ := json.MarshalIndent(view, "", "  ")
	_, _ = stdout.Write(append(b, '\n'))
	return 0
}

// parseSingle reads `<METHOD> <path> [flags]`.
func parseSingle(args []string) (Request, error) {
	if len(args) < 2 {
		return Request{}, errors.New("give a method and a path")
	}
	method := strings.ToUpper(args[0])
	if !isMethod(method) {
		return Request{}, fmt.Errorf("unknown command or method %q", args[0])
	}
	r := Request{Method: method, Path: args[1], Auth: AuthDefault, Headers: map[string]string{}, Query: url.Values{}}
	for i := 2; i < len(args); i++ {
		flag := args[i]
		val := func() (string, error) {
			if i+1 >= len(args) {
				return "", fmt.Errorf("%s needs a value", flag)
			}
			i++
			return args[i], nil
		}
		switch flag {
		case "--json":
			v, err := val()
			if err != nil {
				return r, err
			}
			if !json.Valid([]byte(v)) {
				return r, errors.New("--json is not valid JSON")
			}
			r.Body = []byte(v)
		case "--body-file":
			v, err := val()
			if err != nil {
				return r, err
			}
			if abs, err := filepath.Abs(v); err != nil || strings.HasPrefix(filepath.Clean(abs)+"/", InDir+"/") {
				return r, errors.New("--body-file cannot read agnts's inputs")
			}
			b, err := os.ReadFile(v) //nolint:gosec // G304: a body Claude wrote; agnts's inputs are refused above
			if err != nil {
				return r, err
			}
			r.Body = b
		case "--header":
			v, err := val()
			if err != nil {
				return r, err
			}
			k, hv, ok := strings.Cut(v, ":")
			if !ok {
				return r, errors.New("--header is 'Name: value'")
			}
			r.Headers[strings.TrimSpace(k)] = strings.TrimSpace(hv)
		case "--query":
			v, err := val()
			if err != nil {
				return r, err
			}
			k, qv, _ := strings.Cut(v, "=")
			r.Query.Add(k, qv)
		case "--no-auth":
			r.Auth = AuthOmit
		case "--auth":
			v, err := val()
			if err != nil {
				return r, err
			}
			if v != AuthWrong && v != AuthOmit && v != AuthDefault {
				return r, errors.New("--auth is wrong, none or default")
			}
			r.Auth = v
		case "--id":
			v, err := val()
			if err != nil {
				return r, err
			}
			r.Case = v
		default:
			return r, fmt.Errorf("unknown flag %s", flag)
		}
	}
	return r, nil
}

func isMethod(m string) bool {
	for _, x := range domain.HTTPMethods {
		if x == m {
			return true
		}
	}
	return false
}

// fetchSpec finds and downloads a spec, writing it to FetchedSpecPath and
// what was found to FetchedPath.
func fetchSpec(ctx context.Context, start string, cred *Credential, stdout, stderr io.Writer) int {
	ctx, cancel := context.WithTimeout(ctx, 2*time.Minute)
	defer cancel()
	found, err := Discover(ctx, HTTPGetter(start, nil, cred), start)
	if err := os.MkdirAll(OutDir, 0o750); err != nil {
		_, _ = fmt.Fprintf(stderr, "agnts-api: %v\n", err)
		return 1
	}
	res := map[string]any{"url": found.URL, "choices": found.Choices}
	if err != nil {
		res["error"] = err.Error()
		var ae *AuthError
		if errors.As(err, &ae) {
			res["status"] = ae.Status
			res["login"] = ae.Login
		}
	}
	if len(found.Spec) > 0 {
		if werr := writeFile(FetchedSpecPath, found.Spec); werr != nil {
			res["error"] = werr.Error()
		}
	}
	b, _ := json.Marshal(res)
	if werr := writeFile(FetchedPath, b); werr != nil {
		_, _ = fmt.Fprintf(stderr, "agnts-api: %v\n", werr)
		return 1
	}
	_, _ = stdout.Write(append(b, '\n'))
	if err != nil {
		return 1
	}
	return 0
}
