package toolchain

import (
	"encoding/json"
	"regexp"
	"slices"
	"strings"

	"agnts/internal/domain"
)

// coveredBy reports whether an ancestor of dir is a project of the same
// kind whose commands already include dir (a Go module root, a Cargo or
// npm workspace, a Maven parent, a .sln).
func (d *detector) coveredBy(dir string, isRoot func(string) bool) bool {
	for p := dir; p != ""; {
		i := strings.LastIndexByte(p, '/')
		if i < 0 {
			p = ""
		} else {
			p = p[:i]
		}
		if isRoot(p) {
			return true
		}
	}
	return false
}

// versionFile reads a version file in dir, else at the root.
func (d *detector) versionFile(dir, name string) (string, string) {
	for _, p := range []string{dir, ""} {
		if v := firstLine(d.t.read(p, name)); v != "" {
			return v, join(p, name)
		}
		if p == "" {
			break
		}
	}
	return "", ""
}

var (
	goToolchainRe = regexp.MustCompile(`(?m)^toolchain\s+go(\d+\.\d+(?:\.\d+)?)`)
	goLineRe      = regexp.MustCompile(`(?m)^go\s+(\d+\.\d+(?:\.\d+)?)`)
)

func (d *detector) goProject(dir string) bool {
	if !d.t.has(dir, "go.mod") && !d.t.has(dir, "go.work") {
		return false
	}
	src := d.t.read(dir, "go.work") + "\n" + d.t.read(dir, "go.mod")
	v, from := find(goToolchainRe, src), "go.mod"
	if v == "" {
		v = find(goLineRe, src)
	}
	if v == "" {
		from = "default"
	}
	d.add(domain.Toolchain{Tool: "go", Version: v, Source: join(dir, from), Dir: dir})
	if d.coveredBy(dir, func(p string) bool { return d.t.has(p, "go.mod") || d.t.has(p, "go.work") }) {
		return true
	}
	s := d.steps(dir)
	s.build = append(s.build, "go build ./...")
	lint := "go vet ./..."
	if d.t.has(dir, ".golangci.yml") || d.t.has(dir, ".golangci.yaml") || d.t.has(dir, ".golangci.toml") {
		d.add(domain.Toolchain{Tool: "golangci-lint", Version: "latest", Source: join(dir, ".golangci.yml"), Dir: dir})
		lint = "golangci-lint run ./..."
	}
	s.lint = append(s.lint, lint)
	s.test = append(s.test, "go test ./...")
	return true
}

type packageJSON struct {
	Scripts        map[string]string `json:"scripts"`
	Engines        map[string]string `json:"engines"`
	PackageManager string            `json:"packageManager"`
	Workspaces     json.RawMessage   `json:"workspaces"`
	Volta          map[string]string `json:"volta"`
	Dependencies   map[string]string `json:"dependencies"`
	DevDeps        map[string]string `json:"devDependencies"`
}

func (d *detector) nodeProject(dir string) bool {
	if !d.t.has(dir, "package.json") {
		return false
	}
	var pkg packageJSON
	_ = json.Unmarshal(d.t[join(dir, "package.json")], &pkg)

	pm, pmVer := "npm", ""
	if n, v, ok := strings.Cut(pkg.PackageManager, "@"); ok {
		pm, pmVer = n, strings.SplitN(v, "+", 2)[0]
	}
	switch {
	case pkg.PackageManager != "":
	case d.t.has(dir, "pnpm-lock.yaml") || d.t.has("", "pnpm-lock.yaml"):
		pm = "pnpm"
	case d.t.has(dir, "yarn.lock") || d.t.has("", "yarn.lock"):
		pm = "yarn"
	case d.t.has(dir, "bun.lockb") || d.t.has(dir, "bun.lock"):
		pm = "bun"
	}

	ver, src := "", ""
	for _, f := range []string{".nvmrc", ".node-version"} {
		if v, p := d.versionFile(dir, f); v != "" {
			ver, src = nodeVersion(v), p
			break
		}
	}
	if ver == "" && pkg.Volta["node"] != "" {
		ver, src = nodeVersion(pkg.Volta["node"]), join(dir, "package.json")
	}
	if ver == "" && pkg.Engines["node"] != "" {
		ver, src = rangeVersion(pkg.Engines["node"]), join(dir, "package.json")
	}
	if ver == "" {
		ver, src = "lts", "default"
	}
	d.add(domain.Toolchain{Tool: "node", Version: ver, Source: src, Dir: dir})
	if pm == "bun" {
		v := pmVer
		if v == "" {
			v, _ = d.versionFile(dir, ".bun-version")
		}
		d.add(domain.Toolchain{Tool: "bun", Version: v, Source: join(dir, "package.json"), Dir: dir})
	}

	isWorkspaceRoot := func(p string) bool {
		if !d.t.has(p, "package.json") {
			return false
		}
		if d.t.has(p, "pnpm-workspace.yaml") || d.t.has(p, "lerna.json") || d.t.has(p, "nx.json") || d.t.has(p, "turbo.json") {
			return true
		}
		var root packageJSON
		_ = json.Unmarshal(d.t[join(p, "package.json")], &root)
		return len(root.Workspaces) > 0 && string(root.Workspaces) != "null"
	}
	if d.coveredBy(dir, isWorkspaceRoot) {
		return true
	}

	hasLock := d.t.has(dir, "package-lock.json") || d.t.has(dir, "npm-shrinkwrap.json")
	install, run := "npm install", "npm run "
	switch pm {
	case "pnpm":
		install, run = "pnpm install --frozen-lockfile", "pnpm run "
	case "yarn":
		install, run = "yarn install", "yarn run "
	case "bun":
		install, run = "bun install", "bun run "
	default:
		if hasLock {
			install = "npm ci"
		}
	}
	script := func(names ...string) string {
		for _, n := range names {
			if c, ok := pkg.Scripts[n]; ok && !strings.Contains(c, "no test specified") {
				return n
			}
		}
		return ""
	}
	s := d.steps(dir)
	s.build = append(s.build, install)
	if n := script("build"); n != "" {
		s.build = append(s.build, run+n)
	}
	for _, n := range []string{script("lint"), script("typecheck", "type-check", "check-types", "tsc")} {
		if n != "" {
			s.lint = append(s.lint, run+n)
		}
	}
	if n := script("test", "test:unit", "unit"); n != "" {
		s.test = append(s.test, run+n)
	}
	return true
}

func (d *detector) denoProject(dir string) bool {
	if !d.t.has(dir, "deno.json") && !d.t.has(dir, "deno.jsonc") {
		return false
	}
	v, src := d.versionFile(dir, ".dvmrc")
	if v == "" {
		v, src = "latest", "default"
	}
	d.add(domain.Toolchain{Tool: "deno", Version: strings.TrimPrefix(v, "v"), Source: src, Dir: dir})
	if d.t.has(dir, "package.json") {
		return true // the Node detector already suggested commands
	}
	var cfg struct {
		Tasks map[string]string `json:"tasks"`
	}
	_ = json.Unmarshal(d.t[join(dir, "deno.json")], &cfg)
	s := d.steps(dir)
	if _, ok := cfg.Tasks["build"]; ok {
		s.build = append(s.build, "deno task build")
	}
	s.lint = append(s.lint, "deno lint")
	if _, ok := cfg.Tasks["test"]; ok {
		s.test = append(s.test, "deno task test")
	} else {
		s.test = append(s.test, "deno test --allow-all")
	}
	return true
}

var (
	requiresPythonRe = regexp.MustCompile(`(?m)^requires-python\s*=\s*["']([^"']+)["']`)
	poetryPythonRe   = regexp.MustCompile(`(?m)^python\s*=\s*["']([^"']+)["']`)
	runtimeTxtRe     = regexp.MustCompile(`python-(\d+\.\d+(?:\.\d+)?)`)
	optionalDevRe    = regexp.MustCompile(`(?m)^\s*(dev|test|tests|testing)\s*=\s*\[`)
)

func (d *detector) pythonProject(dir string) bool {
	t := d.t
	markers := []string{"pyproject.toml", "requirements.txt", "setup.py", "setup.cfg", "Pipfile", "manage.py"}
	if !slices.ContainsFunc(markers, func(m string) bool { return t.has(dir, m) }) {
		return false
	}
	pyproject := t.read(dir, "pyproject.toml")
	ver, src := d.versionFile(dir, ".python-version")
	if ver == "" {
		if v := find(runtimeTxtRe, t.read(dir, "runtime.txt")); v != "" {
			ver, src = v, join(dir, "runtime.txt")
		}
	}
	if ver == "" {
		c := find(requiresPythonRe, pyproject)
		if c == "" {
			c = find(poetryPythonRe, pyproject)
		}
		if v := pythonVersion(c); v != "" {
			ver, src = v, join(dir, "pyproject.toml")
		}
	}
	if ver == "" {
		ver, src = "3.12", "default"
	}
	d.add(domain.Toolchain{Tool: "python", Version: ver, Source: src, Dir: dir})

	reqs := []string{}
	for _, f := range []string{"requirements.txt", "requirements-dev.txt", "dev-requirements.txt", "requirements_dev.txt", "requirements/dev.txt", "requirements/test.txt"} {
		if t.has(dir, f) {
			reqs = append(reqs, f)
		}
	}
	all := pyproject + t.read(dir, "setup.cfg") + t.read(dir, "Pipfile")
	for _, f := range reqs {
		all += t.read(dir, f)
	}

	s := d.steps(dir)
	switch {
	case t.has(dir, "uv.lock") || strings.Contains(pyproject, "[tool.uv]"):
		d.add(domain.Toolchain{Tool: "uv", Version: "latest", Source: join(dir, "uv.lock"), Dir: dir})
		if t.has(dir, "uv.lock") {
			s.build = append(s.build, "uv sync --frozen")
		} else {
			s.build = append(s.build, "uv sync")
		}
	case t.has(dir, "poetry.lock") || strings.Contains(pyproject, "[tool.poetry]"):
		s.build = append(s.build, "pip install -q poetry && poetry install --no-interaction")
	case t.has(dir, "Pipfile"):
		s.build = append(s.build, "pip install -q pipenv && pipenv install --dev --system")
	case t.has(dir, "pdm.lock"):
		s.build = append(s.build, "pip install -q pdm && pdm sync --dev")
	case len(reqs) > 0:
		cmd := "pip install"
		for _, f := range reqs {
			cmd += " -r " + f
		}
		s.build = append(s.build, cmd)
	case pyproject != "" || t.has(dir, "setup.py"):
		if optionalDevRe.MatchString(pyproject) {
			extra := find(optionalDevRe, pyproject)
			s.build = append(s.build, "pip install -e '.["+extra+"]'")
		} else {
			s.build = append(s.build, "pip install -e .")
		}
	}

	if strings.Contains(all, "ruff") || t.has(dir, "ruff.toml") || t.has(dir, ".ruff.toml") {
		d.add(domain.Toolchain{Tool: "ruff", Version: "latest", Source: join(dir, "pyproject.toml"), Dir: dir})
		s.lint = append(s.lint, "ruff check .")
	} else if t.has(dir, ".flake8") || strings.Contains(all, "flake8") {
		s.lint = append(s.lint, "python -m flake8")
	}

	switch {
	case strings.Contains(all, "pytest") || t.has(dir, "pytest.ini") || t.has(dir, "conftest.py") || t.has(dir, "tox.ini"):
		s.test = append(s.test, "python -m pytest")
	case t.has(dir, "manage.py"):
		s.test = append(s.test, "python manage.py test")
	case t.hasDir(dir, "tests") || t.hasDir(dir, "test"):
		s.test = append(s.test, "python -m unittest discover")
	}
	return true
}

var (
	rustChannelRe = regexp.MustCompile(`(?m)^\s*channel\s*=\s*["']([^"']+)["']`)
	cargoWsRe     = regexp.MustCompile(`(?m)^\[workspace\]`)
)

func (d *detector) rustProject(dir string) bool {
	if !d.t.has(dir, "Cargo.toml") {
		return false
	}
	ver, src := "", ""
	for _, p := range []string{dir, ""} {
		if v := find(rustChannelRe, d.t.read(p, "rust-toolchain.toml")); v != "" {
			ver, src = v, join(p, "rust-toolchain.toml")
			break
		}
		if v := firstLine(d.t.read(p, "rust-toolchain")); v != "" {
			ver, src = v, join(p, "rust-toolchain")
			break
		}
	}
	if ver == "" {
		ver, src = "stable", "default"
	}
	d.add(domain.Toolchain{Tool: "rust", Version: ver, Source: src, Dir: dir})
	if d.coveredBy(dir, func(p string) bool { return cargoWsRe.MatchString(d.t.read(p, "Cargo.toml")) }) {
		return true
	}
	s := d.steps(dir)
	if d.t.has(dir, "Cargo.lock") {
		s.build = append(s.build, "cargo build --locked")
	} else {
		s.build = append(s.build, "cargo build")
	}
	s.lint = append(s.lint, "cargo clippy --all-targets")
	s.test = append(s.test, "cargo test")
	return true
}

var (
	pomJavaRe    = regexp.MustCompile(`<(?:maven\.compiler\.release|maven\.compiler\.source|java\.version|release)>\s*([0-9.]+)\s*<`)
	pomModulesRe = regexp.MustCompile(`<modules>`)
	gradleJavaRe = regexp.MustCompile(`(?:JavaLanguageVersion\.of\(\s*|JavaVersion\.VERSION_|sourceCompatibility\s*=\s*['"]?|jvmTarget\s*=\s*['"]|JvmTarget\.JVM_)(\d+(?:[._]\d+)?)`)
	sdkmanJavaRe = regexp.MustCompile(`(?m)^java\s*=\s*(\S+)`)
)

func (d *detector) javaVersion(dir, buildFile string) (string, string) {
	if v, src := d.versionFile(dir, ".java-version"); v != "" {
		if strings.IndexFunc(v, func(r rune) bool { return r >= 'a' && r <= 'z' }) >= 0 {
			return v, src // vendor-qualified, e.g. temurin-17.0.2
		}
		return "temurin-" + javaMajor(v), src
	}
	for _, p := range []string{dir, ""} {
		if v := find(sdkmanJavaRe, d.t.read(p, ".sdkmanrc")); v != "" {
			return "temurin-" + javaMajor(v), join(p, ".sdkmanrc")
		}
	}
	if v := find(pomJavaRe, d.t.read(dir, buildFile)); v != "" && buildFile == "pom.xml" {
		return "temurin-" + javaMajor(v), join(dir, buildFile)
	}
	if v := find(gradleJavaRe, d.t.read(dir, buildFile)); v != "" {
		return "temurin-" + javaMajor(strings.ReplaceAll(v, "_", ".")), join(dir, buildFile)
	}
	return "temurin-21", "default"
}

func (d *detector) javaProject(dir string) bool {
	t := d.t
	switch {
	case t.has(dir, "pom.xml"):
		v, src := d.javaVersion(dir, "pom.xml")
		d.add(domain.Toolchain{Tool: "java", Version: v, Source: src, Dir: dir})
		if d.coveredBy(dir, func(p string) bool { return pomModulesRe.MatchString(t.read(p, "pom.xml")) }) {
			return true
		}
		mvn := "./mvnw"
		if !t.has(dir, "mvnw") {
			mvn = "mvn"
			d.add(domain.Toolchain{Tool: "maven", Version: "3", Source: "default", Dir: dir})
		}
		s := d.steps(dir)
		s.build = append(s.build, mvn+" -B -q -DskipTests package")
		s.test = append(s.test, mvn+" -B -q test")
		return true
	case t.has(dir, "build.gradle") || t.has(dir, "build.gradle.kts") || t.has(dir, "settings.gradle") || t.has(dir, "settings.gradle.kts"):
		file := "build.gradle.kts"
		if !t.has(dir, file) {
			file = "build.gradle"
		}
		v, src := d.javaVersion(dir, file)
		d.add(domain.Toolchain{Tool: "java", Version: v, Source: src, Dir: dir})
		if strings.Contains(t.read(dir, file), "com.android") {
			d.note("Android project in " + orRoot(dir) + ": Android builds need the Android SDK, which the runner image does not include. Use a custom runner image for build and test.")
			return true
		}
		isRoot := func(p string) bool { return t.has(p, "settings.gradle") || t.has(p, "settings.gradle.kts") }
		if d.coveredBy(dir, isRoot) {
			return true
		}
		g := "./gradlew"
		if !t.has(dir, "gradlew") {
			g = "gradle"
			d.add(domain.Toolchain{Tool: "gradle", Version: "latest", Source: "default", Dir: dir})
		}
		s := d.steps(dir)
		s.build = append(s.build, g+" --no-daemon -q assemble")
		s.test = append(s.test, g+" --no-daemon -q test")
		return true
	case t.has(dir, "build.sbt"):
		v, src := d.javaVersion(dir, "build.sbt")
		d.add(domain.Toolchain{Tool: "java", Version: v, Source: src, Dir: dir})
		d.add(domain.Toolchain{Tool: "sbt", Version: "latest", Source: "default", Dir: dir})
		s := d.steps(dir)
		s.build = append(s.build, "sbt -batch compile")
		s.test = append(s.test, "sbt -batch test")
		return true
	case t.has(dir, "deps.edn") || t.has(dir, "project.clj"):
		v, src := d.javaVersion(dir, "")
		d.add(domain.Toolchain{Tool: "java", Version: v, Source: src, Dir: dir})
		d.note("Clojure project in " + orRoot(dir) + ": Java is installed, but the Clojure CLI and Leiningen are not. Use a custom runner image, or set the commands by hand.")
		return true
	}
	return false
}

var (
	globalJSONRe = regexp.MustCompile(`"version"\s*:\s*"([^"]+)"`)
	targetFwRe   = regexp.MustCompile(`<TargetFrameworks?>\s*net(?:coreapp)?(\d+\.\d+)`)
	netFxRe      = regexp.MustCompile(`<TargetFrameworks?>\s*net[1-4]\d`)
)

func (d *detector) dotnetProject(dir string) bool {
	t := d.t
	slns := t.glob(dir, ".sln")
	projs := append(append(t.glob(dir, ".csproj"), t.glob(dir, ".fsproj")...), t.glob(dir, ".vbproj")...)
	if len(slns) == 0 && len(projs) == 0 {
		return false
	}
	ver, src := "", ""
	for _, p := range []string{dir, ""} {
		if v := find(globalJSONRe, t.read(p, "global.json")); v != "" {
			ver, src = v, join(p, "global.json")
			break
		}
	}
	if ver == "" {
		// A solution's projects usually live in subdirectories.
		base, candidates := dir, projs
		if len(candidates) == 0 {
			base = ""
			for p := range t {
				if (strings.HasSuffix(p, ".csproj") || strings.HasSuffix(p, ".fsproj")) && strings.HasPrefix(p, join(dir, "")) {
					candidates = append(candidates, p)
				}
			}
			slices.Sort(candidates)
		}
		for _, p := range candidates {
			body := t.read(base, p)
			if netFxRe.MatchString(body) {
				d.note(p + " targets the .NET Framework, which only runs on Windows; the runner can build .NET (Core) 5+ only.")
			}
			if v := find(targetFwRe, body); v != "" {
				ver, src = strings.SplitN(v, ".", 2)[0], join(base, p)
				if strings.HasPrefix(v, "3.") || strings.HasPrefix(v, "2.") {
					ver = v
				}
				break
			}
		}
	}
	if ver == "" {
		ver, src = "10", "default"
	}
	d.add(domain.Toolchain{Tool: "dotnet", Version: ver, Source: src, Dir: dir})
	if d.coveredBy(dir, func(p string) bool { return len(t.glob(p, ".sln")) > 0 }) {
		return true
	}
	target := ""
	switch {
	case len(slns) > 0:
		target = " " + shellQuote(slns[0])
	case len(projs) > 1:
		target = " " + shellQuote(projs[0])
	}
	s := d.steps(dir)
	s.build = append(s.build, "dotnet build"+target)
	s.lint = append(s.lint, "dotnet format"+target+" --verify-no-changes")
	s.test = append(s.test, "dotnet test"+target)
	return true
}

var gemfileRubyRe = regexp.MustCompile(`(?m)^\s*ruby\s+["']([^"']+)["']`)

func (d *detector) rubyProject(dir string) bool {
	t := d.t
	if !t.has(dir, "Gemfile") {
		return false
	}
	ver, src := d.versionFile(dir, ".ruby-version")
	ver = strings.TrimPrefix(ver, "ruby-")
	if ver == "" {
		if v := find(gemfileRubyRe, t.read(dir, "Gemfile")); v != "" {
			if r := rangeVersion(v); r != "" {
				ver, src = r, join(dir, "Gemfile")
			}
		}
	}
	if ver == "" {
		ver, src = "3.4", "default"
	}
	d.add(domain.Toolchain{Tool: "ruby", Version: ver, Source: src, Dir: dir})
	gemfile := t.read(dir, "Gemfile")
	s := d.steps(dir)
	s.build = append(s.build, "bundle install")
	if t.has(dir, ".rubocop.yml") || strings.Contains(gemfile, "rubocop") {
		s.lint = append(s.lint, "bundle exec rubocop")
	}
	switch {
	case t.hasDir(dir, "spec") || strings.Contains(gemfile, "rspec"):
		s.test = append(s.test, "bundle exec rspec")
	case t.has(dir, "bin/rails"):
		s.test = append(s.test, "bin/rails test")
	case t.has(dir, "Rakefile"):
		s.test = append(s.test, "bundle exec rake test")
	}
	return true
}

func (d *detector) phpProject(dir string) bool {
	t := d.t
	if !t.has(dir, "composer.json") {
		return false
	}
	// PHP has no prebuilt mise backend; the runner image ships PHP and
	// Composer, so the toolchain is "system".
	d.add(domain.Toolchain{Tool: "php", Version: "system", Source: "runner image", Dir: dir})
	s := d.steps(dir)
	s.build = append(s.build, "composer install --no-interaction --no-progress")
	if t.has(dir, "phpstan.neon") || t.has(dir, "phpstan.neon.dist") {
		s.lint = append(s.lint, "vendor/bin/phpstan analyse --no-progress")
	}
	switch {
	case t.has(dir, "artisan"):
		s.test = append(s.test, "php artisan test")
	case t.has(dir, "phpunit.xml") || t.has(dir, "phpunit.xml.dist"):
		s.test = append(s.test, "vendor/bin/phpunit")
	}
	return true
}

var mixElixirRe = regexp.MustCompile(`elixir:\s*"([^"]+)"`)

func (d *detector) elixirProject(dir string) bool {
	if !d.t.has(dir, "mix.exs") {
		return false
	}
	v, src := rangeVersion(find(mixElixirRe, d.t.read(dir, "mix.exs"))), join(dir, "mix.exs")
	if v == "" {
		v, src = "latest", "default"
	}
	d.add(domain.Toolchain{Tool: "erlang", Version: "latest", Source: "default", Dir: dir})
	d.add(domain.Toolchain{Tool: "elixir", Version: v, Source: src, Dir: dir})
	if d.coveredBy(dir, func(p string) bool { return d.t.has(p, "mix.exs") }) {
		return true // an umbrella app's child
	}
	s := d.steps(dir)
	s.build = append(s.build, "mix local.hex --force --if-missing && mix local.rebar --force --if-missing && mix deps.get && mix compile")
	s.lint = append(s.lint, "mix format --check-formatted")
	s.test = append(s.test, "mix test")
	return true
}

func (d *detector) gleamProject(dir string) bool {
	if !d.t.has(dir, "gleam.toml") {
		return false
	}
	d.add(domain.Toolchain{Tool: "erlang", Version: "latest", Source: "default", Dir: dir})
	d.add(domain.Toolchain{Tool: "gleam", Version: "latest", Source: "default", Dir: dir})
	s := d.steps(dir)
	s.build = append(s.build, "gleam build")
	s.lint = append(s.lint, "gleam format --check")
	s.test = append(s.test, "gleam test")
	return true
}

var pubspecSDKRe = regexp.MustCompile(`(?m)^\s+sdk:\s*["']?([^"'\n]+)`)

func (d *detector) dartProject(dir string) bool {
	if !d.t.has(dir, "pubspec.yaml") {
		return false
	}
	body := d.t.read(dir, "pubspec.yaml")
	if strings.Contains(body, "sdk: flutter") {
		d.note("Flutter project in " + orRoot(dir) + ": the Flutter SDK has to write into its own install directory, which the shared toolchain volume does not allow. Use a custom runner image with Flutter for build and test.")
		return true
	}
	v, src := rangeVersion(find(pubspecSDKRe, body)), join(dir, "pubspec.yaml")
	if v == "" {
		v, src = "latest", "default"
	}
	d.add(domain.Toolchain{Tool: "dart", Version: v, Source: src, Dir: dir})
	s := d.steps(dir)
	s.build = append(s.build, "dart pub get")
	s.lint = append(s.lint, "dart analyze")
	if d.t.hasDir(dir, "test") {
		s.test = append(s.test, "dart test")
	}
	return true
}

var zigMinRe = regexp.MustCompile(`minimum_zig_version\s*=\s*"([^"]+)"`)

func (d *detector) zigProject(dir string) bool {
	if !d.t.has(dir, "build.zig") {
		return false
	}
	v, src := find(zigMinRe, d.t.read(dir, "build.zig.zon")), join(dir, "build.zig.zon")
	if v == "" {
		v, src = "latest", "default"
	}
	d.add(domain.Toolchain{Tool: "zig", Version: v, Source: src, Dir: dir})
	s := d.steps(dir)
	s.build = append(s.build, "zig build")
	s.test = append(s.test, "zig build test")
	return true
}

func (d *detector) swiftProject(dir string) bool {
	if !d.t.has(dir, "Package.swift") {
		return false
	}
	d.add(domain.Toolchain{Tool: "swift", Version: "latest", Source: "default", Dir: dir})
	s := d.steps(dir)
	s.build = append(s.build, "swift build")
	s.test = append(s.test, "swift test")
	return true
}

// otherProject covers languages with a single obvious build tool.
func (d *detector) otherProject(dir string) bool {
	t := d.t
	found := false
	simple := func(marker, tool string, build, test string) {
		if !t.has(dir, marker) {
			return
		}
		found = true
		d.add(domain.Toolchain{Tool: tool, Version: "latest", Source: "default", Dir: dir})
		s := d.steps(dir)
		if build != "" {
			s.build = append(s.build, build)
		}
		if test != "" {
			s.test = append(s.test, test)
		}
	}
	simple("stack.yaml", "stack", "stack build", "stack test")
	simple("shard.yml", "crystal", "shards install", "crystal spec")
	if t.has(dir, "Project.toml") && strings.Contains(t.read(dir, "Project.toml"), "uuid") {
		simple("Project.toml", "julia", `julia --project -e 'using Pkg; Pkg.instantiate()'`, `julia --project -e 'using Pkg; Pkg.test()'`)
	}
	if nimble := t.glob(dir, ".nimble"); len(nimble) > 0 {
		simple(nimble[0], "nim", "nimble build -y", "nimble test -y")
	}
	if !found && t.has(dir, "elm.json") && !t.has(dir, "package.json") {
		simple("elm.json", "elm", "elm make src/Main.elm --output=/dev/null", "")
	}
	if !found && len(t.glob(dir, ".cabal")) > 0 && !t.has(dir, "stack.yaml") {
		found = true
		d.note("Haskell project in " + orRoot(dir) + " without stack.yaml: install GHC and Cabal through mise.toml (ghc via a prebuilt backend is not available), or use a custom runner image.")
	}
	if !found && t.has(dir, "CMakeLists.txt") && !d.hasOtherProject(dir) {
		found = true
		d.add(domain.Toolchain{Tool: "cmake", Version: "latest", Source: "default", Dir: dir})
		s := d.steps(dir)
		s.build = append(s.build, "cmake -S . -B build && cmake --build build -j2")
		s.test = append(s.test, "ctest --test-dir build --output-on-failure")
	}
	return found
}

// hasOtherProject reports whether a detector already added commands for dir.
func (d *detector) hasOtherProject(dir string) bool {
	_, ok := d.cmds[dir]
	return ok
}

var makeTargetRe = regexp.MustCompile(`(?m)^([A-Za-z0-9_.-]+)\s*:`)

func (d *detector) makeProject(dir string) {
	body := d.t.read(dir, "Makefile") + d.t.read(dir, "makefile") + d.t.read(dir, "GNUmakefile")
	targets := map[string]bool{}
	for _, m := range makeTargetRe.FindAllStringSubmatch(body, -1) {
		targets[m[1]] = true
	}
	pick := func(names ...string) string {
		for _, n := range names {
			if targets[n] {
				return "make " + n
			}
		}
		return ""
	}
	b, l, ts := pick("build", "all"), pick("lint", "check"), pick("test", "tests", "check")
	if b == "" && l == "" && ts == "" {
		return
	}
	if l == ts {
		l = ""
	}
	s := d.steps(dir)
	for _, x := range []struct {
		dst *[]string
		cmd string
	}{{&s.build, b}, {&s.lint, l}, {&s.test, ts}} {
		if x.cmd != "" {
			*x.dst = append(*x.dst, x.cmd)
		}
	}
}

func orRoot(dir string) string {
	if dir == "" {
		return "the repository root"
	}
	return dir + "/"
}
