package domain

import (
	"crypto/rand"
	"errors"
	"fmt"
	"math/big"
	"slices"
	"strings"
	"time"
	"unicode"
	"unicode/utf8"
)

// EventDocuments is a stored event: documents moved to another owner.
// Document changes themselves are not stored events: those go only to the people who can
// open the document.
const EventDocuments = "documents_changed"

// DocumentType says who can read a document: people with access only, or
// also anyone with its public link.
type DocumentType string

// Document types.
const (
	DocPrivate DocumentType = "private"
	DocPublic  DocumentType = "public"
)

// Valid reports whether t is a known type.
func (t DocumentType) Valid() bool { return t == DocPrivate || t == DocPublic }

// DocumentKind is what a document is: a page to read, or a slide deck to
// present. It is chosen when the document is made and never changes.
type DocumentKind string

// Document kinds.
const (
	DocKindPage   DocumentKind = "page"
	DocKindSlides DocumentKind = "slides"
)

// Valid reports whether k is a known kind.
func (k DocumentKind) Valid() bool { return k == DocKindPage || k == DocKindSlides }

// AccessLevel is what a person may do with a document, from least to most.
type AccessLevel int

// Access levels. Grants and the workspace default go up to Edit; Owner is
// the document's owner and the workspace's owner.
const (
	AccessNone AccessLevel = iota
	AccessView
	AccessEdit
	AccessOwner
)

// String is the level's name in the API and the database.
func (l AccessLevel) String() string {
	switch l {
	case AccessView:
		return "view"
	case AccessEdit:
		return "edit"
	case AccessOwner:
		return "owner"
	}
	return "none"
}

// ParseAccessLevel reads a level's name; ok is false for an unknown one.
func ParseAccessLevel(s string) (AccessLevel, bool) {
	for _, l := range []AccessLevel{AccessNone, AccessView, AccessEdit, AccessOwner} {
		if l.String() == s {
			return l, true
		}
	}
	return AccessNone, false
}

// Grantable reports whether a grant or the workspace default may be l.
func (l AccessLevel) Grantable() bool { return l == AccessView || l == AccessEdit }

// EffectiveAccess is the one rule for what a person may do with a
// document. role is the person's workspace role ("" when they are not a
// member), grant their own grant on the document (AccessNone without one).
//
//   - Not a member: nothing.
//   - The workspace owner and the document's owner: Owner.
//   - Anyone else: the higher of their grant and the workspace default,
//     capped at View for workspace viewers.
func EffectiveAccess(d Document, userID int64, role WorkspaceRole, grant AccessLevel) AccessLevel {
	if !role.Valid() || userID == 0 {
		return AccessNone
	}
	if role == RoleOwner || d.OwnerID == userID {
		return AccessOwner
	}
	lvl := max(min(grant, AccessEdit), min(d.WorkspaceAccess, AccessEdit))
	if role == RoleViewer {
		lvl = min(lvl, AccessView)
	}
	return lvl
}

// Document is a Markdown page or slide deck of a workspace.
type Document struct {
	ID              int64
	WorkspaceID     int64
	Kind            DocumentKind
	Title           string
	Body            string
	Version         int // the current version; 0 before the first save
	Type            DocumentType
	PublicToken     string // set only while public
	WorkspaceAccess AccessLevel
	OwnerID         int64
	Language        string
	// Source is what the latest generation was made from; nil for a
	// document people wrote.
	Source   *DocumentSource
	DataAsOf *time.Time
	// DerivedFromID is the page a deck was made from, and DerivedFromVersion
	// the version its current AI version read; nil for anything else.
	DerivedFromID      *int64
	DerivedFromVersion *int
	DeletedAt          *time.Time
	CreatedAt          time.Time
	UpdatedAt          time.Time

	// Filled on reads.
	OwnerName   string
	TicketCount int
	// Run is the latest generation; nil when there was none.
	Run *DocumentRun
}

// Generating reports whether a generation is queued or running.
func (d Document) Generating() bool {
	return d.Run != nil && (d.Run.Status == DocRunQueued || d.Run.Status == DocRunWriting)
}

// VersionSource says who made a version.
type VersionSource string

// Version sources.
const (
	VersionHuman   VersionSource = "human"
	VersionAI      VersionSource = "ai"
	VersionRestore VersionSource = "restore"
)

// DocumentVersion is one saved state of a document. Versions never change.
type DocumentVersion struct {
	DocumentID int64
	Version    int
	Title      string
	Body       string
	Source     VersionSource
	Note       string // for AI versions: the template and instruction
	AuthorID   *int64
	AuthorName string // filled on reads
	RunID      *int64
	CreatedAt  time.Time
}

// DocumentGrant is one member's access to a document.
type DocumentGrant struct {
	UserID    int64
	Username  string // filled on reads
	Level     AccessLevel
	GrantedBy *int64
	CreatedAt time.Time
}

// DocumentTicket is a ticket linked to a document.
type DocumentTicket struct {
	DocumentID int64
	TicketID   int64
	Key        string
	Number     string
	Title      string
	State      TicketState
	Kind       TicketKind
	LinkedBy   *int64 // nil when agnts linked it
	CreatedAt  time.Time
}

// DocRunStatus is where a generation stands.
type DocRunStatus string

// Generation statuses.
const (
	DocRunQueued  DocRunStatus = "queued"
	DocRunWriting DocRunStatus = "writing"
	DocRunDone    DocRunStatus = "done"
	DocRunFailed  DocRunStatus = "failed"
)

// DocumentRun is one generation of a document.
type DocumentRun struct {
	ID            int64
	WorkspaceID   int64
	DocumentID    int64
	RequestedBy   *int64
	Status        DocRunStatus
	Source        DocumentSource
	PromptVersion string
	Error         string
	StartedAt     *time.Time
	FinishedAt    *time.Time
	CreatedAt     time.Time
}

// ExportStatus is where a PDF of a version stands.
type ExportStatus string

// Export statuses.
const (
	ExportPending ExportStatus = "pending"
	ExportDone    ExportStatus = "done"
	ExportFailed  ExportStatus = "failed"
)

// DocumentExport is a PDF made from one version.
type DocumentExport struct {
	DocumentID int64
	Version    int
	Status     ExportStatus
	Data       []byte
	Error      string
	UpdatedAt  time.Time
}

// Limits of documents.
const (
	DocMaxTitle       = 200       // runes
	DocMaxBody        = 200 << 10 // bytes
	DocMaxInstruction = 2000      // runes
	DocMaxTickets     = 50        // chosen tickets of a source
	DocMaxFiltered    = 200       // tickets a filter may gather
	DocMaxRepos       = 10        // repositories of a source
	DocMaxPulls       = 30        // chosen pull requests
	DocMaxPeriod      = 366 * 24 * time.Hour
	DocTrashDays      = 30 // days a deleted document can be restored
)

// ErrDocInvalid wraps every validation error of documents.
var ErrDocInvalid = errors.New("invalid document")

func docInvalid(format string, args ...any) error {
	return fmt.Errorf("%w: %s", ErrDocInvalid, fmt.Sprintf(format, args...))
}

// CleanDocumentTitle trims a title and checks it.
func CleanDocumentTitle(s string) (string, error) {
	s = strings.Join(strings.Fields(s), " ")
	switch {
	case s == "":
		return "", docInvalid("a title is required")
	case !utf8.ValidString(s):
		return "", docInvalid("the title is not valid UTF-8")
	case utf8.RuneCountInString(s) > DocMaxTitle:
		return "", docInvalid("the title is longer than %d characters", DocMaxTitle)
	}
	return s, nil
}

// CleanDocumentBody normalises line endings and checks a body.
func CleanDocumentBody(s string) (string, error) {
	s = strings.ReplaceAll(strings.ReplaceAll(s, "\r\n", "\n"), "\r", "\n")
	switch {
	case !utf8.ValidString(s):
		return "", docInvalid("the text is not valid UTF-8")
	case len(s) > DocMaxBody:
		return "", docInvalid("the text is larger than %d KB", DocMaxBody>>10)
	}
	return s, nil
}

// SourceKind is what a generation gathers.
type SourceKind string

// Source kinds.
const (
	SourceReport  SourceKind = "report"   // one ticket's approved report
	SourceTickets SourceKind = "tickets"  // chosen tickets, or a filter
	SourceCommits SourceKind = "commits"  // commits of repositories in a period
	SourcePulls   SourceKind = "pulls"    // pull requests of repositories
	SourceRepo    SourceKind = "repo"     // one repository, read in the sandbox
	SourceDoc     SourceKind = "document" // a page of the workspace, made into slides
	SourceMeeting SourceKind = "meeting"  // a meeting session's transcript and chat, made into notes
)

// DocTemplate shapes what a generation writes.
type DocTemplate string

// Templates.
const (
	TemplateStatus        DocTemplate = "status"
	TemplateReleaseNotes  DocTemplate = "release_notes"
	TemplatePullReview    DocTemplate = "pr_review"
	TemplateRepoReview    DocTemplate = "repo_review"
	TemplateTicketSummary DocTemplate = "ticket_summary"
	TemplatePresentation  DocTemplate = "presentation"
	TemplateMeetingNotes  DocTemplate = "meeting_notes"
	TemplateBlank         DocTemplate = "blank"
)

// DocTemplates lists the templates, in the order clients show them.
var DocTemplates = []DocTemplate{TemplateStatus, TemplateReleaseNotes, TemplatePullReview, TemplateRepoReview, TemplateTicketSummary,
	TemplatePresentation, TemplateBlank, TemplateMeetingNotes}

// DefaultTemplate is the template a source kind starts with.
func DefaultTemplate(k SourceKind) DocTemplate {
	switch k {
	case SourceReport:
		return TemplateTicketSummary
	case SourceCommits:
		return TemplateReleaseNotes
	case SourcePulls:
		return TemplatePullReview
	case SourceRepo:
		return TemplateRepoReview
	case SourceDoc:
		return TemplatePresentation
	case SourceMeeting:
		return TemplateMeetingNotes
	}
	return TemplateStatus
}

// TicketFilter picks tickets for a Tickets source: all fields are
// optional and combine with AND. The source's period limits by update.
type TicketFilter struct {
	States []TicketState `json:"states,omitempty"`
	Kinds  []TicketKind  `json:"kinds,omitempty"`
	RepoID *int64        `json:"repoId,omitempty"`
}

// DocumentSource is what a generation is made from.
type DocumentSource struct {
	Kind        SourceKind    `json:"kind"`
	Template    DocTemplate   `json:"template"`
	Instruction string        `json:"instruction,omitempty"`
	TicketKeys  []string      `json:"tickets,omitempty"` // report: one; tickets: chosen ones
	Filter      *TicketFilter `json:"filter,omitempty"`  // tickets: instead of chosen ones
	RepoIDs     []int64       `json:"repoIds,omitempty"` // commits, pulls: one or more; repo: one
	Branch      string        `json:"branch,omitempty"`  // commits: "" for the default branch; repo: the ref
	Author      string        `json:"author,omitempty"`  // commits: name or login, "" for everyone
	PRState     string        `json:"prState,omitempty"` // pulls: open, merged or all
	PRNumbers   []int         `json:"prNumbers,omitempty"`
	From        *time.Time    `json:"from,omitempty"`
	To          *time.Time    `json:"to,omitempty"`
	// document: the page, and the version read (0 until the run is queued,
	// which pins the current one).
	DocumentID      int64 `json:"documentId,omitempty"`
	DocumentVersion int   `json:"documentVersion,omitempty"`
	// meeting: the session whose transcript and chat the notes are made from.
	SessionID int64 `json:"sessionId,omitempty"`
}

// Validate checks a source and fills its defaults.
func (s *DocumentSource) Validate() error {
	if s.Template == "" {
		s.Template = DefaultTemplate(s.Kind)
	}
	if !slices.Contains(DocTemplates, s.Template) {
		return docInvalid("unknown template %q", s.Template)
	}
	s.Instruction = strings.TrimSpace(s.Instruction)
	if utf8.RuneCountInString(s.Instruction) > DocMaxInstruction {
		return docInvalid("the instruction is longer than %d characters", DocMaxInstruction)
	}
	if s.Template == TemplateBlank && s.Instruction == "" {
		return docInvalid("the blank template needs an instruction")
	}
	if s.From != nil && s.To != nil {
		if s.To.Before(*s.From) {
			return docInvalid("the period ends before it starts")
		}
		if s.To.Sub(*s.From) > DocMaxPeriod {
			return docInvalid("the period is longer than a year")
		}
	}
	keys := make([]string, 0, len(s.TicketKeys))
	for _, k := range s.TicketKeys {
		if k = strings.TrimSpace(k); k != "" && !slices.Contains(keys, k) {
			keys = append(keys, k)
		}
	}
	s.TicketKeys = keys
	switch s.Kind {
	case SourceReport:
		if len(s.TicketKeys) != 1 {
			return docInvalid("a report source names exactly one ticket")
		}
	case SourceTickets:
		if len(s.TicketKeys) == 0 && s.Filter == nil {
			return docInvalid("choose tickets or a filter")
		}
		if len(s.TicketKeys) > DocMaxTickets {
			return docInvalid("choose at most %d tickets", DocMaxTickets)
		}
		if s.Filter != nil {
			for _, st := range s.Filter.States {
				if !st.Valid() {
					return docInvalid("unknown state %q", st)
				}
			}
			for _, k := range s.Filter.Kinds {
				if !k.Valid() {
					return docInvalid("unknown kind %q", k)
				}
			}
		}
	case SourceCommits, SourcePulls:
		if len(s.RepoIDs) == 0 || len(s.RepoIDs) > DocMaxRepos {
			return docInvalid("choose 1 to %d repositories", DocMaxRepos)
		}
		if s.Kind == SourcePulls {
			if s.PRState == "" {
				s.PRState = "merged"
			}
			if s.PRState != "open" && s.PRState != "merged" && s.PRState != "all" {
				return docInvalid("pull request state is open, merged or all")
			}
			if len(s.PRNumbers) > DocMaxPulls {
				return docInvalid("choose at most %d pull requests", DocMaxPulls)
			}
			if len(s.PRNumbers) > 0 && len(s.RepoIDs) != 1 {
				return docInvalid("chosen pull request numbers need exactly one repository")
			}
		}
		if s.Kind == SourceCommits && s.From == nil {
			return docInvalid("a commits source needs the start of its period")
		}
	case SourceRepo:
		if len(s.RepoIDs) != 1 {
			return docInvalid("a repository source names exactly one repository")
		}
	case SourceMeeting:
		if s.SessionID <= 0 {
			return docInvalid("a meeting source names the session")
		}
		if s.Template != TemplateMeetingNotes {
			return docInvalid("meeting notes use the meeting_notes template")
		}
	case SourceDoc:
		if s.DocumentID <= 0 {
			return docInvalid("a document source names the document")
		}
		if s.DocumentVersion < 0 {
			return docInvalid("the document's version is 1 or more, or 0 for the current one")
		}
	default:
		return docInvalid("unknown source kind %q", s.Kind)
	}
	return nil
}

// Note is the short description of an AI version: its source, template
// and instruction.
func (s DocumentSource) Note() string {
	n := string(s.Kind) + " · " + string(s.Template)
	if s.Instruction != "" {
		ins := s.Instruction
		if utf8.RuneCountInString(ins) > 120 {
			ins = string([]rune(ins)[:120]) + "…"
		}
		n += " · " + ins
	}
	return n
}

// NewPublicToken returns a public link token: 32 random bytes in base62.
func NewPublicToken() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return new(big.Int).SetBytes(b).Text(62), nil
}

// ValidPublicToken reports whether s looks like a public link token, so
// anything else is refused before reaching the database.
func ValidPublicToken(s string) bool {
	if len(s) < 20 || len(s) > 64 {
		return false
	}
	for _, r := range s {
		if (r < '0' || r > '9') && (r < 'a' || r > 'z') && (r < 'A' || r > 'Z') {
			return false
		}
	}
	return true
}

// SecretFinding is a line of a document that looks like it holds a
// secret.
type SecretFinding struct {
	Line    int    // 1-based
	Excerpt string // the line with the secret masked
}

// ScanSecrets finds the lines of body that hold what looks like a
// credential (see MaskCredentials), plus any of the known secret values.
// A document with findings cannot be published.
func ScanSecrets(body string, known Redactor) []SecretFinding {
	var out []SecretFinding
	lines := strings.Split(body, "\n")
	inKey := false
	for i, line := range lines {
		masked := MaskCredentials(line)
		if !known.Empty() {
			masked = known.String(masked)
		}
		begin := strings.Contains(line, "-----BEGIN") && strings.Contains(line, "PRIVATE KEY")
		if begin {
			inKey = true
		}
		if masked != line || inKey {
			ex := masked
			if inKey {
				ex = "-----PRIVATE KEY " + Masked + "-----"
			}
			if utf8.RuneCountInString(ex) > 160 {
				ex = string([]rune(ex)[:160]) + "…"
			}
			out = append(out, SecretFinding{Line: i + 1, Excerpt: ex})
		}
		if inKey && strings.Contains(line, "-----END") {
			inKey = false
		}
	}
	return out
}

// translit spells Russian and Uzbek Cyrillic letters in Latin, for file
// names.
var translit = map[rune]string{
	'а': "a", 'б': "b", 'в': "v", 'г': "g", 'д': "d", 'е': "e", 'ё': "yo", 'ж': "zh", 'з': "z", 'и': "i",
	'й': "y", 'к': "k", 'л': "l", 'м': "m", 'н': "n", 'о': "o", 'п': "p", 'р': "r", 'с': "s", 'т': "t",
	'у': "u", 'ф': "f", 'х': "h", 'ц': "ts", 'ч': "ch", 'ш': "sh", 'щ': "sch", 'ъ': "", 'ы': "y", 'ь': "",
	'э': "e", 'ю': "yu", 'я': "ya", 'ў': "o", 'қ': "q", 'ғ': "g", 'ҳ': "h",
}

// DownloadName is the file name of a version of a document:
// sprint-42-status-report-v7.md. Cyrillic is transliterated and Uzbek
// letters lose their apostrophes; a title with nothing left becomes
// document-<id>.
func DownloadName(title string, id int64, version int, ext string) string {
	var b strings.Builder
	dash := false
	put := func(s string) {
		for _, r := range s {
			if r >= 'a' && r <= 'z' || r >= '0' && r <= '9' {
				b.WriteRune(r)
				dash = false
			} else if !dash && b.Len() > 0 {
				b.WriteByte('-')
				dash = true
			}
		}
	}
	for _, r := range strings.ToLower(title) {
		switch {
		case r == 'ʻ' || r == 'ʼ' || r == '‘' || r == '’' || r == '\'' || r == '`':
			// oʻ, gʻ and apostrophes inside words: drop, do not split.
		case translit[r] != "" || r == 'ъ' || r == 'ь':
			put(translit[r])
		case r < utf8.RuneSelf:
			put(string(r))
		case unicode.IsLetter(r) || unicode.IsDigit(r):
			put(string(foldLatin(r)))
		default:
			put(" ")
		}
	}
	name := strings.Trim(b.String(), "-")
	if len(name) > 80 {
		name = strings.TrimRight(name[:80], "-")
	}
	if name == "" {
		name = fmt.Sprintf("document-%d", id)
	}
	return fmt.Sprintf("%s-v%d.%s", name, version, ext)
}

// foldLatin drops the accents of common Latin letters (é → e); other
// letters become a separator.
func foldLatin(r rune) rune {
	const from, to = "àáâãäåèéêëìíîïòóôõöùúûüýÿñçşğ", "aaaaaaeeeeiiiiooooouuuuyyncsg"
	if i := strings.IndexRune(from, r); i >= 0 {
		return []rune(to)[utf8.RuneCountInString(from[:i])]
	}
	return ' '
}

// DocumentFile is a version of a document of kind k as a .md file: a page
// as MarkdownFile, a deck as its text (its title slide is its heading).
func DocumentFile(k DocumentKind, title, body string) string {
	if k != DocKindSlides {
		return MarkdownFile(title, body)
	}
	return strings.TrimRight(strings.TrimLeft(strings.ReplaceAll(body, "\r\n", "\n"), "\n"), "\n") + "\n"
}

// MarkdownFile is a version as a .md file: the body under the title as a
// heading (unless the body starts with it already), LF line endings, and
// a final newline.
func MarkdownFile(title, body string) string {
	body = strings.TrimLeft(strings.ReplaceAll(body, "\r\n", "\n"), "\n")
	first, _, _ := strings.Cut(body, "\n")
	if strings.TrimSpace(strings.TrimPrefix(strings.TrimSpace(first), "#")) != title || !strings.HasPrefix(strings.TrimSpace(first), "# ") {
		body = "# " + title + "\n\n" + body
	}
	return strings.TrimRight(body, "\n") + "\n"
}

// PendingDocument is the oldest waiting generation of a workspace.
type PendingDocument struct {
	WorkspaceID int64
	RequestedBy *int64 // whose Claude account it may use
	Since       time.Time
}

// DocRunResult is how a generation ended.
type DocRunResult struct {
	Status DocRunStatus // done, failed, or queued to try again later
	Error  string
	// Version is the new version (done only), made the current one.
	Version  *DocumentVersion
	Tickets  []int64 // tickets the source named, linked to the document
	DataAsOf time.Time
	// FromVersion is the version of the source page a document source read.
	FromVersion int
	// ActionItems are what a meeting's notes say people are to do (done
	// meeting generations only).
	ActionItems []ActionItem
}
