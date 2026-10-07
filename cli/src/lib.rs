//! The agnts CLI: installs agnts on a Linux server (over SSH, or on the
//! server itself) and manages it afterwards. See `CLI plan.md`.

pub mod assets;
pub mod capacity;
pub mod cli;
pub mod cloud;
pub mod cmd;
pub mod compose;
pub mod dns;
pub mod env_file;
pub mod ops;
pub mod preflight;
pub mod profile;
pub mod secrets;
pub mod shell;
pub mod steps;
pub mod target;
pub mod tls;
pub mod ui;
pub mod wait;

/// The CLI version; also the image tag it installs by default.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
/// Rust target triple this binary was built for (self-update picks assets by it).
pub const TARGET: &str = env!("AGNTS_TARGET");
