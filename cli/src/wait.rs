//! Waiting out short agnts.uz and registry outages.
//!
//! Every call to agnts.uz and every image pull runs through [`until_up`]. A
//! "down" answer (connection error, timeout, 502/503/504) is retried every
//! interval with a message asking the user to wait 1–2 minutes; anything else
//! fails at once.

use std::fmt;
use std::thread::sleep;
use std::time::{Duration, Instant};

use anyhow::Result;

use crate::ui;

/// Outcome of one attempt that did not succeed.
#[derive(Debug)]
pub enum Attempt {
    /// The service is temporarily unavailable; try again.
    Down {
        reason: String,
        retry_after: Option<Duration>,
    },
    /// A real error; stop.
    Fatal(anyhow::Error),
}

impl From<anyhow::Error> for Attempt {
    fn from(e: anyhow::Error) -> Self {
        Attempt::Fatal(e)
    }
}

/// The service stayed down longer than the user was willing to wait. The
/// process exits with code 75 (EX_TEMPFAIL) for this error.
#[derive(Debug)]
pub struct StillDown {
    pub service: String,
}

impl fmt::Display for StillDown {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{} is still unavailable. Nothing was lost: run the same command again later and it continues where it stopped",
            self.service
        )
    }
}

impl std::error::Error for StillDown {}

#[derive(Clone, Debug)]
pub struct Policy {
    /// Pause between attempts when the server sends no Retry-After.
    pub interval: Duration,
    /// After this long, ask whether to keep waiting.
    pub window: Duration,
    /// Without anyone at the terminal, give up after this long.
    pub unattended_max: Duration,
}

impl Default for Policy {
    fn default() -> Self {
        Policy {
            interval: Duration::from_secs(10),
            window: Duration::from_secs(180),
            unattended_max: Duration::from_secs(600),
        }
    }
}

/// Run `f` until it succeeds or fails for real, waiting while `service` is down.
pub fn until_up<T>(
    service: &str,
    policy: &Policy,
    mut f: impl FnMut() -> std::result::Result<T, Attempt>,
) -> Result<T> {
    let start = Instant::now();
    let mut window_start = start;
    let mut spinner: Option<indicatif::ProgressBar> = None;
    loop {
        match f() {
            Ok(v) => {
                if let Some(pb) = spinner.take() {
                    pb.finish_and_clear();
                    ui::ok(&format!("{service} is back"));
                }
                return Ok(v);
            }
            Err(Attempt::Fatal(e)) => {
                if let Some(pb) = spinner.take() {
                    pb.finish_and_clear();
                }
                return Err(e);
            }
            Err(Attempt::Down {
                reason,
                retry_after,
            }) => {
                let pb = spinner.get_or_insert_with(|| {
                    ui::warn(&format!("{service} is temporarily unavailable ({reason})."));
                    ui::info("This usually takes 1–2 minutes. Waiting and retrying automatically…");
                    ui::spinner("waiting")
                });
                if window_start.elapsed() >= policy.window {
                    let unattended = ui::assume_yes() || !ui::interactive();
                    if unattended {
                        if start.elapsed() >= policy.unattended_max {
                            pb.finish_and_clear();
                            return Err(StillDown {
                                service: service.to_string(),
                            }
                            .into());
                        }
                    } else {
                        let keep = pb.suspend(|| ui::confirm("Still down. Keep waiting?", true))?;
                        if !keep {
                            pb.finish_and_clear();
                            return Err(StillDown {
                                service: service.to_string(),
                            }
                            .into());
                        }
                        window_start = Instant::now();
                    }
                }
                let pause = retry_after
                    .map(|r| r.min(Duration::from_secs(120)))
                    .unwrap_or(policy.interval);
                let until = Instant::now() + pause;
                while Instant::now() < until {
                    pb.set_message(format!("waiting {}  ({reason})", ui::mmss(start.elapsed())));
                    sleep(Duration::from_millis(200).min(pause));
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::cell::Cell;

    fn quick() -> Policy {
        Policy {
            interval: Duration::from_millis(5),
            window: Duration::from_millis(60),
            unattended_max: Duration::from_millis(120),
        }
    }

    #[test]
    fn retries_until_up() {
        let n = Cell::new(0);
        let v = until_up("svc", &quick(), || {
            n.set(n.get() + 1);
            if n.get() < 3 {
                Err(Attempt::Down {
                    reason: "503".into(),
                    retry_after: None,
                })
            } else {
                Ok(42)
            }
        })
        .unwrap();
        assert_eq!(v, 42);
        assert_eq!(n.get(), 3);
    }

    #[test]
    fn fatal_stops_at_once() {
        let n = Cell::new(0);
        let r: Result<()> = until_up("svc", &quick(), || {
            n.set(n.get() + 1);
            Err(Attempt::Fatal(anyhow::anyhow!("bad key")))
        });
        assert!(r.is_err());
        assert_eq!(n.get(), 1);
    }

    #[test]
    fn gives_up_unattended() {
        // Tests have no terminal, so the unattended limit applies.
        let r: Result<()> = until_up("svc", &quick(), || {
            Err(Attempt::Down {
                reason: "timeout".into(),
                retry_after: None,
            })
        });
        let e = r.unwrap_err();
        assert!(e.downcast_ref::<StillDown>().is_some());
    }
}
