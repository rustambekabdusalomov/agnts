//! Terminal output and prompts. Every prompt respects `--yes` and works out
//! what to do when no one is at the terminal.

use std::sync::OnceLock;
use std::time::Duration;

use anyhow::{bail, Result};
use console::style;
use dialoguer::theme::ColorfulTheme;
use indicatif::{ProgressBar, ProgressStyle};

struct Opts {
    yes: bool,
    interactive: bool,
}

static OPTS: OnceLock<Opts> = OnceLock::new();

pub fn init(yes: bool) {
    let interactive = console::user_attended() && console::Term::stdout().is_term();
    let _ = OPTS.set(Opts { yes, interactive });
}

fn opts() -> &'static Opts {
    OPTS.get_or_init(|| Opts {
        yes: false,
        interactive: false,
    })
}

/// Someone is at the terminal and can answer prompts.
pub fn interactive() -> bool {
    opts().interactive
}

/// `--yes` was given: accept defaults and confirmations.
pub fn assume_yes() -> bool {
    opts().yes
}

pub fn header(text: &str) {
    println!("\n{}", style(text).bold());
}

pub fn step(n: usize, total: usize, title: &str) {
    println!(
        "\n{} {}",
        style(format!("[{n}/{total}]")).dim(),
        style(title).bold()
    );
}

pub fn ok(msg: &str) {
    println!("  {} {msg}", style("✓").green());
}

pub fn skip(msg: &str) {
    println!("  {} {}", style("·").dim(), style(msg).dim());
}

pub fn info(msg: &str) {
    println!("  {msg}");
}

pub fn warn(msg: &str) {
    println!("  {} {msg}", style("!").yellow().bold());
}

pub fn fail(msg: &str) {
    println!("  {} {msg}", style("✗").red().bold());
}

pub fn code(text: &str) -> String {
    style(text).cyan().to_string()
}

/// Ask yes/no. `--yes` answers yes; with no terminal, the default is used.
pub fn confirm(prompt: &str, default: bool) -> Result<bool> {
    if assume_yes() {
        return Ok(true);
    }
    if !interactive() {
        return Ok(default);
    }
    Ok(dialoguer::Confirm::with_theme(&ColorfulTheme::default())
        .with_prompt(prompt)
        .default(default)
        .interact()?)
}

/// Ask for a value. With `--yes` or no terminal, the default is used, and a
/// missing default is an error naming the flag to pass instead.
pub fn input(prompt: &str, default: Option<&str>, flag: &str) -> Result<String> {
    if assume_yes() || !interactive() {
        return match default {
            Some(d) if !d.is_empty() => Ok(d.to_string()),
            _ => bail!("{prompt}: no value given; pass {flag}"),
        };
    }
    let theme = ColorfulTheme::default();
    let mut q = dialoguer::Input::<String>::with_theme(&theme).with_prompt(prompt);
    if let Some(d) = default.filter(|d| !d.is_empty()) {
        q = q.default(d.to_string());
    }
    Ok(q.interact_text()?.trim().to_string())
}

/// Ask for a secret without echoing it.
pub fn secret(prompt: &str, flag: &str) -> Result<String> {
    if !interactive() {
        bail!("{prompt}: no value given; pass {flag}");
    }
    Ok(dialoguer::Password::with_theme(&ColorfulTheme::default())
        .with_prompt(prompt)
        .interact()?
        .trim()
        .to_string())
}

/// Ask the user to type `expected` to confirm something destructive.
pub fn typed_confirm(what: &str, expected: &str) -> Result<bool> {
    if assume_yes() {
        return Ok(true);
    }
    if !interactive() {
        bail!("{what}: needs confirmation; run it in a terminal or pass --yes");
    }
    let typed: String = dialoguer::Input::with_theme(&ColorfulTheme::default())
        .with_prompt(format!("{what}. Type {} to continue", code(expected)))
        .allow_empty(true)
        .interact_text()?;
    Ok(typed.trim() == expected)
}

pub fn spinner(msg: &str) -> ProgressBar {
    let pb = ProgressBar::new_spinner();
    pb.set_style(
        ProgressStyle::with_template("  {spinner} {msg}")
            .unwrap()
            .tick_chars("⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏ "),
    );
    pb.set_message(msg.to_string());
    pb.enable_steady_tick(Duration::from_millis(100));
    pb
}

/// `m:ss` for elapsed-time displays.
pub fn mmss(d: Duration) -> String {
    let s = d.as_secs();
    format!("{}:{:02}", s / 60, s % 60)
}
