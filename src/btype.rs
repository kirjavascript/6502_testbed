use super::emu;

pub fn test() {
    let seeds = include_str!("./../validseeds_levelselect.txt");
    let seeds: Vec<u16> = seeds.trim().split(",").map(|x| x.parse::<u16>().unwrap()).collect();

    let mut empty = 0;
    for seed in 0..=0xFFFF {
        if seeds.contains(&seed) && !btype(5, Some(0xC), seed) {

            empty += 1;
        }
    }
    println!("found {} seeds with empty top rows", empty);
    println!("{:#?}", seeds.len());
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
        if ram.read((0x200 + (10 * 8)) + i) != 0xEF {
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
