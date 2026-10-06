//! Does the domain point at the server? Asked of public resolvers over HTTPS
//! (Cloudflare and Google), so the answer matches what Let's Encrypt sees,
//! not a local cache.

use std::net::{IpAddr, Ipv4Addr, Ipv6Addr, ToSocketAddrs};
use std::time::Duration;

use serde::Deserialize;

const RESOLVERS: &[&str] = &[
    "https://cloudflare-dns.com/dns-query",
    "https://dns.google/resolve",
];

#[derive(Deserialize)]
struct DohAnswer {
    #[serde(rename = "Answer", default)]
    answer: Vec<DohRecord>,
}

#[derive(Deserialize)]
struct DohRecord {
    #[serde(rename = "type")]
    rtype: u16,
    data: String,
}

/// Parse a DNS-over-HTTPS JSON answer into the addresses of one type
/// (1 = A, 28 = AAAA), skipping CNAMEs on the way.
pub fn parse_doh(json: &str, rtype: u16) -> Option<Vec<IpAddr>> {
    let a: DohAnswer = serde_json::from_str(json).ok()?;
    Some(
        a.answer
            .into_iter()
            .filter(|r| r.rtype == rtype)
            .filter_map(|r| r.data.trim().parse().ok())
            .collect(),
    )
}

/// One answer per resolver that replied.
fn lookup(domain: &str, rtype: u16) -> Vec<Vec<IpAddr>> {
    let client = match reqwest::blocking::Client::builder()
        .timeout(Duration::from_secs(8))
        .build()
    {
        Ok(c) => c,
        Err(_) => return Vec::new(),
    };
    let t = if rtype == 1 { "A" } else { "AAAA" };
    RESOLVERS
        .iter()
        .filter_map(|r| {
            let resp = client
                .get(*r)
                .query(&[("name", domain), ("type", t)])
                .header("accept", "application/dns-json")
                .send()
                .ok()?;
            parse_doh(&resp.text().ok()?, rtype)
        })
        .collect()
}

#[derive(Debug, PartialEq)]
pub struct Verdict {
    pub ok: bool,
    pub message: String,
}

/// Decide from the resolvers' answers. Every resolver must return the
/// server's IPv4 address; an AAAA record must point at the server too,
/// because Let's Encrypt prefers IPv6 and a stale AAAA breaks certificates.
pub fn judge(
    a_answers: &[Vec<IpAddr>],
    aaaa_answers: &[Vec<IpAddr>],
    v4: Ipv4Addr,
    v6: Option<Ipv6Addr>,
) -> Verdict {
    if a_answers.is_empty() {
        return Verdict {
            ok: false,
            message: "no resolver answered".into(),
        };
    }
    let want = IpAddr::V4(v4);
    for ans in a_answers {
        if ans.is_empty() {
            return Verdict {
                ok: false,
                message: "no A record yet".into(),
            };
        }
        if !ans.contains(&want) {
            let found: Vec<String> = ans.iter().map(|i| i.to_string()).collect();
            return Verdict {
                ok: false,
                message: format!("A record points at {}, not {v4}", found.join(", ")),
            };
        }
    }
    for ans in aaaa_answers {
        if ans.is_empty() {
            continue;
        }
        match v6 {
            Some(v6) if ans.contains(&IpAddr::V6(v6)) => {}
            Some(v6) => {
                return Verdict {
                    ok: false,
                    message: format!("AAAA record points elsewhere; set it to {v6} or delete it"),
                }
            }
            None => {
                return Verdict {
                    ok: false,
                    message: "the domain has an AAAA (IPv6) record but the server has no public IPv6; delete the AAAA record".into(),
                }
            }
        }
    }
    Verdict {
        ok: true,
        message: format!("points at {v4}"),
    }
}

pub fn check(domain: &str, v4: Ipv4Addr, v6: Option<Ipv6Addr>) -> Verdict {
    let mut a = lookup(domain, 1);
    let aaaa = lookup(domain, 28);
    if a.is_empty() {
        // Both resolvers unreachable (filtered networks): use the system's.
        if let Ok(addrs) = (domain, 80).to_socket_addrs() {
            a.push(addrs.map(|s| s.ip()).filter(IpAddr::is_ipv4).collect());
        }
    }
    judge(&a, &aaaa, v4, v6)
}

/// A plausible public hostname: letters, digits, hyphens, at least one dot,
/// not an IP address.
pub fn valid_domain(d: &str) -> bool {
    if d.len() > 253 || d.parse::<IpAddr>().is_ok() || !d.contains('.') {
        return false;
    }
    d.split('.').all(|l| {
        !l.is_empty()
            && l.len() <= 63
            && !l.starts_with('-')
            && !l.ends_with('-')
            && l.bytes()
                .all(|b| b.is_ascii_lowercase() || b.is_ascii_digit() || b == b'-')
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn ip(s: &str) -> IpAddr {
        s.parse().unwrap()
    }

    #[test]
    fn parses_doh() {
        let j = r#"{"Status":0,"Answer":[{"name":"a.b","type":5,"data":"x.b."},{"name":"x.b","type":1,"data":"203.0.113.10"}]}"#;
        assert_eq!(parse_doh(j, 1), Some(vec![ip("203.0.113.10")]));
        assert_eq!(parse_doh(r#"{"Status":3}"#, 1), Some(vec![]));
    }

    #[test]
    fn judges() {
        let v4: Ipv4Addr = "203.0.113.10".parse().unwrap();
        let good = vec![vec![ip("203.0.113.10")], vec![ip("203.0.113.10")]];
        assert!(judge(&good, &[], v4, None).ok);
        assert!(!judge(&[vec![]], &[], v4, None).ok);
        let wrong = judge(&[vec![ip("198.51.100.1")]], &[], v4, None);
        assert!(!wrong.ok && wrong.message.contains("198.51.100.1"));
        let stale6 = judge(&good, &[vec![ip("2001:db8::1")]], v4, None);
        assert!(!stale6.ok);
        let v6: Ipv6Addr = "2001:db8::1".parse().unwrap();
        assert!(judge(&good, &[vec![ip("2001:db8::1")]], v4, Some(v6)).ok);
    }

    #[test]
    fn validates_domains() {
        assert!(valid_domain("agnts.acme.com"));
        assert!(!valid_domain("localhost"));
        assert!(!valid_domain("203.0.113.10"));
        assert!(!valid_domain("Agnts.acme.com"));
        assert!(!valid_domain("-a.acme.com"));
    }
}
