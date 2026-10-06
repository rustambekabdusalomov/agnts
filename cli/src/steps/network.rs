//! DNS and reachability from the internet.

use anyhow::{bail, Result};

use super::{Cx, Step};
use crate::target::Cmd;
use crate::{dns, ops, ui};

pub struct Dns;

impl Dns {
    fn ip(cx: &mut Cx) -> Result<()> {
        if cx.ip.is_none() {
            cx.ip = Some(ops::public_ip(cx.target)?);
        }
        Ok(())
    }
}

impl Step for Dns {
    fn id(&self) -> &'static str {
        "dns"
    }
    fn title(&self) -> &'static str {
        "DNS"
    }

    fn check(&self, cx: &mut Cx) -> Result<bool> {
        if cx.opts.skip_dns_check {
            return Ok(true);
        }
        Self::ip(cx)?;
        let (v4, v6) = cx.ip.unwrap();
        Ok(dns::check(&cx.cfg.domain, v4, v6).ok)
    }

    fn plan(&self, cx: &Cx) -> Vec<String> {
        vec![format!(
            "show the A record for {} and wait until it points at this server",
            cx.cfg.domain
        )]
    }

    fn apply(&self, cx: &mut Cx) -> Result<()> {
        Self::ip(cx)?;
        let (v4, v6) = cx.ip.unwrap();
        ops::wait_dns(&cx.cfg.domain, v4, v6)
    }
}

pub struct Probe;

const PROBE_CONTAINER: &str = "agnts-probe";

impl Step for Probe {
    fn id(&self) -> &'static str {
        "probe"
    }
    fn title(&self) -> &'static str {
        "Reachable from the internet"
    }

    fn check(&self, cx: &mut Cx) -> Result<bool> {
        Ok(cx.opts.skip_probe || cx.completed("probe") || ops::https_ok(&cx.cfg.domain))
    }

    fn plan(&self, cx: &Cx) -> Vec<String> {
        vec![format!(
            "serve a token on port 80 for a moment and ask {} to fetch http://{}/ from outside",
            cx.cloud.base(),
            cx.cfg.domain
        )]
    }

    fn apply(&self, cx: &mut Cx) -> Result<()> {
        let t = cx.target;
        let token = uuid::Uuid::new_v4().simple().to_string();
        let _ = t.run(&Cmd::new(["docker", "rm", "-f", PROBE_CONTAINER]));
        t.run(&Cmd::new([
            "docker",
            "run",
            "-d",
            "--rm",
            "--name",
            PROBE_CONTAINER,
            "-p",
            "80:8080",
            "caddy:2-alpine",
            "caddy",
            "respond",
            "--listen",
            ":8080",
            "--body",
            &token,
        ]))?
        .check("starting the probe listener")?;
        std::thread::sleep(std::time::Duration::from_secs(2));
        let url = format!("http://{}/", cx.cfg.domain);
        let result = cx.cloud.probe(cx.key(), &url, &token);
        let _ = t.run(&Cmd::new(["docker", "rm", "-f", PROBE_CONTAINER]));
        let r = result?;
        if !r.ok {
            bail!(
                "{url} is not reachable from the internet ({}).\nCheck that your hosting provider's firewall or security group allows inbound TCP 80 and 443, then run the same command again",
                r.error.unwrap_or_else(|| "no answer".into())
            );
        }
        ui::ok(&format!("{url} reached from outside"));
        Ok(())
    }
}
