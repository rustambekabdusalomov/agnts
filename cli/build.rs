// The CLI embeds deploy/ so the stack it writes always matches its version.
// Fail early with a clear message when building outside the monorepo.

const DEPLOY_FILES: &[&str] = &[
    "docker-compose.yml",
    "Caddyfile",
    "backup.sh",
    ".env.example",
    "runner/Dockerfile",
    "runner/README.md",
    "runner/managed-settings.json",
];

fn main() {
    for f in DEPLOY_FILES {
        let path = format!("../deploy/{f}");
        if !std::path::Path::new(&path).exists() {
            panic!("missing {path}: the agnts CLI must be built from the agnts monorepo");
        }
        println!("cargo:rerun-if-changed={path}");
    }
    let target = std::env::var("TARGET").unwrap_or_default();
    println!("cargo:rustc-env=AGNTS_TARGET={target}");
}
