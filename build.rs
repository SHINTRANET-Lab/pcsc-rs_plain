use std::io;
use std::process::Command;
#[cfg(windows)]
use winres::WindowsResource;

#[cfg_attr(not(windows), allow(clippy::unnecessary_wraps))]
fn main() -> io::Result<()> {
    let target = std::env::var("TARGET").unwrap_or_default();
    let label = arch_label(&target);
    let suffix = if label.is_empty() {
        String::new()
    } else {
        format!(" {label}")
    };
    println!("cargo::rustc-env=PCSC_ARCH_SUFFIX={suffix}");
    println!("cargo::rustc-env=PCSC_TARGET={target}");
    match get_git_describe_result() {
        Ok(result) => println!("cargo::rustc-env=GIT_DESCRIBE={result}"),
        Err(e) => println!("cargo::warning={e}"),
    }

    #[cfg(windows)]
    if std::env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("windows")
        && std::env::var_os("CARGO_FEATURE_CLIENT").is_some()
    {
        WindowsResource::new()
            .set_icon("assets/icon.ico")
            .compile()?;
    }
    #[cfg(feature = "xp")]
    thunk::thunk();
    Ok(())
}

fn get_git_describe_result() -> Result<String, String> {
    let output = Command::new("git")
        .args(["describe", "--tags", "--always", "--long", "--dirty=-dirty"])
        .output()
        .map_err(|e| format!("failed to run git describe: {e}"))?;
    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        return Err(format!("git describe failed: {}", stderr.trim()));
    }
    String::from_utf8(output.stdout)
        .map(|result| result.trim().to_owned())
        .map_err(|e| format!("git describe returned invalid UTF-8: {e}"))
}
fn arch_label(target: &str) -> &'static str {
    match target {
        "aarch64-linux-android" => "ARM64 bionic",
        "armv7-linux-androideabi" => "ARMv7 bionic",
        "armv7-unknown-linux-musleabi" => "ARMv7 musl",
        "arm-unknown-linux-musleabi" => "ARMv6 musl",
        "aarch64-unknown-linux-musl" => "ARM64 musl",
        "x86_64-unknown-linux-musl" => "x86_64 musl",
        "aarch64-apple-darwin" => "macOS ARM64",
        "x86_64-apple-darwin" => "macOS x86_64",
        "x86_64-pc-windows-msvc" => "Windows x86_64",
        "i686-pc-windows-msvc" => "Windows i686",
        "x86_64-unknown-linux-gnu" => "x86_64 gnu",
        _ => "",
    }
}
