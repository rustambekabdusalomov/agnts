//! `agnts self-update`: download the release for this platform from agnts.uz,
//! verify its SHA-256, and replace the running binary.

use std::io::Read;

use anyhow::{bail, Context, Result};
use sha2::{Digest, Sha256};

use crate::cloud::Cloud;
use crate::ui;

pub fn run(check_only: bool) -> Result<()> {
    let cloud = Cloud::new()?;
    let latest = cloud.latest_cli()?;
    let current = semver::Version::parse(crate::VERSION)?;
    let newest = semver::Version::parse(latest.version.trim_start_matches('v'))
        .with_context(|| format!("bad version {:?} from agnts.uz", latest.version))?;
    if newest <= current {
        ui::ok(&format!("agnts {current} is the latest version"));
        return Ok(());
    }
    if check_only {
        ui::info(&format!(
            "agnts {newest} is available (you have {current}). Run `agnts self-update`."
        ));
        return Ok(());
    }
    let Some(asset) = latest.assets.get(crate::TARGET).cloned() else {
        bail!("no {newest} build for {} yet", crate::TARGET);
    };
    let pb = ui::spinner(&format!("downloading agnts {newest}"));
    let data = cloud.download(&asset.url);
    pb.finish_and_clear();
    let data = data?;
    let digest = hex::encode(Sha256::digest(&data));
    if !digest.eq_ignore_ascii_case(asset.sha256.trim()) {
        bail!(
            "checksum mismatch for {}: refusing to install it",
            asset.url
        );
    }
    let bin = extract(&asset.url, &data)?;
    let dir = tempdir()?;
    let path = dir.join(if cfg!(windows) { "agnts.exe" } else { "agnts" });
    std::fs::write(&path, bin)?;
    self_replace::self_replace(&path).context(
        "replacing the agnts binary (try again with sudo if it lives in /usr/local/bin)",
    )?;
    let _ = std::fs::remove_dir_all(&dir);
    ui::ok(&format!("updated to agnts {newest}"));
    Ok(())
}

fn tempdir() -> Result<std::path::PathBuf> {
    let d = std::env::temp_dir().join(format!("agnts-update-{}", uuid::Uuid::new_v4().simple()));
    std::fs::create_dir_all(&d)?;
    Ok(d)
}

/// The `agnts` binary from a .tar.gz or .zip release archive.
pub fn extract(url: &str, data: &[u8]) -> Result<Vec<u8>> {
    let want = if cfg!(windows) { "agnts.exe" } else { "agnts" };
    if url.ends_with(".zip") {
        let mut z = zip::ZipArchive::new(std::io::Cursor::new(data))?;
        for i in 0..z.len() {
            let mut f = z.by_index(i)?;
            if f.name().rsplit('/').next() == Some(want) {
                let mut out = Vec::new();
                f.read_to_end(&mut out)?;
                return Ok(out);
            }
        }
    } else {
        let mut a = tar::Archive::new(flate2::read::GzDecoder::new(data));
        for entry in a.entries()? {
            let mut e = entry?;
            if e.path()?.file_name().and_then(|n| n.to_str()) == Some(want) {
                let mut out = Vec::new();
                e.read_to_end(&mut out)?;
                return Ok(out);
            }
        }
    }
    bail!("{want} not found in {url}")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn extracts_the_binary_from_a_tarball() {
        let mut gz = Vec::new();
        {
            let enc = flate2::write::GzEncoder::new(&mut gz, flate2::Compression::fast());
            let mut b = tar::Builder::new(enc);
            let mut h = tar::Header::new_gnu();
            h.set_size(4);
            h.set_mode(0o755);
            h.set_cksum();
            b.append_data(
                &mut h,
                if cfg!(windows) { "agnts.exe" } else { "agnts" },
                &b"\x7fELF"[..],
            )
            .unwrap();
            b.into_inner().unwrap().finish().unwrap();
        }
        assert_eq!(extract("x.tar.gz", &gz).unwrap(), b"\x7fELF");
        assert!(extract("x.tar.gz", b"junk").is_err());
    }
}
