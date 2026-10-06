//! POSIX shell quoting for commands sent over SSH.

/// Quote one argument for `sh`. Safe characters pass through unchanged.
pub fn quote(arg: &str) -> String {
    let safe = !arg.is_empty()
        && arg
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || b"_@%+=:,./-".contains(&b));
    if safe {
        return arg.to_string();
    }
    format!("'{}'", arg.replace('\'', r"'\''"))
}

/// Join an argument list into one shell command line.
pub fn join<S: AsRef<str>>(args: &[S]) -> String {
    args.iter()
        .map(|a| quote(a.as_ref()))
        .collect::<Vec<_>>()
        .join(" ")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn quotes_only_when_needed() {
        assert_eq!(quote("docker"), "docker");
        assert_eq!(quote("/opt/agnts/.env"), "/opt/agnts/.env");
        assert_eq!(quote(""), "''");
        assert_eq!(quote("a b"), "'a b'");
        assert_eq!(quote("it's"), r"'it'\''s'");
        assert_eq!(quote("$(rm -rf /)"), "'$(rm -rf /)'");
    }

    #[test]
    fn joins() {
        assert_eq!(join(&["echo", "hello world"]), "echo 'hello world'");
    }
}
