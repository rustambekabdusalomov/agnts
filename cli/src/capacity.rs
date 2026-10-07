//! Server capacity: measure the server and decide whether agnts fits.
//!
//! The numbers come from the stack itself: Caddy, agnts, PostgreSQL and the
//! egress proxy need about 1 GB of RAM, and every run container is capped at
//! 4 GB RAM and 2 CPUs (server/internal/runner/runner.go). Disk holds the
//! images (the runner image carries Claude Code, mise and build libraries),
//! the shared toolchain volume (0.1 to 1 GB per language version, installed
//! on first use), the database, backups, and per run a clone plus the
//! repository's package cache (capped at AGNTS_CACHE_MAX_GB, 5 GB).

use anyhow::Result;

use crate::target::{Cmd, Target};
use crate::ui;

const GB: u64 = 1024 * 1024; // in KB

/// Below these, agnts does not install.
pub const MIN_CPUS: u32 = 2;
pub const MIN_MEM_KB: u64 = 3_600_000; // "4 GB" plans report about 3.8 GB
pub const MIN_DISK_KB: u64 = 25 * GB;
/// Below these, agnts installs with a warning.
pub const GOOD_MEM_KB: u64 = 5 * GB;
pub const GOOD_DISK_KB: u64 = 40 * GB;
pub const SLOW_DISK_MBS: f64 = 50.0;
/// On a server where agnts already runs, its images are already on disk.
pub const MIN_DISK_INSTALLED_KB: u64 = 5 * GB;
pub const GOOD_DISK_INSTALLED_KB: u64 = 10 * GB;

/// What the stack needs besides runs, and what each parallel run adds.
const BASE_MEM_KB: u64 = GB;
const RUN_MEM_KB: u64 = 4 * GB;
const RUN_CPUS: u32 = 2;
const BASE_DISK_KB: u64 = 20 * GB;
const RUN_DISK_KB: u64 = 5 * GB;
const MAX_PARALLEL: u32 = 8;

#[derive(Clone, Debug, Default)]
pub struct Measured {
    pub cpus: u32,
    pub cpu_model: String,
    pub mem_total_kb: u64,
    pub mem_available_kb: u64,
    pub swap_kb: u64,
    pub disk_free_kb: u64,
    pub disk_path: String,
    /// Sequential write speed, when measured.
    pub disk_write_mbs: Option<f64>,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum Level {
    Ok,
    Tight,
    NotEnough,
}

#[derive(Debug)]
pub struct Item {
    pub name: &'static str,
    pub have: String,
    pub need: String,
    pub level: Level,
    pub note: Option<String>,
}

#[derive(Debug)]
pub struct Assessment {
    pub items: Vec<Item>,
    /// Runs that fit at once (AGNTS_PARALLEL).
    pub parallel: u32,
}

impl Assessment {
    pub fn level(&self) -> Level {
        self.items
            .iter()
            .map(|i| i.level)
            .max()
            .unwrap_or(Level::Ok)
    }

    pub fn enough(&self) -> bool {
        self.level() != Level::NotEnough
    }
}

pub fn gb(kb: u64) -> String {
    format!("{:.1} GB", kb as f64 / GB as f64)
}

fn meminfo(text: &str, key: &str) -> u64 {
    text.lines()
        .find_map(|l| l.strip_prefix(key))
        .and_then(|v| v.trim_start_matches(':').split_whitespace().next())
        .and_then(|v| v.parse().ok())
        .unwrap_or(0)
}

/// MB/s from dd's summary line, e.g.
/// "268435456 bytes (268 MB, 256 MiB) copied, 0.52 s, 513 MB/s".
pub fn parse_dd(text: &str) -> Option<f64> {
    let line = text.lines().rev().find(|l| l.contains("copied"))?;
    let speed = line.rsplit(", ").next()?.trim();
    let (num, unit) = speed.split_once(' ')?;
    let n: f64 = num.replace(',', ".").parse().ok()?;
    let factor = match unit {
        "GB/s" => 1000.0,
        "MB/s" => 1.0,
        "kB/s" => 0.001,
        "B/s" => 0.000_001,
        _ => return None,
    };
    Some(n * factor)
}

/// Measure the server. `write_test` writes and deletes 256 MB to time the disk.
pub fn measure(t: &dyn Target, write_test: bool) -> Result<Measured> {
    let cpus = t.run(&Cmd::new(["nproc"]))?.text().parse().unwrap_or(0);
    let cpuinfo = t.read_text("/proc/cpuinfo")?.unwrap_or_default();
    let cpu_model = cpuinfo
        .lines()
        .find_map(|l| l.strip_prefix("model name"))
        .map(|v| v.trim_start_matches([' ', '\t', ':']).trim().to_string())
        .unwrap_or_default();
    let mem = t.read_text("/proc/meminfo")?.unwrap_or_default();

    // Docker keeps images and volumes under /var/lib/docker; measure the
    // filesystem that holds it (or will).
    let disk_path = if t
        .run(&Cmd::new(["test", "-d", "/var/lib/docker"]))?
        .success()
    {
        "/var/lib/docker"
    } else {
        "/var/lib"
    };
    let df = t.run(&Cmd::new(["df", "-Pk", disk_path]))?;
    let disk_free_kb = crate::preflight::parse_df_avail_kb(&df.text()).unwrap_or(0);

    let mut disk_write_mbs = None;
    if write_test && disk_free_kb > 2 * GB {
        let script = r#"f=/var/tmp/.agnts-disk-test
dd if=/dev/zero of="$f" bs=1M count=256 oflag=direct conv=fdatasync 2>&1
rm -f "$f""#;
        disk_write_mbs = parse_dd(&t.run(&Cmd::sh(script, &[]))?.text());
    }

    Ok(Measured {
        cpus,
        cpu_model,
        mem_total_kb: meminfo(&mem, "MemTotal"),
        mem_available_kb: meminfo(&mem, "MemAvailable"),
        swap_kb: meminfo(&mem, "SwapTotal"),
        disk_free_kb,
        disk_path: disk_path.to_string(),
        disk_write_mbs,
    })
}

/// Decide from the measurements. `installed`: agnts already runs there, so
/// its images and its own memory use are already counted.
pub fn assess(m: &Measured, installed: bool) -> Assessment {
    let mut items = Vec::new();

    items.push(Item {
        name: "CPU",
        have: if m.cpu_model.is_empty() {
            format!("{} cores", m.cpus)
        } else {
            format!("{} cores ({})", m.cpus, m.cpu_model)
        },
        need: format!("{MIN_CPUS}+ cores"),
        level: if m.cpus < MIN_CPUS {
            Level::NotEnough
        } else {
            Level::Ok
        },
        note: (m.cpus < MIN_CPUS)
            .then(|| "each run gets 2 CPUs and the server needs room for agnts itself".into()),
    });

    let mem_level = if m.mem_total_kb < MIN_MEM_KB {
        Level::NotEnough
    } else if m.mem_total_kb < GOOD_MEM_KB {
        Level::Tight
    } else {
        Level::Ok
    };
    let mem_note = match mem_level {
        Level::NotEnough => Some("agnts needs about 1 GB and each run up to 4 GB".to_string()),
        Level::Tight if m.swap_kb == 0 => Some(
            "fits one run, but a heavy build can use up to 4 GB; add 2–4 GB of swap or pick a bigger server".into(),
        ),
        Level::Tight => Some("fits one run; a heavy build can use up to 4 GB and will swap".into()),
        Level::Ok => None,
    };
    items.push(Item {
        name: "Memory",
        have: format!("{} (swap {})", gb(m.mem_total_kb), gb(m.swap_kb)),
        need: "4 GB+, 5 GB+ recommended".into(),
        level: mem_level,
        note: mem_note,
    });

    // Memory other programs already hold (only meaningful before install).
    let used_by_others = m.mem_total_kb.saturating_sub(m.mem_available_kb);
    if !installed && m.mem_available_kb > 0 && used_by_others > GB {
        items.push(Item {
            name: "Memory in use",
            have: format!("{} used by other programs", gb(used_by_others)),
            need: "a server dedicated to agnts".into(),
            level: Level::Tight,
            note: Some("other programs on this server leave less room for runs".into()),
        });
    }

    let (min_disk, good_disk) = if installed {
        (MIN_DISK_INSTALLED_KB, GOOD_DISK_INSTALLED_KB)
    } else {
        (MIN_DISK_KB, GOOD_DISK_KB)
    };
    let disk_level = if m.disk_free_kb < min_disk {
        Level::NotEnough
    } else if m.disk_free_kb < good_disk {
        Level::Tight
    } else {
        Level::Ok
    };
    items.push(Item {
        name: "Free disk",
        have: format!("{} on {}", gb(m.disk_free_kb), m.disk_path),
        need: format!("{}+, {}+ recommended", gb(min_disk), gb(good_disk)),
        level: disk_level,
        note: match disk_level {
            Level::NotEnough if installed => {
                Some("free space or resize the disk; backups and clones need room".into())
            }
            Level::NotEnough => {
                Some("images, the database, backups and a clone per run need room".into())
            }
            Level::Tight => Some("enough to start; backups and images grow over time".into()),
            Level::Ok => None,
        },
    });

    if let Some(speed) = m.disk_write_mbs {
        items.push(Item {
            name: "Disk speed",
            have: format!("{speed:.0} MB/s write"),
            need: format!("{SLOW_DISK_MBS:.0}+ MB/s"),
            level: if speed < SLOW_DISK_MBS {
                Level::Tight
            } else {
                Level::Ok
            },
            note: (speed < SLOW_DISK_MBS).then(|| {
                "a slow disk makes builds and tests in runs slow; an SSD/NVMe plan helps".into()
            }),
        });
    }

    let by_mem = m.mem_total_kb.saturating_sub(BASE_MEM_KB) / RUN_MEM_KB;
    let by_cpu = (m.cpus / RUN_CPUS) as u64;
    let disk_left = if installed {
        m.disk_free_kb
    } else {
        m.disk_free_kb.saturating_sub(BASE_DISK_KB)
    };
    let by_disk = disk_left / RUN_DISK_KB;
    let parallel = by_mem
        .min(by_cpu)
        .min(by_disk)
        .clamp(1, MAX_PARALLEL as u64) as u32;

    Assessment { items, parallel }
}

/// The full server check: OS, architecture and ports, then capacity.
/// Prints everything and returns the assessment and whether agnts fits.
pub fn check(
    t: &dyn Target,
    installed: bool,
    write_test: bool,
) -> Result<(crate::preflight::HostInfo, Assessment, bool)> {
    let (info, findings) = crate::preflight::run(t, installed)?;
    let mut ok = true;
    for f in &findings {
        if f.ok {
            ui::ok(&format!("{}: {}", f.name, f.detail));
        } else {
            ok = false;
            ui::fail(&format!("{}: {}", f.name, f.detail));
            if let Some(fix) = &f.fix {
                ui::info(&format!("  → {fix}"));
            }
        }
    }
    let pb =
        write_test.then(|| ui::spinner("measuring the server (disk speed test, a few seconds)"));
    let m = measure(t, write_test);
    if let Some(pb) = pb {
        pb.finish_and_clear();
    }
    let a = assess(&m?, installed);
    ui::info("");
    ui::info("Capacity:");
    let fits = report(&a);
    Ok((info, a, ok && fits))
}

/// Print the report. Returns whether agnts fits.
pub fn report(a: &Assessment) -> bool {
    for i in &a.items {
        let line = format!("{}: {}  (needs {})", i.name, i.have, i.need);
        match i.level {
            Level::Ok => ui::ok(&line),
            Level::Tight => ui::warn(&line),
            Level::NotEnough => ui::fail(&line),
        }
        if let Some(n) = &i.note {
            ui::info(&format!("  → {n}"));
        }
    }
    match a.level() {
        Level::NotEnough => {
            ui::fail("This server is too small for agnts.");
            ui::info("Pick a server with at least 2 vCPU, 4 GB RAM and 25 GB free disk");
            ui::info(
                "(recommended: 4 vCPU, 8 GB RAM, 80 GB SSD), then run the same command again.",
            );
            false
        }
        Level::Tight => {
            ui::warn(&format!(
                "Enough to run agnts, with the warnings above. It will work on {} ticket(s) at once.",
                a.parallel
            ));
            true
        }
        Level::Ok => {
            ui::ok(&format!(
                "Enough capacity. agnts will work on {} ticket(s) at once.",
                a.parallel
            ));
            true
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::target::FakeTarget;

    fn server(cpus: u32, mem_gb: f64, disk_gb: u64) -> Measured {
        Measured {
            cpus,
            mem_total_kb: (mem_gb * GB as f64) as u64,
            mem_available_kb: (mem_gb * GB as f64) as u64 - GB / 4,
            swap_kb: 0,
            disk_free_kb: disk_gb * GB,
            disk_path: "/var/lib".into(),
            disk_write_mbs: Some(400.0),
            ..Default::default()
        }
    }

    #[test]
    fn too_small_is_refused() {
        let a = assess(&server(1, 2.0, 20), false);
        assert!(!a.enough());
        let bad: Vec<&str> = a
            .items
            .iter()
            .filter(|i| i.level == Level::NotEnough)
            .map(|i| i.name)
            .collect();
        assert_eq!(bad, vec!["CPU", "Memory", "Free disk"]);
    }

    #[test]
    fn four_gb_server_is_tight_with_one_run() {
        let a = assess(&server(2, 3.8, 35), false);
        assert!(a.enough());
        assert_eq!(a.level(), Level::Tight);
        assert_eq!(a.parallel, 1);
    }

    #[test]
    fn big_server_runs_several_at_once() {
        let a = assess(&server(8, 16.0, 160), false);
        assert_eq!(a.level(), Level::Ok);
        // (16 - 1) / 4 = 3 by memory; 8 / 2 = 4 by CPU.
        assert_eq!(a.parallel, 3);
        assert_eq!(assess(&server(64, 256.0, 2000), false).parallel, 8);
    }

    #[test]
    fn installed_servers_need_less_free_disk() {
        let m = server(4, 8.0, 12);
        assert!(!assess(&m, false).enough());
        assert!(assess(&m, true).enough());
    }

    #[test]
    fn busy_and_slow_servers_get_warnings() {
        let mut m = server(4, 8.0, 100);
        m.mem_available_kb = 3 * GB;
        m.disk_write_mbs = Some(20.0);
        let a = assess(&m, false);
        assert!(a.enough());
        let warned: Vec<&str> = a
            .items
            .iter()
            .filter(|i| i.level == Level::Tight)
            .map(|i| i.name)
            .collect();
        assert_eq!(warned, vec!["Memory in use", "Disk speed"]);
    }

    #[test]
    fn parses_dd() {
        let gnu = "256+0 records in\n256+0 records out\n268435456 bytes (268 MB, 256 MiB) copied, 0.523 s, 513 MB/s\n";
        assert_eq!(parse_dd(gnu), Some(513.0));
        assert_eq!(parse_dd("x bytes copied, 0.2 s, 1.2 GB/s"), Some(1200.0));
        assert_eq!(parse_dd("x bytes copied, 9 s, 30,5 MB/s"), Some(30.5));
        assert_eq!(parse_dd("nothing"), None);
    }

    #[test]
    fn measures_from_the_server() {
        let t = FakeTarget::new();
        t.put(
            "/proc/meminfo",
            "MemTotal: 8000000 kB\nMemAvailable: 7500000 kB\nSwapTotal: 2097148 kB\n",
        )
        .put(
            "/proc/cpuinfo",
            "processor\t: 0\nmodel name\t: AMD EPYC 7763\n",
        );
        t.on("nproc", 0, "4\n")
            .on("test -d /var/lib/docker", 1, "")
            .on("df -Pk", 0, "h\n/dev/sda 1 1 104857600 1% /\n")
            .on(
                "dd if=/dev/zero",
                0,
                "268435456 bytes (268 MB, 256 MiB) copied, 0.5 s, 537 MB/s\n",
            );
        let m = measure(&t, true).unwrap();
        assert_eq!(m.cpus, 4);
        assert_eq!(m.cpu_model, "AMD EPYC 7763");
        assert_eq!(m.mem_total_kb, 8_000_000);
        assert_eq!(m.swap_kb, 2_097_148);
        assert_eq!(m.disk_path, "/var/lib");
        assert_eq!(m.disk_write_mbs, Some(537.0));
        assert!(t.ran("rm -f"));
        assert!(!measure(&t, false).unwrap().disk_write_mbs.is_some());
    }
}
