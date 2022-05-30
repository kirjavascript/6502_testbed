// build.rs

use std::process::Command;
fn main() {

    for name in [
        "lines-level",
    ] {
        let ca65 = Command::new("ca65").args(&[
            "-l", &format!("bin/{}.lst", name),
            "-g", &format!("asm/{}.asm", name),
            "-o", &format!("bin/{}.o", name),
        ])
            .output().expect("ca65");

        if ca65.stderr.len() > 0 {
            println!("cargo:warning={:?}", String::from_utf8_lossy(&ca65.stderr));
        }

        if ca65.stdout.len() > 0 {
            println!("cargo:warning={:?}", String::from_utf8_lossy(&ca65.stdout));
        }


        let ld65 = Command::new("ld65").args(&[
            "-o", &format!("bin/{}.nes", name),
            "-C", "asm/base.nes.cfg",
            &format!("bin/{}.o", name),
        ])
            .output().expect("ld65");

        if ld65.stderr.len() > 0 {
            println!("cargo:warning={:?}", String::from_utf8_lossy(&ld65.stderr));
        }

        if ld65.stdout.len() > 0 {
            println!("cargo:warning={:?}", String::from_utf8_lossy(&ld65.stdout));
        }
    }

    println!("cargo:rerun-if-changed=./asm");
    println!("cargo:rerun-if-changed=build.rs");
}
