package orchestrator

import (
	"context"
	"encoding/binary"
	"errors"
	"fmt"
	"strings"

	"agnts/internal/ai"
	"agnts/internal/domain"
)

// Voice: a person may speak a question instead of typing it. Muse Code
// hears the clip (`muse voice transcribe`, on the account the person's
// answers run on) and the panel asks the words as it asks typed ones.

// ErrNoSpeech says a clip had no words in it.
var ErrNoSpeech = ai.ErrNoSpeech

// VoiceReady reports whether spoken questions can be heard.
func (o *Orchestrator) VoiceReady() bool { return o.AssistantReady() && o.ai.CanHear() }

// Transcribe returns the words of a spoken question (16-bit PCM WAV, at
// most domain.AssistantMaxVoice long), heard on the account the person's
// answers run on. One clip at a time per person.
func (o *Orchestrator) Transcribe(ctx context.Context, wav []byte) (string, error) {
	if !o.VoiceReady() {
		return "", invalid("spoken questions are not available")
	}
	ws, user, err := asker(ctx)
	if err != nil {
		return "", err
	}
	if err := checkWAV(wav); err != nil {
		return "", err
	}
	lock := o.personLock("voice/" + personKey(ws, user))
	if !lock.TryLock() {
		return "", invalid("a recording is still being heard; wait for it")
	}
	defer lock.Unlock()
	s, err := o.settings.Get(ctx)
	if err != nil {
		return "", err
	}
	if err = o.assistantReady(ctx, s, user); err != nil {
		var ae *assistantError
		if errors.As(err, &ae) {
			return "", invalid("%s", strings.Replace(ae.msg, "The assistant", "Voice", 1))
		}
		return "", err
	}
	text, err := o.ai.HearClip(ctx, ai.Who{Person: user}, wav)
	if err != nil {
		if errors.Is(err, ErrNoSpeech) {
			return "", fmt.Errorf("%w: %w", ErrInvalid, err)
		}
		return "", fmt.Errorf("transcribe: %w", err)
	}
	return text, nil
}

// checkWAV checks that b is a WAV clip of 16-bit PCM Muse can read without
// ffmpeg, and no longer than the assistant takes.
func checkWAV(b []byte) error {
	if len(b) == 0 {
		return invalid("the recording is empty")
	}
	if len(b) < 44 || string(b[0:4]) != "RIFF" || string(b[8:12]) != "WAVE" {
		return invalid("the recording is not a WAV file")
	}
	// Walk the chunks for "fmt " and "data".
	var rate, bytesPerSec uint32
	var format, bits uint16
	data := -1
	for p := 12; p+8 <= len(b); {
		id, size := string(b[p:p+4]), int(binary.LittleEndian.Uint32(b[p+4:p+8]))
		body := b[p+8:]
		switch id {
		case "fmt ":
			if size < 16 || len(body) < 16 {
				return invalid("the recording is not a WAV file")
			}
			format, rate = binary.LittleEndian.Uint16(body[0:2]), binary.LittleEndian.Uint32(body[4:8])
			bytesPerSec, bits = binary.LittleEndian.Uint32(body[8:12]), binary.LittleEndian.Uint16(body[14:16])
		case "data":
			data = min(size, len(body))
		}
		if data >= 0 {
			break
		}
		p += 8 + size + size%2
	}
	switch {
	case format != 1 || bits != 16 || rate == 0 || bytesPerSec == 0:
		return invalid("the recording must be 16-bit PCM WAV")
	case data <= 0:
		return invalid("the recording is empty")
	case float64(data)/float64(bytesPerSec) > domain.AssistantMaxVoice.Seconds()+1:
		return invalid("a spoken question is at most %d seconds", int(domain.AssistantMaxVoice.Seconds()))
	}
	return nil
}
