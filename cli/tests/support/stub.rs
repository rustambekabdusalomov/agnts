//! A stand-in for the agnts.uz API, for tests and for trying the CLI before
//! the real cabinet exists. Plain std HTTP/1.1, one thread per connection.

#![allow(dead_code)]

use std::collections::HashMap;
use std::io::{BufRead, BufReader, Read, Write};
use std::net::{TcpListener, TcpStream};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

#[derive(Default)]
pub struct State {
    /// key -> (install id, domain) it is bound to.
    pub keys: HashMap<String, Option<(String, String)>>,
    /// Answer 503 to this many requests.
    pub down_requests: usize,
    /// Answer 503 until then.
    pub down_until: Option<Instant>,
    pub log: Vec<String>,
    pub reports: Vec<serde_json::Value>,
    pub latest: String,
}

pub struct Stub {
    pub url: String,
    pub state: Arc<Mutex<State>>,
}

impl Stub {
    pub fn start(addr: &str, keys: &[&str]) -> Stub {
        let listener = TcpListener::bind(addr).expect("bind");
        let url = format!("http://{}", listener.local_addr().unwrap());
        let state = Arc::new(Mutex::new(State {
            keys: keys.iter().map(|k| (k.to_string(), None)).collect(),
            latest: "0.1.0".into(),
            ..Default::default()
        }));
        let s = state.clone();
        std::thread::spawn(move || {
            for conn in listener.incoming().flatten() {
                let s = s.clone();
                std::thread::spawn(move || {
                    let _ = handle(conn, &s);
                });
            }
        });
        Stub { url, state }
    }

    pub fn down_for_requests(&self, n: usize) {
        self.state.lock().unwrap().down_requests = n;
    }

    pub fn down_for(&self, d: Duration) {
        self.state.lock().unwrap().down_until = Some(Instant::now() + d);
    }
}

fn respond(mut s: &TcpStream, code: u16, extra: &str, body: &str) -> std::io::Result<()> {
    let reason = match code {
        200 => "OK",
        401 => "Unauthorized",
        404 => "Not Found",
        409 => "Conflict",
        503 => "Service Unavailable",
        _ => "Error",
    };
    write!(
        s,
        "HTTP/1.1 {code} {reason}\r\nContent-Type: application/json\r\nContent-Length: {}\r\nConnection: close\r\n{extra}\r\n{body}",
        body.len()
    )
}

fn handle(conn: TcpStream, state: &Arc<Mutex<State>>) -> std::io::Result<()> {
    let mut r = BufReader::new(conn.try_clone()?);
    let mut line = String::new();
    r.read_line(&mut line)?;
    let mut parts = line.split_whitespace();
    let method = parts.next().unwrap_or_default().to_string();
    let path = parts.next().unwrap_or_default().to_string();
    let mut len = 0usize;
    let mut auth = String::new();
    loop {
        let mut h = String::new();
        r.read_line(&mut h)?;
        let h = h.trim_end();
        if h.is_empty() {
            break;
        }
        if let Some((k, v)) = h.split_once(':') {
            match k.to_ascii_lowercase().as_str() {
                "content-length" => len = v.trim().parse().unwrap_or(0),
                "authorization" => auth = v.trim().trim_start_matches("Bearer ").to_string(),
                _ => {}
            }
        }
    }
    let mut body = vec![0; len];
    r.read_exact(&mut body)?;
    let json: serde_json::Value = serde_json::from_slice(&body).unwrap_or_default();

    let mut st = state.lock().unwrap();
    st.log.push(format!("{method} {path}"));
    let down_by_time = st.down_until.is_some_and(|t| Instant::now() < t);
    if st.down_requests > 0 || down_by_time {
        st.down_requests = st.down_requests.saturating_sub(1);
        return respond(
            &conn,
            503,
            "Retry-After: 1\r\n",
            r#"{"status":"maintenance","message":"planned maintenance"}"#,
        );
    }

    let known = st.keys.contains_key(&auth);
    match (method.as_str(), path.as_str()) {
        ("GET", "/api/status") => respond(&conn, 200, "", r#"{"status":"ok"}"#),
        ("GET", "/api/ip") => respond(&conn, 200, "", &conn.peer_addr()?.ip().to_string()),
        ("GET", "/api/cli/latest") => {
            let v = st.latest.clone();
            respond(
                &conn,
                200,
                "",
                &format!(r#"{{"version":"{v}","assets":{{}}}}"#),
            )
        }
        (_, "/api/installs/claim")
        | (_, "/api/installs/report")
        | (_, "/api/installs/release")
        | (_, "/api/probe")
            if !known =>
        {
            respond(&conn, 401, "", r#"{"message":"unknown access key"}"#)
        }
        ("POST", "/api/installs/claim") => {
            let id = json["install_id"].as_str().unwrap_or_default().to_string();
            let domain = json["domain"].as_str().unwrap_or_default().to_string();
            let mv = json["move"].as_bool().unwrap_or(false);
            let bound = st.keys.get(&auth).cloned().flatten();
            match bound {
                Some((other, d)) if other != id && !mv => respond(
                    &conn,
                    409,
                    "",
                    &format!(r#"{{"message":"key in use","domain":"{d}"}}"#),
                ),
                _ => {
                    st.keys.insert(auth, Some((id.clone(), domain)));
                    respond(&conn, 200, "", &format!(r#"{{"install_id":"{id}"}}"#))
                }
            }
        }
        ("POST", "/api/installs/report") => {
            st.reports.push(json);
            respond(&conn, 200, "", "{}")
        }
        ("POST", "/api/installs/release") => {
            st.keys.insert(auth, None);
            respond(&conn, 200, "", "{}")
        }
        ("POST", "/api/probe") => {
            drop(st);
            let url = json["url"].as_str().unwrap_or_default();
            let expect = json["expect"].as_str().unwrap_or_default();
            let got = reqwest::blocking::Client::builder()
                .timeout(Duration::from_secs(8))
                .build()
                .ok()
                .and_then(|c| c.get(url).send().ok())
                .and_then(|r| r.text().ok());
            let body = match got {
                Some(t) if t.contains(expect) => r#"{"ok":true}"#.to_string(),
                Some(_) => r#"{"ok":false,"error":"answered without the token"}"#.to_string(),
                None => r#"{"ok":false,"error":"connection failed"}"#.to_string(),
            };
            respond(&conn, 200, "", &body)
        }
        _ => respond(&conn, 404, "", r#"{"message":"not found"}"#),
    }
}
