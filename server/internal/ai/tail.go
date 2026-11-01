package ai

import "sync"

// TailBuffer keeps the last 256 KiB written to it: a process's stderr,
// for its error message.
type TailBuffer struct {
	mu  sync.Mutex
	buf []byte
}

const tailMax = 256 << 10

func (t *TailBuffer) Write(p []byte) (int, error) {
	t.mu.Lock()
	defer t.mu.Unlock()
	t.buf = append(t.buf, p...)
	if len(t.buf) > tailMax {
		t.buf = append([]byte(nil), t.buf[len(t.buf)-tailMax:]...)
	}
	return len(p), nil
}

func (t *TailBuffer) String() string {
	t.mu.Lock()
	defer t.mu.Unlock()
	return string(t.buf)
}
