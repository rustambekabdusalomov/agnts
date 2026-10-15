package notify

import (
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestSwaggerNotificationText(t *testing.T) {
	run := &domain.SwaggerRun{Results: domain.SwaggerResults{Cases: []domain.APICase{
		{Operation: "GET /users", Case: "list", Verdict: domain.VerdictPass},
		{Operation: "GET /users/{id}", Case: "unknown id", Verdict: domain.VerdictFail, Reason: "500, spec says 404"},
		{Operation: "GET /orders", Case: "total", Verdict: domain.VerdictFail, Reason: "total is a string"},
	}}}
	tk := domain.Ticket{Key: "API-7", Title: "Swagger test: Shop on staging", State: domain.StateWaitingForReview, Kind: domain.KindSwaggerTest}
	v := orchestrator.TicketView{Ticket: tk, Swagger: &orchestrator.SwaggerView{Run: run}}
	if title, _ := pushText(v, domain.Event{}); title != "API-7: 1 passed, 2 failed" {
		t.Errorf("push title = %q", title)
	}
	v.Swagger.NewFailures = []string{"GET /orders · total"}
	if title, _ := pushText(v, domain.Event{}); title != "API-7: 1 new failure · 1 passed, 2 failed" {
		t.Errorf("push title with new failures = %q", title)
	}
	text := swaggerText(tk, *v.Swagger)
	for _, want := range []string{"New since the last run:\n- GET /orders · total", "GET /users/{id} · unknown id: 500, spec says 404"} {
		if !strings.Contains(text, want) {
			t.Errorf("telegram text misses %q:\n%s", want, text)
		}
	}
}
