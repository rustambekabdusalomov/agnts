package notify

import (
	"context"
	"errors"

	"agnts/internal/domain"
	"agnts/internal/meetings"
)

// MeetingPush sends a meeting's push to some members' phones: invitations,
// reminders, someone ringing, a knock while the host is away, notes ready.
// Tapping it opens the meeting (/m/<code>) in the app.
func (n *Notifier) MeetingPush(ctx context.Context, users []int64, p meetings.Push) {
	if n.fcm == nil || len(users) == 0 {
		return
	}
	ws := domain.WorkspaceOf(ctx)
	if s, err := n.settings.Get(ctx); err == nil && !s.Notify.Push {
		return
	}
	devs, err := n.store.UserDevices(ctx, ws, users)
	if err != nil {
		n.log.Warn("meeting push: devices", "err", err)
		return
	}
	push := Push{Title: p.Title, Body: p.Body, Route: "/m/" + domain.FormatMeetingCode(p.Code), Workspace: ws, Tag: p.Tag}
	for _, d := range devs {
		err := n.fcm.Send(ctx, d.FCMToken, push)
		switch {
		case errors.Is(err, ErrUnregistered):
			_ = n.store.DeleteDevice(ctx, d.FCMToken)
		case err != nil:
			n.log.Warn("meeting push", "device", d.ID, "err", err)
		}
	}
}

// PlatformAlert sends a message about the server itself (not a ticket) to
// workspace ws's Telegram chat, whatever its notification settings say:
// the platform's Admin chose that chat for such alerts.
func (n *Notifier) PlatformAlert(ctx context.Context, ws int64, text string) error {
	if ws <= 0 {
		return errors.New("no workspace chosen for platform alerts (AGNTS_ALERT_WORKSPACE)")
	}
	b, cfg, ok := n.bot(domain.WithWorkspace(domain.System(ctx), ws))
	if !ok {
		return errors.New("the alert workspace has no Telegram chat connected")
	}
	_, err := b.Send(ctx, cfg.ChatID, text, nil, false)
	return err
}
