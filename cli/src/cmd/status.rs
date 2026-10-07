//! `agnts status` and `agnts doctor`.

use anyhow::Result;
use serde::Deserialize;

use crate::cli::Session;
use crate::target::Cmd;
use crate::{capacity, compose, dns, ops, preflight, tls, ui};

#[derive(Deserialize)]
struct VersionJson {
    version: String,
    #[serde(default)]
    commit: String,
}

fn server_version(s: &Session) -> String {
    let out = s.t().run(&compose::cmd(&[
        "exec", "-T", "agnts", "agnts", "version", "--json",
    ]));
    match out {
        Ok(o) if o.success() => match serde_json::from_str::<VersionJson>(&o.text()) {
            Ok(v) if v.commit.is_empty() => v.version,
            Ok(v) => format!("{} ({})", v.version, v.commit),
            Err(_) => o.text(),
        },
        _ => "unknown (agnts is not running)".into(),
    }
}

fn disk_free(s: &Session) -> Option<u64> {
    let out = s.t().run(&Cmd::new(["df", "-Pk", "/"])).ok()?;
    preflight::parse_df_avail_kb(&out.text())
}

/// Sizes of the volumes runs use: the shared toolchains and each
/// repository's package cache, as (name, size) from `docker system df -v`.
fn run_volumes(s: &Session) -> Vec<(String, String)> {
    let out = s.t().run(&Cmd::new([
        "docker",
        "system",
        "df",
        "-v",
        "--format",
        "{{range .Volumes}}{{.Name}}\t{{.Size}}\n{{end}}",
    ]));
    match out {
        Ok(o) if o.success() => parse_run_volumes(&o.text()),
        _ => Vec::new(),
    }
}

fn parse_run_volumes(text: &str) -> Vec<(String, String)> {
    text.lines()
        .filter_map(|l| l.split_once('\t'))
        .filter(|(n, _)| *n == "agnts-toolchains" || n.starts_with("agnts-cache-"))
        .map(|(n, sz)| (n.to_string(), sz.trim().to_string()))
        .collect()
}

fn gb(kb: u64) -> String {
    format!("{:.1} GB", kb as f64 / 1024.0 / 1024.0)
}

pub fn run(s: &Session) -> Result<i32> {
    let domain = s.domain()?;
    ui::header(&format!("agnts at https://{domain}"));
    ui::info(&format!("Server:      {}", s.t().label()));
    ui::info(&format!(
        "Install id:  {}",
        s.install_id().unwrap_or_default()
    ));
    ui::info(&format!("Version:     {}", server_version(s)));

    let services = compose::ps(s.t())?;
    ui::header("Containers");
    for name in compose::SERVICES {
        match services.iter().find(|x| x.name == *name) {
            Some(x) if x.ready() => ui::ok(&format!("{name:<9} {} {}", x.state, x.health)),
            Some(x) => ui::fail(&format!("{name:<9} {} {}", x.state, x.health)),
            None => ui::fail(&format!("{name:<9} not created")),
        }
    }

    ui::header("Health");
    if ops::https_ok(&domain) {
        ui::ok(&format!("https://{domain}/healthz answers"));
    } else {
        ui::fail(&format!("https://{domain}/healthz does not answer"));
    }
    match tls::cert_expiry(&domain) {
        Ok(t) => ui::ok(&format!(
            "certificate valid for {} more days",
            tls::days_left(t)
        )),
        Err(e) => ui::fail(&format!("certificate: {e:#}")),
    }
    if let Some(kb) = disk_free(s) {
        ui::info(&format!("  Free disk:   {}", gb(kb)));
    }
    let vols = run_volumes(s);
    if let Some((_, size)) = vols.iter().find(|(n, _)| n == "agnts-toolchains") {
        ui::info(&format!("  Toolchains:  {size} (installed on first use, shared by runs)"));
    }
    let caches: Vec<_> = vols.iter().filter(|(n, _)| n.starts_with("agnts-cache-")).collect();
    if !caches.is_empty() {
        let list: Vec<String> = caches
            .iter()
            .map(|(n, sz)| format!("{} {sz}", n.trim_start_matches("agnts-cache-")))
            .collect();
        ui::info(&format!("  Pkg caches:  {}", list.join(", ")));
    }
    match ops::list_backups(s.t())?.last() {
        Some(b) => ui::info(&format!("  Last backup: {b}")),
        None => ui::info("  Last backup: none yet (nightly at 03:00, or run `agnts backup`)"),
    }
    Ok(0)
}

pub fn doctor(s: &Session) -> Result<i32> {
    let mut failed = 0;
    let mut report = |ok: bool, name: &str, detail: &str, fix: Option<&str>| {
        if ok {
            ui::ok(&format!("{name}: {detail}"));
        } else {
            failed += 1;
            ui::fail(&format!("{name}: {detail}"));
            if let Some(f) = fix {
                ui::info(&format!("  → {f}"));
            }
        }
    };

    ui::header(&format!("Checking {}", s.t().label()));
    // OS, ports and capacity (no disk write test on a live server).
    let (_, _, fits) = capacity::check(s.t(), true, false)?;
    report(
        fits,
        "Server",
        if fits {
            "fits agnts"
        } else {
            "does not fit agnts"
        },
        None,
    );
    ui::info("");

    let docker = s
        .t()
        .run(&Cmd::new(["docker", "compose", "version", "--short"]))?;
    report(
        docker.success(),
        "Docker Compose",
        &docker.text(),
        Some("run `agnts install` again to install Docker"),
    );

    let outdated = ops::files_outdated(s.t())?;
    report(
        outdated.is_empty(),
        "Stack files",
        &if outdated.is_empty() { "match this CLI".into() } else { format!("differ: {}", outdated.join(", ")) },
        Some("`agnts upgrade` writes this CLI's files (a newer CLI may need `agnts self-update` first)"),
    );

    let services = compose::ps(s.t()).unwrap_or_default();
    let not_ready: Vec<&str> = compose::SERVICES
        .iter()
        .copied()
        .filter(|n| !services.iter().any(|x| x.name == *n && x.ready()))
        .collect();
    report(
        not_ready.is_empty(),
        "Containers",
        &if not_ready.is_empty() {
            "all running".into()
        } else {
            format!("not ready: {}", not_ready.join(", "))
        },
        Some("see `agnts logs <service>`"),
    );

    let domain = s.domain()?;
    match ops::public_ip(s.t()) {
        Ok((v4, v6)) => {
            let v = dns::check(&domain, v4, v6);
            report(
                v.ok,
                "DNS",
                &format!("{domain} {}", v.message),
                Some("fix the A record at your DNS provider"),
            );
        }
        Err(e) => report(false, "DNS", &e.to_string(), None),
    }

    report(
        ops::https_ok(&domain),
        "HTTPS",
        &format!("https://{domain}/healthz"),
        Some("see `agnts logs caddy`"),
    );
    match tls::cert_expiry(&domain) {
        Ok(t) => {
            let d = tls::days_left(t);
            report(
                d > 14,
                "Certificate",
                &format!("{d} days left"),
                Some("Caddy renews at 30 days; check `agnts logs caddy`"),
            );
        }
        Err(e) => report(false, "Certificate", &format!("{e:#}"), None),
    }

    let last = ops::list_backups(s.t())?.last().cloned();
    report(
        last.is_some(),
        "Backups",
        last.as_deref().unwrap_or("none yet"),
        Some("run `agnts backup`; nightly backups run at 03:00"),
    );

    if failed == 0 {
        ui::header("Everything looks good.");
        Ok(0)
    } else {
        ui::header(&format!("{failed} problem(s) found."));
        Ok(1)
    }
}

/// `agnts capacity`: measure a server before (or after) installing.
pub fn capacity(a: crate::cli::CapacityArgs, profile: Option<&str>) -> Result<i32> {
    use crate::target::{LocalTarget, SshTarget, Target};
    let session;
    let target: Box<dyn Target>;
    let t: &dyn Target = if let Some(host) = &a.host {
        let ssh = SshTarget::new(host, a.ssh_port);
        ssh.connect()?;
        target = Box::new(ssh);
        target.as_ref()
    } else if a.local {
        target = Box::new(LocalTarget::new()?);
        target.as_ref()
    } else {
        session = Session::open(profile)?;
        session.t()
    };
    let installed = ops::install_id(t, false)?.is_some();
    ui::header(&format!("Checking {}", t.label()));
    let (_, _, fits) = capacity::check(t, installed, true)?;
    Ok(if fits { 0 } else { 1 })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn run_volumes_are_picked() {
        let got = parse_run_volumes(
            "agnts_pg\t120MB\nagnts-toolchains\t1.4GB\nagnts-cache-repo-3\t310MB\nother\t1kB\n",
        );
        assert_eq!(
            got,
            vec![
                ("agnts-toolchains".to_string(), "1.4GB".to_string()),
                ("agnts-cache-repo-3".to_string(), "310MB".to_string())
            ]
        );
    }
}
