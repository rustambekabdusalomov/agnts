package runner

import (
	"bufio"
	"os"
	"strconv"
	"strings"
	"syscall"
)

// AvailableMemoryMB reads the host's available memory from /proc/meminfo
// (Linux; inside a container it still shows the host's). ok is false
// elsewhere.
func AvailableMemoryMB() (int64, bool) {
	f, err := os.Open("/proc/meminfo")
	if err != nil {
		return 0, false
	}
	defer func() { _ = f.Close() }()
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		rest, ok := strings.CutPrefix(sc.Text(), "MemAvailable:")
		if !ok {
			continue
		}
		fields := strings.Fields(rest)
		if len(fields) == 0 {
			return 0, false
		}
		kb, err := strconv.ParseInt(fields[0], 10, 64)
		if err != nil {
			return 0, false
		}
		return kb / 1024, true
	}
	return 0, false
}

// DiskFreeMB returns the free space of the disk dir is on.
func DiskFreeMB(dir string) (int64, bool) {
	var st syscall.Statfs_t
	if err := syscall.Statfs(dir, &st); err != nil {
		return 0, false
	}
	return int64(st.Bavail * uint64(st.Bsize) / (1 << 20)), true //nolint:gosec // G115: sizes fit
}
