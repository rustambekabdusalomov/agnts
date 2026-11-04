package main

import (
	"context"
	_ "embed"
	"fmt"
	"log/slog"
)

// The panic shop-api's Recover middleware prints for API-1, recorded from
// the real service (Go's crash format, debug.Stack()).
//
//go:embed traces/api-1.txt
var api1Trace string

var (
	// API-1: applyCoupon writes to a zero skuSet (internal/coupon/coupon.go:77, :107).
	bugAPI1 = &bug{repo: "shop-api", file: "internal/coupon/coupon.go",
		has: []string{"var allowed skuSet", "func (s *skuSet) add(sku string) { s.m[sku] = true }"}}
	// API-2: the search text is concatenated into the SQL (internal/catalog/repo.go:52).
	bugAPI2 = &bug{repo: "shop-api", file: "internal/catalog/repo.go", has: []string{"ILIKE '%` + q + `%'"}}
	// API-3: a missing product is wrapped as a plain error, so it answers 500.
	bugAPI3 = &bug{repo: "shop-api", file: "internal/catalog/repo.go",
		has: []string{`fmt.Errorf("failed to load product: %w", err)`}, lacks: []string{"ErrNoRows"}}
	// API-4: at debug level every request's headers are logged, Authorization included.
	bugAPI4 = &bug{repo: "shop-api", file: "internal/httpx/middleware.go", has: []string{`"headers", r.Header`}}
	// API-6: quantity 0 is accepted (internal/cart/handler.go:70).
	bugAPI6 = &bug{repo: "shop-api", file: "internal/cart/handler.go", has: []string{"in.Quantity < 0 || in.Quantity > MaxQuantity"}}
)

// The probes cmd/shopper sends (internal SQL errors as pgx reports them).
var injectionProbes = []struct{ search, err string }{
	{"' UNION SELECT email FROM auth.users --", "search products: ERROR: each UNION query must have the same number of columns (SQLSTATE 42601)"},
	{"' OR sleep(5) --", "search products: ERROR: function sleep(integer) does not exist (SQLSTATE 42883)"},
}

var shopSearches = []string{"headphones", "cable", "mug", "lamp", "backpack", "tote", "notebook"}

func shopAPI() *service {
	s := &service{name: "shop-api"}
	s.start = func(e *emitter) {
		e.json.Info("goose: no migrations to run. current version: 3")
		e.json.Info("shop-api listening", "addr", ":8081")
	}
	s.normal = func(e *emitter) {
		user, ip := e.uuid(), e.ip()
		switch n := e.rng.IntN(10); {
		case n < 4:
			shopRequest(e, "GET", "/api/products", "GET /api/products", 200, ip, "")
		case n < 6:
			id := 1 + e.rng.IntN(40)
			shopRequest(e, "GET", fmt.Sprintf("/api/products/%d", id), "GET /api/products/{id}", 200, ip, "")
		case n < 7:
			shopRequest(e, "GET", "/api/cart", "GET /api/cart", 200, ip, user)
		case n < 8:
			shopRequest(e, "POST", "/api/cart/items", "POST /api/cart/items", 201, ip, user)
		case n < 9:
			shopRequest(e, "GET", "/api/orders", "GET /api/orders", 200, ip, user)
		default:
			shopRequest(e, "POST", "/api/cart/coupon", "POST /api/cart/coupon", 200, ip, user)
			e.pauseMs(300, 1500)
			shopRequest(e, "POST", "/api/checkout", "POST /api/checkout", 201, ip, user)
		}
	}
	s.incidents = []*incident{
		{id: "api-1", title: "checkout with VIP25 panics: assignment to entry in nil map", bug: bugAPI1, run: func(e *emitter) {
			user, ip := e.uuid(), e.ip()
			shopRequest(e, "POST", "/api/cart/items", "POST /api/cart/items", 201, ip, user)
			e.pauseMs(400, 1500)
			e.lines(e.goroutine(api1Trace))
			shopRequest(e, "POST", "/api/checkout", "POST /api/checkout", 500, ip, user)
		}},
		{id: "api-2", title: "search probe breaks the concatenated SQL (SQL injection)", bug: bugAPI2, run: func(e *emitter) {
			ip := e.ip()
			for i, p := range injectionProbes {
				if i > 0 {
					e.pauseMs(500, 2000)
				}
				e.json.Error("search failed", "err", p.err, "caller", "catalog/handler.go:65", "search", p.search)
				shopRequest(e, "GET", "/api/products", "GET /api/products", 500, ip, "")
			}
		}},
		{id: "api-3", title: "a deleted product answers 500: no rows in result set", bug: bugAPI3, run: func(e *emitter) {
			id := 999999
			e.json.Error("get product failed", "err", "failed to load product: no rows in result set", "caller", "catalog/handler.go:94", "product_id", id)
			shopRequest(e, "GET", fmt.Sprintf("/api/products/%d", id), "GET /api/products/{id}", 500, e.ip(), "")
		}},
		{id: "api-4", title: "debug logging writes the Authorization header (bearer token)", bug: bugAPI4, run: func(e *emitter) {
			email, ip := e.shopper(), e.ip()
			path := fmt.Sprintf("/api/products/%d", 1+e.rng.IntN(40))
			e.json.Debug("request headers", "method", "GET", "path", path, "headers", map[string][]string{
				"Accept-Encoding": {"gzip"}, "Authorization": {"Bearer " + e.accessToken(email)},
				"User-Agent": {"Go-http-client/1.1"}, "X-Forwarded-For": {ip}, "X-Request-Id": {e.hex(32)},
			})
			shopRequest(e, "GET", path, "GET /api/products/{id}", 200, ip, e.uuid())
		}},
		{id: "zero-qty", title: "an item with quantity 0 is accepted and checked out (billing-worker then crashes)", bug: bugAPI6, run: func(e *emitter) {
			user, ip := e.uuid(), e.ip()
			shopRequest(e, "POST", "/api/cart/items", "POST /api/cart/items", 201, ip, user)
			e.pauseMs(400, 1500)
			shopRequest(e, "POST", "/api/checkout", "POST /api/checkout", 201, ip, user)
		}},
	}
	return s
}

// shopRequest is internal/httpx's request line.
func shopRequest(e *emitter, method, path, route string, status int, ip, user string) {
	e.json.LogAttrs(context.Background(), slog.LevelInfo, "request",
		slog.String("method", method), slog.String("path", path), slog.String("route", route),
		slog.Int("status", status), slog.Int64("duration_ms", int64(1+e.rng.IntN(25))),
		slog.String("ip", ip), slog.String("user_id", user))
}
