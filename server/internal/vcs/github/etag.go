package github

import (
	"container/list"
	"crypto/sha256"
	"encoding/hex"
	"sync"
)

// Bounds of the ETag cache: a commit with its files can be large, and the
// repository page reads ~90 resources per refresh.
const (
	etagMaxBytes      = 32 << 20
	etagMaxEntryBytes = 1 << 20
)

// etags remembers GET responses by token and path, so a repeated read asks
// GitHub whether it changed (If-None-Match). An unchanged answer is a 304,
// which does not count against the rate limit. Least recently used
// responses go first.
type etags struct {
	mu    sync.Mutex
	size  int
	order *list.List // of *etagEntry, most recent first
	byKey map[string]*list.Element
}

type etagEntry struct {
	key  string
	etag string
	body []byte
}

func newEtags() *etags {
	return &etags{order: list.New(), byKey: map[string]*list.Element{}}
}

// etagKey keeps tokens apart: what one token may read says nothing about another.
func etagKey(token, path string) string {
	sum := sha256.Sum256([]byte(token))
	return hex.EncodeToString(sum[:8]) + " " + path
}

func (c *etags) get(key string) (etag string, body []byte, ok bool) {
	c.mu.Lock()
	defer c.mu.Unlock()
	el, ok := c.byKey[key]
	if !ok {
		return "", nil, false
	}
	c.order.MoveToFront(el)
	e := el.Value.(*etagEntry)
	return e.etag, e.body, true
}

func (c *etags) put(key, etag string, body []byte) {
	if etag == "" || len(body) > etagMaxEntryBytes {
		return
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	if el, ok := c.byKey[key]; ok {
		c.size -= len(el.Value.(*etagEntry).body)
		c.order.Remove(el)
	}
	c.byKey[key] = c.order.PushFront(&etagEntry{key: key, etag: etag, body: body})
	c.size += len(body)
	for c.size > etagMaxBytes {
		el := c.order.Back()
		e := el.Value.(*etagEntry)
		c.order.Remove(el)
		delete(c.byKey, e.key)
		c.size -= len(e.body)
	}
}
