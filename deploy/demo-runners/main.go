// Command demo-runners pretends to be one of the Meta workspace's Shop
// services and writes its logs to stdout, for demonstrating agnts's log
// watcher. The lines copy what the real code prints: the same formats,
// messages, files and line numbers, recorded from the services running with
// their planted bugs. DEMO_SERVICE picks the service:
//
//	shop-api        github.com/abdusalomovrustambek/shop-api (slog JSON, Go panics)
//	billing-worker  github.com/abdusalomovrustambek/billing-worker (text log, crashes)
//	auth-gateway    github.com/abdusalomovrustambek/auth-gateway (Gin, access log)
//
// Ordinary traffic comes every second or two. An incident comes every
// DEMO_EVERY_MIN to DEMO_EVERY_MAX (default 5m to 10m), picked from the
// incidents whose bug is still on the repository's main branch: every
// DEMO_CHECK_EVERY (5m) the runner reads the bug's file from GitHub, so a
// merged fix makes its incident stop, as it would in the real service.
//
// Other settings: DEMO_INCIDENTS limits incidents to a list (empty: none);
// DEMO_IGNORE_FIXES=1 emits incidents whose bug was fixed; DEMO_REPO_OWNER
// is the GitHub owner of the repositories.
//
// Commands:
//
//	demo-runners                 run the service
//	demo-runners trigger <id>    make the running process emit <id> now
//	demo-runners print <id>      write incident <id> once, quickly, and exit
//	demo-runners list            list the service's incidents and their bugs
package main

import (
	"context"
	"errors"
	"fmt"
	"math/rand/v2"
	"os"
	"slices"
	"strings"
	"time"
)

// triggerFile is where `demo-runners trigger` leaves an incident id for the
// running process (the image is FROM scratch: no /tmp).
var triggerFile = "/demo-trigger"

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, "demo-runners:", err)
		os.Exit(2)
	}
}

func run(args []string) error {
	svc, err := serviceNamed(os.Getenv("DEMO_SERVICE"))
	if err != nil {
		return err
	}
	if len(args) > 0 {
		switch args[0] {
		case "trigger":
			if len(args) != 2 {
				return errors.New("usage: demo-runners trigger <incident>")
			}
			if svc.incident(args[1]) == nil {
				return fmt.Errorf("%s has no incident %q (see demo-runners list)", svc.name, args[1])
			}
			return os.WriteFile(triggerFile, []byte(args[1]), 0o644)
		case "print":
			if len(args) != 2 {
				return errors.New("usage: demo-runners print <incident>")
			}
			in := svc.incident(args[1])
			if in == nil {
				return fmt.Errorf("%s has no incident %q", svc.name, args[1])
			}
			e := newEmitter(svc.name, rand.New(rand.NewPCG(1, 2)))
			e.fast = true
			e.errOut = e.out // one stream, in order
			in.run(e)
			return nil
		case "list":
			for _, in := range svc.incidents {
				bug := "always"
				if in.bug != nil {
					bug = in.bug.repo + "/" + in.bug.file
				}
				fmt.Printf("%-10s %s (%s)\n", in.id, in.title, bug)
			}
			return nil
		default:
			return fmt.Errorf("unknown command %q", args[0])
		}
	}
	cfg, err := loadConfig(svc)
	if err != nil {
		return err
	}
	loop(svc, cfg)
	return nil
}

type config struct {
	everyMin, everyMax time.Duration
	checkEvery         time.Duration
	enabled            []string // incident ids
	ignoreFixes        bool
	owner              string
}

func loadConfig(svc *service) (config, error) {
	cfg := config{everyMin: 5 * time.Minute, everyMax: 10 * time.Minute, checkEvery: 5 * time.Minute, owner: "abdusalomovrustambek"}
	for _, d := range []struct {
		env string
		to  *time.Duration
	}{{"DEMO_EVERY_MIN", &cfg.everyMin}, {"DEMO_EVERY_MAX", &cfg.everyMax}, {"DEMO_CHECK_EVERY", &cfg.checkEvery}} {
		if v := os.Getenv(d.env); v != "" {
			t, err := time.ParseDuration(v)
			if err != nil || t <= 0 {
				return cfg, fmt.Errorf("%s must be a duration like 5m, got %q", d.env, v)
			}
			*d.to = t
		}
	}
	if cfg.everyMax < cfg.everyMin {
		return cfg, errors.New("DEMO_EVERY_MAX is shorter than DEMO_EVERY_MIN")
	}
	for _, in := range svc.incidents {
		cfg.enabled = append(cfg.enabled, in.id)
	}
	if v, ok := os.LookupEnv("DEMO_INCIDENTS"); ok {
		cfg.enabled = nil
		for _, id := range strings.FieldsFunc(v, func(r rune) bool { return r == ',' || r == ' ' }) {
			if svc.incident(id) == nil {
				return cfg, fmt.Errorf("DEMO_INCIDENTS: %s has no incident %q", svc.name, id)
			}
			cfg.enabled = append(cfg.enabled, id)
		}
	}
	cfg.ignoreFixes = os.Getenv("DEMO_IGNORE_FIXES") == "1"
	if v := os.Getenv("DEMO_REPO_OWNER"); v != "" {
		cfg.owner = v
	}
	return cfg, nil
}

func loop(svc *service, cfg config) {
	rng := rand.New(rand.NewPCG(uint64(time.Now().UnixNano()), uint64(os.Getpid())))
	e := newEmitter(svc.name, rng)
	bugs := newBugState(cfg.owner)
	if !cfg.ignoreFixes {
		ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
		bugs.refresh(ctx, svc)
		cancel()
		go func() {
			for range time.Tick(cfg.checkEvery) {
				ctx, cancel := context.WithTimeout(context.Background(), time.Minute)
				bugs.refresh(ctx, svc)
				cancel()
			}
		}()
	}
	e.has = func(b *bug) bool { return cfg.ignoreFixes || bugs.present(b) }
	present := func(in *incident) bool { return e.has(in.bug) }

	svc.start(e)
	_ = os.Remove(triggerFile)
	next := time.Now().Add(between(rng, cfg.everyMin, cfg.everyMax))
	for {
		time.Sleep(time.Duration(800+rng.IntN(1700)) * time.Millisecond)
		if b, err := os.ReadFile(triggerFile); err == nil {
			_ = os.Remove(triggerFile)
			if in := svc.incident(strings.TrimSpace(string(b))); in != nil {
				in.run(e) // a trigger runs even when the bug is fixed: the operator asked
				continue
			}
		}
		svc.normal(e)
		if time.Now().After(next) {
			var ready []*incident
			for _, in := range svc.incidents {
				if slices.Contains(cfg.enabled, in.id) && present(in) {
					ready = append(ready, in)
				}
			}
			if len(ready) > 0 {
				ready[rng.IntN(len(ready))].run(e)
			}
			next = time.Now().Add(between(rng, cfg.everyMin, cfg.everyMax))
		}
	}
}

// between is a random duration in [lo, hi].
func between(rng *rand.Rand, lo, hi time.Duration) time.Duration {
	if hi <= lo {
		return lo
	}
	return lo + time.Duration(rng.Int64N(int64(hi-lo)+1))
}

// A service is one pretend service: its start lines, its ordinary traffic
// and its incidents.
type service struct {
	name      string
	start     func(e *emitter)
	normal    func(e *emitter)
	incidents []*incident
}

func (s *service) incident(id string) *incident {
	for _, in := range s.incidents {
		if in.id == id {
			return in
		}
	}
	return nil
}

// An incident is one planted bug showing in the log. bug says where the bug
// lives, so the runner can tell whether it is still on main; nil means the
// incident does not depend on a bug (a scanner, say).
type incident struct {
	id, title string
	bug       *bug
	run       func(e *emitter)
}

func serviceNamed(name string) (*service, error) {
	switch name {
	case "shop-api":
		return shopAPI(), nil
	case "billing-worker":
		return billingWorker(), nil
	case "auth-gateway":
		return authGateway(), nil
	}
	return nil, fmt.Errorf("DEMO_SERVICE must be shop-api, billing-worker or auth-gateway, got %q", name)
}
