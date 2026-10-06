//! Remote mode: commands run through the system `ssh`, so `~/.ssh/config`,
//! agents, ProxyJump, hardware keys and known_hosts all work as usual.

use std::cell::Cell;
use std::io::Write;
use std::process::{Command, Stdio};

use anyhow::{bail, Context, Result};

use super::{Cmd, Out, Target};
use crate::{shell, ui};

pub struct SshTarget {
    dest: String,
    port: Option<u16>,
    /// Prefix commands with `sudo -n` (connected as a non-root user).
    sudo: Cell<bool>,
    control_path: Option<String>,
}

impl SshTarget {
    pub fn new(dest: &str, port: Option<u16>) -> Self {
        // Connection sharing makes each step's commands near-instant. It is not
        // available in Windows OpenSSH, which then opens one connection each.
        let control_path = if cfg!(unix) {
            Some("/tmp/agnts-ssh-%C".to_string())
        } else {
            None
        };
        SshTarget {
            dest: dest.to_string(),
            port,
            sudo: Cell::new(false),
            control_path,
        }
    }

    fn base(&self, tty: bool) -> Command {
        let mut c = Command::new("ssh");
        if let Some(p) = self.port {
            c.arg("-p").arg(p.to_string());
        }
        c.args([
            "-o",
            "StrictHostKeyChecking=accept-new",
            "-o",
            "ConnectTimeout=15",
            "-o",
            "ServerAliveInterval=15",
            "-o",
            "LogLevel=ERROR",
        ]);
        if let Some(cp) = &self.control_path {
            c.args([
                "-o",
                "ControlMaster=auto",
                "-o",
                &format!("ControlPath={cp}"),
                "-o",
                "ControlPersist=120",
            ]);
        }
        c.arg(if tty { "-t" } else { "-T" });
        c.arg(&self.dest);
        c
    }

    fn remote_line(&self, cmd: &Cmd, sudo: bool) -> String {
        let mut argv: Vec<String> = Vec::new();
        if sudo {
            argv.extend(["sudo".into(), "-n".into()]);
        }
        if !cmd.env.is_empty() {
            argv.push("env".into());
            argv.extend(cmd.env.iter().map(|(k, v)| format!("{k}={v}")));
        }
        argv.extend(cmd.args.iter().cloned());
        shell::join(&argv)
    }

    fn exec(&self, cmd: &Cmd, sudo: bool) -> Result<Out> {
        let mut c = self.base(false);
        c.arg(self.remote_line(cmd, sudo));
        c.stdin(if cmd.stdin.is_some() {
            Stdio::piped()
        } else {
            Stdio::null()
        });
        c.stdout(Stdio::piped()).stderr(Stdio::piped());
        let mut child = c.spawn().context("starting ssh (is OpenSSH installed?)")?;
        let writer = cmd.stdin.clone().map(|data| {
            let mut stdin = child.stdin.take().expect("piped stdin");
            std::thread::spawn(move || {
                let _ = stdin.write_all(&data);
            })
        });
        let output = child.wait_with_output()?;
        if let Some(w) = writer {
            let _ = w.join();
        }
        let out = Out {
            code: output.status.code().unwrap_or(-1),
            stdout: output.stdout,
            stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
        };
        if out.code == 255 && looks_like_ssh_failure(&out.stderr) {
            bail!("ssh to {} failed: {}", self.dest, out.stderr.trim());
        }
        Ok(out)
    }

    /// Verify the host key (trust on first use, with the fingerprint shown),
    /// then work out whether commands need sudo.
    pub fn connect(&self) -> Result<()> {
        self.check_host_key()?;
        let id = self
            .exec(&Cmd::new(["id", "-u"]), false)?
            .check("connecting")?;
        if id.text() == "0" {
            return Ok(());
        }
        let sudo = self.exec(&Cmd::new(["sudo", "-n", "true"]), false)?;
        if !sudo.success() {
            bail!(
                "{} is not root and has no passwordless sudo. Connect as root, or allow this user `sudo` without a password",
                self.dest
            );
        }
        self.sudo.set(true);
        Ok(())
    }

    fn check_host_key(&self) -> Result<()> {
        // Resolve aliases from ~/.ssh/config to the real host and port.
        let mut g = Command::new("ssh");
        if let Some(p) = self.port {
            g.arg("-p").arg(p.to_string());
        }
        let g = g
            .arg("-G")
            .arg(&self.dest)
            .output()
            .context("running ssh -G (is OpenSSH installed?)")?;
        let conf = String::from_utf8_lossy(&g.stdout);
        let field = |name: &str| {
            conf.lines()
                .find_map(|l| l.strip_prefix(&format!("{name} ")).map(str::to_string))
        };
        let host = field("hostname").unwrap_or_else(|| self.dest.clone());
        let port = field("port").unwrap_or_else(|| "22".into());
        let lookup = if port == "22" {
            host.clone()
        } else {
            format!("[{host}]:{port}")
        };

        let known = Command::new("ssh-keygen").args(["-F", &lookup]).output();
        if matches!(known, Ok(ref o) if o.status.success() && !o.stdout.is_empty()) {
            return Ok(());
        }

        let scan = Command::new("ssh-keyscan")
            .args(["-T", "10", "-p", &port, &host])
            .stderr(Stdio::null())
            .output()
            .context("running ssh-keyscan")?;
        if scan.stdout.is_empty() {
            bail!("cannot reach {host}:{port} over SSH");
        }
        let mut fp = Command::new("ssh-keygen")
            .args(["-l", "-f", "-"])
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .spawn()?;
        fp.stdin.take().unwrap().write_all(&scan.stdout)?;
        let fp = fp.wait_with_output()?;
        ui::info(&format!(
            "First connection to {host}. Its host key fingerprints:"
        ));
        for line in String::from_utf8_lossy(&fp.stdout).lines() {
            ui::info(&format!("  {line}"));
        }
        ui::info("Compare them with the ones your hosting provider shows, if it does.");
        if !ui::confirm("Trust this host and continue?", false)? {
            bail!("host key not trusted");
        }
        Ok(())
    }
}

fn looks_like_ssh_failure(stderr: &str) -> bool {
    let s = stderr.to_lowercase();
    [
        "ssh:",
        "permission denied",
        "host key verification failed",
        "connection refused",
        "connection timed out",
        "could not resolve hostname",
        "connection closed",
    ]
    .iter()
    .any(|p| s.contains(p))
}

impl Target for SshTarget {
    fn run(&self, cmd: &Cmd) -> Result<Out> {
        self.exec(cmd, self.sudo.get())
    }

    fn run_tty(&self, cmd: &Cmd) -> Result<i32> {
        if cmd.stdin.is_some() {
            bail!("run_tty does not take stdin");
        }
        let mut c = self.base(ui::interactive());
        c.arg(self.remote_line(cmd, self.sudo.get()));
        Ok(c.status()?.code().unwrap_or(-1))
    }

    fn label(&self) -> String {
        self.dest.clone()
    }

    fn is_local(&self) -> bool {
        false
    }

    fn shell(&self, dir: &str) -> Result<i32> {
        let mut c = self.base(true);
        let cd = format!(
            "cd {} && exec \"${{SHELL:-/bin/sh}}\" -l",
            shell::quote(dir)
        );
        c.arg(cd);
        Ok(c.status()?.code().unwrap_or(-1))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn builds_remote_line_with_sudo_and_env() {
        let t = SshTarget::new("u@h", None);
        let cmd = Cmd::new(["docker", "compose", "up"]).env("A", "b c");
        assert_eq!(
            t.remote_line(&cmd, true),
            "sudo -n env 'A=b c' docker compose up"
        );
        assert_eq!(t.remote_line(&cmd, false), "env 'A=b c' docker compose up");
    }

    #[test]
    fn detects_ssh_failures() {
        assert!(looks_like_ssh_failure(
            "ssh: connect to host x port 22: Connection refused"
        ));
        assert!(looks_like_ssh_failure(
            "root@x: Permission denied (publickey)."
        ));
        assert!(!looks_like_ssh_failure("some program error"));
    }
}
