// Package livekit is agnts's adapter to a LiveKit server: the access tokens
// clients join rooms with, the few server API calls agnts makes (rooms,
// participants, data, egress) and the webhooks LiveKit sends. It speaks
// LiveKit's wire formats directly, without its SDK: HS256 JWTs and Twirp
// over JSON.
package livekit

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"
)

// Track sources a participant may publish (LiveKit's names in grants).
const (
	SourceCamera            = "camera"
	SourceMicrophone        = "microphone"
	SourceScreenShare       = "screen_share"
	SourceScreenShareAudio  = "screen_share_audio"
	tokenLeeway             = 10 * time.Second
	defaultClientTokenValid = 10 * time.Minute
)

// VideoGrant is the "video" claim of a LiveKit token.
type VideoGrant struct {
	RoomCreate           bool     `json:"roomCreate,omitempty"`
	RoomList             bool     `json:"roomList,omitempty"`
	RoomRecord           bool     `json:"roomRecord,omitempty"`
	RoomAdmin            bool     `json:"roomAdmin,omitempty"`
	RoomJoin             bool     `json:"roomJoin,omitempty"`
	Room                 string   `json:"room,omitempty"`
	CanPublish           *bool    `json:"canPublish,omitempty"`
	CanSubscribe         *bool    `json:"canSubscribe,omitempty"`
	CanPublishData       *bool    `json:"canPublishData,omitempty"`
	CanPublishSources    []string `json:"canPublishSources,omitempty"`
	CanUpdateOwnMetadata *bool    `json:"canUpdateOwnMetadata,omitempty"`
	Hidden               bool     `json:"hidden,omitempty"`
}

// claims are the JWT claims LiveKit reads.
type claims struct {
	Issuer     string            `json:"iss"`
	Subject    string            `json:"sub,omitempty"`
	ID         string            `json:"jti,omitempty"`
	NotBefore  int64             `json:"nbf"`
	Expires    int64             `json:"exp"`
	Name       string            `json:"name,omitempty"`
	Metadata   string            `json:"metadata,omitempty"`
	Attributes map[string]string `json:"attributes,omitempty"`
	Video      *VideoGrant       `json:"video,omitempty"`
	SHA256     string            `json:"sha256,omitempty"` // webhooks: the body's hash
}

// Join is what a client's access token lets it do.
type Join struct {
	Room     string
	Identity string
	Name     string
	// Attributes are visible to everyone in the room (the person's role,
	// their agnts id).
	Attributes map[string]string
	// Sources are what the participant may publish; empty publishes
	// nothing.
	Sources []string
	// Data lets them send data messages (reactions, hands).
	Data bool
	// Hidden participants are not seen by others (recorders).
	Hidden bool
	// Valid is how long the token can be used to connect; LiveKit
	// refreshes it while connected. 0 means 10 minutes.
	Valid time.Duration
}

// Keys are a LiveKit server's API key and secret.
type Keys struct {
	Key    string
	Secret string
}

// Valid reports whether both are set.
func (k Keys) Valid() bool { return k.Key != "" && k.Secret != "" }

// JoinToken returns the access token a client connects to a room with.
func (k Keys) JoinToken(j Join, now time.Time) (string, error) {
	if j.Room == "" || j.Identity == "" {
		return "", errors.New("livekit: a join token needs a room and an identity")
	}
	valid := j.Valid
	if valid <= 0 {
		valid = defaultClientTokenValid
	}
	t, f := true, false
	g := &VideoGrant{RoomJoin: true, Room: j.Room, CanSubscribe: &t, CanPublishData: &j.Data, CanUpdateOwnMetadata: &t, Hidden: j.Hidden}
	if len(j.Sources) > 0 {
		g.CanPublish = &t
		g.CanPublishSources = append([]string{}, j.Sources...)
	} else {
		g.CanPublish = &f
	}
	return k.sign(claims{Issuer: k.Key, Subject: j.Identity, ID: j.Identity, NotBefore: now.Add(-tokenLeeway).Unix(),
		Expires: now.Add(valid).Unix(), Name: j.Name, Attributes: j.Attributes, Video: g})
}

// serverToken is the token of one server API call.
func (k Keys) serverToken(g VideoGrant, now time.Time) (string, error) {
	return k.sign(claims{Issuer: k.Key, NotBefore: now.Add(-tokenLeeway).Unix(), Expires: now.Add(time.Minute).Unix(), Video: &g})
}

var jwtHeader = base64.RawURLEncoding.EncodeToString([]byte(`{"alg":"HS256","typ":"JWT"}`))

func (k Keys) sign(c claims) (string, error) {
	if !k.Valid() {
		return "", errors.New("livekit: no API key and secret")
	}
	body, err := json.Marshal(c)
	if err != nil {
		return "", err
	}
	unsigned := jwtHeader + "." + base64.RawURLEncoding.EncodeToString(body)
	mac := hmac.New(sha256.New, []byte(k.Secret))
	mac.Write([]byte(unsigned))
	return unsigned + "." + base64.RawURLEncoding.EncodeToString(mac.Sum(nil)), nil
}

// ErrBadToken means a token was not signed with these keys, or expired.
var ErrBadToken = errors.New("livekit: invalid token")

// verify checks a token's signature, issuer and times, and returns its
// claims.
func (k Keys) verify(tok string, now time.Time) (claims, error) {
	var c claims
	parts := strings.Split(strings.TrimSpace(tok), ".")
	if len(parts) != 3 {
		return c, ErrBadToken
	}
	head, err := base64.RawURLEncoding.DecodeString(parts[0])
	if err != nil {
		return c, ErrBadToken
	}
	var h struct {
		Alg string `json:"alg"`
	}
	if json.Unmarshal(head, &h) != nil || h.Alg != "HS256" {
		return c, ErrBadToken
	}
	mac := hmac.New(sha256.New, []byte(k.Secret))
	mac.Write([]byte(parts[0] + "." + parts[1]))
	sig, err := base64.RawURLEncoding.DecodeString(parts[2])
	if err != nil || !hmac.Equal(sig, mac.Sum(nil)) {
		return c, ErrBadToken
	}
	body, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil || json.Unmarshal(body, &c) != nil {
		return c, ErrBadToken
	}
	switch {
	case c.Issuer != k.Key:
		return c, fmt.Errorf("%w: issued by another key", ErrBadToken)
	case c.Expires != 0 && now.Unix() > c.Expires+int64(tokenLeeway.Seconds()):
		return c, fmt.Errorf("%w: expired", ErrBadToken)
	case c.NotBefore != 0 && now.Unix() < c.NotBefore-int64(tokenLeeway.Seconds()):
		return c, fmt.Errorf("%w: not valid yet", ErrBadToken)
	}
	return c, nil
}
