use super::emu;
use emulator_6502::Interface6502;

#[derive(Debug, PartialEq)]
pub enum Block {
    T, J, Z, O, S, L, I, Unknown(u8)
}

impl Block {
    fn from(value: u8) -> Self {
        match value {
            0x2 => Block::T,
            0x7 => Block::J,
            0x8 => Block::Z,
            0xA => Block::O,
            0xB => Block::S,
            0xE => Block::L,
            0x12 => Block::I,
            _ => Block::Unknown(value),
        }
    }
}

pub fn _find_seed() {
    use Block::*;
    let mut top = 0;

    // search for seed
    for seed in 0x1..0x10000 {
        for count in 0..256 {
            let b = generate_blocks(seed, count * 10, 10);
            let ocount = b.iter().filter(|&n| n == &O).count();
            if ocount > top {
                top = ocount;
                println!("seed: {:x} count: {:x} O: {}", seed, count * 10, ocount);
            }

        }

    }
}

pub fn generate_blocks(seed: usize, spawn_count: usize, quantity: usize) -> Vec<Block> {
    let mut blocks = Vec::new();

    let (mut cpu, mut ram) = emu::load();

    // reset
    ram.write(0x19, 0); // spawnID
    ram.write(0xBF, 0); // nextPiece
    ram.write(0xEF, 0); // iter

    // set initial seed
    ram.write(0x17, seed as u8 & 0xFF);
    ram.write(0x18, (seed >> 8) as u8);
    // spawn count
    ram.write(0x1A, spawn_count as u8);
    // spawn ID

    let mut last_iter = 0;

    loop {
        cpu.execute_instruction(&mut ram);

        let iter = ram.read(0xEF);

        if iter != last_iter {
            last_iter = iter;
            blocks.push(Block::from(ram.read(0xBF)));
        }

        if blocks.len() >= quantity {
            break;
        }
    }

    blocks
}

    // use emulator_6502::Interface6502;
    // use std::collections::HashMap;


    // let (mut cpu, mut ram) = emu::load();
    // ram.write(0x17, 0x89);
    // ram.write(0x18, 0x88);
    // let mut count = 0;
    // let mut last_iter = 0;
    // let mut map = HashMap::new();

    // loop {
    //     cpu.execute_instruction(&mut ram);

    //     let iter = ram.read(0xEF);

    //     if iter != last_iter {
    //         last_iter = iter;

    //             count += 1;
    //             let value = ram.read(0xAB);

    //             if map.contains_key(&value) {
    //                 let mapv = map.get_mut(&value).unwrap();
    //                 *mapv += 1;
    //             } else {
    //                 map.insert(value, 1);
    //             }

    //     }


    //     if count > 1000 {
    //         break;
    //     }
    // }
    // println!("{:#?}", map);
