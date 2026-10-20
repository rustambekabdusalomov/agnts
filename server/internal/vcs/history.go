package vcs

import (
	"context"

	"agnts/internal/domain"
)

// HistoryReader reads commits with their full messages, for linking them
// to tickets.
type HistoryReader interface {
	// BranchNames lists up to max of the repository's branch names.
	BranchNames(ctx context.Context, repo domain.Repository, max int) ([]string, error)
	// History returns one page (from 1) of ref's history, newest first.
	History(ctx context.Context, repo domain.Repository, ref string, page, perPage int) ([]domain.PushedCommit, error)
	// Ahead returns the commits head has that base lacks, oldest first;
	// the hosts give up to 250.
	Ahead(ctx context.Context, repo domain.Repository, base, head string) ([]domain.PushedCommit, error)
}

func (m *Multi) history(repo domain.Repository) (HistoryReader, error) {
	p, err := m.pick(repo)
	if err != nil {
		return nil, err
	}
	h, ok := p.(HistoryReader)
	if !ok {
		return nil, ErrUnsupported
	}
	return h, nil
}

// BranchNames implements HistoryReader.
func (m *Multi) BranchNames(ctx context.Context, repo domain.Repository, max int) ([]string, error) {
	h, err := m.history(repo)
	if err != nil {
		return nil, err
	}
	return h.BranchNames(ctx, repo, max)
}

// History implements HistoryReader.
func (m *Multi) History(ctx context.Context, repo domain.Repository, ref string, page, perPage int) ([]domain.PushedCommit, error) {
	h, err := m.history(repo)
	if err != nil {
		return nil, err
	}
	return h.History(ctx, repo, ref, page, perPage)
}

// Ahead implements HistoryReader.
func (m *Multi) Ahead(ctx context.Context, repo domain.Repository, base, head string) ([]domain.PushedCommit, error) {
	h, err := m.history(repo)
	if err != nil {
		return nil, err
	}
	return h.Ahead(ctx, repo, base, head)
}
