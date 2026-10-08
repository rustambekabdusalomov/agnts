// Package domain holds agnts's core types. It imports nothing from adapters.
package domain

import (
	"errors"
	"time"
)

// Common errors returned by stores and use cases.
var (
	ErrNotFound     = errors.New("not found")
	ErrUnauthorized = errors.New("unauthorized")
	ErrConflict     = errors.New("conflict")
)

// User is a person who can sign in. Users own workspaces and are members
// of others.
type User struct {
	ID            int64
	Username      string
	Email         string
	DisplayName   string
	PasswordHash  string
	TOTPSecretEnc []byte // nil until two-factor sign-in is turned on
	// EmailVerifiedAt is when the address was confirmed by a link.
	EmailVerifiedAt *time.Time
	// IsAdmin marks the platform operator (system role Admin); everyone
	// else is a User.
	IsAdmin         bool
	LastWorkspaceID *int64
	CreatedAt       time.Time
}

// HasTOTP reports whether the user signs in with a second factor.
func (u User) HasTOTP() bool { return len(u.TOTPSecretEnc) > 0 }

// HasPassword reports whether the user can sign in with a password; an
// account created with Google sign-in has none until they set one.
func (u User) HasPassword() bool { return u.PasswordHash != "" }

// Client identifies which app a session belongs to.
type Client string

// Session clients.
const (
	ClientWeb    Client = "web"
	ClientMobile Client = "mobile"
)

// Session is a signed-in client. Only the token hash is stored.
type Session struct {
	TokenHash []byte
	UserID    int64
	Client    Client
	UserAgent string
	IP        string
	CreatedAt time.Time
	ExpiresAt time.Time
}

// TicketState is a ticket's place in the pipeline.
type TicketState string

// Ticket states. The orchestrator (phase 1) owns transitions between them.
const (
	StateNew               TicketState = "new"
	StateAnalyzing         TicketState = "analyzing"
	StateWaitingForAnswers TicketState = "waiting_for_answers"
	StateCoding            TicketState = "coding"
	StateTesting           TicketState = "testing"
	StateWaitingForReview  TicketState = "waiting_for_review"
	StatePushing           TicketState = "pushing"
	StateDone              TicketState = "done"
	StateRejected          TicketState = "rejected"
	StateFailed            TicketState = "failed"
	StateRateLimited       TicketState = "rate_limited"
)
