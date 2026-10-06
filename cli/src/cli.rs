//! Command-line parsing and dispatch.

use std::path::PathBuf;

use anyhow::{bail, Result};
use clap::{Args, Parser, Subcommand};

use crate::cmd;
use crate::profile::{Config, Mode, Profile};
use crate::target::{LocalTarget, SshTarget, Target};
use crate::{compose, ops, secrets, ui, wait};

#[derive(Parser)]
#[command(
    name = "agnts",
    version,
    about = "Install and manage agnts on a Linux server",
    long_about = "Install and manage agnts on a Linux server.\n\nRemote mode: run on your laptop and point at a server (agnts install root@203.0.113.10).\nLocal mode: run on the server itself (sudo agnts install --local)."
)]
pub struct Cli {
    /// Which install to manage (see ~/.config/agnts/config.toml).
    #[arg(long, global = true, env = "AGNTS_PROFILE")]
    pub profile: Option<String>,

    /// Answer yes to every question and use defaults.
    #[arg(long, short = 'y', global = true)]
    pub yes: bool,

    #[command(subcommand)]
    pub command: Command,
}

#[derive(Subcommand)]
pub enum Command {
    /// Install agnts on a server (remote: user@host, local: --local).
    Install(InstallArgs),
    /// Containers, version, certificate, disk and backups.
    Status,
    /// Upgrade to this CLI's version (or --version).
    Upgrade {
        #[arg(long = "version", value_name = "VERSION")]
        to: Option<String>,
        /// Skip the backup taken before upgrading.
        #[arg(long)]
        no_backup: bool,
    },
    /// Show container logs.
    Logs {
        /// caddy, agnts, egress, postgres or backup (all when omitted).
        service: Option<String>,
        #[arg(long, short)]
        follow: bool,
        #[arg(long, default_value_t = 200)]
        tail: u32,
    },
    /// Take a database backup now.
    Backup {
        /// Copy backups missing here to this machine (remote mode).
        #[arg(long)]
        pull: bool,
        /// Where --pull stores them (default: the profile's backups folder).
        #[arg(long)]
        dest: Option<PathBuf>,
    },
    /// Restore a database backup (replaces all data).
    Restore {
        /// A dump from `agnts backup --pull`, or a file name in /opt/agnts/backups.
        file: String,
        /// Use the encryption key saved for this profile (when moving servers).
        #[arg(long, value_name = "PROFILE")]
        enc_key_from: Option<String>,
    },
    /// Read or change settings in .env.
    #[command(subcommand)]
    Env(EnvCmd),
    /// Move agnts to another domain.
    #[command(subcommand)]
    Domain(DomainCmd),
    /// Replace the access key.
    #[command(subcommand)]
    Key(KeyCmd),
    /// Run an agnts server command, e.g. `agnts server -- integration set claude`.
    #[command(trailing_var_arg = true)]
    Server {
        #[arg(allow_hyphen_values = true, required = true)]
        args: Vec<String>,
    },
    /// Check the server and the install.
    Doctor,
    /// Open a shell on the server in /opt/agnts (remote mode).
    Ssh,
    /// Stop agnts; --purge also deletes its data and frees the access key.
    Uninstall {
        #[arg(long)]
        purge: bool,
    },
    /// Update this CLI.
    SelfUpdate {
        /// Only say whether an update is available.
        #[arg(long)]
        check: bool,
    },
}

#[derive(Args, Clone, Default)]
pub struct InstallArgs {
    /// The server, as user@host (remote mode).
    pub host: Option<String>,
    /// Install on this server (local mode).
    #[arg(long, conflicts_with = "host")]
    pub local: bool,
    /// SSH port, when not 22 and not set in ~/.ssh/config.
    #[arg(long, short = 'p')]
    pub ssh_port: Option<u16>,
    /// The domain agnts is served on (required; you create its DNS record).
    #[arg(long)]
    pub domain: Option<String>,
    /// Email for Let's Encrypt certificate notices.
    #[arg(long)]
    pub email: Option<String>,
    /// Access key from your agnts.uz cabinet.
    #[arg(long, env = "AGNTS_KEY", hide_env_values = true)]
    pub key: Option<String>,
    #[arg(long)]
    pub git_name: Option<String>,
    #[arg(long)]
    pub git_email: Option<String>,
    /// Admin username (default: admin).
    #[arg(long)]
    pub admin: Option<String>,
    /// Move the access key from its current install to this one.
    #[arg(long = "move")]
    pub move_key: bool,
    /// Show what would happen without changing anything.
    #[arg(long)]
    pub dry_run: bool,
    /// agnts version to install (default: this CLI's version).
    #[arg(long = "version", value_name = "VERSION")]
    pub version: Option<String>,
    /// Leave the firewall alone.
    #[arg(long)]
    pub no_firewall: bool,
    /// Do not wait for the DNS record (split-horizon DNS).
    #[arg(long)]
    pub skip_dns_check: bool,
    /// Do not test port 80 from outside.
    #[arg(long)]
    pub skip_probe: bool,
    /// Treat failed server checks as warnings (testing only).
    #[arg(long, hide = true)]
    pub ignore_preflight: bool,
}

#[derive(Subcommand)]
pub enum EnvCmd {
    /// List settings (secrets hidden).
    List,
    Get {
        key: String,
    },
    /// Set a value and restart agnts.
    Set {
        key: String,
        value: String,
    },
}

#[derive(Subcommand)]
pub enum DomainCmd {
    /// Point agnts at a new domain.
    Set { domain: String },
}

#[derive(Subcommand)]
pub enum KeyCmd {
    /// Replace the access key for this install.
    Set {
        #[arg(long, env = "AGNTS_KEY", hide_env_values = true)]
        key: Option<String>,
        /// Move the new key here from the install it is bound to.
        #[arg(long = "move")]
        move_key: bool,
    },
}

/// An open connection to one install.
pub struct Session {
    pub target: Box<dyn Target>,
    pub mode: Mode,
    /// Profile name in remote mode; "local" in local mode.
    pub name: String,
    pub profile: Option<Profile>,
}

impl Session {
    pub fn open(profile_flag: Option<&str>) -> Result<Session> {
        let conf = Config::load()?;
        let name = match profile_flag {
            Some(n) => Some(n.to_string()),
            None if cfg!(target_os = "linux")
                && std::path::Path::new(&compose::path("install-id")).exists() =>
            {
                let t = LocalTarget::new()?;
                return Ok(Session {
                    target: Box::new(t),
                    mode: Mode::Local,
                    name: secrets::LOCAL.into(),
                    profile: None,
                });
            }
            None => conf.default.clone(),
        };
        let Some(name) = name else {
            bail!("no agnts install found. Install one with `agnts install user@host`, or run on the server itself");
        };
        let Some(p) = conf.profiles.get(&name).cloned() else {
            let known: Vec<&str> = conf.profiles.keys().map(String::as_str).collect();
            bail!(
                "no profile {name:?} (known: {})",
                if known.is_empty() {
                    "none".into()
                } else {
                    known.join(", ")
                }
            );
        };
        let host = p.host.clone().unwrap_or_default();
        let t = SshTarget::new(&host, p.ssh_port);
        t.connect()?;
        Ok(Session {
            target: Box::new(t),
            mode: Mode::Remote,
            name,
            profile: Some(p),
        })
    }

    pub fn t(&self) -> &dyn Target {
        self.target.as_ref()
    }

    pub fn domain(&self) -> Result<String> {
        let env = compose::read_env(self.t())?
            .ok_or_else(|| anyhow::anyhow!("no /opt/agnts/.env on the server"))?;
        Ok(env.get("AGNTS_DOMAIN").unwrap_or_default().to_string())
    }

    pub fn install_id(&self) -> Result<String> {
        ops::install_id(self.t(), false)?
            .ok_or_else(|| anyhow::anyhow!("agnts is not installed on {}", self.t().label()))
    }

    /// The access key: key store, then the server's Docker credential, then ask.
    pub fn key(&self) -> Result<String> {
        if let Some(k) = secrets::load(&self.name)? {
            return Ok(k);
        }
        if let Some(k) = secrets::from_server(self.t())? {
            secrets::save(&self.name, &k)?;
            return Ok(k);
        }
        let k = ui::secret("Access key (from your agnts.uz cabinet)", "AGNTS_KEY")?;
        secrets::save(&self.name, &k)?;
        Ok(k)
    }

    pub fn update_profile(&self, f: impl FnOnce(&mut Profile)) -> Result<()> {
        if self.mode != Mode::Remote {
            return Ok(());
        }
        let mut conf = Config::load()?;
        if let Some(p) = conf.profiles.get_mut(&self.name) {
            f(p);
            conf.save()?;
        }
        Ok(())
    }
}

pub fn main() -> i32 {
    let cli = Cli::parse();
    ui::init(cli.yes);
    match run(cli) {
        Ok(code) => code,
        Err(e) => {
            if e.downcast_ref::<wait::StillDown>().is_some() {
                eprintln!("\n{} {e}", console::style("agnts:").yellow().bold());
                return 75;
            }
            eprintln!("\n{} {e:#}", console::style("agnts:").red().bold());
            1
        }
    }
}

fn run(cli: Cli) -> Result<i32> {
    let profile = cli.profile.as_deref();
    match cli.command {
        Command::Install(args) => cmd::install::run(args, cli.profile).map(|_| 0),
        Command::Status => cmd::status::run(&Session::open(profile)?),
        Command::Upgrade { to, no_backup } => {
            cmd::upgrade::run(&Session::open(profile)?, to, no_backup).map(|_| 0)
        }
        Command::Logs {
            service,
            follow,
            tail,
        } => cmd::manage::logs(&Session::open(profile)?, service, follow, tail),
        Command::Backup { pull, dest } => {
            cmd::backup::backup(&Session::open(profile)?, pull, dest).map(|_| 0)
        }
        Command::Restore { file, enc_key_from } => {
            cmd::backup::restore(&Session::open(profile)?, &file, enc_key_from).map(|_| 0)
        }
        Command::Env(c) => cmd::manage::env(&Session::open(profile)?, c).map(|_| 0),
        Command::Domain(DomainCmd::Set { domain }) => {
            cmd::manage::domain_set(&Session::open(profile)?, &domain).map(|_| 0)
        }
        Command::Key(KeyCmd::Set { key, move_key }) => {
            cmd::manage::key_set(&Session::open(profile)?, key, move_key).map(|_| 0)
        }
        Command::Server { args } => cmd::manage::server(&Session::open(profile)?, &args),
        Command::Doctor => cmd::status::doctor(&Session::open(profile)?),
        Command::Ssh => {
            let s = Session::open(profile)?;
            s.t().shell(compose::DIR)
        }
        Command::Uninstall { purge } => {
            cmd::manage::uninstall(&Session::open(profile)?, purge).map(|_| 0)
        }
        Command::SelfUpdate { check } => cmd::self_update::run(check).map(|_| 0),
    }
}
