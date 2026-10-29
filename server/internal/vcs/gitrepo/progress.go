package gitrepo

// Progress keeps the uncommitted work of each ticket's stopped coding run
// on disk, as <dir>/<workspace>/<key>.json, so the next run can pick it up
// again. Implements orchestrator.Progress.
type Progress struct{ files Homes }

// NewProgress stores saved work under dir.
func NewProgress(dir string) *Progress { return &Progress{files: Homes{dir: dir, ext: ".json"}} }

// Load returns the saved work, or nil when there is none.
func (p *Progress) Load(ws int64, key string) ([]byte, error) { return p.files.Load(ws, key) }

// Save replaces the saved work atomically.
func (p *Progress) Save(ws int64, key string, data []byte) error { return p.files.Save(ws, key, data) }

// Drop removes the saved work, if any.
func (p *Progress) Drop(ws int64, key string) error { return p.files.Drop(ws, key) }

// Delete removes the saved work of a workspace (it was deleted).
func (p *Progress) Delete(ws int64) error { return p.files.Delete(ws) }
