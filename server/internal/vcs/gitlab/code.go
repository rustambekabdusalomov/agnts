package gitlab

import (
	"context"
	"encoding/base64"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"

	"agnts/internal/domain"
	"agnts/internal/vcs"
)

// Tree lists one directory of the repository (up to 1,000 entries),
// directories first. GitLab gives no file sizes here.
func (h *Host) Tree(ctx context.Context, repo domain.Repository, ref, path string) ([]vcs.TreeEntry, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	out := []vcs.TreeEntry{}
	for page := 1; len(out) < vcs.MaxTreeEntries; page++ {
		var batch []struct {
			Name string `json:"name"`
			Path string `json:"path"`
			Type string `json:"type"`
			Mode string `json:"mode"`
		}
		q := url.Values{"ref": {ref}, "path": {path}, "per_page": {"100"}, "page": {strconv.Itoa(page)}}
		if _, err := h.call(ctx, http.MethodGet, p+"/repository/tree?"+q.Encode(), nil, &batch); err != nil {
			return nil, err
		}
		for _, e := range batch {
			t := vcs.EntryFile
			switch {
			case e.Type == "tree":
				t = vcs.EntryDir
			case e.Type == "commit":
				t = vcs.EntrySubmodule
			case e.Mode == "120000":
				t = vcs.EntrySymlink
			}
			out = append(out, vcs.TreeEntry{Name: e.Name, Path: e.Path, Type: t})
		}
		if len(batch) < 100 {
			break
		}
	}
	out = out[:min(len(out), vcs.MaxTreeEntries)]
	vcs.SortTree(out)
	return out, nil
}

// File reads one file. Its size is asked first, so a large file is not
// downloaded only to be left out.
func (h *Host) File(ctx context.Context, repo domain.Repository, ref, path string) (vcs.File, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return vcs.File{}, err
	}
	c, _, err := h.cfg(ctx)
	if err != nil {
		return vcs.File{}, err
	}
	proj, err := ProjectPath(c.URL, repo.CloneURL)
	if err != nil {
		return vcs.File{}, err
	}
	out := vcs.File{Path: path, URL: strings.TrimRight(c.URL, "/") + "/" + proj + "/-/blob/" + escapeSegments(ref) + "/" + escapeSegments(path)}
	file := p + "/repository/files/" + url.PathEscape(path) + "?" + url.Values{"ref": {ref}}.Encode()
	if size, err := h.size(ctx, file); err == nil && size > vcs.MaxFileBytes {
		out.Size, out.TooLarge = size, true
		return out, nil
	}
	var f struct {
		Size     int64  `json:"size"`
		Encoding string `json:"encoding"`
		Content  string `json:"content"`
	}
	if _, err := h.call(ctx, http.MethodGet, file, nil, &f); err != nil {
		return vcs.File{}, err
	}
	out.Size = f.Size
	b := []byte(f.Content)
	if f.Encoding == "base64" {
		if b, err = base64.StdEncoding.DecodeString(f.Content); err != nil {
			return vcs.File{}, err
		}
	}
	out.SetContent(b)
	return out, nil
}

// size reads a file's size from the headers of a HEAD request.
func (h *Host) size(ctx context.Context, file string) (int64, error) {
	c, ok, err := h.cfg(ctx)
	if err != nil {
		return 0, err
	}
	if !ok || c.Token == "" {
		return 0, fmt.Errorf("gitlab is %w", vcs.ErrNotConnected)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodHead, strings.TrimRight(c.URL, "/")+"/api/v4"+file, nil)
	if err != nil {
		return 0, err
	}
	req.Header.Set("PRIVATE-TOKEN", c.Token)
	resp, err := h.hc.Do(req)
	if err != nil {
		return 0, err
	}
	defer func() { _ = resp.Body.Close() }()
	_, _ = io.Copy(io.Discard, resp.Body)
	if resp.StatusCode >= 300 {
		return 0, fmt.Errorf("gitlab HEAD %s: %s", file, resp.Status)
	}
	return strconv.ParseInt(resp.Header.Get("X-Gitlab-Size"), 10, 64)
}

func escapeSegments(p string) string {
	segs := strings.Split(p, "/")
	for i, s := range segs {
		segs[i] = url.PathEscape(s)
	}
	return strings.Join(segs, "/")
}
