//! `agnts upgrade`: backup, new files and images, restart, and roll back the
//! image tags when the new version does not come up healthy.

use std::time::Duration;

use anyhow::{bail, Result};

use crate::cli::Session;
use crate::cloud::{Cloud, Report};
use crate::{assets, compose, ops, ui};

pub fn run(s: &Session, to: Option<String>, no_backup: bool) -> Result<()> {
    let version = to.unwrap_or_else(|| crate::VERSION.to_string());
    let cloud = Cloud::new()?;
    if let Some(latest) = cloud.latest_cli_quick() {
        if let (Ok(l), Ok(c)) = (
            semver::Version::parse(&latest.version),
            semver::Version::parse(crate::VERSION),
        ) {
            if l > c {
                ui::warn(&format!(
                    "agnts {l} is available; this CLI installs {c}. Run `agnts self-update` first to get it"
                ));
            }
        }
    }
    if version != crate::VERSION {
        ui::warn(&format!(
            "installing images {version} with the stack files of CLI {}; they normally go together",
            crate::VERSION
        ));
    }

    let t = s.t();
    let mut env = compose::read_env(t)?
        .ok_or_else(|| anyhow::anyhow!("no .env on the server; run `agnts install`"))?;
    let domain = env.get("AGNTS_DOMAIN").unwrap_or_default().to_string();
    let (image, runner) = compose::images(&version);
    let old_image = env.get("AGNTS_IMAGE").unwrap_or_default().to_string();
    let old_runner = env
        .get("AGNTS_RUNNER_IMAGE")
        .unwrap_or_default()
        .to_string();
    if old_image == image && ops::files_outdated(t)?.is_empty() {
        ui::ok(&format!("already on {version}"));
        return Ok(());
    }
    ui::header(&format!("Upgrading {domain} to {version}"));

    if !no_backup {
        let b = ops::backup_now(t)?;
        ui::ok(&format!("backup taken: {b}"));
    }

    // Keep the previous files to roll back to.
    let mut previous = Vec::new();
    for a in assets::FILES {
        previous.push((a, t.read_file(&compose::path(a.path))?));
    }

    let key = s.key()?;
    let install_id = s.install_id()?;
    ops::registry_login(t, &cloud.policy, &install_id, &key)?;
    let changed = ops::write_files(t)?;
    env.set("AGNTS_IMAGE", &image);
    env.set("AGNTS_RUNNER_IMAGE", &runner);
    compose::write_env(t, &env)?;
    ops::pull(t, &cloud.policy)?;
    ui::ok("images pulled");

    let restart = ops::services_for_changed(&changed);
    let started = ops::up(t, &[]).and_then(|_| {
        if !restart.is_empty() {
            let mut args = vec!["up", "-d", "--force-recreate"];
            args.extend(restart.iter().copied());
            t.run(&compose::cmd(&args))?.check("restarting services")?;
        }
        compose::wait_ready(t, Duration::from_secs(180))?;
        ops::wait_https(t, &domain, Duration::from_secs(120))
    });

    if let Err(e) = started {
        ui::fail(&format!("the new version did not come up: {e:#}"));
        ui::info("Rolling back…");
        for (a, content) in &previous {
            if let Some(c) = content {
                t.write_file(&compose::path(a.path), c, a.mode)?;
            }
        }
        env.set("AGNTS_IMAGE", &old_image);
        env.set("AGNTS_RUNNER_IMAGE", &old_runner);
        compose::write_env(t, &env)?;
        ops::up(t, &["--force-recreate"])?;
        compose::wait_ready(t, Duration::from_secs(180))?;
        let old_version = old_image.rsplit(':').next().unwrap_or_default();
        let _ = cloud.report(
            &key,
            &Report {
                install_id: &install_id,
                domain: &domain,
                version: old_version,
                event: "rolled_back",
            },
        );
        bail!("upgrade failed; rolled back to {old_image}. The backup taken before the upgrade is in /opt/agnts/backups");
    }

    let _ = t.run(&crate::target::Cmd::new(["docker", "image", "prune", "-f"]));
    ui::ok(&format!("agnts {version} is running at https://{domain}"));
    s.update_profile(|p| p.version = version.clone())?;
    if let Err(e) = cloud.report(
        &key,
        &Report {
            install_id: &install_id,
            domain: &domain,
            version: &version,
            event: "upgraded",
        },
    ) {
        ui::warn(&format!("could not update your cabinet: {e}"));
    }
    Ok(())
}
