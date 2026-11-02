// Command demo-runners pretends to be a small production service and writes
// its logs to stdout: ordinary traffic every second or two, and now and then
// an incident the log watcher should notice. DEMO_SERVICE picks the service:
//
//	shop-api        a Go HTTP API: JSON request logs, panics, 5xx bursts,
//	                a bearer token written to the log
//	billing-worker  a Python worker: tracebacks, a database URL with its
//	                password, database connection errors
//	auth-gateway    an nginx front door: brute-force logins, scanners,
//	                .env served to a scanner, debug mode, a Node TypeError
//
// DEMO_EVERY is the average time between incidents (default 45s).
package main

import (
	"encoding/json"
	"fmt"
	"math/rand/v2"
	"os"
	"strings"
	"time"
)

func main() {
	svc := os.Getenv("DEMO_SERVICE")
	every, err := time.ParseDuration(os.Getenv("DEMO_EVERY"))
	if err != nil || every <= 0 {
		every = 45 * time.Second
	}
	var s service
	switch svc {
	case "shop-api":
		s = shopAPI{}
	case "billing-worker":
		s = billingWorker{}
	case "auth-gateway":
		s = authGateway{}
	default:
		fmt.Fprintln(os.Stderr, "DEMO_SERVICE must be shop-api, billing-worker or auth-gateway")
		os.Exit(2)
	}
	s.start()
	next := time.Now().Add(jitter(every))
	for {
		time.Sleep(time.Duration(800+rand.IntN(1700)) * time.Millisecond)
		s.normal()
		if time.Now().After(next) {
			incidents := s.incidents()
			incidents[rand.IntN(len(incidents))]()
			next = time.Now().Add(jitter(every))
		}
	}
}

// jitter is d give or take a half.
func jitter(d time.Duration) time.Duration {
	return d/2 + time.Duration(rand.Int64N(int64(d)))
}

type service interface {
	start()
	normal()
	incidents() []func()
}

func now() string { return time.Now().UTC().Format("2006-01-02T15:04:05.000Z") }

func jsonLine(m map[string]any) {
	m["time"] = now()
	b, _ := json.Marshal(m)
	fmt.Println(string(b))
}

// lines prints a multi-line trace line by line, as runtimes do on stderr.
func lines(s string) {
	for _, l := range strings.Split(strings.TrimRight(s, "\n"), "\n") {
		fmt.Println(l)
		time.Sleep(2 * time.Millisecond)
	}
}

func pick[T any](xs ...T) T { return xs[rand.IntN(len(xs))] }

func ip() string { return fmt.Sprintf("203.0.113.%d", 2+rand.IntN(250)) }

func token() string {
	const abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
	b := make([]byte, 43)
	for i := range b {
		b[i] = abc[rand.IntN(len(abc))]
	}
	return "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyLTQyIn0." + string(b)
}

// ---- shop-api: a Go HTTP API ----

type shopAPI struct{}

var shopRoutes = []string{"/api/products", "/api/products/1187", "/api/cart", "/api/orders", "/api/orders/552/items", "/healthz"}

func (shopAPI) start() {
	jsonLine(map[string]any{"level": "info", "msg": "shop-api listening", "addr": ":8080", "version": "1.14.2"})
}

func (shopAPI) normal() {
	jsonLine(map[string]any{"level": "info", "msg": "request", "method": pick("GET", "GET", "GET", "POST"), "path": pick(shopRoutes...),
		"status": pick(200, 200, 200, 201, 204, 304), "duration_ms": 3 + rand.IntN(80), "ip": ip()})
}

func (shopAPI) incidents() []func() {
	return []func(){
		func() { // a nil map in the coupon code: crashes the handler
			jsonLine(map[string]any{"level": "info", "msg": "applying coupon", "code": pick("BLACKFRIDAY", "WELCOME10", "VIP25")})
			lines(`panic: assignment to entry in nil map

goroutine 4211 [running]:
shop/internal/billing.applyCoupon(0xc0001a6000, {0xc00012e0f0, 0xb})
	/app/internal/billing/coupon.go:88 +0x1d4
shop/internal/http.(*Server).checkout(0xc000110000, {0x9b1f60, 0xc0002c4000}, 0xc0001fe000)
	/app/internal/http/checkout.go:57 +0x2a6
net/http.HandlerFunc.ServeHTTP(0x0?, {0x9b1f60?, 0xc0002c4000?}, 0x0?)
	/usr/local/go/src/net/http/server.go:2220 +0x29`)
		},
		func() { // the orders service is down: a burst of 502s on one route
			for range 24 {
				jsonLine(map[string]any{"level": "error", "msg": "upstream orders failed", "method": "GET", "path": "/api/orders",
					"status": 502, "error": "dial tcp 10.0.3.14:9000: connect: connection refused", "ip": ip()})
				time.Sleep(time.Duration(80+rand.IntN(200)) * time.Millisecond)
			}
		},
		func() { // a debug log that dumps request headers, token and all
			jsonLine(map[string]any{"level": "debug", "msg": "incoming request headers", "caller": "internal/http/middleware.go:41",
				"headers": map[string]string{"authorization": "Bearer " + token(), "user-agent": "shop-ios/5.2"}})
		},
		func() { // a missing product: an error the code logs and goes on
			jsonLine(map[string]any{"level": "error", "msg": "failed to load product", "product_id": 1000 + rand.IntN(9000),
				"error": "sql: no rows in result set", "caller": "internal/catalog/repo.go:112"})
		},
	}
}

// ---- billing-worker: a Python job runner ----

type billingWorker struct{}

func (billingWorker) start() {
	fmt.Printf("%s INFO billing.worker: starting with 4 processes\n", now())
}

func (billingWorker) normal() {
	switch rand.IntN(3) {
	case 0:
		fmt.Printf("%s INFO billing.jobs: invoice INV-%d sent to customer %d\n", now(), 20000+rand.IntN(9000), 1+rand.IntN(5000))
	case 1:
		fmt.Printf("%s INFO billing.jobs: charged order %d (%d.%02d USD)\n", now(), 500+rand.IntN(900), 5+rand.IntN(300), rand.IntN(100))
	default:
		fmt.Printf("%s DEBUG billing.queue: %d jobs waiting\n", now(), rand.IntN(40))
	}
}

func (billingWorker) incidents() []func() {
	return []func(){
		func() { // an order with zero items divides by zero
			fmt.Printf("%s ERROR billing.jobs: job charge_order failed\n", now())
			lines(`Traceback (most recent call last):
  File "/app/billing/jobs.py", line 142, in charge_order
    unit_price = order.total / order.quantity
ZeroDivisionError: division by zero`)
		},
		func() { // a currency nobody configured
			fmt.Printf("%s ERROR billing.jobs: job convert_invoice failed\n", now())
			lines(`Traceback (most recent call last):
  File "/app/billing/fx.py", line 37, in convert
    rate = RATES[invoice.currency]
KeyError: 'UZS'`)
		},
		func() { // the connection string, password included, goes to the log
			fmt.Printf("%s INFO billing.db: connecting to postgres://billing:Sup3rS3cret-2026@db.internal:5432/billing\n", now())
		},
		func() { // the database is unreachable for a moment
			for range 3 {
				fmt.Printf("%s ERROR billing.db: could not connect to server: Connection refused (db.internal:5432)\n", now())
				time.Sleep(300 * time.Millisecond)
			}
		},
	}
}

// ---- auth-gateway: nginx in front of a Node login service ----

type authGateway struct{}

func access(ip, method, path string, status int) {
	fmt.Printf(`%s - - [%s] "%s %s HTTP/1.1" %d %d "-" "%s"`+"\n", ip, time.Now().UTC().Format("02/Jan/2006:15:04:05 -0700"),
		method, path, status, 120+rand.IntN(4000), pick("Mozilla/5.0", "okhttp/4.12", "curl/8.5.0"))
}

func (authGateway) start() {
	// Left on from a debugging session.
	fmt.Println(`WARNING: This is a development server. Do not use it in a production deployment.`)
	fmt.Println(` * Debugger is active!`)
}

func (authGateway) normal() {
	switch rand.IntN(4) {
	case 0:
		access(ip(), "POST", "/auth/login", 200)
	case 1:
		access(ip(), "POST", "/auth/refresh", 200)
	case 2:
		access(ip(), "GET", "/auth/me", pick(200, 200, 304))
	default:
		access(ip(), "GET", "/", 200)
	}
}

func (authGateway) incidents() []func() {
	return []func(){
		func() { // one address trying passwords
			bad := ip()
			for range 26 {
				access(bad, "POST", "/auth/login", 401)
				time.Sleep(time.Duration(200+rand.IntN(600)) * time.Millisecond)
			}
		},
		func() { // a scanner looking for well-known files, and finding one
			bad := ip()
			for _, p := range []string{"/.git/config", "/wp-login.php", "/phpmyadmin/", "/.aws/credentials", "/xmlrpc.php", "/server-status",
				"/actuator/env", "/config.json", "/backup.sql", "/.DS_Store", "/wp-admin/"} {
				access(bad, "GET", p, 404)
				time.Sleep(80 * time.Millisecond)
			}
			access(bad, "GET", "/.env", 200)
		},
		func() { // the Node login service trips on a missing profile
			fmt.Printf("%s ERROR login: request failed\n", now())
			lines(`TypeError: Cannot read properties of undefined (reading 'email')
    at buildSession (/app/src/session.js:44:31)
    at login (/app/src/routes/login.js:18:21)
    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)`)
		},
	}
}
