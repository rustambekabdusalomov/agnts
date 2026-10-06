//! `agnts backup` and `agnts restore`.

use std::path::{Path, PathBuf};
use std::time::Duration;

use anyhow::{bail, Context, Result};

use crate::cli::Session;
use crate::profile::{self, Mode};
use crate::{compose, ui};

pub fn backup(s: &Session, pull: bool, dest: Option<PathBuf>) -> Result<()> {
    let name = crate::ops::backup_now(s.t())?;
    ui::ok(&format!(
        "backup taken: {}",
        compose::path(&format!("backups/{name}"))
    ));
    if !pull {
        if s.mode == Mode::Remote {
            ui::info("Copy backups to this machine with: agnts backup --pull");
        }
        return Ok(());
    }
    if s.mode == Mode::Local {
        ui::info("Backups are in /opt/agnts/backups. Run `agnts backup --pull` from your laptop to copy them off the server.");
        return Ok(());
    }
    let dir = dest.unwrap_or_else(|| profile::backups_dir(&s.name));
    std::fs::create_dir_all(&dir)?;
    let mut copied = 0;
    for f in crate::ops::list_backups(s.t())? {
        let local = dir.join(&f);
        if local.exists() {
            continue;
        }
        let data = s
            .t()
            .read_file(&compose::path(&format!("backups/{f}")))?
            .with_context(|| format!("{f} disappeared"))?;
        profile::write_private(&local, &data)?;
        copied += 1;
    }
    ui::ok(&format!(
        "{copied} new backup(s) copied to {}",
        dir.display()
    ));
    Ok(())
}

pub fn restore(s: &Session, file: &str, enc_key_from: Option<String>) -> Result<()> {
    let t = s.t();
    let domain = s.domain()?;

    // A local file is uploaded; a bare name refers to the server's backups.
    let local = Path::new(file);
    let remote_name = if local.is_file() && s.mode == Mode::Remote {
        let name = format!(
            "restore-{}",
            local
                .file_name()
                .and_then(|n| n.to_str())
                .unwrap_or("upload.dump")
        );
        let data = std::fs::read(local)?;
        t.write_file(&compose::path(&format!("backups/{name}")), &data, 0o600)?;
        ui::ok(&format!(
            "uploaded {} ({} KB)",
            local.display(),
            data.len() / 1024
        ));
        name
    } else {
        let name = Path::new(file)
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or(file)
            .to_string();
        if t.read_file(&compose::path(&format!("backups/{name}")))?
            .is_none()
        {
            bail!("no backup named {name} in /opt/agnts/backups");
        }
        name
    };

    let enc_key = match enc_key_from {
        Some(p) => {
            let path = profile::enc_key_path(&p);
            let k = std::fs::read_to_string(&path).with_context(|| {
                format!(
                    "no saved encryption key for profile {p} ({})",
                    path.display()
                )
            })?;
            Some(k.trim().to_string())
        }
        None => None,
    };

    if !ui::typed_confirm(
        &format!("This replaces ALL data on {domain} with {remote_name}"),
        &domain,
    )? {
        bail!("cancelled");
    }

    t.run(&compose::cmd(&["stop", "agnts"]))?
        .check("stopping agnts")?;
    let out = t.run(&compose::cmd(&[
        "exec",
        "-T",
        "backup",
        "pg_restore",
        "--clean",
        "--if-exists",
        "--no-owner",
        "--dbname=hiro",
        &format!("/backups/{remote_name}"),
    ]))?;
    if !out.success() {
        ui::warn(&format!(
            "pg_restore reported problems:\n{}",
            crate::target::last_lines(&out.stderr, 15)
        ));
    }
    if let Some(k) = enc_key {
        let mut env = compose::read_env(t)?.unwrap_or_default();
        env.set("AGNTS_ENC_KEY", &k);
        compose::write_env(t, &env)?;
        ui::ok("encryption key from the old server set");
    } else {
        ui::info("Stored secrets need the AGNTS_ENC_KEY of the server the backup came from. If this is another server, run again with --enc-key-from <old profile>.");
    }
    t.run(&compose::cmd(&["up", "-d", "agnts"]))?
        .check("starting agnts")?;
    compose::wait_ready(t, Duration::from_secs(180))?;
    ui::ok(&format!("restored {remote_name}"));
    Ok(())
}
