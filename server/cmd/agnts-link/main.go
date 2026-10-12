// Command agnts-link is the agnts connector: run it inside your network to
// let agnts reach your self-hosted GitLab, Jira or package registry
// without a VPN config or an inbound firewall rule.
//
//	AGNTS_LINK_TOKEN=lnk_...                     the token from Settings → Private network
//	AGNTS_LINK_ALLOW=gitlab.corp.local,10.20.0.0/16
//	                                             hosts, .domains and ranges agnts may reach
//	AGNTS_LINK_URL=https://api.agnts.uz/link     where to connect (shown with the token)
//	AGNTS_LINK_HOOKS_ADDR=:8080                  webhook relay ("" turns it off)
//	AGNTS_LINK_LOG_LEVEL=info
package main

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"agnts/internal/link"
)

var version = "dev"

func main() {
	if len(os.Args) > 1 && (os.Args[1] == "version" || os.Args[1] == "--version") {
		fmt.Println("agnts-link", version)
		return
	}
	level := slog.LevelInfo
	_ = level.UnmarshalText([]byte(env("AGNTS_LINK_LOG_LEVEL", "info")))
	log := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: level}))
	var allow []string
	for _, a := range strings.Split(os.Getenv("AGNTS_LINK_ALLOW"), ",") {
		if a = strings.TrimSpace(a); a != "" {
			allow = append(allow, a)
		}
	}
	hooks, ok := os.LookupEnv("AGNTS_LINK_HOOKS_ADDR")
	if !ok {
		hooks = ":8080"
	}
	l, err := link.New(link.Config{
		URL:       env("AGNTS_LINK_URL", "https://api.agnts.uz/link"),
		Token:     strings.TrimSpace(os.Getenv("AGNTS_LINK_TOKEN")),
		Allow:     allow,
		HooksAddr: strings.TrimSpace(hooks),
		Version:   version,
	}, log)
	if err != nil {
		fmt.Fprintln(os.Stderr, "agnts-link:", err)
		os.Exit(2)
	}
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	log.Info("agnts-link starting", "version", version, "allow", strings.Join(allow, ","))
	if err := l.Run(ctx); err != nil {
		fmt.Fprintln(os.Stderr, "agnts-link:", err)
		os.Exit(1)
	}
}

func env(k, def string) string {
	if v := strings.TrimSpace(os.Getenv(k)); v != "" {
		return v
	}
	return def
}
