//! `agnts install`: a list of steps, each with a check and an apply. A step
//! whose check passes is skipped, so a failed install resumes where it
//! stopped. Answers and progress live in `/opt/agnts/.install-state.json`.

mod network;
mod server;
mod setup;
mod stack;

use std::net::{Ipv4Addr, Ipv6Addr};

use anyhow::Result;
use serde::{Deserialize, Serialize};

use crate::cloud::Cloud;
use crate::compose;
use crate::preflight::HostInfo;
use crate::profile::Mode;
use crate::target::Target;
use crate::ui;

/// Everything `agnts install` was given on the command line.
#[derive(Clone, Debug, Default)]
pub struct InstallOpts {
    pub mode: Option<Mode>,
    pub host: Option<String>,
    pub ssh_port: Option<u16>,
    pub profile: Option<String>,
    pub domain: Option<String>,
    pub email: Option<String>,
    pub key: Option<String>,
    pub git_name: Option<String>,
    pub git_email: Option<String>,
    pub admin: Option<String>,
    pub move_key: bool,
    pub dry_run: bool,
    pub version: Option<String>,
    pub no_firewall: bool,
    pub skip_dns_check: bool,
    pub skip_probe: bool,
    pub ignore_preflight: bool,
}

/// The answers, kept on the server so a resumed install does not ask again.
#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct InstallConfig {
    pub domain: String,
    pub email: String,
    pub git_name: String,
    pub git_email: String,
    pub admin: String,
    pub version: String,
}

#[derive(Debug, Default, Serialize, Deserialize)]
pub struct InstallState {
    #[serde(default)]
    pub config: Option<InstallConfig>,
    #[serde(default)]
    pub completed: Vec<String>,
}

pub fn state_path() -> String {
    compose::path(".install-state.json")
}

/// Shared state for the steps of one install.
pub struct Cx<'a> {
    pub target: &'a dyn Target,
    pub cloud: &'a Cloud,
    pub opts: &'a InstallOpts,
    pub mode: Mode,
    pub cfg: InstallConfig,
    pub state: InstallState,
    pub key: Option<String>,
    pub install_id: Option<String>,
    pub host: Option<HostInfo>,
    pub ip: Option<(Ipv4Addr, Option<Ipv6Addr>)>,
    /// Runs that fit at once, from the capacity check.
    pub parallel: Option<u32>,
    pub profile_name: String,
}

impl Cx<'_> {
    pub fn completed(&self, id: &str) -> bool {
        self.state.completed.iter().any(|c| c == id)
    }

    fn save_state(&mut self) -> Result<()> {
        if self.opts.dry_run {
            return Ok(());
        }
        self.state.config = Some(self.cfg.clone());
        let json = serde_json::to_vec_pretty(&self.state)?;
        self.target.write_file(&state_path(), &json, 0o600)
    }

    fn mark(&mut self, id: &str) -> Result<()> {
        if !self.completed(id) {
            self.state.completed.push(id.to_string());
        }
        self.save_state()
    }

    pub fn key(&self) -> &str {
        self.key.as_deref().unwrap_or_default()
    }

    pub fn install_id(&self) -> &str {
        self.install_id.as_deref().unwrap_or_default()
    }
}

pub trait Step {
    fn id(&self) -> &'static str;
    fn title(&self) -> &'static str;
    /// True when nothing needs doing. Errors count as "needed".
    fn check(&self, cx: &mut Cx) -> Result<bool>;
    fn apply(&self, cx: &mut Cx) -> Result<()>;
    /// What `apply` would do, for `--dry-run`.
    fn plan(&self, cx: &Cx) -> Vec<String>;
    /// Safe to run during `--dry-run` (asks questions or reads only).
    fn read_only(&self) -> bool {
        false
    }
}

pub fn all() -> Vec<Box<dyn Step>> {
    vec![
        Box::new(setup::Preflight),
        Box::new(setup::Ask),
        Box::new(setup::ClaimKey),
        Box::new(server::Docker),
        Box::new(server::Firewall),
        Box::new(network::Dns),
        Box::new(network::Probe),
        Box::new(stack::Files),
        Box::new(stack::Secrets),
        Box::new(stack::Images),
        Box::new(stack::Toolchains),
        Box::new(stack::Start),
        Box::new(stack::Https),
        Box::new(stack::AdminUser),
        Box::new(stack::Done),
    ]
}

/// Run the install. `first` is the number of steps already shown (Connect).
pub fn install(
    target: &dyn Target,
    cloud: &Cloud,
    opts: &InstallOpts,
    mode: Mode,
    first: usize,
) -> Result<()> {
    let state = match target.read_text(&state_path())? {
        Some(s) => serde_json::from_str(&s).unwrap_or_default(),
        None => InstallState::default(),
    };
    let mut cx = Cx {
        target,
        cloud,
        opts,
        mode,
        cfg: InstallConfig::default(),
        state,
        key: opts.key.clone(),
        install_id: None,
        host: None,
        ip: None,
        parallel: None,
        profile_name: String::new(),
    };
    let steps = all();
    let total = steps.len() + first;
    run_steps(&mut cx, &steps, first, total, None)?;
    if opts.dry_run {
        ui::header("Dry run: nothing was changed.");
    }
    Ok(())
}

/// Run `steps` in order; stop before the step with id `until` (tests).
fn run_steps(
    cx: &mut Cx,
    steps: &[Box<dyn Step>],
    first: usize,
    total: usize,
    until: Option<&str>,
) -> Result<()> {
    let dry_run = cx.opts.dry_run;
    for (i, step) in steps.iter().enumerate() {
        if until == Some(step.id()) {
            break;
        }
        ui::step(i + 1 + first, total, step.title());
        if dry_run && !step.read_only() {
            match step.check(cx) {
                Ok(true) => ui::skip("already done"),
                _ => {
                    for line in step.plan(cx) {
                        ui::info(&format!("would {line}"));
                    }
                }
            }
            continue;
        }
        if !step.read_only() && step.check(cx).unwrap_or(false) {
            ui::skip("already done");
            continue;
        }
        step.apply(cx)?;
        if !step.read_only() {
            cx.mark(step.id())?;
        } else if step.id() == "ask" {
            cx.save_state()?;
        }
    }
    Ok(())
}

#[cfg(test)]
#[path = "../../tests/support/stub.rs"]
mod stub;

#[cfg(test)]
mod tests {
    use std::time::Duration;

    use super::*;
    use crate::cloud::KeyError;
    use crate::target::FakeTarget;

    fn server() -> FakeTarget {
        let t = FakeTarget::new();
        t.put(
            "/etc/os-release",
            "ID=ubuntu\nVERSION_ID=\"24.04\"\nVERSION_CODENAME=noble\n",
        )
        .put(
            "/proc/meminfo",
            "MemTotal: 8000000 kB\nMemAvailable: 7800000 kB\nSwapTotal: 0 kB\n",
        );
        t.on("uname -m", 0, "x86_64\n")
            .on("df -Pk", 0, "h\n/dev/sda 1 1 99999999 1% /\n")
            .on("ss -H", 0, "")
            .on("nproc", 0, "4\n")
            .on("docker compose version", 0, "2.29.1\n")
            .on("systemctl is-active docker", 0, "active\n")
            .on("getent group docker", 0, "docker:x:998:\n")
            .on("docker image inspect", 1, "");
        t
    }

    fn opts() -> InstallOpts {
        InstallOpts {
            mode: Some(Mode::Local),
            profile: Some("test".into()),
            domain: Some("agnts.acme.com".into()),
            email: Some("me@acme.com".into()),
            key: Some("agk_secret".into()),
            git_name: Some("Me".into()),
            git_email: Some("me@acme.com".into()),
            admin: Some("admin".into()),
            version: Some("1.0.0".into()),
            no_firewall: true,
            skip_dns_check: true,
            skip_probe: true,
            ..Default::default()
        }
    }

    fn run(t: &FakeTarget, cloud: &Cloud, opts: &InstallOpts) -> Result<()> {
        let mut cx = Cx {
            target: t,
            cloud,
            opts,
            mode: Mode::Local,
            cfg: InstallConfig::default(),
            state: t
                .read_text(&state_path())
                .unwrap()
                .map(|s| serde_json::from_str(&s).unwrap())
                .unwrap_or_default(),
            key: opts.key.clone(),
            install_id: None,
            host: None,
            ip: None,
            parallel: None,
            profile_name: String::new(),
        };
        let steps = all();
        // Start onwards needs real containers and a real domain.
        run_steps(&mut cx, &steps, 0, steps.len(), Some("start"))
    }

    #[test]
    fn too_small_server_stops_before_any_change() {
        let stub = stub::Stub::start("127.0.0.1:0", &["agk_secret"]);
        let cloud = Cloud::with_base(&stub.url).unwrap();
        let t = server();
        t.put(
            "/proc/meminfo",
            "MemTotal: 2000000 kB\nMemAvailable: 1900000 kB\n",
        );
        let err = run(&t, &cloud, &opts()).unwrap_err();
        assert!(err.to_string().contains("nothing was installed"), "{err}");
        assert!(
            stub.state.lock().unwrap().log.is_empty(),
            "the key was not claimed"
        );
        assert!(
            t.files
                .borrow()
                .keys()
                .all(|p| !p.starts_with("/opt/agnts")),
            "nothing written"
        );
    }

    #[test]
    fn installs_resumes_and_guards_the_key() {
        let dir =
            std::env::temp_dir().join(format!("agnts-test-{}", uuid::Uuid::new_v4().simple()));
        std::env::set_var("AGNTS_CONFIG_DIR", &dir);
        let stub = stub::Stub::start("127.0.0.1:0", &["agk_secret"]);
        let mut cloud = Cloud::with_base(&stub.url).unwrap();
        cloud.policy.interval = Duration::from_millis(10);

        let t = server();
        stub.down_for_requests(2); // agnts.uz is briefly down during the claim
        run(&t, &cloud, &opts()).unwrap();

        let id = t.file("/opt/agnts/install-id").unwrap().trim().to_string();
        let bound = stub.state.lock().unwrap().keys["agk_secret"]
            .clone()
            .unwrap();
        assert_eq!(bound, (id.clone(), "agnts.acme.com".to_string()));

        let env = t.file("/opt/agnts/.env").unwrap();
        assert!(env.contains("AGNTS_DOMAIN=agnts.acme.com"));
        assert!(env.contains("AGNTS_IMAGE=registry.agnts.uz/agnts:1.0.0"));
        // 8 GB and 4 CPUs: (8 - 1) / 4 = 1 run at a time by memory.
        assert!(env.contains("AGNTS_PARALLEL=1"));
        assert_eq!(t.mode("/opt/agnts/.env"), Some(0o600));
        assert!(t.file("/opt/agnts/docker-compose.yml").is_some());

        // The key goes to docker login on stdin, never on a command line.
        assert!(t.ran(&format!(
            "docker login registry.agnts.uz --username {id} --password-stdin"
        )));
        assert!(!t.log.borrow().iter().any(|l| l.contains("agk_secret")));

        let state: InstallState = serde_json::from_str(&t.file(&state_path()).unwrap()).unwrap();
        for s in ["claim", "files", "env", "images"] {
            assert!(state.completed.iter().any(|c| c == s), "{s} not recorded");
        }

        // A second run resumes: files and .env are already right, so they are
        // not written again, and the secrets stay the same.
        let writes = |t: &FakeTarget| {
            t.log
                .borrow()
                .iter()
                .filter(|l| *l == "write /opt/agnts/.env")
                .count()
        };
        let before = writes(&t);
        run(
            &t,
            &cloud,
            &InstallOpts {
                domain: None,
                email: None,
                ..opts()
            },
        )
        .unwrap();
        assert_eq!(writes(&t), before);
        assert_eq!(t.file("/opt/agnts/.env").unwrap(), env);

        // The same key on another server is refused.
        let other = server();
        let err = run(&other, &cloud, &opts()).unwrap_err();
        assert!(matches!(
            err.downcast_ref::<KeyError>(),
            Some(KeyError::InUse { .. })
        ));
        let _ = std::fs::remove_dir_all(dir);
    }
}
