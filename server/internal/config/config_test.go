package config

import (
	"strings"
	"testing"
	"time"
)

func env(m map[string]string) func(string) (string, bool) {
	return func(k string) (string, bool) { v, ok := m[k]; return v, ok }
}

const testKey = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" // 32 zero bytes

func TestLoadDefaults(t *testing.T) {
	c, err := load(env(map[string]string{
		"AGNTS_DATABASE_URL": "postgres://localhost/hiro",
		"AGNTS_ENC_KEY":      testKey,
	}))
	if err != nil {
		t.Fatal(err)
	}
	if c.Addr != ":8080" || c.SessionTTL != 720*time.Hour || !c.CookieSecure || !c.AutoMigrate {
		t.Fatalf("unexpected defaults: %+v", c)
	}
	if len(c.EncKey) != 32 {
		t.Fatalf("key length %d", len(c.EncKey))
	}
}

func TestLoadReportsEveryProblem(t *testing.T) {
	_, err := load(env(map[string]string{
		"AGNTS_ENC_KEY":    "short",
		"AGNTS_LOG_LEVEL":  "loud",
		"AGNTS_PUBLIC_URL": "not a url",
	}))
	if err == nil {
		t.Fatal("expected error")
	}
	for _, want := range []string{"AGNTS_DATABASE_URL", "AGNTS_ENC_KEY", "AGNTS_LOG_LEVEL", "AGNTS_PUBLIC_URL"} {
		if !strings.Contains(err.Error(), want) {
			t.Errorf("error does not mention %s: %v", want, err)
		}
	}
}

// PostgreSQL rejects Go's "Local" zone (AT TIME ZONE 'Local'), so the
// default must resolve to a real IANA name.
func TestTimeZoneIsNeverLocal(t *testing.T) {
	for _, tz := range []string{"", "Local"} {
		t.Setenv("TZ", "Asia/Tashkent")
		c, err := load(env(map[string]string{"AGNTS_DATABASE_URL": "postgres://localhost/hiro", "AGNTS_ENC_KEY": testKey, "AGNTS_TZ": tz}))
		if err != nil {
			t.Fatal(err)
		}
		if got := c.TimeZone.String(); got != "Asia/Tashkent" {
			t.Errorf("AGNTS_TZ=%q: zone %q", tz, got)
		}
	}
	t.Setenv("TZ", "")
	if name := localZoneName(); name == "" || name == "Local" {
		t.Errorf("machine zone %q", name)
	}
	c, err := load(env(map[string]string{"AGNTS_DATABASE_URL": "postgres://localhost/hiro", "AGNTS_ENC_KEY": testKey, "AGNTS_TZ": "Europe/Berlin"}))
	if err != nil || c.TimeZone.String() != "Europe/Berlin" {
		t.Fatalf("explicit zone: %v %v", c.TimeZone, err)
	}
}
