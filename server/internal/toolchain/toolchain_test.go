package toolchain

import (
	"strings"
	"testing"

	"agnts/internal/domain"
)

func specs(ts []domain.Toolchain) string {
	out := make([]string, len(ts))
	for i, t := range ts {
		out[i] = t.Spec()
	}
	return strings.Join(out, " ")
}

func tree(files map[string]string) Tree {
	t := Tree{}
	for p, c := range files {
		if strings.HasSuffix(p, "/") {
			t[p] = nil
			continue
		}
		t[p] = []byte(c)
	}
	return t
}

func TestDetect(t *testing.T) {
	cases := []struct {
		name                     string
		files                    map[string]string
		tools, build, lint, test string
	}{
		{
			name: "this repository: Go server and npm admin",
			files: map[string]string{
				"Makefile":                     "lint:\n\techo\ntest:\n\techo\n",
				"server/go.mod":                "module agnts\n\ngo 1.26.0\n",
				"server/.golangci.yml":         "",
				"apps/admin/package.json":      `{"scripts":{"build":"vite build","lint":"eslint .","typecheck":"vue-tsc","test":"vitest"}}`,
				"apps/admin/package-lock.json": "{}",
			},
			tools: "go@1.26.0 golangci-lint@latest node@lts",
			build: "(cd server && go build ./...) && (cd apps/admin && npm ci && npm run build)",
			lint:  "(cd server && golangci-lint run ./...) && (cd apps/admin && npm run lint && npm run typecheck)",
			test:  "(cd server && go test ./...) && (cd apps/admin && npm run test)",
		},
		{
			name: "go toolchain line wins",
			files: map[string]string{
				"go.mod":       "module x\ngo 1.22\ntoolchain go1.23.4\n",
				"tools/go.mod": "module tools\ngo 1.21\n",
			},
			tools: "go@1.23.4",
			build: "go build ./...", lint: "go vet ./...", test: "go test ./...",
		},
		{
			name: "pnpm workspace with nvmrc",
			files: map[string]string{
				".nvmrc":                  "lts/iron\n",
				"package.json":            `{"packageManager":"pnpm@9.1.0+sha512.abc","scripts":{"test":"echo \"Error: no test specified\" && exit 1"}}`,
				"pnpm-workspace.yaml":     "packages: ['packages/*']",
				"packages/a/package.json": `{"scripts":{"build":"tsc"}}`,
			},
			tools: "node@20",
			build: "pnpm install --frozen-lockfile",
		},
		{
			name: "uv project with ruff and pytest",
			files: map[string]string{
				"pyproject.toml": "[project]\nrequires-python = \">=3.10,<3.12\"\ndependencies=[]\n[dependency-groups]\ndev=[\"pytest\",\"ruff\"]\n",
				"uv.lock":        "",
			},
			tools: "python@3.11 uv@latest ruff@latest",
			build: "uv sync --frozen", lint: "ruff check .", test: "python -m pytest",
		},
		{
			name: "pip requirements and django",
			files: map[string]string{
				".python-version":  "3.9.18\n",
				"requirements.txt": "django\n",
				"manage.py":        "",
			},
			tools: "python@3.9.18",
			build: "pip install -r requirements.txt", test: "python manage.py test",
		},
		{
			name: "cargo workspace",
			files: map[string]string{
				"Cargo.toml":          "[workspace]\nmembers=[\"crates/a\"]\n",
				"Cargo.lock":          "",
				"rust-toolchain.toml": "[toolchain]\nchannel = \"1.78.0\"\n",
				"crates/a/Cargo.toml": "[package]\nname=\"a\"\n",
			},
			tools: "rust@1.78.0",
			build: "cargo build --locked", lint: "cargo clippy --all-targets", test: "cargo test",
		},
		{
			name: "maven without wrapper",
			files: map[string]string{
				"pom.xml": "<project><properties><maven.compiler.release>17</maven.compiler.release></properties></project>",
			},
			tools: "java@temurin-17 maven@3",
			build: "mvn -B -q -DskipTests package", test: "mvn -B -q test",
		},
		{
			name: "gradle kotlin with wrapper",
			files: map[string]string{
				"settings.gradle.kts":  "",
				"build.gradle.kts":     "kotlin { jvmToolchain { languageVersion.set(JavaLanguageVersion.of(21)) } }",
				"gradlew":              "",
				"app/build.gradle.kts": "",
			},
			tools: "java@temurin-21",
			build: "./gradlew --no-daemon -q assemble", test: "./gradlew --no-daemon -q test",
		},
		{
			name: "dotnet solution",
			files: map[string]string{
				"App.sln":            "",
				"src/App/App.csproj": "<Project><PropertyGroup><TargetFramework>net8.0</TargetFramework></PropertyGroup></Project>",
				"tests/T/T.csproj":   "<Project><PropertyGroup><TargetFramework>net8.0</TargetFramework></PropertyGroup></Project>",
			},
			tools: "dotnet@8",
			build: "dotnet build App.sln", lint: "dotnet format App.sln --verify-no-changes", test: "dotnet test App.sln",
		},
		{
			name: "rails",
			files: map[string]string{
				".ruby-version": "ruby-3.3.1\n",
				"Gemfile":       "source 'https://rubygems.org'\ngem 'rails'\ngem 'rubocop'\n",
				"bin/rails":     "",
			},
			tools: "ruby@3.3.1",
			build: "bundle install", lint: "bundle exec rubocop", test: "bin/rails test",
		},
		{
			name: "laravel",
			files: map[string]string{
				"composer.json": "{}", "artisan": "",
			},
			tools: "php@system",
			build: "composer install --no-interaction --no-progress", test: "php artisan test",
		},
		{
			name: "tool-versions pins beat language files",
			files: map[string]string{
				".tool-versions": "nodejs 18.19.0\nterraform 1.7.0 # infra\n",
				".nvmrc":         "20\n",
				"package.json":   `{"scripts":{"test":"jest"}}`,
			},
			tools: "node@18.19.0 terraform@1.7.0",
			build: "npm install", test: "npm run test",
		},
		{
			name: "mise.toml",
			files: map[string]string{
				"mise.toml": "[env]\nX = \"1\"\n[tools]\npython = \"3.13\"\n\"npm:prettier\" = \"3\"\nnode = [\"22\", \"20\"]\njava = { version = \"zulu-17\" }\n",
			},
			tools: "java@zulu-17 node@22 python@3.13",
		},
		{
			name:  "makefile only",
			files: map[string]string{"Makefile": "all: x\ncheck:\n\tcc\n", "main.c": ""},
			build: "make all", test: "make check",
		},
		{
			name: "elixir",
			files: map[string]string{
				"mix.exs": `def project, do: [app: :x, elixir: "~> 1.15", deps: deps()]`,
			},
			tools: "erlang@latest elixir@1",
			build: "mix local.hex --force --if-missing && mix local.rebar --force --if-missing && mix deps.get && mix compile",
			lint:  "mix format --check-formatted", test: "mix test",
		},
		{
			name: "skipped directories",
			files: map[string]string{
				"node_modules/x/package.json": "{}",
				"examples/demo/go.mod":        "module demo\n",
			},
		},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			got := Detect(tree(c.files))
			if s := specs(got.Toolchains); s != c.tools {
				t.Errorf("toolchains = %q, want %q", s, c.tools)
			}
			if got.Build != c.build {
				t.Errorf("build = %q, want %q", got.Build, c.build)
			}
			if got.Lint != c.lint {
				t.Errorf("lint = %q, want %q", got.Lint, c.lint)
			}
			if got.Test != c.test {
				t.Errorf("test = %q, want %q", got.Test, c.test)
			}
		})
	}
}

func TestDetectNotes(t *testing.T) {
	got := Detect(tree(map[string]string{
		"pubspec.yaml":             "name: app\ndependencies:\n  flutter:\n    sdk: flutter\n",
		"android/app/build.gradle": "apply plugin: 'com.android.application'",
	}))
	if len(got.Notes) == 0 || !strings.Contains(got.Notes[0], "Flutter") {
		t.Fatalf("notes = %v, want a Flutter note", got.Notes)
	}
}

func TestVersions(t *testing.T) {
	for in, want := range map[string]string{
		"v20.11.1": "20.11.1", "lts/*": "lts", "lts/hydrogen": "18", "node": "latest", "22": "22",
	} {
		if got := nodeVersion(in); got != want {
			t.Errorf("nodeVersion(%q) = %q, want %q", in, got, want)
		}
	}
	for in, want := range map[string]string{
		">=18": "", "^20.11.0": "20", "18.x": "18", "20 || 22": "22", "~16.3.0": "16.3", "~> 3.2": "3", "~> 3.2.1": "3.2",
		">=3.0.0 <4.0.0": "3", "<21": "20", "20.11.1": "20.11.1",
	} {
		if got := rangeVersion(in); got != want {
			t.Errorf("rangeVersion(%q) = %q, want %q", in, got, want)
		}
	}
	for in, want := range map[string]string{
		">=3.9": "3.12", ">=3.13": "3.13", ">=3.8,<3.11": "3.10", "^3.11": "3.12", "==3.10.*": "3.10", "~=3.11.2": "3.11",
		">=3.9,!=3.12.*": "3.13", "3.*": "3.12",
	} {
		if got := pythonVersion(in); got != want {
			t.Errorf("pythonVersion(%q) = %q, want %q", in, got, want)
		}
	}
	for in, want := range map[string]string{"1.8": "8", "17": "17", "21.0.2-tem": "21"} {
		if got := javaMajor(in); got != want {
			t.Errorf("javaMajor(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestToolchainValidate(t *testing.T) {
	for _, bad := range []string{"asdf:foo@1", "node@1;rm -rf /", "node@$(id)", "-x@1"} {
		if _, err := domain.ParseToolchain(bad); err == nil {
			t.Errorf("ParseToolchain(%q) passed", bad)
		}
	}
	tc, err := domain.ParseToolchain("python")
	if err != nil || tc.Spec() != "python@latest" {
		t.Fatalf("ParseToolchain(python) = %v, %v", tc, err)
	}
}
