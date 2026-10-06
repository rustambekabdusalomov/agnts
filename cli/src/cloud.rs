//! The agnts.uz API: access keys, install registration, the reachability
//! probe and CLI releases. Every call waits out short outages (see `wait`).

use std::collections::HashMap;
use std::fmt;
use std::time::Duration;

use anyhow::{Context, Result};
use reqwest::blocking::{Client, RequestBuilder, Response};
use reqwest::StatusCode;
use serde::de::DeserializeOwned;
use serde::{Deserialize, Serialize};

use crate::wait::{self, Attempt, Policy};

pub const DEFAULT_URL: &str = "https://agnts.uz";
pub const CABINET_KEYS: &str = "https://agnts.uz/cabinet/keys";

/// Errors about the access key itself. They never trigger waiting.
#[derive(Debug)]
pub enum KeyError {
    Rejected(String),
    InUse { domain: String },
}

impl fmt::Display for KeyError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            KeyError::Rejected(msg) => write!(
                f,
                "the access key was rejected ({msg}). Check it, or create a new one at {CABINET_KEYS}"
            ),
            KeyError::InUse { domain } => write!(
                f,
                "this key is already used by the install at {domain}.\nCreate a new key at {CABINET_KEYS}, or move this key here with --move"
            ),
        }
    }
}

impl std::error::Error for KeyError {}

#[derive(Serialize)]
struct ClaimReq<'a> {
    install_id: &'a str,
    domain: &'a str,
    #[serde(rename = "move")]
    move_key: bool,
    cli_version: &'a str,
}

#[derive(Serialize)]
pub struct Report<'a> {
    pub install_id: &'a str,
    pub domain: &'a str,
    pub version: &'a str,
    /// installed | upgraded | domain_changed | rolled_back
    pub event: &'a str,
}

#[derive(Serialize)]
struct InstallRef<'a> {
    install_id: &'a str,
}

#[derive(Serialize)]
struct ProbeReq<'a> {
    url: &'a str,
    expect: &'a str,
}

#[derive(Deserialize, Debug)]
pub struct ProbeResult {
    pub ok: bool,
    #[serde(default)]
    pub error: Option<String>,
}

#[derive(Deserialize, Debug)]
pub struct Release {
    pub version: String,
    #[serde(default)]
    pub assets: HashMap<String, ReleaseAsset>,
}

#[derive(Deserialize, Debug, Clone)]
pub struct ReleaseAsset {
    pub url: String,
    pub sha256: String,
}

#[derive(Deserialize)]
struct ErrorBody {
    #[serde(default)]
    message: Option<String>,
    #[serde(default)]
    error: Option<String>,
    #[serde(default)]
    domain: Option<String>,
    #[serde(default)]
    retry_after: Option<u64>,
}

pub struct Cloud {
    base: String,
    http: Client,
    pub policy: Policy,
}

impl Cloud {
    pub fn new() -> Result<Self> {
        let base = std::env::var("AGNTS_CLOUD_URL").unwrap_or_else(|_| DEFAULT_URL.to_string());
        Self::with_base(base.trim_end_matches('/'))
    }

    pub fn with_base(base: &str) -> Result<Self> {
        let http = Client::builder()
            .timeout(Duration::from_secs(30))
            .connect_timeout(Duration::from_secs(10))
            .user_agent(format!("agnts-cli/{} ({})", crate::VERSION, crate::TARGET))
            .build()?;
        Ok(Cloud {
            base: base.to_string(),
            http,
            policy: Policy::default(),
        })
    }

    pub fn base(&self) -> &str {
        &self.base
    }

    fn host(&self) -> String {
        self.base
            .trim_start_matches("https://")
            .trim_start_matches("http://")
            .to_string()
    }

    fn call<T: DeserializeOwned>(&self, build: impl Fn(&Client) -> RequestBuilder) -> Result<T> {
        let host = self.host();
        wait::until_up(&host, &self.policy, || {
            let resp = classify(&host, build(&self.http).send())?;
            let text = resp.text().map_err(|e| Attempt::Down {
                reason: short(&e),
                retry_after: None,
            })?;
            let text = if text.trim().is_empty() {
                "null".to_string()
            } else {
                text
            };
            serde_json::from_str(&text)
                .with_context(|| format!("unexpected answer from {host}"))
                .map_err(Attempt::Fatal)
        })
    }

    fn url(&self, path: &str) -> String {
        format!("{}{path}", self.base)
    }

    /// Bind `key` to this install. Idempotent for the same install id.
    pub fn claim(&self, key: &str, install_id: &str, domain: &str, move_key: bool) -> Result<()> {
        let body = ClaimReq {
            install_id,
            domain,
            move_key,
            cli_version: crate::VERSION,
        };
        self.call::<serde_json::Value>(|c| {
            c.post(self.url("/api/installs/claim"))
                .bearer_auth(key)
                .json(&body)
        })?;
        Ok(())
    }

    pub fn report(&self, key: &str, report: &Report) -> Result<()> {
        self.call::<serde_json::Value>(|c| {
            c.post(self.url("/api/installs/report"))
                .bearer_auth(key)
                .json(report)
        })?;
        Ok(())
    }

    /// Free the key for another install.
    pub fn release(&self, key: &str, install_id: &str) -> Result<()> {
        let body = InstallRef { install_id };
        self.call::<serde_json::Value>(|c| {
            c.post(self.url("/api/installs/release"))
                .bearer_auth(key)
                .json(&body)
        })?;
        Ok(())
    }

    /// Ask agnts.uz to fetch `url` from outside and look for `expect`.
    pub fn probe(&self, key: &str, url: &str, expect: &str) -> Result<ProbeResult> {
        let body = ProbeReq { url, expect };
        self.call(|c| c.post(self.url("/api/probe")).bearer_auth(key).json(&body))
    }

    pub fn latest_cli(&self) -> Result<Release> {
        self.call(|c| c.get(self.url("/api/cli/latest")))
    }

    /// One quick attempt, no waiting (for hints that must not block).
    pub fn latest_cli_quick(&self) -> Option<Release> {
        let resp = self
            .http
            .get(self.url("/api/cli/latest"))
            .timeout(Duration::from_secs(5))
            .send()
            .ok()?;
        resp.status()
            .is_success()
            .then(|| resp.json().ok())
            .flatten()
    }

    pub fn download(&self, url: &str) -> Result<Vec<u8>> {
        let host = self.host();
        wait::until_up(&host, &self.policy, || {
            let resp = classify(
                &host,
                self.http.get(url).timeout(Duration::from_secs(300)).send(),
            )?;
            resp.bytes().map(|b| b.to_vec()).map_err(|e| Attempt::Down {
                reason: short(&e),
                retry_after: None,
            })
        })
    }
}

fn short(e: &reqwest::Error) -> String {
    if e.is_timeout() {
        "timed out".into()
    } else if e.is_connect() {
        "cannot connect".into()
    } else {
        e.to_string()
    }
}

/// Sort a response into success, "down, wait", or a real error.
fn classify(host: &str, r: reqwest::Result<Response>) -> std::result::Result<Response, Attempt> {
    let resp = match r {
        Ok(resp) => resp,
        Err(e) if e.is_connect() || e.is_timeout() || e.is_request() => {
            return Err(Attempt::Down {
                reason: short(&e),
                retry_after: None,
            })
        }
        Err(e) => return Err(Attempt::Fatal(e.into())),
    };
    let status = resp.status();
    if status.is_success() {
        return Ok(resp);
    }
    let header_retry = resp
        .headers()
        .get(reqwest::header::RETRY_AFTER)
        .and_then(|v| v.to_str().ok())
        .and_then(|v| v.trim().parse::<u64>().ok());
    let text = resp.text().unwrap_or_default();
    let body: Option<ErrorBody> = serde_json::from_str(&text).ok();
    let message = body
        .as_ref()
        .and_then(|b| b.message.clone().or_else(|| b.error.clone()))
        .unwrap_or_else(|| text.chars().take(200).collect());
    match status {
        StatusCode::BAD_GATEWAY | StatusCode::SERVICE_UNAVAILABLE | StatusCode::GATEWAY_TIMEOUT => {
            let retry = header_retry.or(body.as_ref().and_then(|b| b.retry_after));
            let reason = if message.trim().is_empty() || message.starts_with('<') {
                format!("{host}: {}", status.as_u16())
            } else {
                format!("{host}: {}", message.trim())
            };
            Err(Attempt::Down {
                reason,
                retry_after: retry.map(Duration::from_secs),
            })
        }
        StatusCode::UNAUTHORIZED | StatusCode::FORBIDDEN => {
            Err(Attempt::Fatal(KeyError::Rejected(message).into()))
        }
        StatusCode::CONFLICT => Err(Attempt::Fatal(
            KeyError::InUse {
                domain: body
                    .and_then(|b| b.domain)
                    .unwrap_or_else(|| "another server".into()),
            }
            .into(),
        )),
        _ => Err(Attempt::Fatal(anyhow::anyhow!(
            "{host} answered {status}: {message}"
        ))),
    }
}
