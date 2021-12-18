mod emu;

// (cd asm && make) && cargo run

fn main() {
    let mut empty = 0;
    for seed in 0..=0xFFFF {
        if !btype(6, Some(0x10), seed) {
            empty += 1;
        }
    }
    println!("found {} seeds with empty top rows", empty);
}

fn btype(height: u8, drawheight: Option<u8>, seed: u16) -> bool {

    use emulator_6502::Interface6502;

    let (mut cpu, mut ram) = emu::load();

    ram.write(0x17, (seed >> 8) as _);
    ram.write(0x18, (seed & 0xFF) as _);
    ram.write(0xC, drawheight.unwrap_or(0xC));
    ram.write(3, height);

    let mut i = 0;

    loop {
        cpu.execute_instruction(&mut ram);
        // cpu.cycle(&mut ram);
        i += 1;
        if ram.read(0xEF) == 0xFF {
            break;
        }
    }

    let mut block = false;
    for i in 0..10 {
        if ram.read((0x200 + (10 * 6)) + i) != 0xEF {
            block = true;
            break;
        }
    }

    if block == false {
    println!("seed {:04x} height {} {:#?} instructions", seed, height, i);
    for y in 0..20 {
        print!("|");
        for x in 0..10 {
            let block = ram.read((0x200 + x) + (y * 10));
            print!("{}", if block == 0xEF || block == 0 { " " } else { "#" });
        }
        print!("|\n");
    }

    }


    block
}
