package runner

import (
	"agnts/internal/ai"
)

// Muse Code runs through its provider (ai/providers/musecode); the runner
// keeps only the sign-in (muselogin.go), which happens before there is an
// account to run on.

// museAuthPath is where Muse Code reads and writes its login: the agent's
// own ~/.config/muse.
const museAuthPath = ai.HomeDir + "/.config/muse/auth.json"
