package runner

import (
	"bufio"
	"context"
	"errors"
	"fmt"
	"io"
	"regexp"
	"strings"
	"time"
)

// Muse sign-in: Muse Code's own `muse login` runs in a throwaway
// container from the run image, prints Meta's sign-in page and code, waits
// for the person to approve it, and saves its credential file. agnts reads
// that file out and keeps it as the person's Muse connection, so the login
// is exactly what Muse itself made: its client, its scopes, its format.

// museFileCredentials makes Muse keep its login in a file. Its default
// backend on Linux is a keychain, which lives and dies with the container:
// `muse login` then succeeds and leaves nothing behind to keep. Runs set
// it too, so Muse reads the file it is given and writes a refreshed
// token back into it. (Valid backends, from Muse 1.4.13: file, keychain,
// keychain_fallback_file.)
const museFileCredentials = "TBH_CREDENTIAL_BACKEND=file"

// museLoginHome is the login container's home, on a tmpfs (the root
// filesystem stays read-only).
const museLoginHome = "/tmp/home"

// museLoginFiles are where `muse login` may save its credentials on Linux;
// the first found wins.
var museLoginFiles = []string{museLoginHome + "/.config/muse/auth.json", museLoginHome + "/.local/share/muse/auth.json"}

// MuseLoginPrompt is what the person needs to approve the sign-in.
type MuseLoginPrompt struct {
	URL       string
	Code      string
	ExpiresAt time.Time
}

// MuseLoginResult is how a sign-in ended: Muse's credential file, or why not.
type MuseLoginResult struct {
	File []byte
	Err  error
}

var (
	loginURL  = regexp.MustCompile(`https://\S+`)
	loginCode = regexp.MustCompile(`\b[A-Z0-9]{4}-[A-Z0-9]{4}\b`)
)

// MuseLoginLife is how long a sign-in may wait for approval (Meta's codes
// last 10 minutes).
const MuseLoginLife = 12 * time.Minute

// MuseLogin starts `muse login` in a new container from image and returns
// the page and code once Muse prints them. The result arrives on the
// channel when the person approves (or the code expires); the container
// is removed either way.
func (r *Runner) MuseLogin(ctx context.Context, image string) (MuseLoginPrompt, <-chan MuseLoginResult, error) {
	bg, cancel := context.WithTimeout(context.WithoutCancel(ctx), MuseLoginLife)
	id, err := r.docker.Create(bg, ContainerConfig{
		Image: image, User: agentUser, Cmd: []string{"sleep", "900"}, Network: "bridge",
		MemoryMB: 512, CPUs: 1, PIDs: 256, Labels: map[string]string{"agnts": "muse-login"},
		Tmpfs: map[string]string{"/tmp": "rw,exec,nosuid,size=256m,uid=1000,gid=1000"},
	})
	if err != nil {
		cancel()
		return MuseLoginPrompt{}, nil, fmt.Errorf("muse login container: %w", err)
	}
	cleanup := func() {
		_ = r.docker.Remove(context.WithoutCancel(ctx), id)
		cancel()
	}
	if err := r.docker.Start(bg, id); err != nil {
		cleanup()
		return MuseLoginPrompt{}, nil, err
	}
	var stderr tailBuffer
	a, err := r.docker.ExecAttach(bg, id, ExecConfig{
		Cmd:  []string{"sh", "-c", `mkdir -p "$HOME" && exec muse login`},
		User: agentUser,
		Env:  append([]string{"HOME=" + museLoginHome, "NO_COLOR=1", "MUSE_UPDATE_INTERVAL_SECONDS=31536000"}, museFileCredentials),
	}, &stderr)
	if err != nil {
		cleanup()
		return MuseLoginPrompt{}, nil, err
	}
	_ = a.Close() // no input: `muse login` waits for the browser, not the terminal

	prompt, err := readLoginPrompt(bg, a)
	if err != nil {
		_ = a.Kill()
		cleanup()
		return MuseLoginPrompt{}, nil, fmt.Errorf("%w: %s", err, strings.TrimSpace(stderr.String()))
	}
	prompt.ExpiresAt = time.Now().Add(10 * time.Minute)

	out := make(chan MuseLoginResult, 1)
	go func() {
		defer cleanup()
		_, _ = io.Copy(io.Discard, a) // the rest of its output
		code, err := a.Wait(bg)
		switch {
		case bg.Err() != nil:
			out <- MuseLoginResult{Err: errors.New("the code expired before it was approved; start again")}
			return
		case err != nil:
			out <- MuseLoginResult{Err: err}
			return
		case code != 0:
			out <- MuseLoginResult{Err: fmt.Errorf("muse login ended with exit %d: %s", code, strings.TrimSpace(stderr.String()))}
			return
		}
		w := &workspace{docker: r.docker, id: id}
		for _, p := range museLoginFiles {
			if b, err := w.ReadFile(bg, p); err == nil && len(b) > 0 {
				out <- MuseLoginResult{File: b}
				return
			}
		}
		// Not where expected: ask the container where Muse put it.
		var found strings.Builder
		if _, err := r.docker.Exec(bg, id, ExecConfig{Cmd: []string{"sh", "-c", "find " + museLoginHome + " -name auth.json -path '*muse*' 2>/dev/null | head -1"},
			User: agentUser}, &found, io.Discard); err == nil {
			if p := strings.TrimSpace(found.String()); p != "" {
				if b, err := w.ReadFile(bg, p); err == nil && len(b) > 0 {
					out <- MuseLoginResult{File: b}
					return
				}
			}
		}
		out <- MuseLoginResult{Err: errors.New("muse login finished but saved no credential file")}
	}()
	return prompt, out, nil
}

// readLoginPrompt reads `muse login`'s output until it has printed the
// sign-in page and the code.
func readLoginPrompt(ctx context.Context, r io.Reader) (MuseLoginPrompt, error) {
	type res struct {
		p   MuseLoginPrompt
		err error
	}
	done := make(chan res, 1)
	go func() {
		var p MuseLoginPrompt
		sc := bufio.NewScanner(r)
		for sc.Scan() {
			line := sc.Text()
			if p.URL == "" {
				p.URL = loginURL.FindString(line)
			}
			if p.Code == "" && !strings.Contains(line, "http") {
				p.Code = loginCode.FindString(line)
			}
			if p.URL != "" && p.Code != "" {
				done <- res{p: p}
				return
			}
		}
		done <- res{err: errors.New("muse login printed no sign-in page")}
	}()
	timer := time.NewTimer(90 * time.Second)
	defer timer.Stop()
	select {
	case x := <-done:
		return x.p, x.err
	case <-timer.C:
		return MuseLoginPrompt{}, errors.New("muse login did not print a sign-in page in time")
	case <-ctx.Done():
		return MuseLoginPrompt{}, ctx.Err()
	}
}
