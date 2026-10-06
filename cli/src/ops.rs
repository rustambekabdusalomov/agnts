//! Operations shared by the install steps and the day-2 commands.

use std::net::{Ipv4Addr, Ipv6Addr};
use std::sync::mpsc;
use std::time::{Duration, Instant};

use anyhow::{bail, Context, Result};

use crate::assets;
use crate::compose;
use crate::dns;
use crate::target::{Cmd, Target};
use crate::ui;
use crate::wait::{self, Attempt, Policy};

/// Write the embedded deploy files. Returns the paths that changed.
pub fn write_files(t: &dyn Target) -> Result<Vec<&'static str>> {
    let mut changed = Vec::new();
    for a in assets::FILES {
        let p = compose::path(a.path);
        let current = t.read_file(&p)?;
        if current.as_deref() != Some(a.content.as_bytes()) {
            t.write_file(&p, a.content.as_bytes(), a.mode)?;
            changed.push(a.path);
        }
    }
    Ok(changed)
}

/// Embedded files that differ from what is on the server.
pub fn files_outdated(t: &dyn Target) -> Result<Vec<&'static str>> {
    let mut v = Vec::new();
    for a in assets::FILES {
        if t.read_file(&compose::path(a.path))?.as_deref() != Some(a.content.as_bytes()) {
            v.push(a.path);
        }
    }
    Ok(v)
}

/// Single-file bind mounts keep the old file after it is replaced, so restart
/// the services whose mounted files changed.
pub fn services_for_changed(changed: &[&str]) -> Vec<&'static str> {
    let mut s = Vec::new();
    if changed.contains(&"Caddyfile") {
        s.push("caddy");
    }
    if changed.contains(&"backup.sh") {
        s.push("backup");
    }
    s
}

/// The server's install id, created on first use.
pub fn install_id(t: &dyn Target, create: bool) -> Result<Option<String>> {
    let p = compose::path("install-id");
    if let Some(id) = t.read_text(&p)? {
        let id = id.trim().to_string();
        if !id.is_empty() {
            return Ok(Some(id));
        }
    }
    if !create {
        return Ok(None);
    }
    let id = uuid::Uuid::new_v4().to_string();
    t.write_file(&p, format!("{id}\n").as_bytes(), 0o644)?;
    Ok(Some(id))
}

/// Sort a failed docker command: registry outages wait, bad keys stop.
pub fn classify_docker(stderr: &str, registry: &str) -> Attempt {
    let s = stderr.to_lowercase();
    let mentions_registry = s.contains(&registry.to_lowercase());
    if mentions_registry
        && (s.contains("unauthorized")
            || s.contains("denied")
            || s.contains("401")
            || s.contains("403"))
    {
        return Attempt::Fatal(
            crate::cloud::KeyError::Rejected(format!("{registry} refused the key")).into(),
        );
    }
    let transient = [
        "502",
        "503",
        "504",
        "bad gateway",
        "service unavailable",
        "gateway timeout",
        "timeout",
        "timed out",
        "connection refused",
        "connection reset",
        "no such host",
        "eof",
        "tls handshake",
        "temporary failure",
    ];
    if mentions_registry && transient.iter().any(|p| s.contains(p)) {
        let reason = stderr
            .lines()
            .rev()
            .find(|l| !l.trim().is_empty())
            .unwrap_or("")
            .trim();
        return Attempt::Down {
            reason: reason.chars().take(120).collect(),
            retry_after: None,
        };
    }
    Attempt::Fatal(anyhow::anyhow!(
        "{}",
        crate::target::last_lines(stderr.trim(), 15)
    ))
}

/// `docker login` to the registry as this install.
pub fn registry_login(t: &dyn Target, policy: &Policy, install_id: &str, key: &str) -> Result<()> {
    let registry = compose::registry();
    wait::until_up(&registry, policy, || {
        let out = t
            .run(
                &Cmd::new([
                    "docker",
                    "login",
                    &registry,
                    "--username",
                    install_id,
                    "--password-stdin",
                ])
                .stdin(key.as_bytes().to_vec()),
            )
            .map_err(Attempt::Fatal)?;
        if out.success() {
            return Ok(());
        }
        // docker login does not always name the registry in its errors.
        let msg = format!("{registry}: {}", out.stderr);
        Err(classify_docker(&msg, &registry))
    })
}

/// Pull every image the stack uses, including the runner.
pub fn pull(t: &dyn Target, policy: &Policy) -> Result<()> {
    let registry = compose::registry();
    let pb = ui::spinner("pulling images (the first pull takes a few minutes)");
    let r = wait::until_up(&registry, policy, || {
        let out = t
            .run(&compose::cmd(&["--profile", "build", "pull", "--quiet"]))
            .map_err(Attempt::Fatal)?;
        if out.success() {
            Ok(())
        } else {
            Err(classify_docker(&out.stderr, &registry))
        }
    });
    pb.finish_and_clear();
    r
}

pub fn up(t: &dyn Target, extra: &[&str]) -> Result<()> {
    let mut args = vec!["up", "-d", "--remove-orphans"];
    args.extend_from_slice(extra);
    t.run(&compose::cmd(&args))?.check("docker compose up")?;
    Ok(())
}

pub fn https_ok(domain: &str) -> bool {
    let Ok(c) = reqwest::blocking::Client::builder()
        .timeout(Duration::from_secs(10))
        .build()
    else {
        return false;
    };
    c.get(format!("https://{domain}/healthz"))
        .send()
        .is_ok_and(|r| r.status().is_success())
}

/// Wait for Caddy to get a certificate and agnts to answer over HTTPS.
pub fn wait_https(t: &dyn Target, domain: &str, timeout: Duration) -> Result<()> {
    let pb = ui::spinner(&format!(
        "waiting for https://{domain} (getting a certificate)"
    ));
    let start = Instant::now();
    while start.elapsed() < timeout {
        if https_ok(domain) {
            pb.finish_and_clear();
            return Ok(());
        }
        std::thread::sleep(Duration::from_secs(5));
    }
    pb.finish_and_clear();
    let logs = t.run(&compose::cmd(&["logs", "--tail", "20", "caddy"]))?;
    bail!(
        "https://{domain} did not come up within {}s. Check that the DNS record is right and ports 80 and 443 are open in your provider's firewall.\nLast Caddy logs:\n{}",
        timeout.as_secs(),
        String::from_utf8_lossy(&logs.stdout)
    )
}

/// The server's public addresses, as seen from outside.
pub fn public_ip(t: &dyn Target) -> Result<(Ipv4Addr, Option<Ipv6Addr>)> {
    let cloud =
        std::env::var("AGNTS_CLOUD_URL").unwrap_or_else(|_| crate::cloud::DEFAULT_URL.into());
    let sources = [
        format!("{cloud}/api/ip"),
        "https://api.ipify.org".into(),
        "https://ifconfig.me/ip".into(),
    ];
    let fetch = |flag: &str| -> Option<String> {
        sources.iter().find_map(|u| {
            let out = t
                .run(&Cmd::new(["curl", flag, "-fsS", "--max-time", "8", u]))
                .ok()?;
            out.success().then(|| out.text())
        })
    };
    let v4 = fetch("-4")
        .and_then(|s| s.parse().ok())
        .context("could not find the server's public IPv4 address (is curl installed and outbound HTTPS allowed?)")?;
    let v6 = fetch("-6").and_then(|s| s.parse().ok());
    Ok((v4, v6))
}

/// Show the DNS record to create and wait until public resolvers return it.
pub fn wait_dns(domain: &str, v4: Ipv4Addr, v6: Option<Ipv6Addr>) -> Result<()> {
    let first = dns::check(domain, v4, v6);
    if first.ok {
        ui::ok(&format!("{domain} {}", first.message));
        return Ok(());
    }
    ui::info(&format!("{domain}: {}.", first.message));
    ui::info("Create this record at your DNS provider:");
    ui::info("");
    ui::info(&format!(
        "    Type   Name{}Value",
        " ".repeat(domain.len().saturating_sub(1))
    ));
    ui::info(&format!("    A      {domain}   {v4}"));
    if let Some(v6) = v6 {
        ui::info(&format!("    AAAA   {domain}   {v6}   (optional)"));
    }
    ui::info("");
    let unattended = !ui::interactive();
    if unattended {
        ui::info("Checking every 10 seconds for up to 30 minutes.");
    } else {
        ui::info("Checking every 10 seconds. Press Enter to check now; Ctrl+C stops (agnts install resumes here).");
    }

    // Enter re-checks immediately.
    let (tx, rx) = mpsc::channel::<()>();
    if !unattended {
        std::thread::spawn(move || {
            let mut line = String::new();
            while std::io::stdin().read_line(&mut line).is_ok_and(|n| n > 0) {
                if tx.send(()).is_err() {
                    break;
                }
                line.clear();
            }
        });
    }
    let start = Instant::now();
    let pb = ui::spinner("waiting for DNS");
    loop {
        let _ = rx.recv_timeout(Duration::from_secs(10));
        let v = dns::check(domain, v4, v6);
        if v.ok {
            pb.finish_and_clear();
            ui::ok(&format!("{domain} {}", v.message));
            return Ok(());
        }
        pb.set_message(format!(
            "waiting for DNS {}  ({})",
            ui::mmss(start.elapsed()),
            v.message
        ));
        if unattended && start.elapsed() > Duration::from_secs(1800) {
            pb.finish_and_clear();
            bail!("{domain} still does not point at {v4}: {}", v.message);
        }
    }
}

/// Take a database backup now. Returns the file name under backups/.
pub fn backup_now(t: &dyn Target) -> Result<String> {
    let script = r#"set -eu
ts=$(date +%Y-%m-%dT%H%M%S)
tmp="/backups/.agnts-$ts.dump.partial"
pg_dump --format=custom --file="$tmp"
mv "$tmp" "/backups/agnts-$ts.dump"
echo "agnts-$ts.dump""#;
    let mut c = compose::cmd(&["exec", "-T", "backup", "sh", "-c", script]);
    c.args.push("sh".into());
    let out = t.run(&c)?.check("backup")?;
    Ok(out.text().lines().last().unwrap_or_default().to_string())
}

/// Backup files on the server, oldest first.
pub fn list_backups(t: &dyn Target) -> Result<Vec<String>> {
    let out = t.run(&Cmd::new(["ls", "-1", &compose::path("backups")]))?;
    let mut v: Vec<String> = out
        .text()
        .lines()
        .filter(|l| l.starts_with("agnts-") && l.ends_with(".dump"))
        .map(str::to_string)
        .collect();
    v.sort();
    Ok(v)
}

/// Whether the admin user exists yet.
pub fn has_user(t: &dyn Target) -> Result<bool> {
    let out = t.run(&compose::cmd(&[
        "exec",
        "-T",
        "postgres",
        "psql",
        "-U",
        "hiro",
        "-d",
        "hiro",
        "-tAc",
        "select count(*) from users",
    ]))?;
    Ok(out.success() && out.text().parse::<u64>().unwrap_or(0) > 0)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::target::FakeTarget;

    #[test]
    fn classifies_docker_errors() {
        let r = "registry.agnts.uz";
        assert!(matches!(
            classify_docker("Error response from daemon: Get \"https://registry.agnts.uz/v2/\": 503 Service Unavailable", r),
            Attempt::Down { .. }
        ));
        assert!(matches!(
            classify_docker(
                "Error response from daemon: Get \"https://registry.agnts.uz/v2/\": unauthorized",
                r
            ),
            Attempt::Fatal(_)
        ));
        // Docker Hub trouble is not ours to wait for.
        assert!(matches!(
            classify_docker("docker.io: 503 Service Unavailable", r),
            Attempt::Fatal(_)
        ));
    }

    #[test]
    fn writes_only_changed_files() {
        let t = FakeTarget::new();
        let first = write_files(&t).unwrap();
        assert_eq!(first.len(), assets::FILES.len());
        assert_eq!(t.mode("/opt/agnts/backup.sh"), Some(0o755));
        assert!(write_files(&t).unwrap().is_empty());
        t.put("/opt/agnts/Caddyfile", "old");
        let changed = write_files(&t).unwrap();
        assert_eq!(changed, vec!["Caddyfile"]);
        assert_eq!(services_for_changed(&changed), vec!["caddy"]);
    }

    #[test]
    fn install_id_is_stable() {
        let t = FakeTarget::new();
        assert_eq!(install_id(&t, false).unwrap(), None);
        let a = install_id(&t, true).unwrap().unwrap();
        let b = install_id(&t, true).unwrap().unwrap();
        assert_eq!(a, b);
    }
}
