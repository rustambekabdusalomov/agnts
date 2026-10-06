package httpapi

import (
	"context"
	"net/http"

	"agnts/internal/httpapi/gen"
	"agnts/internal/store/postgres"
)

// Devices stores push registrations.
type Devices interface {
	RegisterDevice(ctx context.Context, d postgres.Device) error
	DeleteDevice(ctx context.Context, token string) error
}

// RegisterDevice implements gen.ServerInterface.
func (s *Server) RegisterDevice(w http.ResponseWriter, r *http.Request) {
	u, ok := userFrom(r.Context())
	if !ok || s.opt.Devices == nil {
		writeError(w, http.StatusUnauthorized, "unauthorized", "sign in required")
		return
	}
	var req gen.DeviceRegistration
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if !req.Platform.Valid() {
		writeError(w, http.StatusBadRequest, "bad_request", "platform must be ios or android")
		return
	}
	d := postgres.Device{UserID: u.ID, Platform: string(req.Platform), FCMToken: req.FcmToken}
	if req.AppVersion != nil {
		d.AppVersion = *req.AppVersion
	}
	if err := s.opt.Devices.RegisterDevice(r.Context(), d); err != nil {
		s.writeInternal(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// UnregisterDevice implements gen.ServerInterface.
func (s *Server) UnregisterDevice(w http.ResponseWriter, r *http.Request) {
	var req gen.UnregisterDeviceJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if s.opt.Devices != nil {
		if err := s.opt.Devices.DeleteDevice(r.Context(), req.FcmToken); err != nil {
			s.writeInternal(w, r, err)
			return
		}
	}
	w.WriteHeader(http.StatusNoContent)
}
