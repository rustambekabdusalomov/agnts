package notify

import (
	"context"
	"crypto/subtle"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"

	"hiro/internal/domain"
	"hiro/internal/store/postgres"
)

func jsonUnmarshal(b []byte, v any) error { return json.Unmarshal(b, v) }

// confirmTTL is how long an Approve or Reject waits for its confirmation.
const confirmTTL = 10 * time.Minute

// WebhookHandler receives Telegram updates at /webhooks/telegram. Only the
// configured chat can act; Approve and Reject need a second tap to confirm.
func (n *Notifier) WebhookHandler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		if r.Method != http.MethodPost {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}
		cfg, ok, err := n.telegram(ctx)
		if err != nil || !ok || cfg.WebhookSecret == "" {
			w.WriteHeader(http.StatusServiceUnavailable)
			return
		}
		got := r.Header.Get("X-Telegram-Bot-Api-Secret-Token")
		if subtle.ConstantTimeCompare([]byte(got), []byte(cfg.WebhookSecret)) != 1 {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		var u Update
		if err := json.NewDecoder(io.LimitReader(r.Body, 1<<20)).Decode(&u); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		if seen, err := n.store.SeenDelivery(ctx, "telegram", strconv.FormatInt(u.UpdateID, 10)); err != nil || seen {
			w.WriteHeader(http.StatusOK)
			return
		}
		// Always 200: Telegram would otherwise retry an update we chose to ignore.
		w.WriteHeader(http.StatusOK)
		n.handleUpdate(context.WithoutCancel(ctx), cfg, u)
	})
}

func (n *Notifier) handleUpdate(ctx context.Context, cfg TelegramConfig, u Update) {
	b := NewBot(n.botAPI, cfg.BotToken)
	var chat int64
	switch {
	case u.Callback != nil && u.Callback.Message != nil:
		chat = u.Callback.Message.Chat.ID
	case u.Message != nil:
		chat = u.Message.Chat.ID
	default:
		return
	}
	if chat != cfg.ChatID {
		// Strangers learn their chat id (to set up their own hiro) and nothing else.
		if u.Message != nil && strings.HasPrefix(u.Message.Text, "/start") {
			_, _ = b.Send(ctx, chat, "This hiro bot belongs to someone else. Your chat id is "+strconv.FormatInt(chat, 10)+".", nil, false)
		}
		n.log.Warn("telegram: message from an unknown chat ignored", "chat", chat)
		return
	}
	if u.Callback != nil {
		note := n.handleCallback(ctx, b, cfg, u.Callback.Message, u.Callback.Data)
		_ = b.AnswerCallback(ctx, u.Callback.ID, note)
		return
	}
	n.handleText(ctx, b, cfg, u.Message)
}

func (n *Notifier) say(ctx context.Context, b *Bot, cfg TelegramConfig, text string) {
	if _, err := b.Send(ctx, cfg.ChatID, text, nil, false); err != nil {
		n.log.Warn("telegram send", "err", err)
	}
}

// handleCallback runs a button press and returns a short toast text.
func (n *Notifier) handleCallback(ctx context.Context, b *Bot, cfg TelegramConfig, msg *Message, data string) string {
	verb, arg, _ := strings.Cut(data, ":")
	switch verb {
	case "ans": // ans:<question id>:<option index>
		qs, idx, _ := strings.Cut(arg, ":")
		qid, err1 := strconv.ParseInt(qs, 10, 64)
		i, err2 := strconv.Atoi(idx)
		m, err3 := n.store.TelegramMessage(ctx, cfg.ChatID, msg.MessageID)
		if err1 != nil || err2 != nil || err3 != nil {
			return "This question is no longer open."
		}
		v, err := n.actions.View(ctx, m.TicketKey)
		if err != nil {
			return "This ticket is gone."
		}
		for _, q := range v.Questions {
			if q.ID == qid && i >= 0 && i < len(q.Options) {
				return n.answer(ctx, b, cfg, msg, m.TicketKey, qid, q.Options[i])
			}
		}
		return "This question is no longer open."
	case "apr", "rej":
		tool, what := "approve", "Approve and push "+arg+"? hiro pushes the branch and opens the pull request."
		if verb == "rej" {
			tool, what = "reject", "Reject "+arg+"? This stops all work on it."
		}
		id := newID()
		if err := n.store.CreatePending(ctx, postgres.PendingAction{ID: id, Origin: domain.OriginTelegram, Tool: tool, TicketKey: arg,
			Summary: what, ExpiresAt: time.Now().Add(confirmTTL)}); err != nil {
			return "Something went wrong."
		}
		mid, err := b.Send(ctx, cfg.ChatID, what+"\n\nConfirm within 10 minutes.", [][]Button{
			{{Text: "Confirm", Data: "ok:" + id}, {Text: "Cancel", Data: "no:" + id}},
		}, false)
		if err == nil {
			_ = n.store.SaveTelegramMessage(ctx, postgres.TelegramMessage{ChatID: cfg.ChatID, MessageID: mid, TicketKey: arg, Kind: "confirm"})
		}
		return ""
	case "ok":
		_ = b.ClearButtons(ctx, cfg.ChatID, msg.MessageID)
		a, err := n.store.ConfirmPending(ctx, arg, domain.OriginTelegram)
		if errors.Is(err, postgres.ErrExpired) {
			n.say(ctx, b, cfg, "That confirmation expired. Tap the button on the review message again.")
			return "Expired"
		}
		if err != nil {
			return "Something went wrong."
		}
		switch a.Tool {
		case "approve":
			_, err = n.actions.Approve(ctx, a.TicketKey, nil, domain.OriginTelegram)
		case "reject":
			_, err = n.actions.Reject(ctx, a.TicketKey, "rejected from Telegram", domain.OriginTelegram)
		}
		if err != nil {
			n.say(ctx, b, cfg, a.TicketKey+": "+friendly(err))
			return "Not done"
		}
		if a.Tool == "approve" {
			n.say(ctx, b, cfg, a.TicketKey+" approved. hiro is pushing it now.")
		} else {
			n.say(ctx, b, cfg, a.TicketKey+" rejected.")
		}
		return "Done"
	case "no":
		_ = b.ClearButtons(ctx, cfg.ChatID, msg.MessageID)
		_ = n.store.CancelPending(ctx, arg)
		return "Cancelled"
	case "chg":
		mid, err := b.Send(ctx, cfg.ChatID, "Reply to this message with what should change in "+arg+".", nil, true)
		if err == nil {
			_ = n.store.SaveTelegramMessage(ctx, postgres.TelegramMessage{ChatID: cfg.ChatID, MessageID: mid, TicketKey: arg, Kind: "feedback"})
		}
		return ""
	case "rty":
		if _, err := n.actions.Retry(ctx, arg, domain.OriginTelegram); err != nil {
			n.say(ctx, b, cfg, arg+": "+friendly(err))
			return "Not done"
		}
		_ = b.ClearButtons(ctx, cfg.ChatID, msg.MessageID)
		return "Retrying"
	}
	return ""
}

func (n *Notifier) answer(ctx context.Context, b *Bot, cfg TelegramConfig, msg *Message, key string, qid int64, text string) string {
	started, err := n.actions.AnswerOne(ctx, key, domain.Answer{QuestionID: qid, Answer: text}, domain.OriginTelegram)
	if err != nil {
		n.say(ctx, b, cfg, key+": "+friendly(err))
		return "Not saved"
	}
	if msg != nil {
		_ = b.ClearButtons(ctx, cfg.ChatID, msg.MessageID)
	}
	if started {
		n.say(ctx, b, cfg, key+": all questions answered. hiro starts coding.")
	}
	return "Saved: " + truncate(text, 40)
}

func (n *Notifier) handleText(ctx context.Context, b *Bot, cfg TelegramConfig, msg *Message) {
	text := strings.TrimSpace(msg.Text)
	if strings.HasPrefix(text, "/start") || strings.HasPrefix(text, "/help") {
		n.say(ctx, b, cfg, "hiro will message you here when a ticket needs answers or a review. Tap the buttons, or reply to a question with your own answer.")
		return
	}
	if msg.ReplyTo == nil || text == "" {
		n.say(ctx, b, cfg, "Reply to one of hiro's messages (a question, or a Request changes prompt) so I know which ticket you mean.")
		return
	}
	m, err := n.store.TelegramMessage(ctx, cfg.ChatID, msg.ReplyTo.MessageID)
	if err != nil {
		n.say(ctx, b, cfg, "I don't know which ticket that message was about.")
		return
	}
	switch m.Kind {
	case "question":
		if m.Ref != nil {
			n.answer(ctx, b, cfg, msg.ReplyTo, m.TicketKey, *m.Ref, text)
		}
	case "feedback":
		if _, err := n.actions.RequestChanges(ctx, m.TicketKey, text, domain.OriginTelegram); err != nil {
			n.say(ctx, b, cfg, m.TicketKey+": "+friendly(err))
			return
		}
		n.say(ctx, b, cfg, m.TicketKey+": changes requested. hiro is on it.")
	default:
		n.say(ctx, b, cfg, "Use the buttons on that message.")
	}
}

func friendly(err error) string {
	var te *domain.TransitionError
	if errors.As(err, &te) {
		return "not possible now, the ticket is " + strings.ReplaceAll(string(te.From), "_", " ")
	}
	return err.Error()
}
