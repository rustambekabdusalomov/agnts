package runner

import (
	"bytes"
	"context"
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"strings"

	"agnts/internal/domain"
)

// Docker is a minimal Docker Engine API client over the Unix socket.
// Paths are unversioned so the daemon answers in its own API version;
// every field used here has been stable since API 1.25.
type Docker struct {
	hc *http.Client
}

// NewDocker connects to the Docker socket at path (usually /var/run/docker.sock).
func NewDocker(socket string) *Docker {
	tr := &http.Transport{
		DialContext: func(ctx context.Context, _, _ string) (net.Conn, error) {
			var d net.Dialer
			return d.DialContext(ctx, "unix", socket)
		},
		DisableCompression: true,
	}
	return &Docker{hc: &http.Client{Transport: tr}}
}

type apiError struct {
	Status  int
	Message string
}

func (e *apiError) Error() string { return fmt.Sprintf("docker: %d %s", e.Status, e.Message) }

func (d *Docker) do(ctx context.Context, method, path string, query url.Values, body io.Reader, contentType string) (*http.Response, error) {
	u := "http://docker" + path
	if len(query) > 0 {
		u += "?" + query.Encode()
	}
	// The host is always the local Docker socket; path parts that come from
	// people (a custom image name) are checked by domain.ValidImage first.
	req, err := http.NewRequestWithContext(ctx, method, u, body) //nolint:gosec // G704: see above
	if err != nil {
		return nil, err
	}
	if contentType != "" {
		req.Header.Set("Content-Type", contentType)
	}
	resp, err := d.hc.Do(req) //nolint:gosec // G704: the Docker socket, see above
	if err != nil {
		return nil, fmt.Errorf("docker %s %s: %w", method, path, err)
	}
	if resp.StatusCode >= 300 {
		defer func() { _ = resp.Body.Close() }()
		var e struct {
			Message string `json:"message"`
		}
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 64*1024))
		if json.Unmarshal(b, &e) != nil || e.Message == "" {
			e.Message = strings.TrimSpace(string(b))
		}
		return nil, &apiError{Status: resp.StatusCode, Message: e.Message}
	}
	return resp, nil
}

func (d *Docker) json(ctx context.Context, method, path string, query url.Values, in, out any) error {
	var body io.Reader
	ct := ""
	if in != nil {
		b, err := json.Marshal(in)
		if err != nil {
			return err
		}
		body, ct = bytes.NewReader(b), "application/json"
	}
	resp, err := d.do(ctx, method, path, query, body, ct)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()
	if out == nil {
		_, _ = io.Copy(io.Discard, resp.Body)
		return nil
	}
	return json.NewDecoder(resp.Body).Decode(out)
}

// Ping checks that the daemon is reachable.
func (d *Docker) Ping(ctx context.Context) error {
	resp, err := d.do(ctx, http.MethodGet, "/_ping", nil, nil, "")
	if err != nil {
		return err
	}
	return resp.Body.Close()
}

// EnsureNetwork creates a bridge network if it does not exist. An internal
// network has no route out; containers on it reach only the egress proxy.
func (d *Docker) EnsureNetwork(ctx context.Context, name string, internal bool) error {
	err := d.json(ctx, http.MethodGet, "/networks/"+url.PathEscape(name), nil, nil, nil)
	var ae *apiError
	if errors.As(err, &ae) && ae.Status == http.StatusNotFound {
		return d.json(ctx, http.MethodPost, "/networks/create", nil, map[string]any{
			"Name": name, "Driver": "bridge", "CheckDuplicate": true, "Internal": internal,
			"Labels": map[string]string{"agnts": "runs"},
		}, nil)
	}
	return err
}

// Info is the Docker host's memory (total, in MB).
func (d *Docker) Info(ctx context.Context) (memTotalMB int64, err error) {
	var out struct {
		MemTotal int64 `json:"MemTotal"`
	}
	if err := d.json(ctx, http.MethodGet, "/info", nil, nil, &out); err != nil {
		return 0, err
	}
	return out.MemTotal / (1 << 20), nil
}

// OOMKilled reports whether the kernel killed a process of the container
// for using more memory than its limit.
func (d *Docker) OOMKilled(ctx context.Context, id string) (bool, error) {
	var out struct {
		State struct {
			OOMKilled bool `json:"OOMKilled"`
		} `json:"State"`
	}
	if err := d.json(ctx, http.MethodGet, "/containers/"+id+"/json", nil, nil, &out); err != nil {
		return false, err
	}
	return out.State.OOMKilled, nil
}

// CreateNetwork creates a bridge network of its own for one run.
func (d *Docker) CreateNetwork(ctx context.Context, name string, internal bool, labels map[string]string) error {
	return d.json(ctx, http.MethodPost, "/networks/create", nil, map[string]any{
		"Name": name, "Driver": "bridge", "CheckDuplicate": true, "Internal": internal, "Labels": labels,
	}, nil)
}

// ConnectNetwork attaches a container to a network under aliases.
func (d *Docker) ConnectNetwork(ctx context.Context, network, container string, aliases []string) error {
	return d.json(ctx, http.MethodPost, "/networks/"+url.PathEscape(network)+"/connect", nil, map[string]any{
		"Container": container, "EndpointConfig": map[string]any{"Aliases": aliases},
	}, nil)
}

// RemoveNetwork disconnects a container from a network (when given) and
// removes the network; one already gone is not an error.
func (d *Docker) RemoveNetwork(ctx context.Context, network, container string) error {
	if container != "" {
		_ = d.json(ctx, http.MethodPost, "/networks/"+url.PathEscape(network)+"/disconnect", nil,
			map[string]any{"Container": container, "Force": true}, nil)
	}
	err := d.json(ctx, http.MethodDelete, "/networks/"+url.PathEscape(network), nil, nil, nil)
	var ae *apiError
	if errors.As(err, &ae) && ae.Status == http.StatusNotFound {
		return nil
	}
	return err
}

// ContainerConfig is the subset of the create request agnts uses.
type ContainerConfig struct {
	Name       string
	Image      string
	User       string
	WorkingDir string
	Cmd        []string
	Labels     map[string]string
	Network    string
	MemoryMB   int64
	CPUs       float64
	PIDs       int64
	Volumes    []string // container paths backed by anonymous volumes
	Mounts     []Mount  // named volumes
	Tmpfs      map[string]string
	Env        []string
	// Runtime is the OCI runtime (runsc for gVisor); "" is Docker's default.
	Runtime string
	// CapAdd are the capabilities given back after dropping all, and
	// Devices the host devices passed through: only the OpenVPN sidecar
	// has any (NET_ADMIN and /dev/net/tun). Run containers never do.
	CapAdd  []string
	Devices []string
	// Sysctls are namespaced kernel settings (the sidecar's rp_filter).
	Sysctls map[string]string
	// Networks are more networks to join after creation (the first is Network).
	Networks []string
}

// Mount is a named volume mounted into a container.
type Mount struct {
	Volume   string
	Target   string
	ReadOnly bool
}

// Create creates (but does not start) a hardened container and returns its id.
func (d *Docker) Create(ctx context.Context, c ContainerConfig) (string, error) {
	mounts := make([]map[string]any, 0, len(c.Volumes))
	for _, p := range c.Volumes {
		mounts = append(mounts, map[string]any{"Type": "volume", "Target": p})
	}
	for _, m := range c.Mounts {
		mounts = append(mounts, map[string]any{"Type": "volume", "Source": m.Volume, "Target": m.Target, "ReadOnly": m.ReadOnly})
	}
	body := map[string]any{
		"Image":      c.Image,
		"User":       c.User,
		"WorkingDir": c.WorkingDir,
		"Cmd":        c.Cmd,
		"Env":        c.Env,
		"Labels":     c.Labels,
		"HostConfig": map[string]any{
			"NetworkMode":    c.Network,
			"Memory":         c.MemoryMB * 1024 * 1024,
			"NanoCpus":       int64(c.CPUs * 1e9),
			"PidsLimit":      c.PIDs,
			"CapDrop":        []string{"ALL"},
			"SecurityOpt":    []string{"no-new-privileges"},
			"ReadonlyRootfs": true,
			"Mounts":         mounts,
			"Tmpfs":          c.Tmpfs,
			"Init":           true,
		},
	}
	hc := body["HostConfig"].(map[string]any)
	if c.Runtime != "" {
		hc["Runtime"] = c.Runtime
	}
	if len(c.CapAdd) > 0 {
		hc["CapAdd"] = c.CapAdd
	}
	if len(c.Sysctls) > 0 {
		hc["Sysctls"] = c.Sysctls
	}
	if len(c.Devices) > 0 {
		devs := make([]map[string]string, 0, len(c.Devices))
		for _, dev := range c.Devices {
			devs = append(devs, map[string]string{"PathOnHost": dev, "PathInContainer": dev, "CgroupPermissions": "rwm"})
		}
		hc["Devices"] = devs
	}
	var out struct {
		ID string `json:"Id"`
	}
	q := url.Values{}
	if c.Name != "" {
		q.Set("name", c.Name)
	}
	if err := d.json(ctx, http.MethodPost, "/containers/create", q, body, &out); err != nil {
		return "", err
	}
	for _, n := range c.Networks {
		if err := d.ConnectNetwork(ctx, n, out.ID, nil); err != nil {
			_ = d.Remove(context.WithoutCancel(ctx), out.ID)
			return "", fmt.Errorf("join network %s: %w", n, err)
		}
	}
	return out.ID, nil
}

// ContainerIP returns a container's address on network.
func (d *Docker) ContainerIP(ctx context.Context, id, network string) (string, error) {
	var out struct {
		NetworkSettings struct {
			Networks map[string]struct {
				IPAddress string `json:"IPAddress"`
			} `json:"Networks"`
		} `json:"NetworkSettings"`
	}
	if err := d.json(ctx, http.MethodGet, "/containers/"+id+"/json", nil, nil, &out); err != nil {
		return "", err
	}
	if n, ok := out.NetworkSettings.Networks[network]; ok && n.IPAddress != "" {
		return n.IPAddress, nil
	}
	return "", fmt.Errorf("the container has no address on %s", network)
}

// Container is a container in a list.
type Container struct {
	ID     string
	Name   string
	State  string // created, running, exited...
	Labels map[string]string
}

// Containers lists the containers (running or not) carrying label (k=v or k).
func (d *Docker) Containers(ctx context.Context, label string) ([]Container, error) {
	filters, _ := json.Marshal(map[string][]string{"label": {label}})
	var out []struct {
		ID     string            `json:"Id"`
		Names  []string          `json:"Names"`
		State  string            `json:"State"`
		Labels map[string]string `json:"Labels"`
	}
	if err := d.json(ctx, http.MethodGet, "/containers/json", url.Values{"all": {"1"}, "filters": {string(filters)}}, nil, &out); err != nil {
		return nil, err
	}
	res := make([]Container, 0, len(out))
	for _, c := range out {
		name := ""
		if len(c.Names) > 0 {
			name = strings.TrimPrefix(c.Names[0], "/")
		}
		res = append(res, Container{ID: c.ID, Name: name, State: c.State, Labels: c.Labels})
	}
	return res, nil
}

// Start starts a created container.
func (d *Docker) Start(ctx context.Context, id string) error {
	return d.json(ctx, http.MethodPost, "/containers/"+id+"/start", nil, nil, nil)
}

// Remove force-removes a container and its anonymous volumes.
func (d *Docker) Remove(ctx context.Context, id string) error {
	err := d.json(ctx, http.MethodDelete, "/containers/"+id, url.Values{"force": {"1"}, "v": {"1"}}, nil, nil)
	var ae *apiError
	if errors.As(err, &ae) && ae.Status == http.StatusNotFound {
		return nil
	}
	return err
}

// PutArchive extracts a tar into dir inside the container.
func (d *Docker) PutArchive(ctx context.Context, id, dir string, tar io.Reader) error {
	resp, err := d.do(ctx, http.MethodPut, "/containers/"+id+"/archive", url.Values{"path": {dir}}, tar, "application/x-tar")
	if err != nil {
		return err
	}
	return resp.Body.Close()
}

// GetArchive returns a tar of path inside the container. A missing path
// returns domain.ErrNotFound.
func (d *Docker) GetArchive(ctx context.Context, id, path string) (io.ReadCloser, error) {
	resp, err := d.do(ctx, http.MethodGet, "/containers/"+id+"/archive", url.Values{"path": {path}}, nil, "")
	var ae *apiError
	if errors.As(err, &ae) && ae.Status == http.StatusNotFound {
		return nil, domain.ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	return resp.Body, nil
}

// ExecConfig describes a command run inside a container.
type ExecConfig struct {
	Cmd        []string
	Env        []string
	User       string
	WorkingDir string
}

// Exec runs a command, streaming its stdout and stderr, and returns its exit code.
func (d *Docker) Exec(ctx context.Context, id string, c ExecConfig, stdout, stderr io.Writer) (int, error) {
	var created struct {
		ID string `json:"Id"`
	}
	if err := d.json(ctx, http.MethodPost, "/containers/"+id+"/exec", nil, map[string]any{
		"Cmd": c.Cmd, "Env": c.Env, "User": c.User, "WorkingDir": c.WorkingDir,
		"AttachStdout": true, "AttachStderr": true, "Tty": false,
	}, &created); err != nil {
		return -1, err
	}
	b, _ := json.Marshal(map[string]any{"Detach": false, "Tty": false})
	resp, err := d.do(ctx, http.MethodPost, "/exec/"+created.ID+"/start", nil, bytes.NewReader(b), "application/json")
	if err != nil {
		return -1, err
	}
	err = demux(resp.Body, stdout, stderr)
	_ = resp.Body.Close()
	if err != nil && ctx.Err() == nil {
		return -1, err
	}
	if ctx.Err() != nil {
		return -1, ctx.Err()
	}
	var info struct {
		ExitCode int  `json:"ExitCode"`
		Running  bool `json:"Running"`
	}
	if err := d.json(ctx, http.MethodGet, "/exec/"+created.ID+"/json", nil, nil, &info); err != nil {
		return -1, err
	}
	return info.ExitCode, nil
}

// demux splits Docker's multiplexed stream: 8-byte header (stream id,
// 3 zero bytes, big-endian length) followed by the payload.
func demux(r io.Reader, stdout, stderr io.Writer) error {
	var hdr [8]byte
	for {
		if _, err := io.ReadFull(r, hdr[:]); err != nil {
			if errors.Is(err, io.EOF) {
				return nil
			}
			return err
		}
		n := int64(binary.BigEndian.Uint32(hdr[4:]))
		w := stdout
		if hdr[0] == 2 {
			w = stderr
		}
		if w == nil {
			w = io.Discard
		}
		if _, err := io.CopyN(w, r, n); err != nil {
			return err
		}
	}
}

// EnsureVolume creates a named volume with labels if it does not exist.
func (d *Docker) EnsureVolume(ctx context.Context, name string, labels map[string]string) error {
	err := d.json(ctx, http.MethodGet, "/volumes/"+url.PathEscape(name), nil, nil, nil)
	var ae *apiError
	if errors.As(err, &ae) && ae.Status == http.StatusNotFound {
		return d.json(ctx, http.MethodPost, "/volumes/create", nil, map[string]any{"Name": name, "Labels": labels}, nil)
	}
	return err
}

// VolumeUsage is a volume's size as the daemon last measured it.
type VolumeUsage struct {
	Name     string
	Labels   map[string]string
	Size     int64 // bytes; -1 when unknown
	RefCount int64 // containers using it; -1 when unknown
}

// Volumes lists volumes with their sizes (GET /system/df; slow on large
// hosts, so callers run it rarely).
func (d *Docker) Volumes(ctx context.Context) ([]VolumeUsage, error) {
	var out struct {
		Volumes []struct {
			Name      string            `json:"Name"`
			Labels    map[string]string `json:"Labels"`
			UsageData *struct {
				Size     int64 `json:"Size"`
				RefCount int64 `json:"RefCount"`
			} `json:"UsageData"`
		} `json:"Volumes"`
	}
	if err := d.json(ctx, http.MethodGet, "/system/df", url.Values{"type": {"volume"}}, nil, &out); err != nil {
		return nil, err
	}
	list := make([]VolumeUsage, 0, len(out.Volumes))
	for _, v := range out.Volumes {
		u := VolumeUsage{Name: v.Name, Labels: v.Labels, Size: -1, RefCount: -1}
		if v.UsageData != nil {
			u.Size, u.RefCount = v.UsageData.Size, v.UsageData.RefCount
		}
		list = append(list, u)
	}
	return list, nil
}

// RemoveVolume deletes a named volume; one still in use is an error.
func (d *Docker) RemoveVolume(ctx context.Context, name string) error {
	err := d.json(ctx, http.MethodDelete, "/volumes/"+url.PathEscape(name), nil, nil, nil)
	var ae *apiError
	if errors.As(err, &ae) && ae.Status == http.StatusNotFound {
		return nil
	}
	return err
}

// ImageLabels returns the labels of a local image, or domain.ErrNotFound.
func (d *Docker) ImageLabels(ctx context.Context, image string) (map[string]string, error) {
	var out struct {
		Config struct {
			Labels map[string]string `json:"Labels"`
		} `json:"Config"`
	}
	err := d.json(ctx, http.MethodGet, "/images/"+image+"/json", nil, nil, &out)
	var ae *apiError
	if errors.As(err, &ae) && ae.Status == http.StatusNotFound {
		return nil, domain.ErrNotFound
	}
	return out.Config.Labels, err
}
