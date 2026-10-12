package admin

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"
)

// OpenAICheck verifies an OpenAI API key (for Codex runs) by listing the
// models it can use; api is the API's base URL.
func OpenAICheck(api string) Checker {
	return func(ctx context.Context, token string, _ map[string]string) (string, error) {
		if !strings.HasPrefix(token, "sk-") || len(token) < 20 {
			return "", errors.New("expected an OpenAI API key (sk-...)")
		}
		ctx, cancel := context.WithTimeout(ctx, 15*time.Second)
		defer cancel()
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, strings.TrimRight(api, "/")+"/v1/models", nil)
		if err != nil {
			return "", err
		}
		req.Header.Set("Authorization", "Bearer "+token)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			return "", err
		}
		defer func() { _ = resp.Body.Close() }()
		if resp.StatusCode != http.StatusOK {
			return "", fmt.Errorf("OpenAI answered %s", resp.Status)
		}
		return "OpenAI API key …" + token[len(token)-4:], nil
	}
}
