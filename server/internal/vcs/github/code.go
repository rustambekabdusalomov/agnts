package github

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"net/http"
	"net/url"
	"strings"

	"agnts/internal/domain"
	"agnts/internal/vcs"
)

// contentsPath is the contents API address of a path at a ref.
func (h *Host) contentsPath(repo domain.Repository, ref, path string) (string, error) {
	base, err := h.base(repo)
	if err != nil {
		return "", err
	}
	segs := strings.Split(path, "/")
	for i, s := range segs {
		segs[i] = url.PathEscape(s)
	}
	p := base + "/contents"
	if path != "" {
		p += "/" + strings.Join(segs, "/")
	}
	if ref != "" {
		p += "?" + url.Values{"ref": {ref}}.Encode()
	}
	return p, nil
}

// Tree lists one directory through the contents API (up to 1,000 entries),
// directories first.
func (h *Host) Tree(ctx context.Context, repo domain.Repository, ref, path string) ([]vcs.TreeEntry, error) {
	p, err := h.contentsPath(repo, ref, path)
	if err != nil {
		return nil, err
	}
	var raw json.RawMessage
	if _, err := h.call(ctx, http.MethodGet, p, nil, &raw); err != nil {
		return nil, err
	}
	if !strings.HasPrefix(strings.TrimSpace(string(raw)), "[") {
		return nil, errors.New(path + " is not a directory")
	}
	var list []struct {
		Name        string  `json:"name"`
		Path        string  `json:"path"`
		Type        string  `json:"type"`
		Size        int64   `json:"size"`
		DownloadURL *string `json:"download_url"`
	}
	if err := json.Unmarshal(raw, &list); err != nil {
		return nil, err
	}
	out := make([]vcs.TreeEntry, 0, len(list))
	for _, e := range list[:min(len(list), vcs.MaxTreeEntries)] {
		t := vcs.EntryFile
		switch e.Type {
		case "dir":
			t = vcs.EntryDir
		case "symlink":
			t = vcs.EntrySymlink
		case "submodule":
			t = vcs.EntrySubmodule
		case "file":
			// Listings call submodules files, without a download address.
			if e.DownloadURL == nil {
				t = vcs.EntrySubmodule
			}
		}
		en := vcs.TreeEntry{Name: e.Name, Path: e.Path, Type: t}
		if t == vcs.EntryFile {
			en.Size = e.Size
		}
		out = append(out, en)
	}
	vcs.SortTree(out)
	return out, nil
}

// File reads one file through the contents API, which inlines files up to
// 1 MB; larger ones come back without content and are marked too large.
func (h *Host) File(ctx context.Context, repo domain.Repository, ref, path string) (vcs.File, error) {
	p, err := h.contentsPath(repo, ref, path)
	if err != nil {
		return vcs.File{}, err
	}
	var raw json.RawMessage
	if _, err := h.call(ctx, http.MethodGet, p, nil, &raw); err != nil {
		return vcs.File{}, err
	}
	if strings.HasPrefix(strings.TrimSpace(string(raw)), "[") {
		return vcs.File{}, errors.New(path + " is a directory")
	}
	var c struct {
		Type     string `json:"type"`
		Path     string `json:"path"`
		Size     int64  `json:"size"`
		Encoding string `json:"encoding"`
		Content  string `json:"content"`
		Target   string `json:"target"`
		HTMLURL  string `json:"html_url"`
	}
	if err := json.Unmarshal(raw, &c); err != nil {
		return vcs.File{}, err
	}
	out := vcs.File{Path: c.Path, Size: c.Size, URL: c.HTMLURL}
	switch {
	case c.Type == "symlink":
		out.Content = c.Target
	case c.Type != "file":
		return vcs.File{}, errors.New(path + " is not a file")
	case c.Size > vcs.MaxFileBytes || c.Encoding != "base64":
		out.TooLarge = true
	default:
		b, err := base64.StdEncoding.DecodeString(strings.ReplaceAll(c.Content, "\n", ""))
		if err != nil {
			return vcs.File{}, err
		}
		out.SetContent(b)
	}
	return out, nil
}
