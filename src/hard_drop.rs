use crate::emu;

mod playfield {
    use emulator_6502::Interface6502;
    pub fn clear(ram: &mut crate::emu::Ram) {
        for addr in 0x400..0x500 {
            ram.write(addr, 0xef);
        }
    }
    pub fn print(ram: &mut crate::emu::Ram) {
        for y in 0..20 {
                for x in 0..10 {
                let index = ((y * 10) + x) + 0x400;

                print!("{}",
                    if ram.read(index) == 0xEF { " " } else { "#" }
                );
            }
            print!("\n");
        }
    }

    pub fn set(ram: &mut crate::emu::Ram, x: u16, y: u16, value: u8) {
        let index = ((y * 10) + x) + 0x400;
        ram.write(index, value);
    }
}

pub fn print() {
    use emulator_6502::Interface6502;


        let (mut cpu, mut ram) = emu::load(include_bytes!("../bin/hard-drop.nes"));


        playfield::clear(&mut ram);

        // for y in 1..4 {
        //     for x in 0..10 {
        //         playfield::set(&mut ram, x, y, 0x7b);
        //     }
        // }

        for y in 16..20 {
            for x in 0..10 {
                playfield::set(&mut ram, x, y, 0x7b);
            }
        }

        playfield::set(&mut ram, 4, 13, 0x7b);
        playfield::set(&mut ram, 2, 15, 0x7b);
        playfield::set(&mut ram, 6, 0, 0x7b);
        playfield::set(&mut ram, 7, 1, 0x7b);
        playfield::set(&mut ram, 8, 2, 0x7b);

        playfield::print(&mut ram);


        let mut i = 0;
        loop {
            cpu.cycle(&mut ram);
            i += 1;

            if ram.read(0xEF) == 0xff {
                println!("{:#?} cycles", i);
                playfield::print(&mut ram);

                for i in 0x500..0x500 + 20 {
                    print!("{:02x} ", ram.read(i));
                }
                print!("\n");

                println!("{}", ram.read(0x10));
                break;
            }
        }


}
