//! Ask, Preflight, Claim key.

use anyhow::{bail, Result};

use super::{Cx, Step};
use crate::cloud::CABINET_KEYS;
use crate::dns::valid_domain;
use crate::profile::{self, Mode};
use crate::{ops, preflight, secrets, ui};

pub struct Ask;

fn local_git(field: &str) -> Option<String> {
    let out = std::process::Command::new("git")
        .args(["config", "--global", field])
        .output()
        .ok()?;
    let v = String::from_utf8_lossy(&out.stdout).trim().to_string();
    (!v.is_empty()).then_some(v)
}

impl Step for Ask {
    fn id(&self) -> &'static str {
        "ask"
    }
    fn title(&self) -> &'static str {
        "Settings"
    }
    fn read_only(&self) -> bool {
        true
    }
    fn check(&self, _: &mut Cx) -> Result<bool> {
        Ok(false)
    }
    fn plan(&self, _: &Cx) -> Vec<String> {
        Vec::new()
    }

    fn apply(&self, cx: &mut Cx) -> Result<()> {
        let prev = cx.state.config.clone().unwrap_or_default();
        let o = cx.opts;
        if !prev.domain.is_empty() {
            ui::info(&format!("Resuming the install for {}.", prev.domain));
        }
        let pick = |flag: &Option<String>, prev: &str| {
            flag.clone()
                .or_else(|| (!prev.is_empty()).then(|| prev.to_string()))
        };

        let domain = match pick(&o.domain, &prev.domain) {
            Some(d) => d,
            None => ui::input("Domain for agnts (e.g. agnts.acme.com)", None, "--domain")?,
        }
        .trim()
        .trim_end_matches('.')
        .to_lowercase();
        if !valid_domain(&domain) {
            bail!("{domain:?} is not a valid domain name. agnts needs a domain you control, like agnts.acme.com");
        }

        let email = match pick(&o.email, &prev.email) {
            Some(e) => e,
            None => ui::input(
                "Email for Let's Encrypt certificate notices",
                local_git("user.email").as_deref(),
                "--email",
            )?,
        };
        if !email.contains('@') {
            bail!("{email:?} is not an email address");
        }

        let git_name = match pick(&o.git_name, &prev.git_name) {
            Some(v) => v,
            None => ui::input(
                "Git author name for agnts commits",
                local_git("user.name").as_deref(),
                "--git-name",
            )?,
        };
        let git_email = match pick(&o.git_email, &prev.git_email) {
            Some(v) => v,
            None => ui::input("Git author email", Some(&email), "--git-email")?,
        };
        let admin = match pick(&o.admin, &prev.admin) {
            Some(v) => v,
            None => ui::input("Admin username", Some("admin"), "--admin")?,
        };

        cx.profile_name = match (&o.profile, cx.mode) {
            (Some(p), _) => p.clone(),
            (None, Mode::Local) => secrets::LOCAL.to_string(),
            (None, Mode::Remote) => profile::name_for(&domain),
        };

        // The access key: flag or AGNTS_KEY, then the key store, then ask.
        if cx.key.is_none() {
            cx.key = secrets::load(&cx.profile_name).ok().flatten();
        }
        if cx.key.is_none() {
            ui::info(&format!(
                "Your access key is in your agnts.uz cabinet: {CABINET_KEYS}"
            ));
            cx.key = Some(ui::secret("Access key", "--key or AGNTS_KEY")?);
        }
        if cx.key.as_deref().is_none_or(str::is_empty) {
            bail!("an access key is required; create one at {CABINET_KEYS}");
        }

        cx.cfg = super::InstallConfig {
            domain,
            email,
            git_name,
            git_email,
            admin,
            version: o
                .version
                .clone()
                .unwrap_or_else(|| crate::VERSION.to_string()),
        };
        ui::ok(&format!(
            "agnts {} at https://{}",
            cx.cfg.version, cx.cfg.domain
        ));
        Ok(())
    }
}

pub struct Preflight;

impl Step for Preflight {
    fn id(&self) -> &'static str {
        "preflight"
    }
    fn title(&self) -> &'static str {
        "Check the server"
    }
    fn read_only(&self) -> bool {
        true
    }
    fn check(&self, _: &mut Cx) -> Result<bool> {
        Ok(false)
    }
    fn plan(&self, _: &Cx) -> Vec<String> {
        Vec::new()
    }

    fn apply(&self, cx: &mut Cx) -> Result<()> {
        let installed = ops::install_id(cx.target, false)?.is_some();
        let (info, findings) = preflight::run(cx.target, installed)?;
        let mut failed = false;
        for f in &findings {
            if f.ok {
                ui::ok(&format!("{}: {}", f.name, f.detail));
            } else {
                failed = true;
                ui::fail(&format!("{}: {}", f.name, f.detail));
                if let Some(fix) = &f.fix {
                    ui::info(&format!("  → {fix}"));
                }
            }
        }
        if failed && cx.opts.ignore_preflight {
            ui::warn("continuing anyway (--ignore-preflight)");
        } else if failed {
            bail!("the server is not ready for agnts; fix the items above and run the same command again");
        }
        cx.host = Some(info);
        Ok(())
    }
}

pub struct ClaimKey;

impl Step for ClaimKey {
    fn id(&self) -> &'static str {
        "claim"
    }
    fn title(&self) -> &'static str {
        "Access key"
    }
    // Claiming is idempotent, so it always runs: it also verifies the key.
    fn check(&self, _: &mut Cx) -> Result<bool> {
        Ok(false)
    }
    fn plan(&self, cx: &Cx) -> Vec<String> {
        vec![format!(
            "bind the access key to this server at {}",
            cx.cloud.base()
        )]
    }

    fn apply(&self, cx: &mut Cx) -> Result<()> {
        let id = ops::install_id(cx.target, true)?.expect("created");
        cx.cloud
            .claim(cx.key(), &id, &cx.cfg.domain, cx.opts.move_key)?;
        secrets::save(&cx.profile_name, cx.key())?;
        if cx.opts.move_key {
            ui::ok("key moved to this server; the old install can no longer pull or upgrade");
        } else {
            ui::ok("key verified and bound to this server");
        }
        cx.install_id = Some(id);
        Ok(())
    }
}
