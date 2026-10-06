//! Docker and the firewall.

use anyhow::Result;

use super::{Cx, Step};
use crate::target::Cmd;
use crate::ui;

/// Docker Engine and the Compose plugin from Docker's own apt repository.
const INSTALL_DOCKER: &str = r#"set -eu
export DEBIAN_FRONTEND=noninteractive
. /etc/os-release
apt-get update -qq
apt-get install -y -qq ca-certificates curl >/dev/null
install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/$ID/gpg" -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$ID $VERSION_CODENAME stable" > /etc/apt/sources.list.d/docker.list
apt-get update -qq
apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null
systemctl enable --now docker"#;

pub struct Docker;

impl Step for Docker {
    fn id(&self) -> &'static str {
        "docker"
    }
    fn title(&self) -> &'static str {
        "Docker"
    }

    fn check(&self, cx: &mut Cx) -> Result<bool> {
        let compose = cx
            .target
            .run(&Cmd::new(["docker", "compose", "version", "--short"]))?;
        let active = cx
            .target
            .run(&Cmd::new(["systemctl", "is-active", "docker"]))?;
        let curl = cx.target.run(&Cmd::sh("command -v curl", &[]))?;
        Ok(compose.success() && active.text() == "active" && curl.success())
    }

    fn plan(&self, _: &Cx) -> Vec<String> {
        vec![
            "install Docker Engine and the Compose plugin from download.docker.com, and start it"
                .into(),
        ]
    }

    fn apply(&self, cx: &mut Cx) -> Result<()> {
        let pb = ui::spinner("installing Docker (about a minute)");
        let r = cx.target.run(&Cmd::sh(INSTALL_DOCKER, &[]));
        pb.finish_and_clear();
        r?.check("installing Docker")?;
        let v = cx
            .target
            .run(&Cmd::new(["docker", "compose", "version", "--short"]))?
            .check("docker compose")?;
        ui::ok(&format!("Docker Compose {}", v.text()));
        Ok(())
    }
}

pub struct Firewall;

/// TCP ports sshd listens on, from `sshd -T`.
pub fn parse_sshd_ports(text: &str) -> Vec<String> {
    let mut v: Vec<String> = text
        .lines()
        .filter_map(|l| l.strip_prefix("port "))
        .map(|p| p.trim().to_string())
        .filter(|p| p.parse::<u16>().is_ok())
        .collect();
    if v.is_empty() {
        v.push("22".into());
    }
    v.dedup();
    v
}

impl Step for Firewall {
    fn id(&self) -> &'static str {
        "firewall"
    }
    fn title(&self) -> &'static str {
        "Firewall"
    }

    fn check(&self, cx: &mut Cx) -> Result<bool> {
        if cx.opts.no_firewall {
            return Ok(true);
        }
        let s = cx.target.run(&Cmd::new(["ufw", "status"]))?;
        let t = s.text();
        Ok(s.success()
            && t.contains("Status: active")
            && t.contains("80/tcp")
            && t.contains("443/tcp")
            && t.contains("443/udp"))
    }

    fn plan(&self, _: &Cx) -> Vec<String> {
        vec!["allow SSH, 80/tcp, 443/tcp and 443/udp in ufw, then enable it".into()]
    }

    fn apply(&self, cx: &mut Cx) -> Result<()> {
        let t = cx.target;
        if !t.run(&Cmd::sh("command -v ufw", &[]))?.success() {
            t.run(
                &Cmd::new(["apt-get", "install", "-y", "-qq", "ufw"])
                    .env("DEBIAN_FRONTEND", "noninteractive"),
            )?
            .check("installing ufw")?;
        }
        // Allow SSH first so enabling the firewall never locks us out.
        let ports = parse_sshd_ports(&t.run(&Cmd::new(["sshd", "-T"]))?.text());
        for p in &ports {
            t.run(&Cmd::new(["ufw", "allow", &format!("{p}/tcp")]))?
                .check("ufw allow")?;
        }
        for rule in ["80/tcp", "443/tcp", "443/udp"] {
            t.run(&Cmd::new(["ufw", "allow", rule]))?
                .check("ufw allow")?;
        }
        t.run(&Cmd::new(["ufw", "--force", "enable"]))?
            .check("ufw enable")?;
        ui::ok(&format!("ufw active: SSH ({}), 80, 443", ports.join(", ")));
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn reads_sshd_ports() {
        assert_eq!(
            parse_sshd_ports("port 2222\nport 22\naddressfamily any\n"),
            vec!["2222", "22"]
        );
        assert_eq!(parse_sshd_ports(""), vec!["22"]);
    }
}
