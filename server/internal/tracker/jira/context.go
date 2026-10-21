package jira

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Limits on what TicketContext reads.
const (
	maxComments     = 30
	maxCommentRunes = 4000
	maxParentRunes  = 3000
	maxImages       = 6
	maxImageBytes   = 5 << 20
)

// briefIssue is a linked issue, parent or subtask as Jira embeds it.
type briefIssue struct {
	Key    string `json:"key"`
	Fields struct {
		Summary string `json:"summary"`
		Status  *struct {
			Name string `json:"name"`
		} `json:"status"`
	} `json:"fields"`
}

func (b briefIssue) brief(relation string) domain.IssueBrief {
	out := domain.IssueBrief{Key: b.Key, Title: b.Fields.Summary, Relation: relation}
	if b.Fields.Status != nil {
		out.Status = b.Fields.Status.Name
	}
	return out
}

// TicketContext reads the issue's parent, links, subtasks, comments (not
// agnts's own) and image attachments.
func (c *Client) TicketContext(ctx context.Context, key string) (domain.TicketContext, error) {
	var is struct {
		Fields struct {
			Description json.RawMessage `json:"description"`
			Parent      *briefIssue     `json:"parent"`
			IssueLinks  []struct {
				Type struct {
					Inward  string `json:"inward"`
					Outward string `json:"outward"`
				} `json:"type"`
				InwardIssue  *briefIssue `json:"inwardIssue"`
				OutwardIssue *briefIssue `json:"outwardIssue"`
			} `json:"issuelinks"`
			Subtasks []briefIssue `json:"subtasks"`
			Comment  struct {
				Comments []struct {
					Author *struct {
						AccountID   string `json:"accountId"`
						DisplayName string `json:"displayName"`
					} `json:"author"`
					Body    json.RawMessage `json:"body"`
					Created string          `json:"created"`
				} `json:"comments"`
			} `json:"comment"`
			Attachment []struct {
				Filename string `json:"filename"`
				MimeType string `json:"mimeType"`
				Size     int64  `json:"size"`
				Content  string `json:"content"`
			} `json:"attachment"`
		} `json:"fields"`
	}
	var out domain.TicketContext
	path := "/rest/api/3/issue/" + url.PathEscape(key) + "?fields=description,parent,issuelinks,subtasks,comment,attachment"
	if err := c.call(ctx, http.MethodGet, path, nil, &is); err != nil {
		return out, err
	}
	f := is.Fields
	if f.Parent != nil {
		p := f.Parent.brief("parent")
		var pd struct {
			Fields struct {
				Description json.RawMessage `json:"description"`
			} `json:"fields"`
		}
		if c.call(ctx, http.MethodGet, "/rest/api/3/issue/"+url.PathEscape(p.Key)+"?fields=description", nil, &pd) == nil {
			p.Description = clipRunes(descriptionText(pd.Fields.Description), maxParentRunes)
		}
		out.Parent = &p
	}
	for _, l := range f.IssueLinks {
		switch {
		case l.InwardIssue != nil:
			out.Links = append(out.Links, l.InwardIssue.brief(l.Type.Inward))
		case l.OutwardIssue != nil:
			out.Links = append(out.Links, l.OutwardIssue.brief(l.Type.Outward))
		}
	}
	for _, s := range f.Subtasks {
		out.Subtasks = append(out.Subtasks, s.brief("subtask"))
	}
	out.Refs = adfRefs(f.Description)
	me := c.accountID(ctx)
	cs := f.Comment.Comments
	if len(cs) > maxComments {
		cs = cs[len(cs)-maxComments:]
	}
	for _, cm := range cs {
		if cm.Author != nil && me != "" && cm.Author.AccountID == me {
			continue // agnts's own comments
		}
		body := clipRunes(descriptionText(cm.Body), maxCommentRunes)
		if body == "" {
			continue
		}
		x := domain.IssueComment{Body: body}
		if cm.Author != nil {
			x.Author = cm.Author.DisplayName
		}
		x.At, _ = time.Parse("2006-01-02T15:04:05.000-0700", cm.Created)
		out.Comments = append(out.Comments, x)
	}
	for _, a := range f.Attachment {
		if len(out.Images) == maxImages {
			break
		}
		if !strings.HasPrefix(a.MimeType, "image/") || a.Size <= 0 || a.Size > maxImageBytes || a.Content == "" {
			continue
		}
		data, err := c.download(ctx, a.Content)
		if err != nil {
			continue
		}
		out.Images = append(out.Images, domain.IssueImage{Name: a.Filename, MIME: a.MimeType, Data: data})
	}
	return out, nil
}

// accountID is the connected account's id, "" when it cannot be read.
func (c *Client) accountID(ctx context.Context) string {
	var me struct {
		AccountID string `json:"accountId"`
	}
	if c.call(ctx, http.MethodGet, "/rest/api/3/myself", nil, &me) != nil {
		return ""
	}
	return me.AccountID
}

// download reads an attachment's content (at most maxImageBytes) from a
// URL on the Jira site.
func (c *Client) download(ctx context.Context, raw string) ([]byte, error) {
	cfg, ok, err := c.cfg(ctx)
	if err != nil || !ok {
		return nil, ErrNotConnected
	}
	u, err := url.Parse(raw)
	site, serr := url.Parse(cfg.Site)
	if err != nil || serr != nil || u.Host != site.Host || u.Scheme != site.Scheme {
		return nil, fmt.Errorf("attachment %q is not on the Jira site", raw)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u.String(), nil)
	if err != nil {
		return nil, err
	}
	req.SetBasicAuth(cfg.Email, cfg.APIToken)
	resp, err := c.hc.Do(req)
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode >= 300 {
		return nil, fmt.Errorf("download attachment: %s", resp.Status)
	}
	b, err := io.ReadAll(io.LimitReader(resp.Body, maxImageBytes+1))
	if err != nil || len(b) > maxImageBytes {
		return nil, fmt.Errorf("attachment too large")
	}
	return b, nil
}

// adfRefs lists the links and images in an ADF document, which the plain
// text of the description leaves out.
func adfRefs(raw json.RawMessage) []string {
	var root refNode
	if json.Unmarshal(raw, &root) != nil {
		return nil
	}
	var out []string
	seen := map[string]bool{}
	add := func(s string) {
		if s = strings.TrimSpace(s); s != "" && !seen[s] && len(out) < 40 {
			seen[s] = true
			out = append(out, s)
		}
	}
	var walk func(n refNode)
	walk = func(n refNode) {
		switch n.Type {
		case "inlineCard", "blockCard", "embedCard":
			add(n.Attrs.URL)
		case "media", "mediaInline":
			if n.Attrs.Alt != "" {
				add("image " + n.Attrs.Alt + " (attached to the issue)")
			}
		case "text":
			for _, m := range n.Marks {
				if m.Type == "link" && m.Attrs.Href != "" {
					add(strings.TrimSpace(n.Text) + ": " + m.Attrs.Href)
				}
			}
		}
		for _, ch := range n.Content {
			walk(ch)
		}
	}
	walk(root)
	return out
}

type refNode struct {
	Type  string `json:"type"`
	Text  string `json:"text"`
	Attrs struct {
		URL string `json:"url"`
		Alt string `json:"alt"`
	} `json:"attrs"`
	Marks []struct {
		Type  string `json:"type"`
		Attrs struct {
			Href string `json:"href"`
		} `json:"attrs"`
	} `json:"marks"`
	Content []refNode `json:"content"`
}

func clipRunes(s string, n int) string {
	if r := []rune(s); len(r) > n {
		return string(r[:n-1]) + "…"
	}
	return s
}
