package domain

import (
	"path"
	"strings"
	"time"
	"unicode"
	"unicode/utf8"
)

// AttachmentPurpose says what an attachment belongs to.
type AttachmentPurpose string

// Attachment purposes. An upload is pending until the action that uses it
// (creating a task, answering, retrying, requesting changes) links it to
// the ticket.
const (
	AttachPending  AttachmentPurpose = "pending"
	AttachTicket   AttachmentPurpose = "ticket"   // the task's description
	AttachAnswer   AttachmentPurpose = "answer"   // an answer to one question
	AttachRetry    AttachmentPurpose = "retry"    // a retry note
	AttachFeedback AttachmentPurpose = "feedback" // requested changes
)

// Limits on attachments.
const (
	MaxAttachmentBytes = 10 << 20 // one file
	MaxAttachments     = 10       // per task, answer, retry note or feedback
	// AttachmentPendingTTL is how long an upload nobody used is kept.
	AttachmentPendingTTL = 24 * time.Hour
)

// Attachment is a file someone attached. The bytes are stored apart.
type Attachment struct {
	ID          int64
	TicketID    *int64
	QuestionID  *int64 // set for answers
	Purpose     AttachmentPurpose
	Name        string
	ContentType string
	Size        int64
	CreatedAt   time.Time
}

// inlineTypes are the content types a browser may show in place. Anything
// else (SVG and HTML among them, which can carry scripts) is downloaded.
var inlineTypes = map[string]bool{
	"image/png": true, "image/jpeg": true, "image/gif": true, "image/webp": true,
}

// Image reports whether the attachment is a picture clients can show.
func (a Attachment) Image() bool { return inlineTypes[a.ContentType] }

// CleanFileName makes an uploaded file name safe to show and to use as
// the last part of a path: no folders, no control characters, at most 120
// bytes, never empty.
func CleanFileName(name string) string {
	name = strings.ReplaceAll(name, "\\", "/")
	name = path.Base(strings.TrimSpace(name))
	name = strings.Map(func(r rune) rune {
		if unicode.IsControl(r) || r == '/' || r == ':' {
			return -1
		}
		return r
	}, name)
	name = strings.Trim(name, ". ")
	for len(name) > 120 {
		_, size := utf8.DecodeLastRuneInString(name)
		name = name[:len(name)-size]
	}
	if name == "" {
		return "file"
	}
	return name
}

// JoinChoices is the answer to a multiple-choice question: the chosen
// options, one per line.
func JoinChoices(choices []string) string { return strings.Join(choices, "\n") }
