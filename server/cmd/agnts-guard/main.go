// Command agnts-guard is the Claude Code hook agnts installs in every run
// container: agnts-guard pre|post|stop|session reads the hook input on
// stdin. See package guard.
package main

import (
	"fmt"
	"os"

	"agnts/internal/guard"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: agnts-guard pre|post|stop|session")
		os.Exit(0) // never get in Claude's way over a wiring mistake
	}
	os.Exit(guard.Main(os.Args[1], os.Stdin, os.Stdout, os.Stderr))
}
