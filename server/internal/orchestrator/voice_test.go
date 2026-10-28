package orchestrator_test

import (
	"context"
	"encoding/binary"
	"errors"
	"strings"
	"sync"
	"testing"

	"agnts/internal/orchestrator"
)

type fakeEars struct {
	mu     sync.Mutex
	clips  int
	text   string
	err    error
	block  chan struct{} // when set, a clip waits for it
	inside chan struct{}
}

func (f *fakeEars) Transcribe(_ context.Context, _ string, _ []byte) (string, error) {
	f.mu.Lock()
	f.clips++
	f.mu.Unlock()
	if f.block != nil {
		f.inside <- struct{}{}
		<-f.block
	}
	return f.text, f.err
}

// wav is a 16 kHz mono 16-bit PCM clip of the given seconds of silence.
func wav(seconds float64, format, bits uint16) []byte {
	const rate = 16000
	n := int(seconds * rate * 2)
	b := make([]byte, 44+n)
	copy(b[0:], "RIFF")
	binary.LittleEndian.PutUint32(b[4:], uint32(36+n))
	copy(b[8:], "WAVEfmt ")
	binary.LittleEndian.PutUint32(b[16:], 16)
	binary.LittleEndian.PutUint16(b[20:], format)
	binary.LittleEndian.PutUint16(b[22:], 1)
	binary.LittleEndian.PutUint32(b[24:], rate)
	binary.LittleEndian.PutUint32(b[28:], rate*uint32(bits/8))
	binary.LittleEndian.PutUint16(b[32:], bits/8)
	binary.LittleEndian.PutUint16(b[34:], bits)
	copy(b[36:], "data")
	binary.LittleEndian.PutUint32(b[40:], uint32(n))
	return b
}

func TestTranscribeChecksTheClip(t *testing.T) {
	a := newAssistantHarness(t)
	ears := &fakeEars{text: "What waits on me?"}
	if _, err := a.o.Transcribe(a.ask, wav(1, 1, 16)); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("without a transcriber: %v", err)
	}
	a.o.SetTranscriber(ears)

	for _, c := range []struct {
		name string
		clip []byte
		want string
	}{
		{"empty", nil, "empty"},
		{"not wav", []byte(strings.Repeat("ID3", 20)), "not a WAV"},
		{"float", wav(1, 3, 32), "16-bit PCM"},
		{"8-bit", wav(1, 1, 8), "16-bit PCM"},
		{"no samples", wav(0, 1, 16), "empty"},
		{"too long", wav(125, 1, 16), "at most 120 seconds"},
	} {
		if _, err := a.o.Transcribe(a.ask, c.clip); !errors.Is(err, orchestrator.ErrInvalid) || !strings.Contains(err.Error(), c.want) {
			t.Errorf("%s: %v", c.name, err)
		}
	}
	if _, err := a.o.Transcribe(a.ctx, wav(1, 1, 16)); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Errorf("no person: %v", err)
	}
	if ears.clips != 0 {
		t.Fatalf("muse heard %d bad clips", ears.clips)
	}

	got, err := a.o.Transcribe(a.ask, wav(2, 1, 16))
	if err != nil || got != "What waits on me?" {
		t.Fatalf("heard %q, %v", got, err)
	}

	ears.text, ears.err = "", orchestrator.ErrNoSpeech
	if _, err := a.o.Transcribe(a.ask, wav(2, 1, 16)); !errors.Is(err, orchestrator.ErrInvalid) || !errors.Is(err, orchestrator.ErrNoSpeech) {
		t.Fatalf("silence: %v", err)
	}
	ears.err = errors.New("the Muse speech service failed")
	if _, err := a.o.Transcribe(a.ask, wav(2, 1, 16)); err == nil || errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("service failure is not the person's: %v", err)
	}
}

func TestTranscribeOneClipAtATime(t *testing.T) {
	a := newAssistantHarness(t)
	ears := &fakeEars{text: "hi", block: make(chan struct{}), inside: make(chan struct{})}
	a.o.SetTranscriber(ears)
	done := make(chan error, 1)
	go func() {
		_, err := a.o.Transcribe(a.ask, wav(1, 1, 16))
		done <- err
	}()
	<-ears.inside
	if _, err := a.o.Transcribe(a.ask, wav(1, 1, 16)); !errors.Is(err, orchestrator.ErrInvalid) || !strings.Contains(err.Error(), "still being heard") {
		t.Fatalf("second clip: %v", err)
	}
	close(ears.block)
	if err := <-done; err != nil {
		t.Fatal(err)
	}
	ears.block = nil
	for _, ctx := range []context.Context{a.ask, a.other} {
		if _, err := a.o.Transcribe(ctx, wav(1, 1, 16)); err != nil {
			t.Fatalf("after the first: %v", err)
		}
	}
}
