package orchestrator

import (
	"fmt"
	"regexp"
	"slices"
	"strings"

	"agnts/internal/domain"
)

// Check failures that come from the run container's setup, not the code:
// a host it may not reach, a private host it cannot log in to. Claude
// cannot fix these, so the run stops at once and tells the person what to
// change instead. Every pattern is what git, go or npm print themselves,
// never what a test might print about its own fixtures.

var (
	// The egress proxy refused the host: git's CONNECT line, Go's HTTP
	// client, or the proxy's own message.
	egressDeniedRe = []*regexp.Regexp{
		regexp.MustCompile(`unable to access '[a-z]+://([^/:']+)[^']*': Received HTTP code 403 from proxy after CONNECT`),
		regexp.MustCompile(`Get "https?://([^/:"]+)[^"]*": Forbidden`),
		regexp.MustCompile(`agnts egress: ([^\s:]+)(?::\d+)? is not on the allowlist`),
	}
	// The proxy took the host but could not connect to it, or there is no
	// such host: the private network is down, or its route is missing.
	unreachableRe = []*regexp.Regexp{
		regexp.MustCompile(`unable to access '[a-z]+://([^/:']+)[^']*': Received HTTP code 502 from proxy after CONNECT`),
		regexp.MustCompile(`unable to access '[a-z]+://([^/:']+)[^']*': (?:Could not resolve host|Failed to connect to)`),
		regexp.MustCompile(`Get "https?://([^/:"]+)[^"]*": Bad Gateway`),
		regexp.MustCompile(`go: [^\n]*dial tcp: lookup ([^\s:]+)[^\n]*no such host`),
	}
	// git reached the host and was asked to log in.
	gitAuthRe = []*regexp.Regexp{
		regexp.MustCompile(`fatal: could not read Username for '[a-z]+://([^/:']+)[^']*'`),
		regexp.MustCompile(`fatal: Authentication failed for '[a-z]+://([^/:']+)[^']*'`),
		regexp.MustCompile(`remote: HTTP Basic: Access denied[\s\S]*?fatal: [^\n]*'[a-z]+://([^/:']+)`),
	}
	// git logged in, but the host hides the project from the token (GitLab
	// and GitHub answer "not found" for a project the token cannot see).
	gitNoAccessRe = regexp.MustCompile(`fatal: repository '[a-z]+://(?:[^@/']+@)?([^/:']+)(?::\d+)?/([^']+?)(?:\.git)?/?' not found`)
	// The modules a go command was fetching: "reading host/path/go.mod at
	// revision", "host/path@v1.2.3: ...".
	goModuleRe = regexp.MustCompile(`(?:reading |go: (?:downloading )?)([a-z0-9.-]+\.[a-z]{2,}/[^\s@]+?)(?:/go\.mod at revision|@v| v\d)`)
	// Go checked a module against the public checksum database.
	goSumDBRe = regexp.MustCompile(`verifying (?:module: )?([a-z0-9.-]+\.[a-z]{2,})/[^\s@]+@\S+: [^\n]*sum\.golang\.org[^\n]*(?:404|410)`)
	// npm, pnpm or yarn were refused by a registry.
	registryAuthRe = []*regexp.Regexp{
		regexp.MustCompile(`npm (?:ERR!|error) 40[13] [^\n]*?https?://([^/\s:]+)`),
		regexp.MustCompile(`ERR_PNPM_FETCH_40[13][^\n]*?https?://([^/\s:]+)`),
		regexp.MustCompile(`Request failed "40[13] [^"]*"[^\n]*?https?://([^/\s:]+)`),
	}
)

// diagnose explains a check failure that the run container's setup
// caused, with the fix spelled out; "" when the output shows none.
func diagnose(repo domain.Repository, output string) (msg, reason string) {
	if host := firstMatch(egressDeniedRe, output); host != "" {
		return fmt.Sprintf("the run container may not reach %s: agnts's egress proxy refused the connection, so this is a setting, not the code.\n\n"+
			"If %s is inside your network, add it to the routes of a private network under Settings → Private networks. "+
			"If it is a public host, add it under Settings → Preview → Allowed hosts. Then retry the ticket.", host, host), "egress_blocked"
	}
	if host := firstMatch(unreachableRe, output); host != "" {
		return fmt.Sprintf("the run container could not connect to %s: the host did not answer, so this is the network, not the code.\n\n"+
			"If %s is on a private network, check under Settings → Private networks that a route covers it and that the network is connected. "+
			"A VPN account that another client uses at the same time can drop agnts's session. Then retry the ticket.", host, host), "host_unreachable"
	}
	if host := firstMatch(gitAuthRe, output); host != "" {
		return gitAuthHelp(repo, host, output), "git_auth"
	}
	if ms := gitNoAccessRe.FindAllStringSubmatch(output, -1); ms != nil {
		return gitNoAccessHelp(repo, ms), "git_no_access"
	}
	if host := firstMatch(registryAuthRe, output); host != "" {
		return fmt.Sprintf("the package registry %s refused the run container: it needs a token, and the build environment gives it none that works.\n\n"+
			"Add a read-only token under Repositories → %s → Advanced → Build environment:\n\n"+
			"NPM_TOKEN=<TOKEN>\n\n"+
			"and make the repository's .npmrc use it:\n\n"+
			"//%s/:_authToken=${NPM_TOKEN}\n\n"+
			"Then retry the ticket.", host, repo.Name, host), "registry_auth"
	}
	if m := goSumDBRe.FindStringSubmatch(output); m != nil {
		host := m[1]
		if slices.Contains(repo.BuildEnvNames, "GOPRIVATE") || slices.Contains(repo.BuildEnvNames, "GONOSUMDB") {
			return fmt.Sprintf("Go looked up a module of %s in the public checksum database (sum.golang.org), which cannot see private modules. "+
				"The build environment sets GOPRIVATE, but it does not cover %s: add it (hosts are comma-separated) under Repositories → %s → Advanced → Build environment, then retry the ticket.",
				host, host, repo.Name), "go_private_module"
		}
		return fmt.Sprintf("Go looked up a module of %s in the public checksum database (sum.golang.org), which cannot see private modules.\n\n"+
			"Add this under Repositories → %s → Advanced → Build environment:\n\n"+
			"GOPRIVATE=%s\n\n"+
			"Then retry the ticket.", host, repo.Name, host), "go_private_module"
	}
	return "", ""
}

// gitAuthHelp explains a git host that asked the run container to log in.
// The host answered, so the network is fine: what is missing is a token,
// since agnts never passes its own into runs.
func gitAuthHelp(repo domain.Repository, host, output string) string {
	mods := goModules(output, host)
	needs := ""
	if len(mods) > 0 {
		needs = " The build fetches " + strings.Join(mods, ", ") + "."
	}
	where := fmt.Sprintf("Repositories → %s → Advanced → Build environment", repo.Name)
	if slices.Contains(repo.BuildEnvNames, "GIT_CONFIG_COUNT") {
		return fmt.Sprintf("%s refused the git credentials of the build environment.%s The token may have expired, lack access to those projects, "+
			"or the insteadOf URL may not match https://%s/. Replace it under %s, then retry the ticket.", host, needs, host, where)
	}
	var b strings.Builder
	fmt.Fprintf(&b, "git could not log in to %s from the run container. The host answered, so the network is fine: the container has no credentials for it, "+
		"because agnts does not pass its own git token into runs.%s\n\n", host, needs)
	fmt.Fprintf(&b, "Add a read-only token (read_repository) that can see those projects under %s:\n\n", where)
	if len(mods) > 0 && !slices.Contains(repo.BuildEnvNames, "GOPRIVATE") {
		fmt.Fprintf(&b, "GOPRIVATE=%s\n", host)
	}
	user := "oauth2"
	if host == "github.com" {
		user = "x-access-token"
	}
	fmt.Fprintf(&b, "GIT_CONFIG_COUNT=1\nGIT_CONFIG_KEY_0=url.https://%s:<TOKEN>@%s/.insteadOf\nGIT_CONFIG_VALUE_0=https://%s/\n\n", user, host, host)
	if user == "oauth2" {
		b.WriteString("For a deploy token, put its username in place of oauth2. ")
	}
	b.WriteString(domain.ToolName(domain.DefaultAccess()) + " can read the build environment while it works, so keep the token read-only. Then retry the ticket.")
	return b.String()
}

// gitNoAccessHelp explains projects a git host hid from the run's token.
func gitNoAccessHelp(repo domain.Repository, ms [][]string) string {
	host := ms[0][1]
	var projects []string
	for _, m := range ms {
		if p := m[1] + "/" + m[2]; !slices.Contains(projects, p) {
			projects = append(projects, p)
		}
	}
	return fmt.Sprintf("%s says %s does not exist: that is what it answers for a project the token cannot see, so the build environment's git token has no access to %s. "+
		"The network and the login are fine.\n\n"+
		"Give the token read access to %s (add its user to the project or group, or use a token of a user who sees every project the build needs), "+
		"or replace it under Repositories → %s → Advanced → Build environment. Then retry the ticket.",
		host, strings.Join(projects, ", "), plural(len(projects), "it", "them"), strings.Join(projects, ", "), repo.Name)
}

// goModules lists, in order, the modules of host a go command was
// fetching.
func goModules(output, host string) []string {
	var mods []string
	for _, m := range goModuleRe.FindAllStringSubmatch(output, -1) {
		if strings.HasPrefix(m[1], host+"/") && !slices.Contains(mods, m[1]) {
			mods = append(mods, m[1])
		}
	}
	return mods
}

func firstMatch(res []*regexp.Regexp, s string) string {
	for _, re := range res {
		if m := re.FindStringSubmatch(s); m != nil {
			return m[1]
		}
	}
	return ""
}
