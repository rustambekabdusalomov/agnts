package livekit

import (
	"context"
	"errors"
	"os"
	"strings"
	"testing"
	"time"
)

// TestLiveServer runs the client against a real LiveKit server when
// AGNTS_TEST_LIVEKIT_URL is set (e.g. `livekit-server --dev`, whose keys
// are devkey / secret; AGNTS_TEST_LIVEKIT_KEYS=key:secret overrides).
func TestLiveServer(t *testing.T) {
	url := os.Getenv("AGNTS_TEST_LIVEKIT_URL")
	if url == "" {
		t.Skip("AGNTS_TEST_LIVEKIT_URL not set")
	}
	k := Keys{Key: "devkey", Secret: "secret"}
	if v := os.Getenv("AGNTS_TEST_LIVEKIT_KEYS"); v != "" {
		k.Key, k.Secret, _ = strings.Cut(v, ":")
	}
	c := NewClient(url, k)
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	name := "ws1-m1-s" + time.Now().Format("150405")

	room, err := c.CreateRoom(ctx, NewRoom{Name: name, EmptyTimeout: 60, DepartureTimeout: 120, MaxParticipants: 10, Metadata: `{"locked":false}`})
	if err != nil {
		t.Fatal(err)
	}
	if room.Name != name || room.SID == "" || room.CreationTime == 0 {
		t.Errorf("created %+v", room)
	}
	rooms, err := c.ListRooms(ctx, name)
	if err != nil || len(rooms) != 1 || rooms[0].Metadata != `{"locked":false}` {
		t.Fatalf("list rooms %+v %v", rooms, err)
	}
	if err := c.UpdateRoomMetadata(ctx, name, `{"locked":true}`); err != nil {
		t.Fatal(err)
	}
	ps, err := c.ListParticipants(ctx, name)
	if err != nil || len(ps) != 0 {
		t.Fatalf("participants %+v %v", ps, err)
	}
	// Nobody is there: a message to everyone still goes.
	if err := c.SendData(ctx, name, "chat", []byte(`{"body":"hi"}`)); err != nil {
		t.Errorf("send data: %v", err)
	}
	if err := c.RemoveParticipant(ctx, name, "u1-abcd"); !errors.Is(err, ErrNotFound) {
		t.Errorf("remove a missing participant: %v", err)
	}
	if err := c.DeleteRoom(ctx, name); err != nil {
		t.Fatal(err)
	}
	rooms, err = c.ListRooms(ctx, name)
	if err != nil || len(rooms) != 0 {
		t.Errorf("after delete %+v %v", rooms, err)
	}
}
