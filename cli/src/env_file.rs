//! A `.env` file that keeps comments and order when edited.

#[derive(Clone, Debug)]
enum Line {
    Entry { key: String, value: String },
    Other(String),
}

#[derive(Clone, Debug, Default)]
pub struct EnvFile {
    lines: Vec<Line>,
}

impl EnvFile {
    pub fn parse(text: &str) -> Self {
        let lines = text
            .lines()
            .map(|raw| {
                let t = raw.trim_start();
                if t.starts_with('#') || t.is_empty() {
                    return Line::Other(raw.to_string());
                }
                let t = t.strip_prefix("export ").unwrap_or(t);
                match t.split_once('=') {
                    Some((k, v)) if valid_key(k.trim()) => Line::Entry {
                        key: k.trim().to_string(),
                        value: parse_value(v),
                    },
                    _ => Line::Other(raw.to_string()),
                }
            })
            .collect();
        EnvFile { lines }
    }

    pub fn get(&self, key: &str) -> Option<&str> {
        self.lines.iter().rev().find_map(|l| match l {
            Line::Entry { key: k, value } if k == key => Some(value.as_str()),
            _ => None,
        })
    }

    /// Present and not empty.
    pub fn has_value(&self, key: &str) -> bool {
        self.get(key).is_some_and(|v| !v.is_empty())
    }

    pub fn keys(&self) -> Vec<&str> {
        self.lines
            .iter()
            .filter_map(|l| match l {
                Line::Entry { key, .. } => Some(key.as_str()),
                _ => None,
            })
            .collect()
    }

    /// Set a value in place, or append it.
    pub fn set(&mut self, key: &str, value: &str) {
        for l in self.lines.iter_mut().rev() {
            if let Line::Entry { key: k, value: v } = l {
                if k == key {
                    *v = value.to_string();
                    return;
                }
            }
        }
        self.lines.push(Line::Entry {
            key: key.to_string(),
            value: value.to_string(),
        });
    }

    /// Add every key of `template` missing here, with the comment block above
    /// it. Existing values are never touched.
    pub fn merge_missing(&mut self, template: &EnvFile) -> Vec<String> {
        let mut added = Vec::new();
        let mut comments: Vec<String> = Vec::new();
        for l in &template.lines {
            match l {
                Line::Other(text) if text.trim().is_empty() => comments.clear(),
                Line::Other(text) => comments.push(text.clone()),
                Line::Entry { key, value } => {
                    if self.get(key).is_none() {
                        self.lines.push(Line::Other(String::new()));
                        self.lines.extend(comments.iter().cloned().map(Line::Other));
                        self.lines.push(Line::Entry {
                            key: key.clone(),
                            value: value.clone(),
                        });
                        added.push(key.clone());
                    }
                    comments.clear();
                }
            }
        }
        added
    }

    pub fn render(&self) -> String {
        let mut out = String::new();
        for l in &self.lines {
            match l {
                Line::Other(t) => out.push_str(t),
                Line::Entry { key, value } => {
                    out.push_str(key);
                    out.push('=');
                    out.push_str(&format_value(value));
                }
            }
            out.push('\n');
        }
        out
    }
}

pub fn valid_key(k: &str) -> bool {
    !k.is_empty()
        && k.bytes().all(|b| b.is_ascii_alphanumeric() || b == b'_')
        && !k.as_bytes()[0].is_ascii_digit()
}

fn parse_value(raw: &str) -> String {
    let v = raw.trim();
    for q in ['\'', '"'] {
        if let Some(rest) = v.strip_prefix(q) {
            if let Some(end) = rest.find(q) {
                let inner = &rest[..end];
                return if q == '"' {
                    inner.replace("\\\"", "\"")
                } else {
                    inner.to_string()
                };
            }
        }
    }
    // Unquoted: an inline comment starts at " #".
    match v.find(" #") {
        Some(i) => v[..i].trim_end().to_string(),
        None => v.to_string(),
    }
}

fn format_value(v: &str) -> String {
    let needs_quotes = v.contains(" #")
        || v.starts_with(char::is_whitespace)
        || v.ends_with(char::is_whitespace)
        || v.starts_with('\'')
        || v.starts_with('"');
    if !needs_quotes {
        return v.to_string();
    }
    if !v.contains('\'') {
        format!("'{v}'")
    } else {
        format!("\"{}\"", v.replace('"', "\\\""))
    }
}

/// Keys whose values `agnts env list` hides.
pub fn is_secret(key: &str) -> bool {
    ["PASSWORD", "KEY", "TOKEN", "SECRET", "CREDENTIALS"]
        .iter()
        .any(|s| key.contains(s))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn round_trips_comments_and_values() {
        let text = "# top\nA=1\n\n# about b\nB='x y'\nC=v # note\n";
        let f = EnvFile::parse(text);
        assert_eq!(f.get("A"), Some("1"));
        assert_eq!(f.get("B"), Some("x y"));
        assert_eq!(f.get("C"), Some("v"));
        assert!(f.render().starts_with("# top\nA=1\n\n# about b\n"));
    }

    #[test]
    fn sets_in_place_and_appends() {
        let mut f = EnvFile::parse("A=1\nB=2\n");
        f.set("A", "9");
        f.set("Z", "Your Name");
        assert_eq!(f.render(), "A=9\nB=2\nZ=Your Name\n");
    }

    #[test]
    fn merge_adds_missing_with_comments_only() {
        let mut f = EnvFile::parse("A=keep\n");
        let t = EnvFile::parse("# about a\nA=default\n\n# about b\nB=2\n");
        let added = f.merge_missing(&t);
        assert_eq!(added, vec!["B"]);
        assert_eq!(f.get("A"), Some("keep"));
        assert_eq!(f.render(), "A=keep\n\n# about b\nB=2\n");
    }

    #[test]
    fn quotes_awkward_values() {
        let mut f = EnvFile::default();
        f.set("N", "O'Brien #1");
        f.set("M", "a #b");
        let r = f.render();
        assert_eq!(EnvFile::parse(&r).get("N"), Some("O'Brien #1"));
        assert_eq!(EnvFile::parse(&r).get("M"), Some("a #b"));
    }

    #[test]
    fn secrets() {
        assert!(is_secret("AGNTS_ENC_KEY"));
        assert!(is_secret("POSTGRES_PASSWORD"));
        assert!(!is_secret("AGNTS_DOMAIN"));
    }
}
