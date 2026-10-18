package toolchain

import (
	"net/url"
	"regexp"
	"slices"
	"sort"
	"strings"
)

// Dependencies a run container cannot fetch on its own: Go modules on a
// self-hosted git host, packages on a registry that wants a token. agnts
// clones the repository with its own git token but never passes it into
// runs, so these fail the build until the build environment has a token.
// The notes say so before the first ticket rather than after it.

// publicGitHosts serve public modules without a token; private repositories
// there are not told apart, so they get no note.
var publicGitHosts = []string{"github.com", "gitlab.com", "bitbucket.org"}

// goRequireRe matches a required module path in go.mod, inside a require
// block or on a require line.
var goRequireRe = regexp.MustCompile(`(?m)^\s*(?:require\s+)?([a-z0-9.-]+\.[a-z]{2,}/\S+)\s+v\d\S*`)

// npmRegistryRe matches a registry .npmrc points a scope or everything at.
var npmRegistryRe = regexp.MustCompile(`(?m)^\s*(?:@[^:\s]+:)?registry\s*=\s*(https?://[^\s/]+)`)

// HostOf is the host of a clone URL, https or scp-like ssh
// (git@host:group/repo.git); "" when it has none.
func HostOf(cloneURL string) string {
	if u, err := url.Parse(cloneURL); err == nil && u.Host != "" {
		return strings.ToLower(u.Hostname())
	}
	if at := strings.Index(cloneURL, "@"); at >= 0 {
		if colon := strings.Index(cloneURL[at:], ":"); colon > 0 {
			return strings.ToLower(cloneURL[at+1 : at+colon])
		}
	}
	return ""
}

// privateGoModules adds dir's go.mod modules on one of the self-hosted
// git hosts to mods, by host.
func (d *detector) privateGoModules(dir string, mods map[string][]string) {
	for _, m := range goRequireRe.FindAllStringSubmatch(d.t.read(dir, "go.mod"), -1) {
		host, _, _ := strings.Cut(m[1], "/")
		if slices.Contains(d.gitHosts, host) && !slices.Contains(mods[host], m[1]) {
			mods[host] = append(mods[host], m[1])
		}
	}
}

// privateNotes notes the private dependencies of every project.
func (d *detector) privateNotes(dirs []string) {
	mods := map[string][]string{}
	var registries []string
	for _, dir := range dirs {
		d.privateGoModules(dir, mods)
		for _, m := range npmRegistryRe.FindAllStringSubmatch(d.t.read(dir, ".npmrc"), -1) {
			host := strings.ToLower(strings.TrimPrefix(strings.TrimPrefix(m[1], "https://"), "http://"))
			if host != "registry.npmjs.org" && host != "registry.yarnpkg.com" && !slices.Contains(registries, host) {
				registries = append(registries, host)
			}
		}
	}
	hosts := make([]string, 0, len(mods))
	for h := range mods {
		hosts = append(hosts, h)
	}
	sort.Strings(hosts)
	if slices.Contains(d.env, "GOPRIVATE") && slices.Contains(d.env, "GIT_CONFIG_COUNT") {
		hosts = nil // set up already; a wrong token shows in the run's diagnosis
	}
	for _, h := range hosts {
		ms := mods[h]
		if len(ms) > 3 {
			ms = append(ms[:3:3], "…")
		}
		d.note("go.mod requires private modules from " + h + " (" + strings.Join(ms, ", ") + "). Run containers get no git token, so `go build` cannot download them: " +
			"add GOPRIVATE=" + h + " and a read-only token to the build environment (Advanced → Build environment): " +
			"GIT_CONFIG_COUNT=1, GIT_CONFIG_KEY_0=url.https://oauth2:<TOKEN>@" + h + "/.insteadOf, GIT_CONFIG_VALUE_0=https://" + h + "/.")
	}
	if slices.Contains(d.env, "NPM_TOKEN") {
		registries = nil
	}
	for _, r := range registries {
		d.note(".npmrc uses the registry " + r + ": if it needs a token, put it in the build environment (Advanced → Build environment) as NPM_TOKEN " +
			"and refer to it in .npmrc as //" + r + "/:_authToken=${NPM_TOKEN}. Check that run containers may reach " + r + " (Settings → Private networks or Allowed hosts).")
	}
}

// selfHosted keeps the hosts that are not public git hosts.
func selfHosted(hosts []string) []string {
	var out []string
	for _, h := range hosts {
		h = strings.ToLower(strings.TrimSpace(h))
		if h != "" && !slices.Contains(publicGitHosts, h) && !slices.Contains(out, h) {
			out = append(out, h)
		}
	}
	return out
}
