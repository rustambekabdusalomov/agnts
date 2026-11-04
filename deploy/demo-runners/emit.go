package main

import (
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"math/rand/v2"
	"os"
	"strconv"
	"strings"
	"time"
)

// emitter writes one service's lines. stdout and stderr go to the same
// container log, as in the real services (Go prints panics to stderr).
type emitter struct {
	service string
	rng     *rand.Rand
	out     io.Writer
	errOut  io.Writer
	fast    bool // print: no pauses
	json    *slog.Logger
	// has says whether a bug is still on main (always, when printing).
	has func(*bug) bool
}

func newEmitter(service string, rng *rand.Rand) *emitter {
	e := &emitter{service: service, rng: rng, out: os.Stdout, errOut: os.Stderr, has: func(*bug) bool { return true }}
	e.json = newEmitterJSON(e.out)
	return e
}

// newEmitterJSON is the services' logger: slog's JSON handler, in UTC as in
// the containers.
func newEmitterJSON(w io.Writer) *slog.Logger {
	return slog.New(slog.NewJSONHandler(w, &slog.HandlerOptions{Level: slog.LevelDebug,
		ReplaceAttr: func(_ []string, a slog.Attr) slog.Attr {
			if a.Key == slog.TimeKey {
				a.Value = slog.TimeValue(a.Value.Time().UTC())
			}
			return a
		}}))
}

// pause sleeps d, or nothing when printing.
func (e *emitter) pause(d time.Duration) {
	if !e.fast {
		time.Sleep(d)
	}
}

// pauseMs sleeps between lo and hi milliseconds.
func (e *emitter) pauseMs(lo, hi int) {
	e.pause(time.Duration(lo+e.rng.IntN(hi-lo+1)) * time.Millisecond)
}

// lines prints a multi-line text line by line to stderr, as the runtime does.
func (e *emitter) lines(s string) {
	for _, l := range strings.Split(strings.TrimRight(s, "\n"), "\n") {
		fmt.Fprintln(e.errOut, l)
	}
}

func (e *emitter) ip() string { return fmt.Sprintf("203.0.113.%d", 2+e.rng.IntN(250)) }

func (e *emitter) uuid() string {
	b := make([]byte, 16)
	for i := range b {
		b[i] = byte(e.rng.UintN(256))
	}
	b[6] = b[6]&0x0f | 0x40
	b[8] = b[8]&0x3f | 0x80
	h := hex.EncodeToString(b)
	return h[0:8] + "-" + h[8:12] + "-" + h[12:16] + "-" + h[16:20] + "-" + h[20:]
}

func (e *emitter) hex(n int) string {
	b := make([]byte, n/2)
	for i := range b {
		b[i] = byte(e.rng.UintN(256))
	}
	return hex.EncodeToString(b)
}

// shopper is one of cmd/shopper's accounts (shopper-01@shop.test …).
func (e *emitter) shopper() string { return fmt.Sprintf("shopper-%02d@shop.test", 1+e.rng.IntN(50)) }

// accessToken is a JWT like auth-gateway's (EdDSA, kid, issuer shop.agnts.uz).
func (e *emitter) accessToken(email string) string {
	enc := base64.RawURLEncoding
	header, _ := json.Marshal(map[string]string{"alg": "EdDSA", "kid": e.hex(16), "typ": "JWT"})
	iat := time.Now().Unix()
	claims, _ := json.Marshal(map[string]any{"email": email, "name": "Shopper", "iss": "shop.agnts.uz",
		"sub": e.uuid(), "aud": []string{"shop-api"}, "exp": iat + 900, "iat": iat})
	sig := make([]byte, 64)
	for i := range sig {
		sig[i] = byte(e.rng.UintN(256))
	}
	return enc.EncodeToString(header) + "." + enc.EncodeToString(claims) + "." + enc.EncodeToString(sig)
}

// goroutine fills a trace template's {{G}}.
func (e *emitter) goroutine(trace string) string {
	return strings.ReplaceAll(trace, "{{G}}", strconv.Itoa(8+e.rng.IntN(400)))
}
