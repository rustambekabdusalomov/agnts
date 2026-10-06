//! logs, env, domain, key, server, uninstall.

use std::time::Duration;

use anyhow::{bail, Result};

use crate::cli::{EnvCmd, Session};
use crate::cloud::{Cloud, Report, CABINET_KEYS};
use crate::env_file::{is_secret, valid_key};
use crate::profile::{Config, Mode};
use crate::target::Cmd;
use crate::{compose, dns, ops, secrets, ui};

pub fn logs(s: &Session, service: Option<String>, follow: bool, tail: u32) -> Result<i32> {
    let tail = tail.to_string();
    let mut args = vec!["logs", "--tail", tail.as_str()];
    if follow {
        args.push("-f");
    }
    if let Some(svc) = service.as_deref() {
        args.push(svc);
    }
    s.t().run_tty(&compose::cmd(&args))
}

pub fn env(s: &Session, c: EnvCmd) -> Result<()> {
    let t = s.t();
    let mut env = compose::read_env(t)?.ok_or_else(|| anyhow::anyhow!("no .env on the server"))?;
    match c {
        EnvCmd::List => {
            for k in env.keys() {
                let v = env.get(k).unwrap_or_default();
                let shown = if is_secret(k) && !v.is_empty() {
                    "••••••".to_string()
                } else {
                    v.to_string()
                };
                println!("{k}={shown}");
            }
        }
        EnvCmd::Get { key } => match env.get(&key) {
            Some(v) => println!("{v}"),
            None => bail!("{key} is not set"),
        },
        EnvCmd::Set { key, value } => {
            if !valid_key(&key) {
                bail!("{key:?} is not a valid variable name");
            }
            if value.contains('\n') {
                bail!("values cannot contain newlines");
            }
            if matches!(key.as_str(), "AGNTS_DOMAIN" | "AGNTS_PUBLIC_URL") {
                bail!("use `agnts domain set <domain>` to change the domain");
            }
            if key == "AGNTS_ENC_KEY"
                && !ui::confirm(
                    "Changing AGNTS_ENC_KEY makes every stored secret unreadable. Continue?",
                    false,
                )?
            {
                bail!("cancelled");
            }
            env.set(&key, &value);
            compose::write_env(t, &env)?;
            ops::up(t, &[])?;
            compose::wait_ready(t, Duration::from_secs(120))?;
            ui::ok(&format!("{key} set; agnts restarted"));
        }
    }
    Ok(())
}

pub fn domain_set(s: &Session, domain: &str) -> Result<()> {
    let domain = domain.trim().trim_end_matches('.').to_lowercase();
    if !dns::valid_domain(&domain) {
        bail!("{domain:?} is not a valid domain name");
    }
    let t = s.t();
    let mut env = compose::read_env(t)?.ok_or_else(|| anyhow::anyhow!("no .env on the server"))?;
    let old = env.get("AGNTS_DOMAIN").unwrap_or_default().to_string();
    if old == domain {
        ui::ok(&format!("already on {domain}"));
        return Ok(());
    }
    ui::header(&format!("Moving agnts from {old} to {domain}"));
    let (v4, v6) = ops::public_ip(t)?;
    ops::wait_dns(&domain, v4, v6)?;

    env.set("AGNTS_DOMAIN", &domain);
    env.set("AGNTS_PUBLIC_URL", &format!("https://{domain}"));
    compose::write_env(t, &env)?;
    t.run(&compose::cmd(&[
        "up",
        "-d",
        "--force-recreate",
        "caddy",
        "agnts",
    ]))?
    .check("restarting")?;
    compose::wait_ready(t, Duration::from_secs(180))?;
    ops::wait_https(t, &domain, Duration::from_secs(300))?;
    ui::ok(&format!("agnts answers at https://{domain}"));

    s.update_profile(|p| p.domain = domain.clone())?;
    let version = env
        .get("AGNTS_IMAGE")
        .and_then(|i| i.rsplit(':').next())
        .unwrap_or("unknown")
        .to_string();
    let cloud = Cloud::new()?;
    let id = s.install_id()?;
    if let Err(e) = cloud.report(
        &s.key()?,
        &Report {
            install_id: &id,
            domain: &domain,
            version: &version,
            event: "domain_changed",
        },
    ) {
        ui::warn(&format!("could not update your cabinet: {e}"));
    }

    ui::header("Update these, which still point at the old domain:");
    ui::info(&format!(
        "  • Jira webhook: https://{domain}/… (Integrations → Jira shows the new URL)"
    ));
    ui::info("  • GitHub / GitLab webhooks (Integrations shows the new URL)");
    ui::info(&format!(
        "  • Claude custom connector: https://{domain}/mcp"
    ));
    ui::info("  • Telegram: agnts registers the new webhook itself on restart");
    Ok(())
}

pub fn key_set(s: &Session, key: Option<String>, move_key: bool) -> Result<()> {
    let key = match key.filter(|k| !k.is_empty()) {
        Some(k) => k,
        None => {
            ui::info(&format!("Create a key at {CABINET_KEYS}"));
            ui::secret("New access key", "--key or AGNTS_KEY")?
        }
    };
    let cloud = Cloud::new()?;
    let id = s.install_id()?;
    cloud.claim(&key, &id, &s.domain()?, move_key)?;
    ops::registry_login(s.t(), &cloud.policy, &id, &key)?;
    secrets::save(&s.name, &key)?;
    ui::ok("access key replaced");
    Ok(())
}

pub fn server(s: &Session, args: &[String]) -> Result<i32> {
    let mut v: Vec<&str> = vec!["exec"];
    if !ui::interactive() {
        v.push("-T");
    }
    v.extend(["agnts", "agnts"]);
    v.extend(args.iter().map(String::as_str));
    s.t().run_tty(&compose::cmd(&v))
}

pub fn uninstall(s: &Session, purge: bool) -> Result<()> {
    let t = s.t();
    let domain = s.domain().unwrap_or_default();
    if purge {
        if !ui::typed_confirm(
            &format!(
                "This deletes agnts on {} with ALL its data (database, backups, certificates)",
                t.label()
            ),
            &domain,
        )? {
            bail!("cancelled");
        }
    } else if !ui::confirm(
        &format!("Stop agnts on {}? Data is kept.", t.label()),
        false,
    )? {
        bail!("cancelled");
    }

    if !purge {
        t.run(&compose::cmd(&["down", "--remove-orphans"]))?
            .check("docker compose down")?;
        ui::ok("agnts stopped; data kept. Start it again with `agnts upgrade` or `docker compose up -d` in /opt/agnts");
        return Ok(());
    }

    let id = s.install_id().ok();
    let key = s.key().ok();
    t.run(&compose::cmd(&["down", "--volumes", "--remove-orphans"]))?
        .check("docker compose down")?;
    let _ = t.run(&Cmd::new(["docker", "logout", &compose::registry()]));
    if let (Some(id), Some(key)) = (id, key) {
        match Cloud::new()?.release(&key, &id) {
            Ok(()) => ui::ok("access key released; you can use it for another install"),
            Err(e) => ui::warn(&format!(
                "could not release the key ({e}); release it in your cabinet"
            )),
        }
    }
    t.run(&Cmd::new(["rm", "-rf", "--one-file-system", compose::DIR]))?
        .check("removing /opt/agnts")?;
    if s.mode == Mode::Remote {
        let mut conf = Config::load()?;
        conf.remove(&s.name);
        conf.save()?;
        let _ = secrets::delete(&s.name);
        ui::info(&format!(
            "The encryption key backup stays at {}; delete it when you no longer need old backups",
            crate::profile::enc_key_path(&s.name).display()
        ));
    } else {
        let _ = secrets::delete(&s.name);
    }
    ui::ok("agnts removed");
    Ok(())
}
