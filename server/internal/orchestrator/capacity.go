package orchestrator

import (
	"fmt"
	"sync"
)

// MemoryBudget is a Capacity for one server: runs reserve their memory
// limit (not what they use now, which grows during a build) from a budget,
// and are held back while the host has less memory available than the
// run's limit or less free disk than the floor.
type MemoryBudget struct {
	// BudgetMB is what all runs together may reserve; 0 does not limit.
	BudgetMB int64
	// DefaultMB and MaxMB are a run's memory without and with a
	// repository's setting (capped at MaxMB).
	DefaultMB, MaxMB int64
	// MinFreeDiskMB holds runs back while the data disk has less free.
	MinFreeDiskMB int64
	// Available returns the host's available memory in MB (ok false when
	// unknown); DiskFree the data disk's free space in MB.
	Available func() (int64, bool)
	DiskFree  func() (int64, bool)

	mu       sync.Mutex
	reserved int64
	runs     int
	full     bool
}

var _ Capacity = (*MemoryBudget)(nil)

// RunMemory implements Capacity.
func (b *MemoryBudget) RunMemory(repoMB int) int64 {
	if repoMB <= 0 {
		return b.DefaultMB
	}
	return min(int64(repoMB), max(b.MaxMB, b.DefaultMB))
}

// Reserve implements Capacity.
func (b *MemoryBudget) Reserve(mb int64) (func(), bool, string) {
	b.mu.Lock()
	defer b.mu.Unlock()
	if why := b.short(mb); why != "" {
		b.full = true
		return nil, false, why
	}
	b.full = false
	b.reserved += mb
	b.runs++
	var once sync.Once
	return func() {
		once.Do(func() {
			b.mu.Lock()
			b.reserved -= mb
			b.runs--
			b.mu.Unlock()
		})
	}, true, ""
}

// short says what the server lacks for a run of mb, "" when it fits.
// Call it with b.mu held.
func (b *MemoryBudget) short(mb int64) string {
	if b.BudgetMB > 0 && b.reserved+mb > b.BudgetMB {
		return fmt.Sprintf("the server is at capacity (%d runs, %s of %s reserved; this run needs %s)",
			b.runs, gb(b.reserved), gb(b.BudgetMB), gb(mb))
	}
	if b.Available != nil {
		if avail, ok := b.Available(); ok && avail < mb {
			return fmt.Sprintf("the server has %s of memory available; this run needs %s", gb(avail), gb(mb))
		}
	}
	if b.DiskFree != nil && b.MinFreeDiskMB > 0 {
		if free, ok := b.DiskFree(); ok && free < b.MinFreeDiskMB {
			return fmt.Sprintf("the server's disk has %s free, below the %s it keeps", gb(free), gb(b.MinFreeDiskMB))
		}
	}
	return ""
}

// Spare implements Capacity.
func (b *MemoryBudget) Spare(mb int64) bool {
	b.mu.Lock()
	defer b.mu.Unlock()
	return b.BudgetMB <= 0 || b.reserved+2*mb <= b.BudgetMB
}

// Status implements Capacity.
func (b *MemoryBudget) Status() CapacityStatus {
	b.mu.Lock()
	defer b.mu.Unlock()
	st := CapacityStatus{BudgetMB: b.BudgetMB, ReservedMB: b.reserved, Runs: b.runs, Full: b.full, DiskFreeMB: -1}
	if b.DiskFree != nil {
		if free, ok := b.DiskFree(); ok {
			st.DiskFreeMB = free
		}
	}
	return st
}

func gb(mb int64) string {
	if mb%1024 == 0 {
		return fmt.Sprintf("%d GB", mb/1024)
	}
	return fmt.Sprintf("%.1f GB", float64(mb)/1024)
}
