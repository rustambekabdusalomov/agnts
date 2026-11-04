package perfreview

import (
	"slices"
	"strconv"
	"strings"
	"time"
)

// AgentKey is the author key of agnts's own commits.
const AgentKey = "agent"

// UserKey is a member's author key.
func UserKey(id int64) string { return "user:" + strconv.FormatInt(id, 10) }

// UnmappedKey is the author key of a git identity no member has.
func UnmappedKey(loginOrEmail string) string { return "unmapped:" + strings.ToLower(loginOrEmail) }

// ParseUserKey returns the member of a user key.
func ParseUserKey(key string) (int64, bool) {
	s, ok := strings.CutPrefix(key, "user:")
	if !ok {
		return 0, false
	}
	id, err := strconv.ParseInt(s, 10, 64)
	return id, err == nil
}

// Share is one author's part of a delivery's points.
type Share struct {
	Key   string  `json:"key"`
	Days  int     `json:"days"`
	Share float64 `json:"share"`
}

// Floor is the least share an author gets when 2 to 4 people share a
// delivery.
const (
	Floor           = 0.2
	floorMaxAuthors = 4
)

// Resolve maps a git identity to a member (0: none).
type Resolve func(login, email string) int64

// AuthorKey is the author key of an earner.
func AuthorKey(e Earner, resolve Resolve) string {
	if e.Agent {
		return AgentKey
	}
	if resolve != nil {
		if id := resolve(e.Login, e.Email); id > 0 {
			return UserKey(id)
		}
	}
	switch {
	case e.Login != "":
		return UnmappedKey(e.Login)
	case e.Email != "":
		return UnmappedKey(e.Email)
	case e.Name != "":
		return UnmappedKey(e.Name)
	}
	return UnmappedKey("unknown")
}

// Shares splits a delivery between its earners' authors by the distinct
// days each committed on (in tz), with Floor for 2 to 4 authors. Raw
// commit counts are not used: many tiny commits would game them.
func Shares(earners []Earner, resolve Resolve, tz *time.Location) []Share {
	if tz == nil {
		tz = time.UTC
	}
	days := map[string]map[string]bool{}
	var keys []string
	for _, e := range earners {
		k := AuthorKey(e, resolve)
		if days[k] == nil {
			days[k] = map[string]bool{}
			keys = append(keys, k)
		}
		days[k][e.At.In(tz).Format(time.DateOnly)] = true
	}
	slices.Sort(keys)
	weights := make([]float64, len(keys))
	for i, k := range keys {
		weights[i] = float64(len(days[k]))
	}
	split := splitWithFloor(weights)
	out := make([]Share, len(keys))
	for i, k := range keys {
		out[i] = Share{Key: k, Days: len(days[k]), Share: split[i]}
	}
	return out
}

// splitWithFloor splits 1 in proportion to weights. With 2 to 4 weights,
// every part under Floor gets exactly Floor and the rest is split in
// proportion between the others, until no part is under it: raising and
// normalising again would push the small ones back under.
func splitWithFloor(weights []float64) []float64 {
	n := len(weights)
	out := make([]float64, n)
	if n == 0 {
		return out
	}
	total := 0.0
	for _, w := range weights {
		total += w
	}
	if total <= 0 {
		for i := range out {
			out[i] = 1 / float64(n)
		}
		return out
	}
	for i, w := range weights {
		out[i] = w / total
	}
	if n < 2 || n > floorMaxAuthors {
		return out
	}
	fixed := make([]bool, n)
	for {
		changed := false
		for i := range out {
			if !fixed[i] && out[i] < Floor {
				fixed[i], out[i], changed = true, Floor, true
			}
		}
		if !changed {
			return out
		}
		left, free := 1.0, 0.0
		for i := range out {
			if fixed[i] {
				left -= Floor
			} else {
				free += weights[i]
			}
		}
		for i := range out {
			if !fixed[i] {
				out[i] = left * weights[i] / free
			}
		}
	}
}

// RegressionTake is the part of a ticket's points each confirmed
// regression takes back.
const RegressionTake = 0.3

// AfterPenalties is a delivery's points after a revert took its share
// (revertedShare of the scored lines) and each regression 30% of what
// was left. Decimals: only a score is on the scale.
func AfterPenalties(points int, revertedShare float64, regressions int) float64 {
	p := float64(points) * (1 - min(max(revertedShare, 0), 1))
	for range regressions {
		p *= 1 - RegressionTake
	}
	return round2(p)
}

func round2(x float64) float64 {
	return float64(int64(x*100+0.5)) / 100
}

// Undone says which of shas stay reverted: reverts maps each revert
// commit to the sha it reverts (a prefix may be given). A revert of a
// revert (a re-land) cancels it, and so on down the chain.
func Undone(shas []string, reverts map[string]string) map[string]bool {
	target := func(prefix string) string {
		for _, s := range shas {
			if strings.HasPrefix(s, prefix) {
				return s
			}
		}
		for r := range reverts {
			if strings.HasPrefix(r, prefix) {
				return r
			}
		}
		return ""
	}
	// active reports whether a revert commit is in force: not itself
	// reverted by one in force.
	var active func(r string, depth int) bool
	active = func(r string, depth int) bool {
		if depth > 20 {
			return true
		}
		for other, of := range reverts {
			if target(of) == r && active(other, depth+1) {
				return false
			}
		}
		return true
	}
	out := map[string]bool{}
	for r, of := range reverts {
		t := target(of)
		if t == "" || !active(r, 0) {
			continue
		}
		for _, s := range shas {
			if s == t {
				out[s] = true
			}
		}
	}
	return out
}
