//! Profiles: one entry per install this machine manages, in the OS config
//! directory (`~/.config/agnts`, `~/Library/Application Support/agnts`,
//! `%APPDATA%\agnts`).

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Mode {
    Remote,
    Local,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Profile {
    pub mode: Mode,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub host: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub ssh_port: Option<u16>,
    pub domain: String,
    pub install_id: String,
    pub version: String,
}

#[derive(Debug, Default, Serialize, Deserialize)]
pub struct Config {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub default: Option<String>,
    #[serde(default)]
    pub profiles: BTreeMap<String, Profile>,
}

pub fn config_dir() -> PathBuf {
    if let Ok(d) = std::env::var("AGNTS_CONFIG_DIR") {
        return PathBuf::from(d);
    }
    directories::BaseDirs::new()
        .map(|b| b.config_dir().join("agnts"))
        .unwrap_or_else(|| PathBuf::from(".agnts"))
}

fn config_file() -> PathBuf {
    config_dir().join("config.toml")
}

impl Config {
    pub fn load() -> Result<Self> {
        let p = config_file();
        match std::fs::read_to_string(&p) {
            Ok(s) => toml::from_str(&s).with_context(|| format!("reading {}", p.display())),
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok(Config::default()),
            Err(e) => Err(e).with_context(|| format!("reading {}", p.display())),
        }
    }

    pub fn save(&self) -> Result<()> {
        write_private(&config_file(), toml::to_string_pretty(self)?.as_bytes())
    }

    pub fn put(&mut self, name: &str, p: Profile) {
        self.profiles.insert(name.to_string(), p);
        if self.default.is_none() || self.profiles.len() == 1 {
            self.default = Some(name.to_string());
        }
    }

    pub fn remove(&mut self, name: &str) {
        self.profiles.remove(name);
        if self.default.as_deref() == Some(name) {
            self.default = self.profiles.keys().next().cloned();
        }
    }
}

/// Where remote mode keeps the off-server copy of `AGNTS_ENC_KEY`.
pub fn enc_key_path(profile: &str) -> PathBuf {
    config_dir().join("keys").join(format!("{profile}.enc-key"))
}

/// Where `agnts backup --pull` stores dumps.
pub fn backups_dir(profile: &str) -> PathBuf {
    config_dir().join("backups").join(profile)
}

/// Write a file only the current user can read.
pub fn write_private(path: &Path, data: &[u8]) -> Result<()> {
    if let Some(dir) = path.parent() {
        std::fs::create_dir_all(dir)?;
    }
    let tmp = path.with_extension("tmp");
    {
        use std::io::Write;
        let mut opts = std::fs::OpenOptions::new();
        opts.write(true).create(true).truncate(true);
        #[cfg(unix)]
        {
            use std::os::unix::fs::OpenOptionsExt;
            opts.mode(0o600);
        }
        let mut f = opts
            .open(&tmp)
            .with_context(|| format!("writing {}", tmp.display()))?;
        f.write_all(data)?;
    }
    std::fs::rename(&tmp, path).with_context(|| format!("writing {}", path.display()))?;
    Ok(())
}

/// Profile name from a domain: `agnts.acme.com` stays as it is.
pub fn name_for(domain: &str) -> String {
    domain.to_string()
}
