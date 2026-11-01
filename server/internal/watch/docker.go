package watch

import (
	"bufio"
	"context"
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"

	"agnts/internal/domain"
)

// docker is a read-only Docker Engine API client: list, inspect, events
// and logs. It works through a socket proxy that refuses every write.
type docker struct {
	hc   *http.Client
	base string
}

func newDocker(addr string) (*docker, error) {
	switch {
	case strings.HasPrefix(addr, "unix://"):
		path := strings.TrimPrefix(addr, "unix://")
		tr := &http.Transport{DialContext: func(ctx context.Context, _, _ string) (net.Conn, error) {
			var d net.Dialer
			return d.DialContext(ctx, "unix", path)
		}}
		return &docker{hc: &http.Client{Transport: tr}, base: "http://docker"}, nil
	case strings.HasPrefix(addr, "tcp://"):
		return &docker{hc: &http.Client{}, base: "http://" + strings.TrimPrefix(addr, "tcp://")}, nil
	case strings.HasPrefix(addr, "http://"):
		return &docker{hc: &http.Client{}, base: strings.TrimRight(addr, "/")}, nil
	}
	return nil, fmt.Errorf("docker address %q: use unix:///var/run/docker.sock or tcp://host:2375", addr)
}

func (d *docker) get(ctx context.Context, path string, q url.Values) (*http.Response, error) {
	u := d.base + path
	if len(q) > 0 {
		u += "?" + q.Encode()
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		return nil, err
	}
	resp, err := d.hc.Do(req)
	if err != nil {
		return nil, err
	}
	if resp.StatusCode/100 != 2 {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
		_ = resp.Body.Close()
		return nil, fmt.Errorf("docker GET %s: %d %s", path, resp.StatusCode, strings.TrimSpace(string(b)))
	}
	return resp, nil
}

func (d *docker) json(ctx context.Context, path string, q url.Values, out any) error {
	resp, err := d.get(ctx, path, q)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()
	return json.NewDecoder(resp.Body).Decode(out)
}

func (d *docker) ping(ctx context.Context) error {
	resp, err := d.get(ctx, "/_ping", nil)
	if err != nil {
		return err
	}
	return resp.Body.Close()
}

type container struct {
	ID     string            `json:"Id"`
	Names  []string          `json:"Names"`
	Labels map[string]string `json:"Labels"`
	State  string            `json:"State"`
}

type inspect struct {
	Name   string `json:"Name"`
	Config struct {
		Tty    bool              `json:"Tty"`
		Labels map[string]string `json:"Labels"`
	} `json:"Config"`
	State struct {
		ExitCode  int  `json:"ExitCode"`
		OOMKilled bool `json:"OOMKilled"`
	} `json:"State"`
	RestartCount int `json:"RestartCount"`
}

// serviceOf names a container's service: agnts.service, the compose
// service, or the container's name.
func serviceOf(name string, labels map[string]string) string {
	for _, k := range []string{"agnts.service", "com.docker.compose.service"} {
		if v := labels[k]; v != "" {
			return v
		}
	}
	return strings.TrimPrefix(name, "/")
}

func revisionOf(labels map[string]string) string { return labels["org.opencontainers.image.revision"] }

// watchDocker follows the labelled containers' logs and their events.
func (a *Agent) watchDocker(ctx context.Context, d *docker) {
	var mu sync.Mutex
	following := map[string]context.CancelFunc{}
	follow := func(id string, since time.Time) {
		mu.Lock()
		defer mu.Unlock()
		if _, ok := following[id]; ok {
			return
		}
		fctx, stop := context.WithCancel(ctx)
		following[id] = stop
		go func() {
			defer func() {
				mu.Lock()
				delete(following, id)
				mu.Unlock()
			}()
			a.followLogs(fctx, d, id, since)
		}()
	}
	var list []container
	q := url.Values{"filters": {fmt.Sprintf(`{"label":[%q]}`, a.cfg.Label)}}
	if err := d.json(ctx, "/containers/json", q, &list); err != nil {
		a.log.Error("list containers", "err", err)
	}
	now := a.now()
	for _, c := range list {
		if c.Labels[a.cfg.Label] != "crash" {
			follow(c.ID, now)
		}
	}
	a.log.Info("watching containers", "count", len(list), "label", a.cfg.Label)
	a.watchEvents(ctx, d, func(id string, at time.Time) { follow(id, at) })
}

// watchEvents reads the event stream for good, reconnecting from the last
// event seen. start (re)starts a container's log following.
func (a *Agent) watchEvents(ctx context.Context, d *docker, start func(id string, at time.Time)) {
	since := a.now()
	stopped := map[string]time.Time{} // a stop or kill before a die: a deploy, not a crash
	backoff := time.Second
	for ctx.Err() == nil {
		filters := fmt.Sprintf(`{"type":["container"],"label":[%q],"event":["start","die","oom","kill","stop","health_status"]}`, a.cfg.Label)
		resp, err := d.get(ctx, "/events", url.Values{"since": {strconv.FormatInt(since.Unix(), 10)}, "filters": {filters}})
		if err != nil {
			a.log.Warn("docker events", "err", err)
			select {
			case <-ctx.Done():
				return
			case <-time.After(backoff):
			}
			backoff = min(backoff*2, time.Minute)
			continue
		}
		backoff = time.Second
		dec := json.NewDecoder(resp.Body)
		for {
			var ev struct {
				Status string `json:"status"`
				Action string `json:"Action"`
				ID     string `json:"id"`
				Actor  struct {
					ID         string            `json:"ID"`
					Attributes map[string]string `json:"Attributes"`
				} `json:"Actor"`
				TimeNano int64 `json:"timeNano"`
			}
			if err := dec.Decode(&ev); err != nil {
				break
			}
			at := time.Unix(0, ev.TimeNano)
			since = at
			id := ev.Actor.ID
			attrs := ev.Actor.Attributes
			svc := serviceOf(attrs["name"], attrs)
			e := domain.LogEntry{Time: at, Service: svc, Stream: shortID(id), Revision: revisionOf(attrs), Level: "fatal"}
			action := ev.Action
			switch {
			case action == "start":
				if attrs[a.cfg.Label] != "crash" {
					start(id, at)
				}
			case action == "kill" || action == "stop":
				stopped[id] = at
			case action == "die":
				code, _ := strconv.Atoi(attrs["exitCode"])
				if t, ok := stopped[id]; ok && at.Sub(t) < 30*time.Second {
					delete(stopped, id)
					continue // stopped on purpose: a deploy or docker stop
				}
				if code == 0 {
					continue
				}
				var in inspect
				_ = d.json(ctx, "/containers/"+id+"/json", nil, &in)
				if in.State.OOMKilled || code == 137 {
					e.Message = fmt.Sprintf("container %s was OOM-killed (exit code %d, %d restarts): oom-killed", svc, code, in.RestartCount)
				} else {
					e.Message = fmt.Sprintf("fatal: container %s exited with code %d (%d restarts)", svc, code, in.RestartCount)
				}
				a.emit(e)
			case action == "oom":
				e.Message = fmt.Sprintf("container %s ran out of memory: oom-killed", svc)
				a.emit(e)
			case strings.HasPrefix(action, "health_status") && strings.Contains(action, "unhealthy"):
				e.Level, e.Message = "error", fmt.Sprintf("error: container %s is unhealthy (its health check fails)", svc)
				a.emit(e)
			}
		}
		_ = resp.Body.Close()
	}
}

func shortID(id string) string {
	if len(id) > 12 {
		return id[:12]
	}
	return id
}

// followLogs reads one container's output from since until it stops.
func (a *Agent) followLogs(ctx context.Context, d *docker, id string, since time.Time) {
	var in inspect
	if err := d.json(ctx, "/containers/"+id+"/json", nil, &in); err != nil {
		a.log.Warn("inspect container", "id", shortID(id), "err", err)
		return
	}
	svc := serviceOf(in.Name, in.Config.Labels)
	rev := revisionOf(in.Config.Labels)
	q := url.Values{"follow": {"1"}, "stdout": {"1"}, "stderr": {"1"}, "timestamps": {"1"},
		"since": {strconv.FormatInt(since.Unix(), 10)}}
	resp, err := d.get(ctx, "/containers/"+id+"/logs", q)
	if err != nil {
		a.log.Warn("container logs", "service", svc, "err", err)
		return
	}
	defer func() { _ = resp.Body.Close() }()
	a.log.Info("following", "service", svc, "container", shortID(id))
	line := func(raw string) {
		t, msg := splitTimestamp(raw)
		a.emit(domain.LogEntry{Time: t, Service: svc, Stream: shortID(id), Revision: rev, Message: msg})
	}
	if in.Config.Tty {
		sc := bufio.NewScanner(resp.Body)
		sc.Buffer(make([]byte, 64<<10), 1<<20)
		for sc.Scan() {
			line(sc.Text())
		}
		return
	}
	if err := demux(resp.Body, line); err != nil && ctx.Err() == nil && !errors.Is(err, io.EOF) {
		a.log.Warn("container logs", "service", svc, "err", err)
	}
}

// demux reads Docker's multiplexed log stream (an 8-byte header per
// frame: stream, 0, 0, 0, big-endian size) and calls line per line.
func demux(r io.Reader, line func(string)) error {
	br := bufio.NewReader(r)
	hdr := make([]byte, 8)
	var partial strings.Builder
	for {
		if _, err := io.ReadFull(br, hdr); err != nil {
			if partial.Len() > 0 {
				line(partial.String())
			}
			return err
		}
		n := binary.BigEndian.Uint32(hdr[4:])
		if n > 1<<20 {
			return errors.New("log frame too large")
		}
		buf := make([]byte, n)
		if _, err := io.ReadFull(br, buf); err != nil {
			return err
		}
		chunk := string(buf)
		for {
			i := strings.IndexByte(chunk, '\n')
			if i < 0 {
				partial.WriteString(chunk)
				break
			}
			partial.WriteString(chunk[:i])
			line(strings.TrimRight(partial.String(), "\r"))
			partial.Reset()
			chunk = chunk[i+1:]
		}
	}
}

// splitTimestamp takes the RFC 3339 timestamp Docker puts first.
func splitTimestamp(raw string) (time.Time, string) {
	if i := strings.IndexByte(raw, ' '); i > 0 {
		if t, err := time.Parse(time.RFC3339Nano, raw[:i]); err == nil {
			return t, raw[i+1:]
		}
	}
	return time.Time{}, raw
}
