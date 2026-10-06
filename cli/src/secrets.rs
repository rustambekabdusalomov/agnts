//! Access key storage on the machine the CLI runs on: the OS keychain on
//! macOS and Windows, a 0600 file elsewhere (and whenever AGNTS_CONFIG_DIR
//! is set). The server itself only keeps the key as Docker's registry
//! credential.

use anyhow::Result;
use base64::Engine;

use crate::target::Target;

/// The account name for local mode.
pub const LOCAL: &str = "local";

#[cfg(any(target_os = "macos", target_os = "windows"))]
mod keychain {
    use anyhow::Result;

    fn entry(account: &str) -> Result<keyring::Entry> {
        Ok(keyring::Entry::new("agnts", account)?)
    }

    pub fn save(account: &str, key: &str) -> Result<()> {
        entry(account)?.set_password(key)?;
        Ok(())
    }

    pub fn load(account: &str) -> Result<Option<String>> {
        match entry(account)?.get_password() {
            Ok(k) => Ok(Some(k)),
            Err(keyring::Error::NoEntry) => Ok(None),
            Err(e) => Err(e.into()),
        }
    }

    pub fn delete(account: &str) -> Result<()> {
        match entry(account)?.delete_credential() {
            Ok(()) | Err(keyring::Error::NoEntry) => Ok(()),
            Err(e) => Err(e.into()),
        }
    }
}

mod file {
    use std::collections::BTreeMap;

    use anyhow::Result;

    use crate::profile::{config_dir, write_private};

    fn file() -> std::path::PathBuf {
        config_dir().join("credentials.toml")
    }

    fn read() -> Result<BTreeMap<String, String>> {
        match std::fs::read_to_string(file()) {
            Ok(s) => Ok(toml::from_str(&s)?),
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok(BTreeMap::new()),
            Err(e) => Err(e.into()),
        }
    }

    fn write(m: &BTreeMap<String, String>) -> Result<()> {
        write_private(&file(), toml::to_string(m)?.as_bytes())
    }

    pub fn save(account: &str, key: &str) -> Result<()> {
        let mut m = read()?;
        m.insert(account.to_string(), key.to_string());
        write(&m)
    }

    pub fn load(account: &str) -> Result<Option<String>> {
        Ok(read()?.get(account).cloned())
    }

    pub fn delete(account: &str) -> Result<()> {
        let mut m = read()?;
        if m.remove(account).is_some() {
            write(&m)?;
        }
        Ok(())
    }
}

/// An isolated config directory (tests, scripted runs) keeps its keys next
/// to it instead of in the OS keychain.
#[cfg(any(target_os = "macos", target_os = "windows"))]
fn use_keychain() -> bool {
    std::env::var_os("AGNTS_CONFIG_DIR").is_none()
}

pub fn save(account: &str, key: &str) -> Result<()> {
    #[cfg(any(target_os = "macos", target_os = "windows"))]
    if use_keychain() {
        return keychain::save(account, key);
    }
    file::save(account, key)
}

pub fn load(account: &str) -> Result<Option<String>> {
    #[cfg(any(target_os = "macos", target_os = "windows"))]
    if use_keychain() {
        return keychain::load(account);
    }
    file::load(account)
}

pub fn delete(account: &str) -> Result<()> {
    #[cfg(any(target_os = "macos", target_os = "windows"))]
    if use_keychain() {
        return keychain::delete(account);
    }
    file::delete(account)
}

/// The key from the server's Docker credential, for a laptop that does not
/// have it (a second laptop, or a reinstalled one).
pub fn from_server(t: &dyn Target) -> Result<Option<String>> {
    let Some(text) = t.read_text("/root/.docker/config.json")? else {
        return Ok(None);
    };
    Ok(parse_docker_config(&text, &crate::compose::registry()))
}

pub fn parse_docker_config(text: &str, registry: &str) -> Option<String> {
    let v: serde_json::Value = serde_json::from_str(text).ok()?;
    let auth = v.get("auths")?.get(registry)?.get("auth")?.as_str()?;
    let raw = base64::engine::general_purpose::STANDARD
        .decode(auth)
        .ok()?;
    let s = String::from_utf8(raw).ok()?;
    s.split_once(':').map(|(_, pass)| pass.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn reads_key_from_docker_config() {
        let auth = base64::engine::general_purpose::STANDARD.encode("install-1:agk_secret");
        let cfg = format!(r#"{{"auths":{{"registry.agnts.uz":{{"auth":"{auth}"}}}}}}"#);
        assert_eq!(
            parse_docker_config(&cfg, "registry.agnts.uz").as_deref(),
            Some("agk_secret")
        );
        assert_eq!(parse_docker_config(&cfg, "other"), None);
    }
}
