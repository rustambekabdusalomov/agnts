//! Where commands run. Install steps and commands only talk to a [`Target`];
//! [`SshTarget`] (remote mode) and [`LocalTarget`] (local mode) are the only
//! difference between the two modes.

mod fake;
mod local;
mod ssh;

pub use fake::FakeTarget;
pub use local::LocalTarget;
pub use ssh::SshTarget;

use anyhow::{bail, Result};

/// A command as an argument list. Targets quote it for the remote shell or run
/// it directly; nothing depends on a particular shell on the CLI's machine.
#[derive(Clone, Debug, Default)]
pub struct Cmd {
    pub args: Vec<String>,
    pub stdin: Option<Vec<u8>>,
    pub env: Vec<(String, String)>,
}

impl Cmd {
    pub fn new<I, S>(args: I) -> Self
    where
        I: IntoIterator<Item = S>,
        S: Into<String>,
    {
        Cmd {
            args: args.into_iter().map(Into::into).collect(),
            ..Default::default()
        }
    }

    /// A short `sh -c` script with positional arguments (`$1`, `$2`, …).
    pub fn sh(script: &str, args: &[&str]) -> Self {
        let mut v = vec![
            "sh".to_string(),
            "-c".to_string(),
            script.to_string(),
            "sh".to_string(),
        ];
        v.extend(args.iter().map(|a| a.to_string()));
        Cmd {
            args: v,
            ..Default::default()
        }
    }

    pub fn stdin(mut self, data: impl Into<Vec<u8>>) -> Self {
        self.stdin = Some(data.into());
        self
    }

    pub fn env(mut self, key: &str, value: &str) -> Self {
        self.env.push((key.to_string(), value.to_string()));
        self
    }

    /// The command as it would be typed, for logs and `--dry-run`.
    pub fn display(&self) -> String {
        let mut parts: Vec<String> = self.env.iter().map(|(k, v)| format!("{k}={v}")).collect();
        parts.extend(self.args.iter().cloned());
        crate::shell::join(&parts)
    }
}

#[derive(Clone, Debug, Default)]
pub struct Out {
    pub code: i32,
    pub stdout: Vec<u8>,
    pub stderr: String,
}

impl Out {
    pub fn success(&self) -> bool {
        self.code == 0
    }

    /// Stdout as trimmed text.
    pub fn text(&self) -> String {
        String::from_utf8_lossy(&self.stdout).trim().to_string()
    }

    /// Fail with the command's stderr when it exited non-zero.
    pub fn check(self, what: &str) -> Result<Out> {
        if self.success() {
            return Ok(self);
        }
        let mut detail = self.stderr.trim().to_string();
        if detail.is_empty() {
            detail = self.text();
        }
        bail!(
            "{what} failed (exit {}): {}",
            self.code,
            last_lines(&detail, 15)
        )
    }
}

pub fn last_lines(text: &str, n: usize) -> String {
    let lines: Vec<&str> = text.lines().collect();
    lines[lines.len().saturating_sub(n)..].join("\n")
}

pub trait Target {
    /// Run and capture output.
    fn run(&self, cmd: &Cmd) -> Result<Out>;

    /// Run attached to the user's terminal; returns the exit code.
    fn run_tty(&self, cmd: &Cmd) -> Result<i32>;

    /// "root@203.0.113.10" or "this server".
    fn label(&self) -> String;

    fn is_local(&self) -> bool;

    /// Replace a file, creating parent directories. Contents travel on stdin,
    /// never on a command line.
    fn write_file(&self, path: &str, data: &[u8], mode: u32) -> Result<()> {
        let script = r#"set -e
mkdir -p "$(dirname "$1")"
umask 077
cat > "$1.agnts-tmp"
chmod "$2" "$1.agnts-tmp"
mv -f "$1.agnts-tmp" "$1""#;
        let mode = format!("{mode:o}");
        self.run(&Cmd::sh(script, &[path, &mode]).stdin(data.to_vec()))?
            .check(&format!("writing {path}"))?;
        Ok(())
    }

    /// Read a file; `None` when it does not exist.
    fn read_file(&self, path: &str) -> Result<Option<Vec<u8>>> {
        let out = self.run(&Cmd::sh(
            r#"if [ -e "$1" ]; then cat "$1"; else exit 3; fi"#,
            &[path],
        ))?;
        match out.code {
            0 => Ok(Some(out.stdout)),
            3 => Ok(None),
            _ => {
                out.check(&format!("reading {path}"))?;
                unreachable!()
            }
        }
    }

    fn read_text(&self, path: &str) -> Result<Option<String>> {
        Ok(self
            .read_file(path)?
            .map(|b| String::from_utf8_lossy(&b).into_owned()))
    }

    /// An interactive login shell in `dir` (remote mode only).
    fn shell(&self, _dir: &str) -> Result<i32> {
        bail!("`agnts ssh` is for remote installs; you are already on the server")
    }
}
