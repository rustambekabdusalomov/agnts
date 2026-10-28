package livekit

import (
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"fmt"
	"strings"
	"time"
)

// Webhook events agnts listens to.
const (
	EventRoomStarted       = "room_started"
	EventRoomFinished      = "room_finished"
	EventParticipantJoined = "participant_joined"
	EventParticipantLeft   = "participant_left"
	EventTrackPublished    = "track_published"
	EventTrackUnpublished  = "track_unpublished"
	EventEgressStarted     = "egress_started"
	EventEgressUpdated     = "egress_updated"
	EventEgressEnded       = "egress_ended"
)

// Event is one webhook from LiveKit.
type Event struct {
	ID          string       `json:"id"`
	Event       string       `json:"event"`
	CreatedAt   Int64        `json:"created_at"` // seconds
	Room        *Room        `json:"room"`
	Participant *Participant `json:"participant"`
	Track       *Track       `json:"track"`
	Egress      *Egress      `json:"egress_info"`
}

// At is when the event happened (now if LiveKit did not say).
func (e Event) At(now time.Time) time.Time {
	if e.CreatedAt > 0 {
		return time.Unix(int64(e.CreatedAt), 0)
	}
	return now
}

// RoomName is the room the event is about, from whichever part names it.
func (e Event) RoomName() string {
	switch {
	case e.Room != nil && e.Room.Name != "":
		return e.Room.Name
	case e.Egress != nil:
		return e.Egress.RoomName
	}
	return ""
}

// ErrBadWebhook means a webhook is not from this LiveKit server.
var ErrBadWebhook = errors.New("livekit: webhook not signed by this server")

// webhookMaxAge refuses old webhooks replayed later.
const webhookMaxAge = 10 * time.Minute

// ReadWebhook checks that body was signed by the server (the token in the
// Authorization header carries its SHA-256) and parses it.
func (k Keys) ReadWebhook(auth string, body []byte, now time.Time) (Event, error) {
	var e Event
	auth = strings.TrimSpace(strings.TrimPrefix(strings.TrimSpace(auth), "Bearer "))
	if auth == "" {
		return e, fmt.Errorf("%w: no Authorization header", ErrBadWebhook)
	}
	c, err := k.verify(auth, now)
	if err != nil {
		return e, fmt.Errorf("%w: %w", ErrBadWebhook, err)
	}
	sum := sha256.Sum256(body)
	if c.SHA256 != base64.StdEncoding.EncodeToString(sum[:]) {
		return e, fmt.Errorf("%w: the body does not match its signature", ErrBadWebhook)
	}
	if err := decodeProtoJSON(body, &e); err != nil {
		return e, fmt.Errorf("livekit: webhook: %w", err)
	}
	if e.CreatedAt > 0 && now.Sub(time.Unix(int64(e.CreatedAt), 0)) > webhookMaxAge {
		return e, fmt.Errorf("%w: sent %s ago", ErrBadWebhook, now.Sub(time.Unix(int64(e.CreatedAt), 0)).Round(time.Second))
	}
	return e, nil
}

// SignWebhook signs a body as LiveKit does; for tests and the dev tools.
func (k Keys) SignWebhook(body []byte, now time.Time) (string, error) {
	sum := sha256.Sum256(body)
	return k.sign(claims{Issuer: k.Key, NotBefore: now.Add(-tokenLeeway).Unix(), Expires: now.Add(5 * time.Minute).Unix(),
		SHA256: base64.StdEncoding.EncodeToString(sum[:])})
}
