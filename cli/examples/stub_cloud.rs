//! Run the stand-in agnts.uz API, for trying `agnts install` before the real
//! cabinet exists:
//!
//!   STUB_KEYS=agk_test STUB_DOWN_SECS=90 cargo run --example stub_cloud
//!   AGNTS_CLOUD_URL=http://<this machine>:8787 agnts install root@server --key agk_test ...
//!
//! STUB_DOWN_SECS answers 503 for that long after start (the outage test).

#[path = "../tests/support/stub.rs"]
mod stub;

use std::time::Duration;

fn main() {
    let port = std::env::var("STUB_PORT").unwrap_or_else(|_| "8787".into());
    let keys = std::env::var("STUB_KEYS").unwrap_or_else(|_| "agk_test".into());
    let keys: Vec<&str> = keys.split(',').map(str::trim).collect();
    let s = stub::Stub::start(&format!("0.0.0.0:{port}"), &keys);
    if let Some(secs) = std::env::var("STUB_DOWN_SECS")
        .ok()
        .and_then(|v| v.parse().ok())
    {
        s.down_for(Duration::from_secs(secs));
        println!("answering 503 for the first {secs}s");
    }
    println!("stub agnts.uz on {} (keys: {})", s.url, keys.join(", "));
    loop {
        std::thread::sleep(Duration::from_secs(5));
        let st = s.state.lock().unwrap();
        for (k, b) in &st.keys {
            if let Some((id, d)) = b {
                println!("  {k} → {id} ({d})");
            }
        }
    }
}
