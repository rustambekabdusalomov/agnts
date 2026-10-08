package billing

import (
	"crypto/md5" //nolint:gosec // G501: Click's SHOP API signs with MD5
	"crypto/subtle"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"strings"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// ClickConfig is a Click merchant (SHOP API).
type ClickConfig struct {
	ServiceID  string
	MerchantID string
	SecretKey  string
}

func (c ClickConfig) enabled() bool {
	return c.ServiceID != "" && c.MerchantID != "" && c.SecretKey != ""
}

func (c ClickConfig) checkoutURL(p postgres.Payment, publicURL string) string {
	q := url.Values{}
	q.Set("service_id", c.ServiceID)
	q.Set("merchant_id", c.MerchantID)
	q.Set("amount", strconv.FormatInt(p.AmountUZS, 10))
	q.Set("transaction_param", strconv.FormatInt(p.ID, 10))
	q.Set("return_url", strings.TrimRight(publicURL, "/")+"/billing/return?payment="+strconv.FormatInt(p.ID, 10))
	return "https://my.click.uz/services/pay?" + q.Encode()
}

// Click's error codes.
const (
	clickOK            = 0
	clickSignFailed    = -1
	clickWrongAmount   = -2
	clickBadAction     = -3
	clickAlreadyPaid   = -4
	clickOrderNotFound = -5
	clickTxnNotFound   = -6
	clickUpdateFailed  = -7
	clickBadRequest    = -8
	clickCancelled     = -9
)

// ClickHandler answers Click's Prepare (action 0) and Complete (action 1)
// calls at /webhooks/click.
func (s *Service) ClickHandler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !s.cfg.Click.enabled() {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		r.Body = http.MaxBytesReader(w, r.Body, 64<<10)
		if err := r.ParseForm(); err != nil {
			writeClick(w, map[string]any{"error": clickBadRequest, "error_note": "bad request"})
			return
		}
		f := r.PostForm
		out := map[string]any{"click_trans_id": f.Get("click_trans_id"), "merchant_trans_id": f.Get("merchant_trans_id")}
		fail := func(code int, note string) {
			out["error"], out["error_note"] = code, note
			writeClick(w, out)
		}
		action := f.Get("action")
		signed := f.Get("click_trans_id") + f.Get("service_id") + s.cfg.Click.SecretKey + f.Get("merchant_trans_id")
		if action == "1" {
			signed += f.Get("merchant_prepare_id")
		}
		signed += f.Get("amount") + action + f.Get("sign_time")
		sum := md5.Sum([]byte(signed)) //nolint:gosec // G401: Click's signature scheme
		if subtle.ConstantTimeCompare([]byte(hex.EncodeToString(sum[:])), []byte(strings.ToLower(f.Get("sign_string")))) != 1 {
			fail(clickSignFailed, "SIGN CHECK FAILED")
			return
		}
		if f.Get("service_id") != s.cfg.Click.ServiceID {
			fail(clickBadRequest, "wrong service")
			return
		}
		ctx := domain.System(r.Context())
		id, err := strconv.ParseInt(f.Get("merchant_trans_id"), 10, 64)
		if err != nil {
			fail(clickOrderNotFound, "payment not found")
			return
		}
		pay, err := s.store.PaymentByID(ctx, id)
		if err != nil || pay.Provider != "click" {
			fail(clickOrderNotFound, "payment not found")
			return
		}
		amount, err := strconv.ParseFloat(f.Get("amount"), 64)
		if err != nil || int64(amount) != pay.AmountUZS {
			fail(clickWrongAmount, "incorrect amount")
			return
		}
		switch action {
		case "0":
			switch pay.State {
			case postgres.PaymentPaid:
				fail(clickAlreadyPaid, "already paid")
				return
			case postgres.PaymentCancelled:
				fail(clickCancelled, "transaction cancelled")
				return
			}
			if _, err := s.store.BeginPayment(ctx, pay.ID, f.Get("click_trans_id"), 0); err != nil {
				fail(clickUpdateFailed, "could not prepare")
				return
			}
			out["merchant_prepare_id"] = pay.ID
		case "1":
			if f.Get("merchant_prepare_id") != strconv.FormatInt(pay.ID, 10) {
				fail(clickTxnNotFound, "transaction does not exist")
				return
			}
			if code, _ := strconv.Atoi(f.Get("error")); code < 0 {
				// Click could not take the money: the payment is off.
				if _, err := s.store.CancelPayment(ctx, pay.ID, code); err != nil {
					fail(clickUpdateFailed, "could not cancel")
					return
				}
				fail(clickCancelled, "transaction cancelled")
				return
			}
			switch pay.State {
			case postgres.PaymentPaid:
				fail(clickAlreadyPaid, "already paid")
				return
			case postgres.PaymentCancelled:
				fail(clickCancelled, "transaction cancelled")
				return
			}
			done, err := s.store.CompletePayment(ctx, pay.ID)
			if err != nil {
				fail(clickUpdateFailed, "could not complete")
				return
			}
			s.paid(ctx, done)
			out["merchant_confirm_id"] = pay.ID
		default:
			fail(clickBadAction, "action not found")
			return
		}
		out["error"], out["error_note"] = clickOK, "Success"
		writeClick(w, out)
	})
}

func writeClick(w http.ResponseWriter, v map[string]any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if err := json.NewEncoder(w).Encode(v); err != nil {
		http.Error(w, fmt.Sprint(err), http.StatusInternalServerError)
	}
}
