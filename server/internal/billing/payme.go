package billing

import (
	"context"
	"crypto/subtle"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// PaymeConfig is a Payme merchant (Payme Business, Merchant API).
type PaymeConfig struct {
	MerchantID string
	Key        string // the cashbox key Payme signs its calls with
	// CheckoutURL is Payme's checkout (https://checkout.paycom.uz, or
	// https://test.paycom.uz for the sandbox).
	CheckoutURL string
}

func (c PaymeConfig) enabled() bool { return c.MerchantID != "" && c.Key != "" }

// checkoutURL is the page that takes payment p: the parameters are
// base64 of "m=<merchant>;ac.payment_id=<id>;a=<tiyin>;c=<return URL>".
func (c PaymeConfig) checkoutURL(p postgres.Payment, publicURL string) string {
	base := c.CheckoutURL
	if base == "" {
		base = "https://checkout.paycom.uz"
	}
	params := fmt.Sprintf("m=%s;ac.payment_id=%d;a=%d;c=%s", c.MerchantID, p.ID, p.AmountUZS*100,
		strings.TrimRight(publicURL, "/")+"/billing/return?payment="+strconv.FormatInt(p.ID, 10))
	return strings.TrimRight(base, "/") + "/" + base64.StdEncoding.EncodeToString([]byte(params))
}

// Payme's error codes.
const (
	paymeAuth          = -32504
	paymeParse         = -32700
	paymeMethod        = -32601
	paymeInvalid       = -32600
	paymeWrongAmount   = -31001
	paymeTxnNotFound   = -31003
	paymeCannotCancel  = -31007
	paymeCannotPerform = -31008
	paymeOrderNotFound = -31050
	paymeOrderBusy     = -31099
)

// paymeTimeout is how long a created transaction may wait for payment.
const paymeTimeout = 12 * time.Hour

// Payme transaction states.
const (
	paymeCreated         = 1
	paymePerformed       = 2
	paymeCancelled       = -1
	paymeCancelledPaid   = -2
	paymeReasonTimeout   = 4
	paymeReasonRefunded  = 5
	paymeDefaultCancelBy = 3
)

type paymeRequest struct {
	Method string          `json:"method"`
	Params json.RawMessage `json:"params"`
	ID     json.RawMessage `json:"id"`
}

type paymeError struct {
	Code    int               `json:"code"`
	Message map[string]string `json:"message"`
	Data    string            `json:"data,omitempty"`
}

func perr(code int, msg string) *paymeError {
	return &paymeError{Code: code, Message: map[string]string{"en": msg, "ru": msg, "uz": msg}}
}

// PaymeHandler answers Payme's Merchant API calls at /webhooks/payme.
func (s *Service) PaymeHandler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		reply := func(id json.RawMessage, result any, e *paymeError) {
			w.Header().Set("Content-Type", "application/json; charset=utf-8")
			out := map[string]any{"jsonrpc": "2.0", "id": id}
			if e != nil {
				out["error"] = e
			} else {
				out["result"] = result
			}
			_ = json.NewEncoder(w).Encode(out)
		}
		if !s.cfg.Payme.enabled() {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		body, err := io.ReadAll(io.LimitReader(r.Body, 64<<10))
		var req paymeRequest
		if err != nil || json.Unmarshal(body, &req) != nil {
			reply(nil, nil, perr(paymeParse, "parse error"))
			return
		}
		if !s.paymeAuthorized(r) {
			reply(req.ID, nil, perr(paymeAuth, "insufficient privileges"))
			return
		}
		ctx := domain.System(r.Context())
		result, e := s.payme(ctx, req.Method, req.Params)
		reply(req.ID, result, e)
	})
}

// paymeAuthorized checks Basic auth "Paycom:<key>".
func (s *Service) paymeAuthorized(r *http.Request) bool {
	user, pass, ok := r.BasicAuth()
	return ok && user == "Paycom" && subtle.ConstantTimeCompare([]byte(pass), []byte(s.cfg.Payme.Key)) == 1
}

type paymeParams struct {
	ID      string `json:"id"`
	Time    int64  `json:"time"`
	Amount  int64  `json:"amount"`
	Reason  int    `json:"reason"`
	From    int64  `json:"from"`
	To      int64  `json:"to"`
	Account struct {
		PaymentID json.Number `json:"payment_id"`
	} `json:"account"`
}

func (s *Service) payme(ctx context.Context, method string, raw json.RawMessage) (any, *paymeError) {
	var p paymeParams
	if err := json.Unmarshal(raw, &p); err != nil {
		return nil, perr(paymeInvalid, "invalid params")
	}
	switch method {
	case "CheckPerformTransaction":
		if _, e := s.paymeOrder(ctx, p); e != nil {
			return nil, e
		}
		return map[string]any{"allow": true}, nil
	case "CreateTransaction":
		return s.paymeCreate(ctx, p)
	case "PerformTransaction":
		return s.paymePerform(ctx, p)
	case "CancelTransaction":
		return s.paymeCancel(ctx, p)
	case "CheckTransaction":
		pay, err := s.store.PaymentByTxn(ctx, "payme", p.ID)
		if err != nil {
			return nil, perr(paymeTxnNotFound, "transaction not found")
		}
		return paymeTxn(pay), nil
	case "GetStatement":
		ps, err := s.store.PaymentsBetween(ctx, "payme", p.From, p.To)
		if err != nil {
			return nil, perr(paymeInvalid, "could not read transactions")
		}
		list := make([]map[string]any, 0, len(ps))
		for _, pay := range ps {
			t := paymeTxn(pay)
			t["id"], t["time"], t["amount"] = pay.ProviderTxn, pay.ProviderTime, pay.AmountUZS*100
			t["account"] = map[string]string{"payment_id": strconv.FormatInt(pay.ID, 10)}
			list = append(list, t)
		}
		return map[string]any{"transactions": list}, nil
	}
	return nil, perr(paymeMethod, "method not found")
}

// paymeOrder finds the payment p is for and checks its amount.
func (s *Service) paymeOrder(ctx context.Context, p paymeParams) (postgres.Payment, *paymeError) {
	id, err := p.Account.PaymentID.Int64()
	if err != nil {
		return postgres.Payment{}, perr(paymeOrderNotFound, "payment not found")
	}
	pay, err := s.store.PaymentByID(ctx, id)
	if err != nil || pay.Provider != "payme" {
		return pay, perr(paymeOrderNotFound, "payment not found")
	}
	if pay.State == postgres.PaymentPaid || pay.State == postgres.PaymentCancelled {
		return pay, perr(paymeOrderNotFound, "this payment is closed")
	}
	if pay.AmountUZS*100 != p.Amount {
		return pay, perr(paymeWrongAmount, "wrong amount")
	}
	return pay, nil
}

func (s *Service) paymeCreate(ctx context.Context, p paymeParams) (any, *paymeError) {
	if pay, err := s.store.PaymentByTxn(ctx, "payme", p.ID); err == nil {
		if pay.State != postgres.PaymentPending {
			return nil, perr(paymeCannotPerform, "transaction is not open")
		}
		if s.now().Sub(pay.CreatedAt) > paymeTimeout {
			_, _ = s.store.CancelPayment(ctx, pay.ID, paymeReasonTimeout)
			return nil, perr(paymeCannotPerform, "transaction timed out")
		}
		return map[string]any{"create_time": pay.CreatedAt.UnixMilli(), "transaction": strconv.FormatInt(pay.ID, 10), "state": paymeCreated}, nil
	}
	pay, e := s.paymeOrder(ctx, p)
	if e != nil {
		return nil, e
	}
	if pay.ProviderTxn != "" && pay.ProviderTxn != p.ID {
		return nil, perr(paymeOrderBusy, "another transaction is paying this")
	}
	pay, err := s.store.BeginPayment(ctx, pay.ID, p.ID, p.Time)
	if errors.Is(err, domain.ErrConflict) {
		return nil, perr(paymeOrderBusy, "another transaction is paying this")
	}
	if err != nil {
		return nil, perr(paymeCannotPerform, "could not create the transaction")
	}
	return map[string]any{"create_time": pay.CreatedAt.UnixMilli(), "transaction": strconv.FormatInt(pay.ID, 10), "state": paymeCreated}, nil
}

func (s *Service) paymePerform(ctx context.Context, p paymeParams) (any, *paymeError) {
	pay, err := s.store.PaymentByTxn(ctx, "payme", p.ID)
	if err != nil {
		return nil, perr(paymeTxnNotFound, "transaction not found")
	}
	switch pay.State {
	case postgres.PaymentPaid:
		return paymeTxn(pay), nil
	case postgres.PaymentPending:
		if s.now().Sub(pay.CreatedAt) > paymeTimeout {
			_, _ = s.store.CancelPayment(ctx, pay.ID, paymeReasonTimeout)
			return nil, perr(paymeCannotPerform, "transaction timed out")
		}
		if pay, err = s.store.CompletePayment(ctx, pay.ID); err != nil {
			return nil, perr(paymeCannotPerform, "could not perform the transaction")
		}
		s.paid(ctx, pay)
		return paymeTxn(pay), nil
	}
	return nil, perr(paymeCannotPerform, "transaction is cancelled")
}

func (s *Service) paymeCancel(ctx context.Context, p paymeParams) (any, *paymeError) {
	pay, err := s.store.PaymentByTxn(ctx, "payme", p.ID)
	if err != nil {
		return nil, perr(paymeTxnNotFound, "transaction not found")
	}
	if pay.State == postgres.PaymentCancelled {
		return paymeTxn(pay), nil
	}
	reason := p.Reason
	if reason == 0 {
		reason = paymeDefaultCancelBy
	}
	if pay, err = s.store.CancelPayment(ctx, pay.ID, reason); err != nil {
		return nil, perr(paymeCannotCancel, "could not cancel")
	}
	s.changed(pay.WorkspaceID)
	return paymeTxn(pay), nil
}

// paymeTxn is a payment as CheckTransaction reports it.
func paymeTxn(p postgres.Payment) map[string]any {
	state := paymeCreated
	switch {
	case p.State == postgres.PaymentPaid:
		state = paymePerformed
	case p.State == postgres.PaymentCancelled && p.PerformedAt != nil:
		state = paymeCancelledPaid
	case p.State == postgres.PaymentCancelled:
		state = paymeCancelled
	}
	ms := func(t *time.Time) int64 {
		if t == nil {
			return 0
		}
		return t.UnixMilli()
	}
	var reason any
	if p.Reason != nil {
		reason = *p.Reason
	}
	return map[string]any{"create_time": p.CreatedAt.UnixMilli(), "perform_time": ms(p.PerformedAt), "cancel_time": ms(p.CancelledAt),
		"transaction": strconv.FormatInt(p.ID, 10), "state": state, "reason": reason}
}
