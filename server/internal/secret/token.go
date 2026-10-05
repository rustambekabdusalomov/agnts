package secret

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
)

// NewToken returns a random URL-safe token with 256 bits of entropy.
func NewToken() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(b), nil
}

// HashToken returns the SHA-256 of a token; only hashes are stored.
func HashToken(token string) []byte {
	h := sha256.Sum256([]byte(token))
	return h[:]
}
