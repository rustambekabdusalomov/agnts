//! The install directory and `docker compose` on the server.

use std::time::{Duration, Instant};

use anyhow::{bail, Result};
use serde::Deserialize;

use crate::env_file::EnvFile;
use crate::target::{Cmd, Target};

pub const DIR: &str = "/opt/agnts";
pub const DEFAULT_REGISTRY: &str = "registry.agnts.uz";

pub fn path(name: &str) -> String {
    format!("{DIR}/{name}")
}

pub fn env_path() -> String {
    path(".env")
}

/// The registry images come from (`AGNTS_REGISTRY` overrides it for testing).
pub fn registry() -> String {
    std::env::var("AGNTS_REGISTRY").unwrap_or_else(|_| DEFAULT_REGISTRY.to_string())
}

/// (agnts image, runner image) for a version.
pub fn images(version: &str) -> (String, String) {
    let r = registry();
    (
        format!("{r}/agnts:{version}"),
        format!("{r}/agnts-runner:{version}"),
    )
}

/// `docker compose -f /opt/agnts/docker-compose.yml <args>`.
pub fn cmd(args: &[&str]) -> Cmd {
    let file = path("docker-compose.yml");
    let mut v = vec!["docker", "compose", "-f", file.as_str()];
    v.extend_from_slice(args);
    Cmd::new(v)
}

pub fn read_env(t: &dyn Target) -> Result<Option<EnvFile>> {
    Ok(t.read_text(&env_path())?.map(|s| EnvFile::parse(&s)))
}

pub fn write_env(t: &dyn Target, env: &EnvFile) -> Result<()> {
    t.write_file(&env_path(), env.render().as_bytes(), 0o600)
}

#[derive(Debug, Deserialize, Clone)]
pub struct Service {
    #[serde(rename = "Service")]
    pub name: String,
    #[serde(rename = "State", default)]
    pub state: String,
    #[serde(rename = "Health", default)]
    pub health: String,
}

impl Service {
    pub fn ready(&self) -> bool {
        self.state == "running" && (self.health.is_empty() || self.health == "healthy")
    }
}

/// Parse `docker compose ps --format json`: a JSON array in older Compose,
/// one object per line in newer releases.
pub fn parse_ps(text: &str) -> Vec<Service> {
    let t = text.trim();
    if t.starts_with('[') {
        return serde_json::from_str(t).unwrap_or_default();
    }
    t.lines()
        .filter_map(|l| serde_json::from_str(l.trim()).ok())
        .collect()
}

pub fn ps(t: &dyn Target) -> Result<Vec<Service>> {
    let out = t
        .run(&cmd(&["ps", "--all", "--format", "json"]))?
        .check("docker compose ps")?;
    Ok(parse_ps(&String::from_utf8_lossy(&out.stdout)))
}

/// The long-running services of the stack (the runner is build-only).
pub const SERVICES: &[&str] = &["caddy", "agnts", "egress", "postgres", "backup"];

/// Every service running, and healthy where it has a health check.
pub fn all_ready(services: &[Service]) -> bool {
    SERVICES
        .iter()
        .all(|name| services.iter().any(|s| s.name == *name && s.ready()))
}

pub fn wait_ready(t: &dyn Target, timeout: Duration) -> Result<()> {
    let pb = crate::ui::spinner("waiting for the containers to become healthy");
    let start = Instant::now();
    loop {
        let services = ps(t)?;
        if all_ready(&services) {
            pb.finish_and_clear();
            return Ok(());
        }
        if start.elapsed() > timeout {
            pb.finish_and_clear();
            let bad: Vec<String> = SERVICES
                .iter()
                .filter_map(|n| match services.iter().find(|s| s.name == *n) {
                    Some(s) if s.ready() => None,
                    Some(s) => Some(format!("{n}: {} {}", s.state, s.health)),
                    None => Some(format!("{n}: not created")),
                })
                .collect();
            let logs = t.run(&cmd(&["logs", "--tail", "30", "agnts"]))?;
            bail!(
                "containers not healthy after {}s ({})\nLast agnts logs:\n{}",
                timeout.as_secs(),
                bad.join(", "),
                String::from_utf8_lossy(&logs.stdout)
            );
        }
        std::thread::sleep(Duration::from_secs(3));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_both_ps_formats() {
        let ndjson = r#"{"Service":"agnts","State":"running","Health":"healthy"}
{"Service":"caddy","State":"running","Health":""}"#;
        let arr = r#"[{"Service":"agnts","State":"exited","Health":""}]"#;
        let a = parse_ps(ndjson);
        assert_eq!(a.len(), 2);
        assert!(a[0].ready() && a[1].ready());
        assert!(!parse_ps(arr)[0].ready());
    }

    #[test]
    fn all_ready_needs_every_service() {
        let mk = |n: &str| Service {
            name: n.into(),
            state: "running".into(),
            health: String::new(),
        };
        let mut s: Vec<Service> = SERVICES.iter().map(|n| mk(n)).collect();
        assert!(all_ready(&s));
        s[1].health = "starting".into();
        assert!(!all_ready(&s));
    }
}
