package main

import (
	_ "embed"
	"fmt"
	"strings"
	"time"
)

// What gin.Default() prints at start with GIN_MODE unset, recorded from the
// real gateway: the debug-mode warning and the route table.
//
//go:embed traces/gin-banner.txt
var ginBanner string

var (
	// GW-1: the per-IP login limiter is on /auth/login/, so /auth/login is never limited.
	bugGW1 = &bug{repo: "auth-gateway", file: "cmd/auth-gateway/main.go", has: []string{`limit.OnPath("/auth/login/", loginLimit)`}}
	// GW-2: a wrong password logs the email (internal/account/login.go:79).
	bugGW2 = &bug{repo: "auth-gateway", file: "internal/account/login.go", has: []string{"login failed for %s: wrong password"}}
	// GW-3: the static handler serves dotfiles, and the web root is /app, next to /app/.env.
	bugGW3 = &bug{repo: "auth-gateway", file: "internal/edge/static.go", has: []string{"func Static("}, lacks: []string{"seg[0] == '.'"}}
	// GW-4: gin.Default() in debug mode.
	bugGW4 = &bug{repo: "auth-gateway", file: "cmd/auth-gateway/main.go", has: []string{"gin.Default()"}, lacks: []string{"gin.SetMode(gin.ReleaseMode)"}}
)

// The paths a scanner tries before /.env: more than ten well-known ones, so
// agnts counts a scan.
var gatewayScanPaths = []string{"/wp-login.php", "/phpmyadmin/", "/.git/config", "/server-status", "/xmlrpc.php",
	"/.aws/credentials", "/actuator/env", "/config.json", "/backup.sql", "/.DS_Store", "/wp-admin/", "/.htaccess"}

var browserAgents = []string{
	"Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Mobile/15E148 Safari/604.1",
	"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
}

// gatewayRequest writes what the gateway prints for one request: its access
// log line (internal/edge/accesslog.go) and gin's Logger line.
func gatewayRequest(e *emitter, ip, method, uri string, status, size int, ua string) {
	now := time.Now().UTC()
	fmt.Fprintf(e.out, "%s - - [%s] \"%s %s HTTP/1.1\" %d %d \"-\" \"%s\"\n", ip, now.Format("02/Jan/2006:15:04:05 -0700"), method, uri, status, size, ua)
	latency := time.Duration(60+e.rng.IntN(1500)) * time.Microsecond
	switch {
	case strings.HasPrefix(uri, "/auth/login") && status != 429:
		latency = time.Duration(33+e.rng.IntN(8))*time.Millisecond + time.Duration(e.rng.IntN(1000))*time.Microsecond // argon2
	case strings.HasPrefix(uri, "/api/"):
		latency = time.Duration(1+e.rng.IntN(14))*time.Millisecond + time.Duration(e.rng.IntN(1000))*time.Microsecond
	}
	fmt.Fprintf(e.out, "[GIN] %s | %3d | %13v | %15s | %-7s %#v\n", now.Format("2006/01/02 - 15:04:05"), status, latency, ip, method, uri)
}

func authGateway() *service {
	s := &service{name: "auth-gateway"}
	start := func(e *emitter) {
		if e.has(bugGW4) {
			fmt.Fprint(e.out, ginBanner)
		}
		e.json.Info("listening", "addr", ":8080")
	}
	s.start = start
	s.normal = func(e *emitter) {
		ip, ua := e.ip(), "Go-http-client/1.1"
		if e.rng.IntN(3) == 0 {
			ua = browserAgents[e.rng.IntN(len(browserAgents))]
		}
		switch n := e.rng.IntN(12); {
		case n < 3:
			gatewayRequest(e, ip, "GET", "/api/products?limit=20", 200, 4600+e.rng.IntN(120), ua)
		case n < 5:
			gatewayRequest(e, ip, "GET", fmt.Sprintf("/api/products/%d", 1+e.rng.IntN(40)), 200, 205+e.rng.IntN(30), ua)
		case n < 6:
			gatewayRequest(e, ip, "GET", "/api/products?search="+shopSearches[e.rng.IntN(len(shopSearches))], 200, 250+e.rng.IntN(60), ua)
		case n < 7:
			gatewayRequest(e, ip, "POST", "/auth/login", 200, 543, ua)
		case n < 8:
			gatewayRequest(e, ip, "POST", "/auth/refresh", 200, 543, ua)
		case n < 9:
			gatewayRequest(e, ip, "POST", "/api/cart/items", 201, 210+e.rng.IntN(20), ua)
		case n < 10:
			gatewayRequest(e, ip, "GET", "/api/orders", 200, 260+e.rng.IntN(400), ua)
		case n < 11:
			gatewayRequest(e, ip, "GET", "/", 200, 1554, browserAgents[e.rng.IntN(len(browserAgents))])
		default:
			gatewayRequest(e, ip, "POST", "/api/checkout", 201, 260+e.rng.IntN(110), ua)
		}
	}
	s.incidents = []*incident{
		{id: "gw-1", title: "credential stuffing: 26 failed logins from one address, never limited", bug: bugGW1, run: func(e *emitter) {
			ip := e.ip()
			for i := range 26 {
				if i%3 == 0 { // a shopper's address from a leaked list: the email goes to the log (GW-2)
					email := e.shopper()
					if e.has(bugGW2) {
						e.json.Warn(fmt.Sprintf("login failed for %s: wrong password", email), "user_id", e.uuid(), "failed_logins", 1)
					} else {
						e.json.Warn("login failed", "reason", "wrong password")
					}
				} else {
					e.json.Warn("login failed", "reason", "unknown email")
				}
				gatewayRequest(e, ip, "POST", "/auth/login", 401, 37, "python-requests/2.32.3")
				e.pauseMs(150, 900)
			}
		}},
		{id: "gw-2", title: "a mistyped password: the email address goes to the log", bug: bugGW2, run: func(e *emitter) {
			ip, email := e.ip(), e.shopper()
			ua := browserAgents[e.rng.IntN(len(browserAgents))]
			e.json.Warn(fmt.Sprintf("login failed for %s: wrong password", email), "user_id", e.uuid(), "failed_logins", 1)
			gatewayRequest(e, ip, "POST", "/auth/login", 401, 37, ua)
			e.pauseMs(2000, 6000)
			gatewayRequest(e, ip, "POST", "/auth/login", 200, 543, ua)
		}},
		{id: "scan", title: "a scanner walks well-known paths; /.env answers 200 while GW-3 is on main", run: func(e *emitter) {
			ip := e.ip()
			ua := []string{"Mozilla/5.0 zgrab/0.x", "curl/8.5.0", "Go-http-client/1.1"}[e.rng.IntN(3)]
			for _, p := range gatewayScanPaths {
				gatewayRequest(e, ip, "GET", p, 404, 21, ua)
				e.pauseMs(40, 160)
			}
			if e.has(bugGW3) {
				gatewayRequest(e, ip, "GET", "/.env", 200, 110, ua)
			} else {
				gatewayRequest(e, ip, "GET", "/.env", 404, 21, ua)
			}
		}},
		{id: "gw-4", title: "a restart: Gin starts in debug mode", bug: bugGW4, run: func(e *emitter) {
			start(e)
		}},
	}
	return s
}
