package github

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/vcs"
)

// graphqlURL is where GitHub serves GraphQL for the REST address:
// api.github.com/graphql, or /api/graphql on Enterprise Server.
func (h *Host) graphqlURL() string {
	if base, ok := strings.CutSuffix(h.api, "/api/v3"); ok {
		return base + "/api/graphql"
	}
	return h.api + "/graphql"
}

// graphql runs query. GitHub answers 200 with partial data and errors when
// some fields fail (a check rollup the token may not read): the data is
// used, and only a query that returns no data fails.
func (h *Host) graphql(ctx context.Context, query string, vars map[string]any, out any) error {
	var res struct {
		Data   json.RawMessage `json:"data"`
		Errors []struct {
			Message string `json:"message"`
		} `json:"errors"`
	}
	if _, err := h.call(ctx, http.MethodPost, h.graphqlURL(), map[string]any{"query": query, "variables": vars}, &res); err != nil {
		return err
	}
	if len(res.Data) == 0 || string(res.Data) == "null" {
		msgs := make([]string, len(res.Errors))
		for i, e := range res.Errors {
			msgs[i] = e.Message
		}
		return fmt.Errorf("github graphql: %s", strings.Join(msgs, "; "))
	}
	return json.Unmarshal(res.Data, out)
}

// branchesQuery reads the default branch and up to 30 others with their
// tip and check rollup. compare runs from each branch (the base) to the
// default branch (the head): its aheadBy is what the branch is behind.
const branchesQuery = `query($owner: String!, $name: String!, $base: String!, $qualified: String!) {
  repository(owner: $owner, name: $name) {
    base: ref(qualifiedName: $qualified) { ...branch }
    refs(refPrefix: "refs/heads/", first: 30, orderBy: {field: ALPHABETICAL, direction: ASC}) {
      nodes { ...branch compare(headRef: $base) { aheadBy behindBy } }
    }
  }
}
fragment branch on Ref {
  name
  target {
    ... on Commit {
      oid
      messageHeadline
      author { name date }
      statusCheckRollup { state }
    }
  }
}`

type gqlBranch struct {
	Name   string `json:"name"`
	Target struct {
		OID      string `json:"oid"`
		Headline string `json:"messageHeadline"`
		Author   struct {
			Name string     `json:"name"`
			Date *time.Time `json:"date"`
		} `json:"author"`
		Rollup *struct {
			State string `json:"state"`
		} `json:"statusCheckRollup"`
	} `json:"target"`
	Compare *struct {
		AheadBy  int `json:"aheadBy"`
		BehindBy int `json:"behindBy"`
	} `json:"compare"`
}

func (h *Host) branchesGraphQL(ctx context.Context, repo domain.Repository) ([]vcs.Branch, error) {
	owner, name, err := OwnerRepo(repo.CloneURL)
	if err != nil {
		return nil, err
	}
	var data struct {
		Repository *struct {
			Base *gqlBranch `json:"base"`
			Refs struct {
				Nodes []gqlBranch `json:"nodes"`
			} `json:"refs"`
		} `json:"repository"`
	}
	vars := map[string]any{"owner": owner, "name": name, "base": repo.DefaultBranch, "qualified": "refs/heads/" + repo.DefaultBranch}
	if err := h.graphql(ctx, branchesQuery, vars, &data); err != nil {
		return nil, err
	}
	if data.Repository == nil {
		return nil, errors.New("github graphql: repository not found")
	}
	var out []vcs.Branch
	if b := data.Repository.Base; b != nil {
		out = append(out, b.branch(true))
	}
	for _, b := range data.Repository.Refs.Nodes {
		if b.Name != repo.DefaultBranch {
			out = append(out, b.branch(false))
		}
	}
	return out, nil
}

func (b gqlBranch) branch(isDefault bool) vcs.Branch {
	out := vcs.Branch{Name: b.Name, Default: isDefault, SHA: b.Target.OID, Message: b.Target.Headline, Author: b.Target.Author.Name, CI: vcs.CINone}
	if b.Target.Author.Date != nil {
		out.Date = *b.Target.Author.Date
	}
	if b.Compare != nil && !isDefault {
		out.Ahead, out.Behind = b.Compare.BehindBy, b.Compare.AheadBy
	}
	if b.Target.Rollup != nil {
		out.CI = rollupStatus(b.Target.Rollup.State)
	}
	return out
}

// rollupStatus maps a commit's combined checks and statuses.
func rollupStatus(state string) string {
	switch state {
	case "SUCCESS":
		return vcs.CIOK
	case "FAILURE", "ERROR":
		return vcs.CIFail
	case "PENDING", "EXPECTED":
		return vcs.CIRun
	}
	return vcs.CINone
}
