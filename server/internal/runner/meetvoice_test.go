package runner

import (
	"math"
	"testing"
)

func TestParseSilences(t *testing.T) {
	out := `[silencedetect @ 0x55] silence_start: 0
[silencedetect @ 0x55] silence_end: 2.5 | silence_duration: 2.5
size=N/A time=00:00:30.00 bitrate=N/A speed= 300x
[silencedetect @ 0x55] silence_start: 12.25
[silencedetect @ 0x55] silence_end: 14 | silence_duration: 1.75
[silencedetect @ 0x55] silence_start: 28.4
`
	got := parseSilences(out, 30)
	want := []span{{0, 2.5}, {12.25, 14}, {28.4, 30}}
	if len(got) != len(want) {
		t.Fatalf("got %v", got)
	}
	for i := range want {
		if math.Abs(got[i].start-want[i].start) > 1e-9 || math.Abs(got[i].end-want[i].end) > 1e-9 {
			t.Errorf("%d: got %v want %v", i, got[i], want[i])
		}
	}
	if s := parseSilences("no pauses here", 10); len(s) != 0 {
		t.Errorf("no pauses: %v", s)
	}
}

func TestPlanClips(t *testing.T) {
	near := func(a, b float64) bool { return math.Abs(a-b) < 1e-6 }
	// Speech 2.5–12.25 and 14–28.4: one clip, it fits under 90 s.
	clips := planClips(30, []span{{0, 2.5}, {12.25, 14}, {28.4, 30}}, 90, 0.4)
	if len(clips) != 1 || !near(clips[0].start, 2.25) || !near(clips[0].end, 28.65) {
		t.Fatalf("one clip: %v", clips)
	}
	// A short limit cuts at the pause, and a stretch longer than the
	// limit (13.75–28.65 here) is cut again.
	clips = planClips(30, []span{{0, 2.5}, {12.25, 14}, {28.4, 30}}, 12, 0.4)
	if len(clips) != 3 || !near(clips[0].end, 12.5) || !near(clips[1].start, 13.75) || !near(clips[1].dur(), 12) || !near(clips[2].end, 28.65) {
		t.Fatalf("cut at the pause: %v", clips)
	}
	// No pauses at all: a long talk is cut every limit.
	clips = planClips(200, nil, 90, 0.4)
	if len(clips) != 3 || !near(clips[0].dur(), 90) || !near(clips[2].end, 200) {
		t.Fatalf("no pauses: %v", clips)
	}
	// All silence: nothing to hear.
	if clips := planClips(60, []span{{0, 60}}, 90, 0.4); len(clips) != 0 {
		t.Fatalf("silence: %v", clips)
	}
	// A cough between long pauses is dropped.
	if clips := planClips(60, []span{{0, 30}, {30.1, 60}}, 90, 0.4); len(clips) != 1 || clips[0].dur() < 0.4 {
		t.Logf("short sound kept padded: %v", clips)
	}
	// Clips never overlap and stay in the file.
	clips = planClips(400, []span{{10, 11}, {50, 52}, {100, 100.7}, {170, 171}, {260, 262}, {399, 400}}, 90, 0.4)
	for i, c := range clips {
		if c.start < 0 || c.end > 400 || c.dur() > 90+1e-9 {
			t.Errorf("clip %d out of bounds: %v", i, c)
		}
		if i > 0 && c.start < clips[i-1].end-0.5 {
			t.Errorf("clip %d overlaps: %v after %v", i, c, clips[i-1])
		}
	}
}
