// Command agnts-guard is the Claude Code hook agnts installs in every run
// container: agnts-guard pre|post|stop|session reads the hook input on
// stdin. See package guard.
//
// The same binary is agnts-api, the Swagger test client (package
// apiclient), when run through a link of that name or as `agnts-guard api`.
package main

import (
	"fmt"
	"os"
	"path/filepath"

	"agnts/internal/apiclient"
	"agnts/internal/guard"
)

func main() {
	if filepath.Base(os.Args[0]) == "agnts-api" {
		os.Exit(apiclient.Main(os.Args[1:], os.Stdout, os.Stderr))
	}
	if len(os.Args) >= 2 && os.Args[1] == "api" {
		os.Exit(apiclient.Main(os.Args[2:], os.Stdout, os.Stderr))
	}
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: agnts-guard pre|post|stop|session")
		os.Exit(0) // never get in Claude's way over a wiring mistake
	}
	os.Exit(guard.Main(os.Args[1], os.Stdin, os.Stdout, os.Stderr))
}
