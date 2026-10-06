//! A target for tests: records commands, answers from canned rules, and keeps
//! files in memory.

use std::cell::RefCell;
use std::collections::BTreeMap;

use anyhow::Result;

use super::{Cmd, Out, Target};

#[derive(Default)]
pub struct FakeTarget {
    pub log: RefCell<Vec<String>>,
    pub files: RefCell<BTreeMap<String, (Vec<u8>, u32)>>,
    rules: RefCell<Vec<(String, Out)>>,
}

impl FakeTarget {
    pub fn new() -> Self {
        Self::default()
    }

    /// Answer commands whose display form contains `needle`. Later rules win.
    pub fn on(&self, needle: &str, code: i32, stdout: &str) -> &Self {
        self.rules.borrow_mut().push((
            needle.to_string(),
            Out {
                code,
                stdout: stdout.as_bytes().to_vec(),
                stderr: String::new(),
            },
        ));
        self
    }

    pub fn on_err(&self, needle: &str, code: i32, stderr: &str) -> &Self {
        self.rules.borrow_mut().push((
            needle.to_string(),
            Out {
                code,
                stdout: Vec::new(),
                stderr: stderr.to_string(),
            },
        ));
        self
    }

    pub fn put(&self, path: &str, content: &str) -> &Self {
        self.files
            .borrow_mut()
            .insert(path.to_string(), (content.as_bytes().to_vec(), 0o644));
        self
    }

    pub fn file(&self, path: &str) -> Option<String> {
        self.files
            .borrow()
            .get(path)
            .map(|(b, _)| String::from_utf8_lossy(b).into_owned())
    }

    pub fn mode(&self, path: &str) -> Option<u32> {
        self.files.borrow().get(path).map(|(_, m)| *m)
    }

    pub fn ran(&self, needle: &str) -> bool {
        self.log.borrow().iter().any(|l| l.contains(needle))
    }
}

impl Target for FakeTarget {
    fn run(&self, cmd: &Cmd) -> Result<Out> {
        let line = cmd.display();
        self.log.borrow_mut().push(line.clone());
        let rules = self.rules.borrow();
        Ok(rules
            .iter()
            .rev()
            .find(|(needle, _)| line.contains(needle.as_str()))
            .map(|(_, out)| out.clone())
            .unwrap_or_default())
    }

    fn run_tty(&self, cmd: &Cmd) -> Result<i32> {
        Ok(self.run(cmd)?.code)
    }

    fn label(&self) -> String {
        "fake".into()
    }

    fn is_local(&self) -> bool {
        false
    }

    fn write_file(&self, path: &str, data: &[u8], mode: u32) -> Result<()> {
        self.log.borrow_mut().push(format!("write {path}"));
        self.files
            .borrow_mut()
            .insert(path.to_string(), (data.to_vec(), mode));
        Ok(())
    }

    fn read_file(&self, path: &str) -> Result<Option<Vec<u8>>> {
        Ok(self.files.borrow().get(path).map(|(b, _)| b.clone()))
    }
}
