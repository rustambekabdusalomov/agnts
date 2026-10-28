package livekit

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"
	"unicode"
)

// Client calls a LiveKit server's API (Twirp over JSON) from agnts's side
// of the network: http://livekit:7880 in the Compose stack.
type Client struct {
	base string
	keys Keys
	http *http.Client
	now  func() time.Time
}

// NewClient returns a client of the server at base (http or https).
func NewClient(base string, keys Keys) *Client {
	base = strings.TrimRight(base, "/")
	base = strings.Replace(strings.Replace(base, "wss://", "https://", 1), "ws://", "http://", 1)
	return &Client{base: base, keys: keys, http: &http.Client{Timeout: 10 * time.Second}, now: time.Now}
}

// Errors of the API, by Twirp code.
var (
	ErrNotFound    = errors.New("livekit: not found")
	ErrUnavailable = errors.New("livekit: unavailable")
)

// APIError is any other error LiveKit answered.
type APIError struct {
	Code string
	Msg  string
}

func (e *APIError) Error() string { return "livekit: " + e.Code + ": " + e.Msg }

// call posts req to service/method with a token carrying grant, and
// decodes the answer into out.
func (c *Client) call(ctx context.Context, service, method string, grant VideoGrant, req, out any) error {
	tok, err := c.keys.serverToken(grant, c.now())
	if err != nil {
		return err
	}
	body, err := json.Marshal(req)
	if err != nil {
		return err
	}
	// The base is the operator's LiveKit server (AGNTS_LIVEKIT_INTERNAL_URL);
	// service and method are constants of this file.
	r, err := http.NewRequestWithContext(ctx, http.MethodPost, c.base+"/twirp/livekit."+service+"/"+method, bytes.NewReader(body)) //nolint:gosec // G704: see above
	if err != nil {
		return err
	}
	r.Header.Set("Content-Type", "application/json")
	r.Header.Set("Authorization", "Bearer "+tok)
	res, err := c.http.Do(r) //nolint:gosec // G704: the operator's own LiveKit server
	if err != nil {
		return fmt.Errorf("%w: %w", ErrUnavailable, err)
	}
	defer func() { _ = res.Body.Close() }()
	raw, err := io.ReadAll(io.LimitReader(res.Body, 4<<20))
	if err != nil {
		return fmt.Errorf("%w: %w", ErrUnavailable, err)
	}
	if res.StatusCode != http.StatusOK {
		var te struct {
			Code string `json:"code"`
			Msg  string `json:"msg"`
		}
		_ = json.Unmarshal(raw, &te)
		switch {
		case te.Code == "not_found":
			return fmt.Errorf("%w: %s", ErrNotFound, te.Msg)
		case res.StatusCode >= 500 && te.Code == "":
			return fmt.Errorf("%w: HTTP %d", ErrUnavailable, res.StatusCode)
		case te.Code == "":
			te.Code = strconv.Itoa(res.StatusCode)
		}
		return &APIError{Code: te.Code, Msg: te.Msg}
	}
	if out == nil {
		return nil
	}
	return decodeProtoJSON(raw, out)
}

// decodeProtoJSON decodes LiveKit's JSON, whichever field naming its
// version uses: keys are turned into snake_case first, as the structs
// here name them.
func decodeProtoJSON(raw []byte, out any) error {
	var v any
	if err := json.Unmarshal(raw, &v); err != nil {
		return err
	}
	norm, err := json.Marshal(snakeKeys(v))
	if err != nil {
		return err
	}
	return json.Unmarshal(norm, out)
}

func snakeKeys(v any) any {
	switch t := v.(type) {
	case map[string]any:
		out := make(map[string]any, len(t))
		for k, val := range t {
			// Attribute maps are the participant's own keys: keep them.
			if k == "attributes" {
				out[k] = val
				continue
			}
			out[snake(k)] = snakeKeys(val)
		}
		return out
	case []any:
		for i := range t {
			t[i] = snakeKeys(t[i])
		}
	}
	return v
}

func snake(s string) string {
	var b strings.Builder
	for i, r := range s {
		if unicode.IsUpper(r) {
			if i > 0 {
				b.WriteByte('_')
			}
			b.WriteRune(unicode.ToLower(r))
			continue
		}
		b.WriteRune(r)
	}
	return b.String()
}

// Int64 is a protobuf int64: JSON writes it as a string, or a number.
type Int64 int64

// UnmarshalJSON reads both.
func (n *Int64) UnmarshalJSON(b []byte) error {
	s := strings.Trim(string(b), `"`)
	if s == "" || s == "null" {
		*n = 0
		return nil
	}
	v, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		f, ferr := strconv.ParseFloat(s, 64)
		if ferr != nil {
			return err
		}
		v = int64(f)
	}
	*n = Int64(v)
	return nil
}

// Enum is a protobuf enum: a name, or a number some versions write.
type Enum string

// UnmarshalJSON keeps the name, or the number as text.
func (e *Enum) UnmarshalJSON(b []byte) error {
	*e = Enum(strings.Trim(string(b), `"`))
	return nil
}

// is reports whether e is name, or the number that stands for it.
func (e Enum) is(name string, number int) bool {
	return string(e) == name || string(e) == strconv.Itoa(number)
}

// Track is a track a participant publishes.
type Track struct {
	SID    string `json:"sid"`
	Type   Enum   `json:"type"`
	Source Enum   `json:"source"`
	Muted  bool   `json:"muted"`
}

// IsMicrophone reports whether the track is someone's microphone.
func (t Track) IsMicrophone() bool { return t.Source.is("MICROPHONE", 2) }

// IsCamera reports whether the track is someone's camera.
func (t Track) IsCamera() bool { return t.Source.is("CAMERA", 1) }

// IsScreenShare reports whether the track is a shared screen.
func (t Track) IsScreenShare() bool { return t.Source.is("SCREEN_SHARE", 3) }

// IsScreenAudio reports whether the track is a shared screen's sound.
func (t Track) IsScreenAudio() bool { return t.Source.is("SCREEN_SHARE_AUDIO", 4) }

// IsAudio reports whether the track carries sound.
func (t Track) IsAudio() bool { return t.Type.is("AUDIO", 0) }

// Participant is someone connected to a room.
type Participant struct {
	SID        string            `json:"sid"`
	Identity   string            `json:"identity"`
	Name       string            `json:"name"`
	State      Enum              `json:"state"`
	Tracks     []Track           `json:"tracks"`
	Metadata   string            `json:"metadata"`
	JoinedAt   Int64             `json:"joined_at"`
	Attributes map[string]string `json:"attributes"`
}

// Room is a LiveKit room.
type Room struct {
	SID             string `json:"sid"`
	Name            string `json:"name"`
	CreationTime    Int64  `json:"creation_time"`
	NumParticipants int    `json:"num_participants"`
	Metadata        string `json:"metadata"`
}

// NewRoom is a room to create.
type NewRoom struct {
	Name             string `json:"name"`
	EmptyTimeout     int    `json:"empty_timeout,omitempty"`     // seconds a room nobody joined lives
	DepartureTimeout int    `json:"departure_timeout,omitempty"` // seconds a room lives after the last person left
	MaxParticipants  int    `json:"max_participants,omitempty"`
	Metadata         string `json:"metadata,omitempty"`
}

// CreateRoom creates a room (or returns the one by that name).
func (c *Client) CreateRoom(ctx context.Context, r NewRoom) (Room, error) {
	var out Room
	err := c.call(ctx, "RoomService", "CreateRoom", VideoGrant{RoomCreate: true}, r, &out)
	return out, err
}

// ListRooms returns the rooms with these names, or all rooms.
func (c *Client) ListRooms(ctx context.Context, names ...string) ([]Room, error) {
	var out struct {
		Rooms []Room `json:"rooms"`
	}
	err := c.call(ctx, "RoomService", "ListRooms", VideoGrant{RoomList: true}, map[string]any{"names": names}, &out)
	return out.Rooms, err
}

// DeleteRoom disconnects everyone and closes the room.
func (c *Client) DeleteRoom(ctx context.Context, room string) error {
	return c.call(ctx, "RoomService", "DeleteRoom", VideoGrant{RoomCreate: true}, map[string]any{"room": room}, &struct{}{})
}

// ListParticipants returns who is in a room.
func (c *Client) ListParticipants(ctx context.Context, room string) ([]Participant, error) {
	var out struct {
		Participants []Participant `json:"participants"`
	}
	err := c.call(ctx, "RoomService", "ListParticipants", VideoGrant{RoomAdmin: true, Room: room}, map[string]any{"room": room}, &out)
	return out.Participants, err
}

// RemoveParticipant disconnects one participant.
func (c *Client) RemoveParticipant(ctx context.Context, room, identity string) error {
	return c.call(ctx, "RoomService", "RemoveParticipant", VideoGrant{RoomAdmin: true, Room: room},
		map[string]any{"room": room, "identity": identity}, &struct{}{})
}

// MuteTrack mutes one published track (LiveKit can't unmute someone).
func (c *Client) MuteTrack(ctx context.Context, room, identity, trackSID string) error {
	return c.call(ctx, "RoomService", "MutePublishedTrack", VideoGrant{RoomAdmin: true, Room: room},
		map[string]any{"room": room, "identity": identity, "track_sid": trackSID, "muted": true}, &struct{}{})
}

// Permission is what a connected participant may do.
type Permission struct {
	Sources []string // what they may publish; empty for nothing
	Data    bool
}

var protoSources = map[string]string{SourceCamera: "CAMERA", SourceMicrophone: "MICROPHONE", SourceScreenShare: "SCREEN_SHARE",
	SourceScreenShareAudio: "SCREEN_SHARE_AUDIO"}

// UpdateParticipant changes a connected participant's permissions and
// attributes (nil keeps them).
func (c *Client) UpdateParticipant(ctx context.Context, room, identity string, perm *Permission, attrs map[string]string) error {
	req := map[string]any{"room": room, "identity": identity}
	if perm != nil {
		srcs := make([]string, 0, len(perm.Sources))
		for _, s := range perm.Sources {
			srcs = append(srcs, protoSources[s])
		}
		req["permission"] = map[string]any{"can_subscribe": true, "can_publish": len(srcs) > 0, "can_publish_data": perm.Data,
			"can_publish_sources": srcs, "can_update_metadata": true}
	}
	if attrs != nil {
		req["attributes"] = attrs
	}
	return c.call(ctx, "RoomService", "UpdateParticipant", VideoGrant{RoomAdmin: true, Room: room}, req, &struct{}{})
}

// UpdateRoomMetadata sets the room's metadata, which every client sees.
func (c *Client) UpdateRoomMetadata(ctx context.Context, room, metadata string) error {
	return c.call(ctx, "RoomService", "UpdateRoomMetadata", VideoGrant{RoomAdmin: true, Room: room},
		map[string]any{"room": room, "metadata": metadata}, &struct{}{})
}

// SendData sends a reliable data message on topic to the identities, or
// to everyone when there are none.
func (c *Client) SendData(ctx context.Context, room, topic string, data []byte, to ...string) error {
	req := map[string]any{"room": room, "data": data, "kind": "RELIABLE", "topic": topic}
	if len(to) > 0 {
		req["destination_identities"] = to
	}
	return c.call(ctx, "RoomService", "SendData", VideoGrant{RoomAdmin: true, Room: room}, req, &struct{}{})
}

// FileResult is a file an egress wrote.
type FileResult struct {
	Filename  string `json:"filename"`
	StartedAt Int64  `json:"started_at"`
	EndedAt   Int64  `json:"ended_at"`
	Duration  Int64  `json:"duration"`
	Size      Int64  `json:"size"`
	Location  string `json:"location"`
}

// Egress is a recording LiveKit Egress runs.
type Egress struct {
	EgressID    string       `json:"egress_id"`
	RoomName    string       `json:"room_name"`
	Status      Enum         `json:"status"`
	StartedAt   Int64        `json:"started_at"` // nanoseconds
	EndedAt     Int64        `json:"ended_at"`
	Error       string       `json:"error"`
	FileResults []FileResult `json:"file_results"`
	File        *FileResult  `json:"file"` // older servers
}

// Done reports whether the egress has stopped, and whether it failed.
func (e Egress) Done() (done, failed bool) {
	switch {
	case e.Status.is("EGRESS_COMPLETE", 3):
		return true, false
	case e.Status.is("EGRESS_FAILED", 4), e.Status.is("EGRESS_ABORTED", 5), e.Status.is("EGRESS_LIMIT_REACHED", 6):
		return true, e.Status.is("EGRESS_FAILED", 4) || e.Status.is("EGRESS_ABORTED", 5)
	}
	return false, false
}

// Result is the egress's file, if it wrote one.
func (e Egress) Result() (FileResult, bool) {
	if len(e.FileResults) > 0 {
		return e.FileResults[0], true
	}
	if e.File != nil && e.File.Filename != "" {
		return *e.File, true
	}
	return FileResult{}, false
}

// RoomRecording records a whole room into one file.
type RoomRecording struct {
	Room      string
	AudioOnly bool
	// Layout of the video ("speaker", "grid"); ignored for audio.
	Layout string
	// FileType is "MP4" or "OGG".
	FileType string
	// Path is where Egress writes the file, in its own file system.
	Path string
}

// StartRoomRecording starts a room composite egress.
func (c *Client) StartRoomRecording(ctx context.Context, r RoomRecording) (Egress, error) {
	req := map[string]any{"room_name": r.Room, "audio_only": r.AudioOnly,
		"file_outputs": []any{map[string]any{"file_type": r.FileType, "filepath": r.Path, "disable_manifest": true}}}
	if !r.AudioOnly && r.Layout != "" {
		req["layout"] = r.Layout
	}
	var out Egress
	err := c.call(ctx, "Egress", "StartRoomCompositeEgress", VideoGrant{RoomRecord: true}, req, &out)
	return out, err
}

// StartTrackRecording records one track as it is (Ogg for Opus audio).
func (c *Client) StartTrackRecording(ctx context.Context, room, trackSID, path string) (Egress, error) {
	req := map[string]any{"room_name": room, "track_id": trackSID, "file": map[string]any{"filepath": path, "disable_manifest": true}}
	var out Egress
	err := c.call(ctx, "Egress", "StartTrackEgress", VideoGrant{RoomRecord: true}, req, &out)
	return out, err
}

// StopEgress stops a recording; it ends with egress_ended.
func (c *Client) StopEgress(ctx context.Context, id string) (Egress, error) {
	var out Egress
	err := c.call(ctx, "Egress", "StopEgress", VideoGrant{RoomRecord: true}, map[string]any{"egress_id": id}, &out)
	return out, err
}

// ListEgress returns the recordings of a room (active ones only, if asked).
func (c *Client) ListEgress(ctx context.Context, room string, active bool) ([]Egress, error) {
	var out struct {
		Items []Egress `json:"items"`
	}
	err := c.call(ctx, "Egress", "ListEgress", VideoGrant{RoomRecord: true}, map[string]any{"room_name": room, "active": active}, &out)
	return out.Items, err
}
