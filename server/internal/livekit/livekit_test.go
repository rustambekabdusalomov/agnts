package livekit

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

var keys = Keys{Key: "APIkey", Secret: "secret-of-at-least-32-characters-long"}

func TestJoinToken(t *testing.T) {
	now := time.Unix(1_800_000_000, 0)
	tok, err := keys.JoinToken(Join{Room: "ws1-m2-s3", Identity: "u7-abcd", Name: "Rustam", Attributes: map[string]string{"agnts.role": "host"},
		Sources: []string{SourceCamera, SourceMicrophone}, Data: true}, now)
	if err != nil {
		t.Fatal(err)
	}
	c, err := keys.verify(tok, now)
	if err != nil {
		t.Fatal(err)
	}
	if c.Issuer != "APIkey" || c.Subject != "u7-abcd" || c.Name != "Rustam" || c.Attributes["agnts.role"] != "host" {
		t.Errorf("claims %+v", c)
	}
	v := c.Video
	if !v.RoomJoin || v.Room != "ws1-m2-s3" || !*v.CanPublish || !*v.CanSubscribe || !*v.CanPublishData || len(v.CanPublishSources) != 2 || v.RoomAdmin {
		t.Errorf("grant %+v", v)
	}
	if c.Expires-now.Unix() != int64(defaultClientTokenValid.Seconds()) {
		t.Errorf("expires in %d s", c.Expires-now.Unix())
	}
	// The grant uses LiveKit's claim names.
	body, _ := base64.RawURLEncoding.DecodeString(strings.Split(tok, ".")[1])
	for _, want := range []string{`"roomJoin":true`, `"canPublishSources":["camera","microphone"]`, `"sub":"u7-abcd"`} {
		if !strings.Contains(string(body), want) {
			t.Errorf("token body %s lacks %s", body, want)
		}
	}

	// Nothing to publish: canPublish false.
	tok, _ = keys.JoinToken(Join{Room: "r", Identity: "g1-abcd"}, now)
	c, _ = keys.verify(tok, now)
	if *c.Video.CanPublish || *c.Video.CanPublishData {
		t.Errorf("a listener may publish: %+v", c.Video)
	}

	if _, err := keys.verify(tok, now.Add(time.Hour)); !errors.Is(err, ErrBadToken) {
		t.Errorf("expired token: %v", err)
	}
	if _, err := (Keys{Key: "APIkey", Secret: "another-secret-of-32-characters!!"}).verify(tok, now); !errors.Is(err, ErrBadToken) {
		t.Errorf("wrong secret: %v", err)
	}
	if _, err := (Keys{Key: "other", Secret: keys.Secret}).verify(tok, now); !errors.Is(err, ErrBadToken) {
		t.Errorf("other key: %v", err)
	}
	if _, err := keys.JoinToken(Join{Room: "r"}, now); err == nil {
		t.Error("a token without identity")
	}
}

func TestReadWebhook(t *testing.T) {
	now := time.Unix(1_800_000_000, 0)
	// LiveKit writes camelCase field names and int64s as strings.
	body := []byte(`{"event":"participant_joined","id":"EV_1","createdAt":"1800000000",
		"room":{"sid":"RM_1","name":"ws1-m2-s3","numParticipants":2},
		"participant":{"sid":"PA_1","identity":"u7-abcd","name":"Rustam","joinedAt":"1799999990","attributes":{"agnts.role":"host"},
			"tracks":[{"sid":"TR_1","type":"AUDIO","source":"MICROPHONE"}]}}`)
	auth, err := keys.SignWebhook(body, now)
	if err != nil {
		t.Fatal(err)
	}
	e, err := keys.ReadWebhook(auth, body, now)
	if err != nil {
		t.Fatal(err)
	}
	if e.Event != EventParticipantJoined || e.ID != "EV_1" || e.RoomName() != "ws1-m2-s3" || e.Room.NumParticipants != 2 {
		t.Errorf("event %+v", e)
	}
	p := e.Participant
	if p.Identity != "u7-abcd" || p.JoinedAt != 1_799_999_990 || p.Attributes["agnts.role"] != "host" || !p.Tracks[0].IsMicrophone() || !p.Tracks[0].IsAudio() {
		t.Errorf("participant %+v", p)
	}
	if !e.At(now).Equal(now) {
		t.Errorf("at %s", e.At(now))
	}

	// "Bearer " is accepted too.
	if _, err := keys.ReadWebhook("Bearer "+auth, body, now); err != nil {
		t.Errorf("bearer: %v", err)
	}
	changed := append([]byte{}, body...)
	changed[10] = 'X'
	if _, err := keys.ReadWebhook(auth, changed, now); !errors.Is(err, ErrBadWebhook) {
		t.Errorf("changed body: %v", err)
	}
	other := Keys{Key: "APIkey", Secret: "another-secret-of-32-characters!!"}
	if _, err := other.ReadWebhook(auth, body, now); !errors.Is(err, ErrBadWebhook) {
		t.Errorf("wrong secret: %v", err)
	}
	if _, err := keys.ReadWebhook("", body, now); !errors.Is(err, ErrBadWebhook) {
		t.Errorf("no header: %v", err)
	}
	later := now.Add(time.Hour)
	auth2, _ := keys.SignWebhook(body, later)
	if _, err := keys.ReadWebhook(auth2, body, later); !errors.Is(err, ErrBadWebhook) {
		t.Errorf("an hour-old event: %v", err)
	}

	// Numbers for enums and snake_case keys, as other versions write.
	body = []byte(`{"event":"egress_ended","id":"EV_2","egress_info":{"egress_id":"EG_1","room_name":"ws1-m2-s3","status":3,
		"file_results":[{"filename":"/m/a.ogg","size":"1234","started_at":"5","ended_at":"6"}]}}`)
	auth, _ = keys.SignWebhook(body, now)
	e, err = keys.ReadWebhook(auth, body, now)
	if err != nil {
		t.Fatal(err)
	}
	done, failed := e.Egress.Done()
	f, ok := e.Egress.Result()
	if !done || failed || !ok || f.Size != 1234 || e.RoomName() != "ws1-m2-s3" {
		t.Errorf("egress %+v", e.Egress)
	}
}

func TestClient(t *testing.T) {
	var got []string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		auth := strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer ")
		c, err := keys.verify(auth, time.Now())
		if err != nil {
			w.WriteHeader(http.StatusUnauthorized)
			_, _ = w.Write([]byte(`{"code":"unauthenticated","msg":"bad token"}`))
			return
		}
		body, _ := io.ReadAll(r.Body)
		got = append(got, r.URL.Path+" "+string(body))
		switch r.URL.Path {
		case "/twirp/livekit.RoomService/ListParticipants":
			if !c.Video.RoomAdmin || c.Video.Room != "ws1-m2-s3" {
				t.Errorf("list participants grant %+v", c.Video)
			}
			_, _ = w.Write([]byte(`{"participants":[{"identity":"u7-abcd","tracks":[{"sid":"TR_1","source":"MICROPHONE","type":"AUDIO"},{"sid":"TR_2","source":"CAMERA","type":"VIDEO"}],"joinedAt":"17"}]}`))
		case "/twirp/livekit.RoomService/DeleteRoom":
			w.WriteHeader(http.StatusNotFound)
			_, _ = w.Write([]byte(`{"code":"not_found","msg":"room not found"}`))
		case "/twirp/livekit.Egress/StartRoomCompositeEgress":
			if !c.Video.RoomRecord {
				t.Errorf("egress grant %+v", c.Video)
			}
			_, _ = w.Write([]byte(`{"egressId":"EG_9","roomName":"ws1-m2-s3","status":"EGRESS_STARTING","startedAt":"100"}`))
		default:
			_, _ = w.Write([]byte(`{}`))
		}
	}))
	defer srv.Close()
	c := NewClient(strings.Replace(srv.URL, "http://", "ws://", 1), keys)
	ctx := context.Background()

	ps, err := c.ListParticipants(ctx, "ws1-m2-s3")
	if err != nil {
		t.Fatal(err)
	}
	if len(ps) != 1 || ps[0].JoinedAt != 17 || !ps[0].Tracks[0].IsMicrophone() || !ps[0].Tracks[1].IsCamera() {
		t.Errorf("participants %+v", ps)
	}
	if err := c.DeleteRoom(ctx, "gone"); !errors.Is(err, ErrNotFound) {
		t.Errorf("delete a missing room: %v", err)
	}
	eg, err := c.StartRoomRecording(ctx, RoomRecording{Room: "ws1-m2-s3", AudioOnly: true, FileType: "OGG", Path: "/out/a.ogg"})
	if err != nil || eg.EgressID != "EG_9" || eg.StartedAt != 100 {
		t.Errorf("egress %+v %v", eg, err)
	}
	if err := c.SendData(ctx, "ws1-m2-s3", "chat", []byte(`{"x":1}`), "u7-abcd"); err != nil {
		t.Fatal(err)
	}
	if err := c.UpdateParticipant(ctx, "ws1-m2-s3", "g1-abcd", &Permission{Sources: []string{SourceMicrophone}}, map[string]string{"agnts.role": "cohost"}); err != nil {
		t.Fatal(err)
	}
	last := func(prefix string) map[string]any {
		for i := len(got) - 1; i >= 0; i-- {
			if strings.HasPrefix(got[i], prefix) {
				var m map[string]any
				_ = json.Unmarshal([]byte(strings.SplitN(got[i], " ", 2)[1]), &m)
				return m
			}
		}
		t.Fatalf("no call to %s", prefix)
		return nil
	}
	sd := last("/twirp/livekit.RoomService/SendData")
	if sd["topic"] != "chat" || sd["data"] != base64.StdEncoding.EncodeToString([]byte(`{"x":1}`)) || sd["kind"] != "RELIABLE" {
		t.Errorf("send data %v", sd)
	}
	up := last("/twirp/livekit.RoomService/UpdateParticipant")
	perm := up["permission"].(map[string]any)
	if perm["can_publish"] != true || perm["can_publish_sources"].([]any)[0] != "MICROPHONE" || perm["can_publish_data"] != false {
		t.Errorf("update participant %v", up)
	}

	bad := NewClient(srv.URL, Keys{Key: "APIkey", Secret: "another-secret-of-32-characters!!"})
	var api *APIError
	if _, err := bad.ListRooms(ctx); !errors.As(err, &api) || api.Code != "unauthenticated" {
		t.Errorf("bad keys: %v", err)
	}
}
