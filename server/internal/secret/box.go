package secret

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"errors"
)

const boxVersion byte = 1

// Box encrypts small secrets (tokens, TOTP seeds) with AES-256-GCM.
// The output layout is version || nonce || ciphertext.
type Box struct {
	aead cipher.AEAD
}

// NewBox returns a Box using a 32-byte key.
func NewBox(key []byte) (*Box, error) {
	if len(key) != 32 {
		return nil, errors.New("secret: key must be 32 bytes")
	}
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	aead, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}
	return &Box{aead: aead}, nil
}

// Seal encrypts plaintext. aad binds the ciphertext to its context
// (for example "integration:jira") so it cannot be swapped between rows.
func (b *Box) Seal(plaintext, aad []byte) ([]byte, error) {
	nonce := make([]byte, b.aead.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		return nil, err
	}
	out := make([]byte, 0, 1+len(nonce)+len(plaintext)+b.aead.Overhead())
	out = append(out, boxVersion)
	out = append(out, nonce...)
	return b.aead.Seal(out, nonce, plaintext, aad), nil
}

// Open decrypts data produced by Seal with the same aad.
func (b *Box) Open(data, aad []byte) ([]byte, error) {
	ns := b.aead.NonceSize()
	if len(data) < 1+ns || data[0] != boxVersion {
		return nil, errors.New("secret: malformed ciphertext")
	}
	return b.aead.Open(nil, data[1:1+ns], data[1+ns:], aad)
}
