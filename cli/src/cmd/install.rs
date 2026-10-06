use anyhow::{bail, Result};

use crate::cli::InstallArgs;
use crate::cloud::Cloud;
use crate::profile::Mode;
use crate::steps::{self, InstallOpts};
use crate::target::{LocalTarget, SshTarget, Target};
use crate::ui;

pub fn run(a: InstallArgs, profile: Option<String>) -> Result<()> {
    let mode = match (&a.host, a.local) {
        (Some(_), false) => Mode::Remote,
        (None, true) => Mode::Local,
        _ => bail!("say where to install: `agnts install root@your-server` (remote) or `sudo agnts install --local` (on the server)"),
    };
    let opts = InstallOpts {
        mode: Some(mode),
        host: a.host.clone(),
        ssh_port: a.ssh_port,
        profile,
        domain: a.domain,
        email: a.email,
        key: a.key.filter(|k| !k.is_empty()),
        git_name: a.git_name,
        git_email: a.git_email,
        admin: a.admin,
        move_key: a.move_key,
        dry_run: a.dry_run,
        version: a.version,
        no_firewall: a.no_firewall,
        skip_dns_check: a.skip_dns_check,
        skip_probe: a.skip_probe,
        ignore_preflight: a.ignore_preflight,
    };
    let total = steps::all().len() + 1;
    ui::header("Installing agnts");
    ui::step(1, total, "Connect");
    let target: Box<dyn Target> = match mode {
        Mode::Remote => {
            let t = SshTarget::new(a.host.as_deref().unwrap(), a.ssh_port);
            t.connect()?;
            Box::new(t)
        }
        Mode::Local => Box::new(LocalTarget::new()?),
    };
    ui::ok(&format!("connected to {}", target.label()));
    let cloud = Cloud::new()?;
    steps::install(target.as_ref(), &cloud, &opts, mode, 1)
}
