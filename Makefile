# agnts monorepo tasks. Run `make help` for the list.
SHELL := /bin/bash
.DEFAULT_GOAL := help

VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
COMMIT  ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)
IMAGE   ?= agnts:local
MUSE_DIR ?= ../agnts-muse

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
	rm -rf apps/mobile/packages/agnts_api
	$(OPENAPI_GEN) generate -i shared/openapi/openapi.yaml -g dart-dio \
	  -o apps/mobile/packages/agnts_api \
	  --additional-properties=pubName=agnts_api,serializationLibrary=json_serializable \
	  > /dev/null
	# json_serializable emits null-aware elements (Dart 3.8); the generator
	# still declares an older SDK floor. The app itself needs Dart 3.12.
	sed -i.bak "s/^  sdk: '>=3.5.0 <4.0.0'/  sdk: '>=3.8.0 <4.0.0'/" apps/mobile/packages/agnts_api/pubspec.yaml
	rm apps/mobile/packages/agnts_api/pubspec.yaml.bak
	grep -q "sdk: '>=3.8.0" apps/mobile/packages/agnts_api/pubspec.yaml

gen-arb: i18n-check
	node scripts/i18n.mjs arb apps/mobile/lib/l10n

.PHONY: i18n-check
i18n-check: ## Check that EN/RU/UZ dictionaries have the same keys and placeholders
	node scripts/i18n.mjs check

# ---- Checks ----

.PHONY: lint lint-server lint-admin lint-website
lint: lint-server lint-admin lint-website ## Lint server, admin and website

lint-server:
	cd server && $(GOLANGCI) run ./...

lint-admin:
	cd apps/admin && npm run lint && npm run typecheck

lint-website:
	cd apps/website && npm run lint && npm run typecheck

.PHONY: test test-server test-admin test-website
test: test-server test-admin test-website ## Run unit tests (set AGNTS_TEST_DATABASE_URL for DB tests)

test-server:
	cd server && go test -race -p 1 ./...

test-admin:
	cd apps/admin && npm test

test-website:
	cd apps/website && npm test

# ---- Local development ----

.PHONY: dev-db dev-meetings dev-server dev-guard dev-admin dev-website dev-user
dev-db: ## Start the local PostgreSQL (Docker)
	docker compose -f deploy/docker-compose.dev.yml up -d

dev-meetings: ## Start the local LiveKit, Redis and Egress for meetings (Docker)
	mkdir -p .dev-data-agnts/meetings && chmod 777 .dev-data-agnts/meetings
	docker compose -f deploy/docker-compose.dev.yml --profile meetings up -d

dev-server: dev-guard ## Run the server against the local database
	cd server && set -a && source ../deploy/.env.dev && set +a && go run ./cmd/agnts serve

dev-guard: ## Build agnts-guard for the local run containers (Linux, this machine's CPU)
	cd server && CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags "-s -w" -o ../.dev-data-agnts/agnts-guard ./cmd/agnts-guard

dev-admin: ## Run the admin panel with hot reload on :5173
	cd apps/admin && npm run dev

dev-website: ## Run the public website on :3000
	cd apps/website && npm run dev

.PHONY: demo-db demo-server
DEMO_DB := docker exec -i agnts-dev-postgres-1 psql -U hiro -v ON_ERROR_STOP=1 -q
demo-db: ## Recreate the demo database (agnts_demo) with screenshot data: DEMO_EMAIL=you@gmail.com DEMO_NAME="Your Name"
	@test -n "$(DEMO_EMAIL)" || (echo "set DEMO_EMAIL to the Google account you sign in with" && exit 1)
	$(DEMO_DB) -d hiro -c "DROP DATABASE IF EXISTS agnts_demo WITH (FORCE)" -c "CREATE DATABASE agnts_demo"
	cd server && set -a && source ../deploy/.env.demo && set +a && go run ./cmd/agnts migrate
	python3 scripts/demo_seed.py "$(DEMO_EMAIL)" "$(or $(DEMO_NAME),Demo Owner)" | $(DEMO_DB) -d agnts_demo

demo-server: ## Run the server against the demo database (API only, no agent runs)
	mkdir -p .dev-data-demo
	cd server && set -a && source ../deploy/.env.demo && set +a && go run ./cmd/agnts serve

dev-user: ## Create the local admin user
	cd server && set -a && source ../deploy/.env.dev && set +a && go run ./cmd/agnts user create $${USERNAME:-admin}

# ---- Build ----

.PHONY: build image
build: ## Build the server binary, the admin panel and the website
	cd apps/admin && npm run build
	cd apps/website && npm run generate
	cd server && go build -trimpath -ldflags "-X main.version=$(VERSION) -X main.commit=$(COMMIT)" -o ../bin/agnts ./cmd/agnts

image: ## Build the production Docker image
	docker build --build-context agnts-muse=$(MUSE_DIR) --build-arg VERSION=$(VERSION) --build-arg COMMIT=$(COMMIT) -t $(IMAGE) .

# ---- CLI (Rust; installs and manages agnts on a server) ----

.PHONY: cli cli-test cli-lint cli-stub
cli: ## Build the agnts CLI (release) to cli/target/release/agnts
	cd cli && cargo build --release --locked

cli-test: ## Run the CLI tests
	cd cli && cargo test --locked

cli-lint: ## Check CLI formatting and clippy
	cd cli && cargo fmt --check && cargo clippy --all-targets --locked -- -D warnings

cli-stub: ## Run a stand-in agnts.uz API on :8787 (key: agk_test)
	cd cli && cargo run --example stub_cloud
