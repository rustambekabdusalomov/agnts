package postgres

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

// Feedback kinds.
const (
	FeedbackKind  = "feedback"  // sent from an account
	ConnectorKind = "connector" // a connector request from the website
)

// Feedback is one message a person sent from their account, or a connector
// request from the website.
type Feedback struct {
	ID          int64
	Kind        string // FeedbackKind or ConnectorKind; empty is FeedbackKind
	UserID      *int64 // nil once the account is deleted
	Sender      string // their name when they sent it
	Email       string
	WorkspaceID *int64 // the workspace they sent it from, if any
	Workspace   string // its name ("" when none or deleted)
	Title       string
	Description string
	Status      string // new or done
	CreatedAt   time.Time
}

// Feedbacks is the feedback store.
type Feedbacks struct{ db *pgxpool.Pool }

// NewFeedbacks returns a feedback store.
func NewFeedbacks(db *pgxpool.Pool) *Feedbacks { return &Feedbacks{db: db} }

const feedbackCols = `f.id, f.kind, f.user_id, f.sender, f.email, f.workspace_id, COALESCE(w.name, ''), f.title, f.description, f.status, f.created_at`

func scanFeedback(row interface{ Scan(...any) error }) (Feedback, error) {
	var f Feedback
	err := row.Scan(&f.ID, &f.Kind, &f.UserID, &f.Sender, &f.Email, &f.WorkspaceID, &f.Workspace, &f.Title, &f.Description, &f.Status, &f.CreatedAt)
	return f, notFound(err)
}

// Create stores a new feedback.
func (s *Feedbacks) Create(ctx context.Context, f Feedback) (Feedback, error) {
	if f.Kind == "" {
		f.Kind = FeedbackKind
	}
	var id int64
	if err := s.db.QueryRow(ctx, `INSERT INTO feedback (kind, user_id, sender, email, workspace_id, title, description)
		VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`, f.Kind, f.UserID, f.Sender, f.Email, f.WorkspaceID, f.Title, f.Description).Scan(&id); err != nil {
		return Feedback{}, err
	}
	return s.byID(ctx, id)
}

func (s *Feedbacks) byID(ctx context.Context, id int64) (Feedback, error) {
	return scanFeedback(s.db.QueryRow(ctx, `SELECT `+feedbackCols+` FROM feedback f LEFT JOIN workspaces w ON w.id = f.workspace_id
		WHERE f.id = $1`, id))
}

// List returns every feedback, newest first.
func (s *Feedbacks) List(ctx context.Context) ([]Feedback, error) {
	rows, err := s.db.Query(ctx, `SELECT `+feedbackCols+` FROM feedback f LEFT JOIN workspaces w ON w.id = f.workspace_id
		ORDER BY f.created_at DESC, f.id DESC LIMIT 1000`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []Feedback{}
	for rows.Next() {
		f, err := scanFeedback(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, f)
	}
	return out, rows.Err()
}

// SetStatus marks a feedback new or done.
func (s *Feedbacks) SetStatus(ctx context.Context, id int64, status string) (Feedback, error) {
	tag, err := s.db.Exec(ctx, `UPDATE feedback SET status = $2, updated_at = now() WHERE id = $1`, id, status)
	if err != nil {
		return Feedback{}, err
	}
	if tag.RowsAffected() == 0 {
		return Feedback{}, domain.ErrNotFound
	}
	return s.byID(ctx, id)
}
