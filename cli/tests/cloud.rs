//! The agnts.uz client against the stub: key binding, errors, and waiting
//! out outages.

mod support;

use std::time::Duration;

use agnts_cli::cloud::{Cloud, KeyError};
use agnts_cli::wait::Policy;
use support::stub::Stub;

fn client(stub: &Stub) -> Cloud {
    let mut c = Cloud::with_base(&stub.url).unwrap();
    c.policy = Policy {
        interval: Duration::from_millis(20),
        window: Duration::from_secs(5),
        unattended_max: Duration::from_secs(10),
    };
    c
}

#[test]
fn one_key_one_install() {
    let stub = Stub::start("127.0.0.1:0", &["agk_one"]);
    let c = client(&stub);
    c.claim("agk_one", "id-a", "a.acme.com", false).unwrap();
    // Re-running the install on the same server is fine.
    c.claim("agk_one", "id-a", "a.acme.com", false).unwrap();

    let err = c.claim("agk_one", "id-b", "b.acme.com", false).unwrap_err();
    match err.downcast_ref::<KeyError>() {
        Some(KeyError::InUse { domain }) => assert_eq!(domain, "a.acme.com"),
        other => panic!("expected InUse, got {other:?}"),
    }

    // --move rebinds it.
    c.claim("agk_one", "id-b", "b.acme.com", true).unwrap();
    assert!(c.claim("agk_one", "id-a", "a.acme.com", false).is_err());

    // Releasing frees it.
    c.release("agk_one", "id-b").unwrap();
    c.claim("agk_one", "id-c", "c.acme.com", false).unwrap();
}

#[test]
fn unknown_key_fails_at_once() {
    let stub = Stub::start("127.0.0.1:0", &["agk_one"]);
    let err = client(&stub)
        .claim("agk_wrong", "id", "a.acme.com", false)
        .unwrap_err();
    assert!(matches!(
        err.downcast_ref::<KeyError>(),
        Some(KeyError::Rejected(_))
    ));
    assert_eq!(
        stub.state.lock().unwrap().log.len(),
        1,
        "no retries for a bad key"
    );
}

#[test]
fn waits_out_an_outage() {
    let stub = Stub::start("127.0.0.1:0", &["agk_one"]);
    stub.down_for_requests(3);
    client(&stub)
        .claim("agk_one", "id", "a.acme.com", false)
        .unwrap();
    assert_eq!(stub.state.lock().unwrap().log.len(), 4);
}

#[test]
fn gives_up_after_the_limit() {
    let stub = Stub::start("127.0.0.1:0", &["agk_one"]);
    stub.down_for(Duration::from_secs(60));
    let mut c = client(&stub);
    c.policy.window = Duration::from_millis(50);
    c.policy.unattended_max = Duration::from_millis(300);
    let err = c.claim("agk_one", "id", "a.acme.com", false).unwrap_err();
    assert!(err.downcast_ref::<agnts_cli::wait::StillDown>().is_some());
}

#[test]
fn connection_refused_counts_as_down() {
    // Nothing listens here; with a short limit this must end in StillDown,
    // not an immediate error.
    let mut c = Cloud::with_base("http://127.0.0.1:9").unwrap();
    c.policy = Policy {
        interval: Duration::from_millis(20),
        window: Duration::from_millis(50),
        unattended_max: Duration::from_millis(200),
    };
    let err = c.latest_cli().unwrap_err();
    assert!(err.downcast_ref::<agnts_cli::wait::StillDown>().is_some());
}

#[test]
fn reports_reach_the_cabinet() {
    let stub = Stub::start("127.0.0.1:0", &["agk_one"]);
    let c = client(&stub);
    c.report(
        "agk_one",
        &agnts_cli::cloud::Report {
            install_id: "id",
            domain: "a.acme.com",
            version: "0.1.0",
            event: "installed",
        },
    )
    .unwrap();
    let st = stub.state.lock().unwrap();
    assert_eq!(st.reports[0]["event"], "installed");
}
