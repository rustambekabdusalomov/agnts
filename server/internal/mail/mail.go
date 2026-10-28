// Package mail sends agnts's few emails: address verification, password
// resets, workspace invites and meeting invitations (with their calendar
// event attached).
package mail

import (
	"context"
	"crypto/tls"
	"encoding/base64"
	"errors"
	"fmt"
	"log/slog"
	"mime"
	"net"
	"net/mail"
	"net/smtp"
	"net/url"
	"strings"
	"time"
)

// Message is one plain-text email, with optional attachments.
type Message struct {
	To          string
	Subject     string
	Body        string
	Attachments []Attachment
}

// Attachment is a file sent with a message.
type Attachment struct {
	Name string
	// ContentType is the part's type, e.g. `text/calendar; method=REQUEST;
	// charset=utf-8` for a meeting invitation calendars pick up.
	ContentType string
	Data        []byte
}

// Sender delivers email.
type Sender interface {
	Send(ctx context.Context, m Message) error
	// Enabled reports whether messages leave the server (false: logged).
	Enabled() bool
}

// New returns an SMTP sender for smtpURL (smtp://user:pass@host:587 with
// STARTTLS, or smtps:// for implicit TLS), or a sender that logs the
// messages when smtpURL is empty.
func New(smtpURL, from string, log *slog.Logger) (Sender, error) {
	if smtpURL == "" {
		return logSender{log: log}, nil
	}
	u, err := url.Parse(smtpURL)
	if err != nil {
		return nil, fmt.Errorf("mail: %w", err)
	}
	addr, err := mail.ParseAddress(from)
	if err != nil {
		return nil, fmt.Errorf("mail: AGNTS_MAIL_FROM: %w", err)
	}
	s := &smtpSender{host: u.Hostname(), port: u.Port(), implicitTLS: u.Scheme == "smtps", from: addr}
	if s.port == "" {
		s.port = "587"
		if s.implicitTLS {
			s.port = "465"
		}
	}
	if u.User != nil {
		pw, _ := u.User.Password()
		s.auth = smtp.PlainAuth("", u.User.Username(), pw, s.host)
	}
	return s, nil
}

type logSender struct{ log *slog.Logger }

func (l logSender) Send(_ context.Context, m Message) error {
	l.log.Info("email (AGNTS_SMTP_URL is not set, so it is only logged)", "to", m.To, "subject", m.Subject, "body", m.Body,
		"attachments", len(m.Attachments))
	return nil
}

func (logSender) Enabled() bool { return false }

type smtpSender struct {
	host, port  string
	implicitTLS bool
	auth        smtp.Auth
	from        *mail.Address
}

func (s *smtpSender) Enabled() bool { return true }

// Send delivers m, giving up after 30 seconds.
func (s *smtpSender) Send(ctx context.Context, m Message) error {
	to, err := mail.ParseAddress(m.To)
	if err != nil {
		return fmt.Errorf("mail: bad address %q", m.To)
	}
	if strings.ContainsAny(m.Subject, "\r\n") {
		return errors.New("mail: subject has a line break")
	}
	ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()
	d := net.Dialer{}
	conn, err := d.DialContext(ctx, "tcp", net.JoinHostPort(s.host, s.port))
	if err != nil {
		return fmt.Errorf("mail: connect: %w", err)
	}
	if dl, ok := ctx.Deadline(); ok {
		_ = conn.SetDeadline(dl)
	}
	if s.implicitTLS {
		conn = tls.Client(conn, &tls.Config{ServerName: s.host, MinVersion: tls.VersionTLS12})
	}
	c, err := smtp.NewClient(conn, s.host)
	if err != nil {
		_ = conn.Close()
		return fmt.Errorf("mail: %w", err)
	}
	defer func() { _ = c.Close() }()
	if !s.implicitTLS {
		if ok, _ := c.Extension("STARTTLS"); ok {
			if err := c.StartTLS(&tls.Config{ServerName: s.host, MinVersion: tls.VersionTLS12}); err != nil {
				return fmt.Errorf("mail: starttls: %w", err)
			}
		}
	}
	if s.auth != nil {
		if err := c.Auth(s.auth); err != nil {
			return fmt.Errorf("mail: auth: %w", err)
		}
	}
	if err := c.Mail(s.from.Address); err != nil {
		return fmt.Errorf("mail: from: %w", err)
	}
	if err := c.Rcpt(to.Address); err != nil {
		return fmt.Errorf("mail: to: %w", err)
	}
	w, err := c.Data()
	if err != nil {
		return fmt.Errorf("mail: data: %w", err)
	}
	if _, err := w.Write(compose(s.from, to, m, time.Now())); err != nil {
		return fmt.Errorf("mail: write: %w", err)
	}
	if err := w.Close(); err != nil {
		return fmt.Errorf("mail: send: %w", err)
	}
	return c.Quit()
}

// compose builds the RFC 5322 message: plain text, or multipart/mixed
// with the text first when there are attachments.
func compose(from, to *mail.Address, m Message, now time.Time) []byte {
	var b strings.Builder
	b.WriteString("From: " + from.String() + "\r\n")
	b.WriteString("To: " + to.String() + "\r\n")
	b.WriteString("Subject: " + mime.QEncoding.Encode("utf-8", m.Subject) + "\r\n")
	b.WriteString("Date: " + now.Format(time.RFC1123Z) + "\r\n")
	b.WriteString("MIME-Version: 1.0\r\n")
	text := strings.ReplaceAll(strings.ReplaceAll(m.Body, "\r\n", "\n"), "\n", "\r\n")
	if len(m.Attachments) == 0 {
		b.WriteString("Content-Type: text/plain; charset=utf-8\r\n")
		b.WriteString("Content-Transfer-Encoding: 8bit\r\n\r\n")
		b.WriteString(text)
		b.WriteString("\r\n")
		return []byte(b.String())
	}
	boundary := fmt.Sprintf("agnts-%x", now.UnixNano())
	b.WriteString("Content-Type: multipart/mixed; boundary=\"" + boundary + "\"\r\n\r\n")
	b.WriteString("--" + boundary + "\r\n")
	b.WriteString("Content-Type: text/plain; charset=utf-8\r\n")
	b.WriteString("Content-Transfer-Encoding: 8bit\r\n\r\n")
	b.WriteString(text + "\r\n")
	for _, a := range m.Attachments {
		ct := a.ContentType
		if ct == "" {
			ct = "application/octet-stream"
		}
		name := mime.QEncoding.Encode("utf-8", strings.NewReplacer("\"", "", "\r", "", "\n", "").Replace(a.Name))
		b.WriteString("--" + boundary + "\r\n")
		b.WriteString("Content-Type: " + ct + "; name=\"" + name + "\"\r\n")
		b.WriteString("Content-Disposition: attachment; filename=\"" + name + "\"\r\n")
		b.WriteString("Content-Transfer-Encoding: base64\r\n\r\n")
		enc := base64.StdEncoding.EncodeToString(a.Data)
		for len(enc) > 76 {
			b.WriteString(enc[:76] + "\r\n")
			enc = enc[76:]
		}
		b.WriteString(enc + "\r\n")
	}
	b.WriteString("--" + boundary + "--\r\n")
	return []byte(b.String())
}
