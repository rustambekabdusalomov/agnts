//! deploy/ embedded at build time. These files are the single source of truth
//! for the stack; the CLI never generates its own variants.

pub const COMPOSE: &str = include_str!("../../deploy/docker-compose.yml");
pub const CADDYFILE: &str = include_str!("../../deploy/Caddyfile");
pub const BACKUP_SH: &str = include_str!("../../deploy/backup.sh");
pub const ENV_EXAMPLE: &str = include_str!("../../deploy/.env.example");

/// A file written under the install directory.
pub struct Asset {
    pub path: &'static str,
    pub content: &'static str,
    pub mode: u32,
}

/// Every file the install directory holds besides `.env` and state.
pub const FILES: &[Asset] = &[
    Asset {
        path: "docker-compose.yml",
        content: COMPOSE,
        mode: 0o644,
    },
    Asset {
        path: "Caddyfile",
        content: CADDYFILE,
        mode: 0o644,
    },
    Asset {
        path: "backup.sh",
        content: BACKUP_SH,
        mode: 0o755,
    },
    // The runner service is build-only; its context must exist for Compose
    // to accept the file, even though the image is pulled.
    Asset {
        path: "runner/Dockerfile",
        content: include_str!("../../deploy/runner/Dockerfile"),
        mode: 0o644,
    },
    Asset {
        path: "runner/README.md",
        content: include_str!("../../deploy/runner/README.md"),
        mode: 0o644,
    },
    Asset {
        path: "runner/managed-settings.json",
        content: include_str!("../../deploy/runner/managed-settings.json"),
        mode: 0o644,
    },
    // Preview tools copied into the image (COPY preview/...).
    Asset {
        path: "runner/preview/package.json",
        content: include_str!("../../deploy/runner/preview/package.json"),
        mode: 0o644,
    },
    Asset {
        path: "runner/preview/agnts-shot.mjs",
        content: include_str!("../../deploy/runner/preview/agnts-shot.mjs"),
        mode: 0o755,
    },
    Asset {
        path: "runner/preview/agnts-preview",
        content: include_str!("../../deploy/runner/preview/agnts-preview"),
        mode: 0o755,
    },
];
