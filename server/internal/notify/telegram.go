package notify

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"time"
)

// Bot is a minimal Telegram Bot API client.
type Bot struct {
	api   string // https://api.telegram.org
	token string
	hc    *http.Client
}

// NewBot returns a client for a bot token.
func NewBot(api, token string) *Bot {
	if api == "" {
		api = "https://api.telegram.org"
	}
	return &Bot{api: api, token: token, hc: &http.Client{Timeout: 20 * time.Second}}
}

func (b *Bot) call(ctx context.Context, method string, in, out any) error {
	body, _ := json.Marshal(in)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, b.api+"/bot"+b.token+"/"+method, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	resp, err := b.hc.Do(req)
	if err != nil {
		// The URL contains the token; never let it reach a log.
		return fmt.Errorf("telegram %s: request failed", method)
	}
	defer func() { _ = resp.Body.Close() }()
	var env struct {
		OK          bool            `json:"ok"`
		Result      json.RawMessage `json:"result"`
		Description string          `json:"description"`
	}
	raw, _ := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if err := json.Unmarshal(raw, &env); err != nil {
		return fmt.Errorf("telegram %s: %s", method, resp.Status)
	}
	if !env.OK {
		return fmt.Errorf("telegram %s: %s", method, env.Description)
	}
	if out != nil {
		return json.Unmarshal(env.Result, out)
	}
	return nil
}

// GetMe returns the bot's username.
func (b *Bot) GetMe(ctx context.Context) (string, error) {
	var me struct {
		Username string `json:"username"`
	}
	err := b.call(ctx, "getMe", map[string]any{}, &me)
	return "@" + me.Username, err
}

// SetWebhook points Telegram at agnts, with a secret header.
func (b *Bot) SetWebhook(ctx context.Context, url, secret string) error {
	return b.call(ctx, "setWebhook", map[string]any{
		"url": url, "secret_token": secret, "allowed_updates": []string{"message", "callback_query"}, "drop_pending_updates": true,
	}, nil)
}

// Button is an inline keyboard button.
type Button struct {
	Text string `json:"text"`
	Data string `json:"callback_data,omitempty"`
	URL  string `json:"url,omitempty"`
}

// Send posts a message and returns its id. rows are inline keyboard rows.
func (b *Bot) Send(ctx context.Context, chatID int64, text string, rows [][]Button, forceReply bool) (int64, error) {
	in := map[string]any{"chat_id": chatID, "text": text, "link_preview_options": map[string]bool{"is_disabled": true}}
	switch {
	case len(rows) > 0:
		in["reply_markup"] = map[string]any{"inline_keyboard": rows}
	case forceReply:
		in["reply_markup"] = map[string]any{"force_reply": true, "input_field_placeholder": "Type your reply"}
	}
	var msg struct {
		MessageID int64 `json:"message_id"`
	}
	err := b.call(ctx, "sendMessage", in, &msg)
	return msg.MessageID, err
}

// ClearButtons removes a message's inline keyboard.
func (b *Bot) ClearButtons(ctx context.Context, chatID, messageID int64) error {
	return b.call(ctx, "editMessageReplyMarkup", map[string]any{
		"chat_id": chatID, "message_id": messageID, "reply_markup": map[string]any{"inline_keyboard": [][]Button{}},
	}, nil)
}

// AnswerCallback stops the button's spinner, optionally with a short note.
func (b *Bot) AnswerCallback(ctx context.Context, id, text string) error {
	return b.call(ctx, "answerCallbackQuery", map[string]any{"callback_query_id": id, "text": text}, nil)
}

// Update is the part of a Telegram update agnts reads.
type Update struct {
	UpdateID int64    `json:"update_id"`
	Message  *Message `json:"message"`
	Callback *struct {
		ID      string   `json:"id"`
		Message *Message `json:"message"`
		Data    string   `json:"data"`
	} `json:"callback_query"`
}

// Message is a Telegram message.
type Message struct {
	MessageID int64 `json:"message_id"`
	Chat      struct {
		ID int64 `json:"id"`
	} `json:"chat"`
	Text    string   `json:"text"`
	ReplyTo *Message `json:"reply_to_message"`
}

// TelegramConfig is the stored Telegram connection.
type TelegramConfig struct {
	BotToken      string `json:"bot_token"`
	WebhookSecret string `json:"webhook_secret"`
	ChatID        int64  `json:"-"`
}

// ParseTelegram reads the integration: secrets in the token JSON, chat id in settings.
func ParseTelegram(token string, settings map[string]string) (TelegramConfig, error) {
	var c TelegramConfig
	if err := json.Unmarshal([]byte(token), &c); err != nil {
		return c, errors.New("telegram secrets are unreadable")
	}
	if s := settings["chat_id"]; s != "" {
		id, err := strconv.ParseInt(s, 10, 64)
		if err != nil {
			return c, errors.New("telegram chat_id must be a number")
		}
		c.ChatID = id
	}
	return c, nil
}

// TelegramToken packs the secrets for the encrypted token column.
func TelegramToken(botToken, webhookSecret string) string {
	b, _ := json.Marshal(TelegramConfig{BotToken: botToken, WebhookSecret: webhookSecret}) //nolint:gosec // G117: encrypted before storage
	return string(b)
}
