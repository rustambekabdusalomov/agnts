//! Files, secrets, images, start, HTTPS, admin user, done.

use std::time::Duration;

use anyhow::{bail, Result};
use base64::Engine;
use rand::distr::{Alphanumeric, SampleString};
use rand::RngCore;

use super::{Cx, InstallConfig, Step};
use crate::cloud::Report;
use crate::env_file::EnvFile;
use crate::profile::{self, Config, Mode, Profile};
use crate::target::{Cmd, Target};
use crate::{assets, compose, ops, ui};

pub struct Files;

impl Step for Files {
    fn id(&self) -> &'static str {
        "files"
    }
    fn title(&self) -> &'static str {
        "Stack files"
    }
    fn check(&self, cx: &mut Cx) -> Result<bool> {
        Ok(ops::files_outdated(cx.target)?.is_empty())
    }
    fn plan(&self, _: &Cx) -> Vec<String> {
        assets::FILES
            .iter()
            .map(|a| format!("write {}", compose::path(a.path)))
            .collect()
    }
    fn apply(&self, cx: &mut Cx) -> Result<()> {
        let changed = ops::write_files(cx.target)?;
        ui::ok(&format!(
            "wrote {} file(s) to {}",
            changed.len(),
            compose::DIR
        ));
        Ok(())
    }
}

pub fn new_enc_key() -> String {
    let mut b = [0u8; 32];
    rand::rng().fill_bytes(&mut b);
    base64::engine::general_purpose::STANDARD.encode(b)
}

pub fn new_password() -> String {
    Alphanumeric.sample_string(&mut rand::rng(), 40)
}

/// Template values that only stand in for a real one.
fn is_placeholder(key: &str, value: &str, template: &EnvFile) -> bool {
    value.is_empty() || template.get(key) == Some(value) && !matches!(key, "AGNTS_LOG_LEVEL" | "TZ")
}

/// Build the `.env`: keep every existing value, add missing keys from the
/// template, fill placeholders, and point the images at this version.
pub fn build_env(existing: Option<EnvFile>, cfg: &InstallConfig, docker_gid: &str) -> EnvFile {
    let template = EnvFile::parse(assets::ENV_EXAMPLE);
    let mut env = existing.unwrap_or_else(|| template.clone());
    env.merge_missing(&template);
    let (image, runner) = compose::images(&cfg.version);
    let wanted: Vec<(&str, String)> = vec![
        ("AGNTS_DOMAIN", cfg.domain.clone()),
        ("ACME_EMAIL", cfg.email.clone()),
        ("AGNTS_PUBLIC_URL", format!("https://{}", cfg.domain)),
        ("POSTGRES_PASSWORD", new_password()),
        ("AGNTS_ENC_KEY", new_enc_key()),
        ("AGNTS_GIT_AUTHOR_NAME", cfg.git_name.clone()),
        ("AGNTS_GIT_AUTHOR_EMAIL", cfg.git_email.clone()),
        ("DOCKER_GID", docker_gid.to_string()),
    ];
    for (k, v) in wanted {
        let current = env.get(k).unwrap_or_default().to_string();
        if is_placeholder(k, &current, &template) {
            env.set(k, &v);
        }
    }
    env.set("AGNTS_IMAGE", &image);
    env.set("AGNTS_RUNNER_IMAGE", &runner);
    env
}

pub fn env_complete(env: &EnvFile, cfg: &InstallConfig) -> bool {
    let template = EnvFile::parse(assets::ENV_EXAMPLE);
    let (image, runner) = compose::images(&cfg.version);
    [
        "AGNTS_DOMAIN",
        "ACME_EMAIL",
        "AGNTS_PUBLIC_URL",
        "POSTGRES_PASSWORD",
        "AGNTS_ENC_KEY",
    ]
    .iter()
    .all(|k| !is_placeholder(k, env.get(k).unwrap_or_default(), &template))
        && env.get("AGNTS_IMAGE") == Some(image.as_str())
        && env.get("AGNTS_RUNNER_IMAGE") == Some(runner.as_str())
}

fn docker_gid(t: &dyn Target) -> Result<String> {
    let out = t.run(&Cmd::new(["getent", "group", "docker"]))?;
    Ok(out
        .text()
        .split(':')
        .nth(2)
        .filter(|s| !s.is_empty())
        .unwrap_or("999")
        .to_string())
}

/// Keep the off-server copy of AGNTS_ENC_KEY (remote mode).
fn backup_enc_key(cx: &Cx, env: &EnvFile) -> Result<()> {
    let Some(key) = env.get("AGNTS_ENC_KEY") else {
        return Ok(());
    };
    if cx.mode == Mode::Local {
        return Ok(());
    }
    let path = profile::enc_key_path(&cx.profile_name);
    match std::fs::read_to_string(&path) {
        Ok(existing) if existing.trim() == key => return Ok(()),
        Ok(_) => {
            let old = path.with_extension(format!("enc-key.{}", chrono_stamp()));
            std::fs::rename(&path, &old)?;
            ui::warn(&format!(
                "a different encryption key was saved before; kept it as {}",
                old.display()
            ));
        }
        Err(_) => {}
    }
    profile::write_private(&path, format!("{key}\n").as_bytes())?;
    ui::ok(&format!("encryption key backed up to {}", path.display()));
    Ok(())
}

fn chrono_stamp() -> u64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0)
}

pub struct Secrets;

impl Step for Secrets {
    fn id(&self) -> &'static str {
        "env"
    }
    fn title(&self) -> &'static str {
        "Secrets and configuration"
    }
    fn check(&self, cx: &mut Cx) -> Result<bool> {
        let Some(env) = compose::read_env(cx.target)? else {
            return Ok(false);
        };
        let done = env_complete(&env, &cx.cfg);
        if done {
            backup_enc_key(cx, &env)?;
        }
        Ok(done)
    }
    fn plan(&self, _: &Cx) -> Vec<String> {
        vec![format!(
            "generate POSTGRES_PASSWORD and AGNTS_ENC_KEY and write {} (0600), keeping any existing values",
            compose::env_path()
        )]
    }
    fn apply(&self, cx: &mut Cx) -> Result<()> {
        let existing = compose::read_env(cx.target)?;
        let adopted = existing.is_some();
        let env = build_env(existing, &cx.cfg, &docker_gid(cx.target)?);
        compose::write_env(cx.target, &env)?;
        ui::ok(if adopted {
            "updated .env (existing values kept)"
        } else {
            "wrote .env"
        });
        backup_enc_key(cx, &env)?;
        if cx.mode == Mode::Local {
            ui::warn("Copy AGNTS_ENC_KEY from /opt/agnts/.env into your password manager. Without it, stored secrets cannot be decrypted from a backup.");
        }
        Ok(())
    }
}

pub struct Images;

impl Step for Images {
    fn id(&self) -> &'static str {
        "images"
    }
    fn title(&self) -> &'static str {
        "Images"
    }
    fn check(&self, cx: &mut Cx) -> Result<bool> {
        let (image, runner) = compose::images(&cx.cfg.version);
        Ok(cx
            .target
            .run(&Cmd::new(["docker", "image", "inspect", &image, &runner]))?
            .success())
    }
    fn plan(&self, cx: &Cx) -> Vec<String> {
        vec![
            format!("log in to {} as this install", compose::registry()),
            format!("pull agnts {} and the other images", cx.cfg.version),
        ]
    }
    fn apply(&self, cx: &mut Cx) -> Result<()> {
        ops::registry_login(cx.target, &cx.cloud.policy, cx.install_id(), cx.key())?;
        ops::pull(cx.target, &cx.cloud.policy)?;
        ui::ok(&format!("images for agnts {} pulled", cx.cfg.version));
        Ok(())
    }
}

pub struct Start;

impl Step for Start {
    fn id(&self) -> &'static str {
        "start"
    }
    fn title(&self) -> &'static str {
        "Start agnts"
    }
    fn check(&self, cx: &mut Cx) -> Result<bool> {
        Ok(compose::all_ready(&compose::ps(cx.target)?))
    }
    fn plan(&self, _: &Cx) -> Vec<String> {
        vec!["docker compose up -d and wait until every container is healthy".into()]
    }
    fn apply(&self, cx: &mut Cx) -> Result<()> {
        ops::up(cx.target, &[])?;
        compose::wait_ready(cx.target, Duration::from_secs(180))?;
        ui::ok("all containers running");
        Ok(())
    }
}

pub struct Https;

impl Step for Https {
    fn id(&self) -> &'static str {
        "https"
    }
    fn title(&self) -> &'static str {
        "HTTPS"
    }
    fn check(&self, cx: &mut Cx) -> Result<bool> {
        Ok(ops::https_ok(&cx.cfg.domain))
    }
    fn plan(&self, cx: &Cx) -> Vec<String> {
        vec![format!(
            "wait until https://{}/healthz answers (Caddy gets the certificate)",
            cx.cfg.domain
        )]
    }
    fn apply(&self, cx: &mut Cx) -> Result<()> {
        ops::wait_https(cx.target, &cx.cfg.domain, Duration::from_secs(300))?;
        ui::ok(&format!("https://{} is up", cx.cfg.domain));
        Ok(())
    }
}

pub struct AdminUser;

impl Step for AdminUser {
    fn id(&self) -> &'static str {
        "admin"
    }
    fn title(&self) -> &'static str {
        "Admin user"
    }
    fn check(&self, cx: &mut Cx) -> Result<bool> {
        ops::has_user(cx.target)
    }
    fn plan(&self, cx: &Cx) -> Vec<String> {
        vec![format!(
            "create the admin user {:?} (password and authenticator app)",
            cx.cfg.admin
        )]
    }
    fn apply(&self, cx: &mut Cx) -> Result<()> {
        if !ui::interactive() {
            ui::warn(&format!(
                "no terminal to set a password and authenticator app; create the user later with: agnts server -- user create {}",
                cx.cfg.admin
            ));
            return Ok(());
        }
        ui::info("Set the admin password, then add agnts to your authenticator app.");
        let code = cx.target.run_tty(&compose::cmd(&[
            "exec",
            "agnts",
            "agnts",
            "user",
            "create",
            &cx.cfg.admin,
        ]))?;
        if code != 0 {
            bail!("creating the user failed; run the same command again to retry");
        }
        Ok(())
    }
}

pub struct Done;

impl Step for Done {
    fn id(&self) -> &'static str {
        "done"
    }
    fn title(&self) -> &'static str {
        "Done"
    }
    fn check(&self, _: &mut Cx) -> Result<bool> {
        Ok(false)
    }
    fn plan(&self, _: &Cx) -> Vec<String> {
        vec!["save the profile and register the install in your agnts.uz cabinet".into()]
    }
    fn apply(&self, cx: &mut Cx) -> Result<()> {
        if cx.mode == Mode::Remote {
            let mut conf = Config::load()?;
            conf.put(
                &cx.profile_name,
                Profile {
                    mode: Mode::Remote,
                    host: cx.opts.host.clone(),
                    ssh_port: cx.opts.ssh_port,
                    domain: cx.cfg.domain.clone(),
                    install_id: cx.install_id().to_string(),
                    version: cx.cfg.version.clone(),
                },
            );
            conf.save()?;
        }
        let report = Report {
            install_id: cx.install_id(),
            domain: &cx.cfg.domain,
            version: &cx.cfg.version,
            event: "installed",
        };
        if let Err(e) = cx.cloud.report(cx.key(), &report) {
            ui::warn(&format!("could not register the install in your cabinet ({e}); it will show after the next upgrade"));
        }
        ui::header(&format!("agnts is running at https://{}", cx.cfg.domain));
        ui::info("Next, in the admin panel → Integrations:");
        ui::info("  1. Claude: a token from `claude setup-token`");
        ui::info("  2. GitHub: a fine-grained token (Contents + Pull requests, read/write)");
        ui::info("  3. Jira: site, email, API token and label; then add the webhook it shows");
        if cx.mode == Mode::Remote {
            ui::info(&format!(
                "Manage it from here with: agnts status --profile {}",
                cx.profile_name
            ));
        } else {
            ui::info("Manage it on this server with: sudo agnts status");
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn cfg() -> InstallConfig {
        InstallConfig {
            domain: "agnts.acme.com".into(),
            email: "me@acme.com".into(),
            git_name: "Me".into(),
            git_email: "me@acme.com".into(),
            admin: "admin".into(),
            version: "1.2.3".into(),
        }
    }

    #[test]
    fn fresh_env_is_filled() {
        let env = build_env(None, &cfg(), "998");
        assert_eq!(env.get("AGNTS_DOMAIN"), Some("agnts.acme.com"));
        assert_eq!(env.get("AGNTS_PUBLIC_URL"), Some("https://agnts.acme.com"));
        assert_eq!(env.get("DOCKER_GID"), Some("998"));
        assert_eq!(
            env.get("AGNTS_IMAGE"),
            Some("registry.agnts.uz/agnts:1.2.3")
        );
        assert_eq!(env.get("AGNTS_ENC_KEY").unwrap().len(), 44);
        assert_ne!(env.get("POSTGRES_PASSWORD"), Some("change-me"));
        assert!(env_complete(&env, &cfg()));
    }

    #[test]
    fn existing_values_are_kept() {
        let old = EnvFile::parse(
            "AGNTS_DOMAIN=old.acme.com\nAGNTS_ENC_KEY=keepme\nPOSTGRES_PASSWORD=pw\n",
        );
        let env = build_env(Some(old), &cfg(), "999");
        assert_eq!(env.get("AGNTS_DOMAIN"), Some("old.acme.com"));
        assert_eq!(env.get("AGNTS_ENC_KEY"), Some("keepme"));
        assert_eq!(env.get("POSTGRES_PASSWORD"), Some("pw"));
        // Missing keys come from the template.
        assert!(env.get("AGNTS_LOG_LEVEL").is_some());
        assert_eq!(
            env.get("AGNTS_RUNNER_IMAGE"),
            Some("registry.agnts.uz/agnts-runner:1.2.3")
        );
    }
}
