//! Checks that the server can run agnts. Shared by `install` and `doctor`.

use std::collections::HashMap;

use anyhow::Result;

use crate::target::{Cmd, Target};

pub const MIN_MEM_KB: u64 = 1_900_000; // 2 GB, minus what the kernel reserves
pub const MIN_DISK_KB: u64 = 20 * 1024 * 1024;

#[derive(Clone, Debug, Default)]
pub struct HostInfo {
    pub os_id: String,
    pub version_id: String,
    pub codename: String,
    pub pretty: String,
    pub arch: String,
}

#[derive(Debug)]
pub struct Finding {
    pub name: &'static str,
    pub ok: bool,
    pub detail: String,
    pub fix: Option<String>,
}

impl Finding {
    fn pass(name: &'static str, detail: impl Into<String>) -> Self {
        Finding {
            name,
            ok: true,
            detail: detail.into(),
            fix: None,
        }
    }

    fn fail(name: &'static str, detail: impl Into<String>, fix: impl Into<String>) -> Self {
        Finding {
            name,
            ok: false,
            detail: detail.into(),
            fix: Some(fix.into()),
        }
    }
}

pub fn parse_os_release(text: &str) -> HashMap<String, String> {
    text.lines()
        .filter_map(|l| l.split_once('='))
        .map(|(k, v)| (k.trim().to_string(), v.trim().trim_matches('"').to_string()))
        .collect()
}

pub fn supported_os(id: &str, version: &str) -> bool {
    matches!(
        (id, version),
        ("ubuntu", "22.04") | ("ubuntu", "24.04") | ("debian", "12")
    )
}

pub fn parse_meminfo_kb(text: &str) -> Option<u64> {
    text.lines()
        .find_map(|l| l.strip_prefix("MemTotal:"))
        .and_then(|v| v.split_whitespace().next())
        .and_then(|v| v.parse().ok())
}

/// Available KB from `df -Pk <path>`.
pub fn parse_df_avail_kb(text: &str) -> Option<u64> {
    text.lines().nth(1)?.split_whitespace().nth(3)?.parse().ok()
}

/// (port, process) for TCP listeners on 80/443 from `ss -H -ltnp`.
pub fn parse_listeners(text: &str) -> Vec<(u16, String)> {
    text.lines()
        .filter_map(|l| {
            let cols: Vec<&str> = l.split_whitespace().collect();
            let local = cols.get(3)?;
            let port: u16 = local.rsplit(':').next()?.parse().ok()?;
            if port != 80 && port != 443 {
                return None;
            }
            let proc = l
                .split("((\"")
                .nth(1)
                .and_then(|r| r.split('"').next())
                .unwrap_or("unknown")
                .to_string();
            Some((port, proc))
        })
        .collect()
}

/// Run every check. `installed` means agnts may already hold 80/443.
pub fn run(t: &dyn Target, installed: bool) -> Result<(HostInfo, Vec<Finding>)> {
    let mut info = HostInfo::default();
    let mut f = Vec::new();

    let os = parse_os_release(&t.read_text("/etc/os-release")?.unwrap_or_default());
    info.os_id = os.get("ID").cloned().unwrap_or_default();
    info.version_id = os.get("VERSION_ID").cloned().unwrap_or_default();
    info.codename = os.get("VERSION_CODENAME").cloned().unwrap_or_default();
    info.pretty = os
        .get("PRETTY_NAME")
        .cloned()
        .unwrap_or_else(|| "unknown OS".into());
    if supported_os(&info.os_id, &info.version_id) {
        f.push(Finding::pass("Operating system", info.pretty.clone()));
    } else {
        f.push(Finding::fail(
            "Operating system",
            info.pretty.clone(),
            "agnts supports Ubuntu 22.04, Ubuntu 24.04 and Debian 12. Reinstall the server with one of them",
        ));
    }

    info.arch = t.run(&Cmd::new(["uname", "-m"]))?.text();
    match info.arch.as_str() {
        "x86_64" => f.push(Finding::pass("Architecture", "amd64")),
        "aarch64" => f.push(Finding::fail(
            "Architecture",
            "arm64",
            "arm64 servers are not supported yet; use an amd64 (x86_64) server",
        )),
        other => f.push(Finding::fail(
            "Architecture",
            other.to_string(),
            "use an amd64 (x86_64) server",
        )),
    }

    let mem = parse_meminfo_kb(&t.read_text("/proc/meminfo")?.unwrap_or_default()).unwrap_or(0);
    let gb = |kb: u64| format!("{:.1} GB", kb as f64 / 1024.0 / 1024.0);
    if mem >= MIN_MEM_KB {
        f.push(Finding::pass("Memory", gb(mem)));
    } else {
        f.push(Finding::fail(
            "Memory",
            gb(mem),
            "agnts needs at least 2 GB of RAM; pick a bigger server",
        ));
    }

    let df = t.run(&Cmd::new(["df", "-Pk", "/"]))?;
    let disk = parse_df_avail_kb(&df.text()).unwrap_or(0);
    if disk >= MIN_DISK_KB {
        f.push(Finding::pass("Free disk", gb(disk)));
    } else {
        f.push(Finding::fail(
            "Free disk",
            gb(disk),
            "agnts needs at least 20 GB free on /; free some space or resize the disk",
        ));
    }

    let ss = t.run(&Cmd::new(["ss", "-H", "-ltnp"]))?;
    if ss.success() {
        let busy: Vec<(u16, String)> = parse_listeners(&ss.text())
            .into_iter()
            .filter(|(_, p)| !(installed && p == "docker-proxy"))
            .collect();
        if busy.is_empty() {
            f.push(Finding::pass("Ports 80/443", "free"));
        } else {
            let who: Vec<String> = busy
                .iter()
                .map(|(p, n)| format!("{p} used by {n}"))
                .collect();
            f.push(Finding::fail(
                "Ports 80/443",
                who.join(", "),
                "agnts serves HTTPS itself; stop and disable the web server using these ports (for example: systemctl disable --now nginx)",
            ));
        }
    } else {
        f.push(Finding::pass("Ports 80/443", "not checked (no `ss`)"));
    }

    Ok((info, f))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::target::FakeTarget;

    #[test]
    fn parses_helpers() {
        let os = parse_os_release("ID=ubuntu\nVERSION_ID=\"24.04\"\n");
        assert!(supported_os(&os["ID"], &os["VERSION_ID"]));
        assert!(!supported_os("centos", "9"));
        assert_eq!(
            parse_meminfo_kb("MemTotal:        4028248 kB\n"),
            Some(4028248)
        );
        let df = "Filesystem 1024-blocks Used Available Capacity Mounted on\n/dev/sda1 80000000 1000 50000000 2% /\n";
        assert_eq!(parse_df_avail_kb(df), Some(50000000));
        let ss = r#"LISTEN 0 4096 0.0.0.0:80 0.0.0.0:* users:(("docker-proxy",pid=10,fd=4))
LISTEN 0 511 [::]:443 [::]:* users:(("nginx",pid=11,fd=6))
LISTEN 0 128 0.0.0.0:22 0.0.0.0:* users:(("sshd",pid=1,fd=3))"#;
        assert_eq!(
            parse_listeners(ss),
            vec![(80, "docker-proxy".to_string()), (443, "nginx".to_string())]
        );
    }

    #[test]
    fn flags_a_small_server() {
        let t = FakeTarget::new();
        t.put(
            "/etc/os-release",
            "ID=ubuntu\nVERSION_ID=\"24.04\"\nPRETTY_NAME=\"Ubuntu 24.04\"\n",
        )
        .put("/proc/meminfo", "MemTotal: 1000000 kB\n");
        t.on("uname", 0, "x86_64\n")
            .on("df -Pk", 0, "h\n/dev/sda 1 1 99999999 1% /\n")
            .on("ss -H", 0, "");
        let (info, f) = run(&t, false).unwrap();
        assert_eq!(info.os_id, "ubuntu");
        let failed: Vec<&str> = f.iter().filter(|x| !x.ok).map(|x| x.name).collect();
        assert_eq!(failed, vec!["Memory"]);
    }
}
