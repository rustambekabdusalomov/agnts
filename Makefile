# hiro monorepo tasks. Run `make help` for the list.
SHELL := /bin/bash
.DEFAULT_GOAL := help

VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
COMMIT  ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)
IMAGE   ?= hiro:local

GOLANGCI := go run github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.14.0
OPENAPI_GEN := npx --yes @openapitools/openapi-generator-cli@2.41.0

.PHONY: help
help: ## Show this help
	@grep -hE '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[1m%-16s\033[0m %s\n", $$1, $$2}'

# ---- Code generation (spec and dictionaries are the source of truth) ----

.PHONY: gen gen-go gen-ts gen-dart gen-arb
gen: gen-go gen-ts gen-dart gen-arb ## Regenerate API clients, server stubs and ARB files

gen-go:
	cd server && go generate ./internal/httpapi

gen-ts:
	cd apps/admin && npm run gen

gen-dart:
	rm -rf apps/mobile/packages/hiro_api
	$(OPENAPI_GEN) generate -i shared/openapi/openapi.yaml -g dart-dio \
	  -o apps/mobile/packages/hiro_api \
	  --additional-properties=pubName=hiro_api,serializationLibrary=json_serializable \
	  > /dev/null
	# json_serializable emits null-aware elements (Dart 3.8); the generator
	# still declares an older SDK floor. The app itself needs Dart 3.12.
	sed -i.bak "s/^  sdk: '>=3.5.0 <4.0.0'/  sdk: '>=3.8.0 <4.0.0'/" apps/mobile/packages/hiro_api/pubspec.yaml
	rm apps/mobile/packages/hiro_api/pubspec.yaml.bak
	grep -q "sdk: '>=3.8.0" apps/mobile/packages/hiro_api/pubspec.yaml

gen-arb: i18n-check
	node scripts/i18n.mjs arb apps/mobile/lib/l10n

.PHONY: i18n-check
i18n-check: ## Check that EN/RU/UZ dictionaries have the same keys and placeholders
	node scripts/i18n.mjs check

# ---- Checks ----

.PHONY: lint lint-server lint-admin
lint: lint-server lint-admin ## Lint server and admin

lint-server:
	cd server && $(GOLANGCI) run ./...

lint-admin:
	cd apps/admin && npm run lint && npm run typecheck

.PHONY: test test-server test-admin
test: test-server test-admin ## Run unit tests (set HIRO_TEST_DATABASE_URL for DB tests)

test-server:
	cd server && go test -race -p 1 ./...

test-admin:
	cd apps/admin && npm test

# ---- Local development ----

.PHONY: dev-db dev-server dev-admin dev-user
dev-db: ## Start the local PostgreSQL (Docker)
	docker compose -f deploy/docker-compose.dev.yml up -d

dev-server: ## Run the server against the local database
	cd server && set -a && source ../deploy/.env.dev && set +a && go run ./cmd/hiro serve

dev-admin: ## Run the admin panel with hot reload on :5173
	cd apps/admin && npm run dev

dev-user: ## Create the local admin user
	cd server && set -a && source ../deploy/.env.dev && set +a && go run ./cmd/hiro user create $${USERNAME:-admin}

# ---- Build ----

.PHONY: build image
build: ## Build the server binary and the admin panel
	cd apps/admin && npm run build
	cd server && go build -trimpath -ldflags "-X main.version=$(VERSION) -X main.commit=$(COMMIT)" -o ../bin/hiro ./cmd/hiro

image: ## Build the production Docker image
	docker build --build-arg VERSION=$(VERSION) --build-arg COMMIT=$(COMMIT) -t $(IMAGE) .
