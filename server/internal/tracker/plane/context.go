package plane

import (
	"context"
	"encoding/json"
	"net/http"
	"net/url"
	"time"

	"agnts/internal/domain"
)

// maxComments caps the comments TicketContext reads, newest kept.
const maxComments = 30

// TicketContext reads the work item's comments, without agnts's own.
// Images in Plane need the asset service's own auth, so none are read.
func (c *Client) TicketContext(ctx context.Context, key string) (domain.TicketContext, error) {
	var out domain.TicketContext
	cfg, err := c.config(ctx)
	if err != nil {
		return out, err
	}
	r, err := c.resolve(ctx, cfg, key)
	if err != nil {
		return out, err
	}
	var me struct {
		ID string `json:"id"`
	}
	_ = c.call(ctx, cfg, http.MethodGet, "/users/me/", nil, &me)
	path := ws(cfg) + "/projects/" + url.PathEscape(r.project) + "/work-items/" + url.PathEscape(r.id) + "/comments/"
	var cs []domain.IssueComment
	err = c.list(ctx, cfg, path, nil, func(raw json.RawMessage) error {
		var cm struct {
			CommentHTML string    `json:"comment_html"`
			CreatedBy   string    `json:"created_by"`
			Actor       string    `json:"actor"`
			CreatedAt   time.Time `json:"created_at"`
			ActorDetail *struct {
				DisplayName string `json:"display_name"`
			} `json:"actor_detail"`
		}
		if json.Unmarshal(raw, &cm) != nil {
			return nil
		}
		if me.ID != "" && (cm.CreatedBy == me.ID || cm.Actor == me.ID) {
			return nil // agnts's own
		}
		body := textFromHTML(cm.CommentHTML)
		if body == "" {
			return nil
		}
		x := domain.IssueComment{Body: body, At: cm.CreatedAt}
		if cm.ActorDetail != nil {
			x.Author = cm.ActorDetail.DisplayName
		}
		cs = append(cs, x)
		return nil
	})
	if err != nil {
		return out, err
	}
	if len(cs) > maxComments {
		cs = cs[len(cs)-maxComments:]
	}
	out.Comments = cs
	return out, nil
}
