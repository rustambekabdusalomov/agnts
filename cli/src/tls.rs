//! Certificate expiry of a live HTTPS site, for `status` and `doctor`.

use std::io::ErrorKind;
use std::net::{TcpStream, ToSocketAddrs};
use std::sync::Arc;
use std::time::Duration;

use anyhow::{anyhow, Context, Result};
use rustls::pki_types::ServerName;

/// Unix time the certificate served for `domain` expires.
pub fn cert_expiry(domain: &str) -> Result<i64> {
    let roots = rustls::RootCertStore {
        roots: webpki_roots::TLS_SERVER_ROOTS.to_vec(),
    };
    let config = rustls::ClientConfig::builder_with_provider(Arc::new(
        rustls::crypto::ring::default_provider(),
    ))
    .with_safe_default_protocol_versions()?
    .with_root_certificates(roots)
    .with_no_client_auth();
    let name = ServerName::try_from(domain.to_string())?;
    let mut conn = rustls::ClientConnection::new(Arc::new(config), name)?;
    let addr = (domain, 443)
        .to_socket_addrs()
        .with_context(|| format!("resolving {domain}"))?
        .next()
        .ok_or_else(|| anyhow!("{domain} does not resolve"))?;
    let mut sock = TcpStream::connect_timeout(&addr, Duration::from_secs(10))?;
    sock.set_read_timeout(Some(Duration::from_secs(10)))?;
    sock.set_write_timeout(Some(Duration::from_secs(10)))?;
    while conn.is_handshaking() {
        match conn.complete_io(&mut sock) {
            Ok(_) => {}
            Err(e) if e.kind() == ErrorKind::Interrupted => {}
            Err(e) => return Err(e).context("TLS handshake"),
        }
    }
    let cert = conn
        .peer_certificates()
        .and_then(|c| c.first())
        .ok_or_else(|| anyhow!("no certificate"))?;
    let (_, x) = x509_parser::parse_x509_certificate(cert.as_ref()).map_err(|e| anyhow!("{e}"))?;
    Ok(x.validity().not_after.timestamp())
}

/// Days from now until `unix`.
pub fn days_left(unix: i64) -> i64 {
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0);
    (unix - now) / 86_400
}
