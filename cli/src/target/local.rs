//! Local mode: the CLI runs on the server itself, as root.

use std::io::Write;
use std::process::{Command, Stdio};

use anyhow::{bail, Context, Result};

use super::{Cmd, Out, Target};

pub struct LocalTarget;

impl LocalTarget {
    /// Local mode needs a Linux server and root.
    pub fn new() -> Result<Self> {
        if !cfg!(target_os = "linux") {
            bail!(
                "local mode runs on the Linux server itself. From this machine, use remote mode: agnts install root@your-server"
            );
        }
        #[cfg(unix)]
        {
            // SAFETY: geteuid has no preconditions.
            if unsafe { libc::geteuid() } != 0 {
                bail!("local mode needs root; run it with sudo (sudo agnts ...)");
            }
        }
        Ok(LocalTarget)
    }

    fn command(cmd: &Cmd) -> Result<Command> {
        let Some((prog, rest)) = cmd.args.split_first() else {
            bail!("empty command")
        };
        let mut c = Command::new(prog);
        c.args(rest);
        for (k, v) in &cmd.env {
            c.env(k, v);
        }
        Ok(c)
    }
}

impl Target for LocalTarget {
    fn run(&self, cmd: &Cmd) -> Result<Out> {
        let mut c = Self::command(cmd)?;
        c.stdin(if cmd.stdin.is_some() {
            Stdio::piped()
        } else {
            Stdio::null()
        });
        c.stdout(Stdio::piped()).stderr(Stdio::piped());
        let mut child = c
            .spawn()
            .with_context(|| format!("running {}", cmd.args[0]))?;
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
        Ok(Out {
            code: output.status.code().unwrap_or(-1),
            stdout: output.stdout,
            stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
        })
    }

    fn run_tty(&self, cmd: &Cmd) -> Result<i32> {
        Ok(Self::command(cmd)?.status()?.code().unwrap_or(-1))
    }

    fn label(&self) -> String {
        "this server".into()
    }

    fn is_local(&self) -> bool {
        true
    }

    #[cfg(unix)]
    fn write_file(&self, path: &str, data: &[u8], mode: u32) -> Result<()> {
        use std::os::unix::fs::PermissionsExt;
        let p = std::path::Path::new(path);
        if let Some(dir) = p.parent() {
            std::fs::create_dir_all(dir)?;
        }
        let tmp = format!("{path}.agnts-tmp");
        {
            let mut f = std::fs::OpenOptions::new()
                .write(true)
                .create(true)
                .truncate(true)
                .open(&tmp)?;
            f.set_permissions(std::fs::Permissions::from_mode(mode))?;
            f.write_all(data)?;
            f.sync_all()?;
        }
        std::fs::rename(&tmp, path).with_context(|| format!("writing {path}"))?;
        Ok(())
    }

    fn read_file(&self, path: &str) -> Result<Option<Vec<u8>>> {
        match std::fs::read(path) {
            Ok(b) => Ok(Some(b)),
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok(None),
            Err(e) => Err(e).with_context(|| format!("reading {path}")),
        }
    }
}
