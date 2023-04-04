use crate::emu;

mod ramsetup {
    use emulator_6502::Interface6502;
    pub fn init(ram: &mut crate::emu::Ram, addr: u16, value: u8) {
        ram.write(addr, value);
        }

}

pub fn print_line_clear() {
    use emulator_6502::Interface6502;

        let (mut cpu, mut ram) = emu::load(include_bytes!("../bin/line-clear.nes"));
        ramsetup::init(&mut ram, 0x0041, 0x12); // tetriminoY
        ramsetup::init(&mut ram, 0x0049, 0x20); // vramRow
        ramsetup::init(&mut ram, 0x00B9, 0x04); // playfieldAddr+1


        let mut i = 0;
        loop {
            cpu.cycle(&mut ram);
            i += 1;

            if ram.read(0xEF) == 0xff {
                println!("line-clear: {:#?} cycles", i);
                break;
            }
        }

}


pub fn print_line_clear_crash() {
    use emulator_6502::Interface6502;

        let (mut cpu, mut ram) = emu::load(include_bytes!("../bin/line-clear-crash.nes"));
        ramsetup::init(&mut ram, 0x0041, 0x12); // tetriminoY
        ramsetup::init(&mut ram, 0x0049, 0x20); // vramRow
        ramsetup::init(&mut ram, 0x00B9, 0x04); // playfieldAddr+1


        let mut i = 0;
        loop {
            cpu.cycle(&mut ram);
            i += 1;

            if ram.read(0xEF) == 0xff {
                println!("line-clear-crash: {:#?} cycles", i);
                break;
            }
        }

}



pub fn print_line_clear_mod() {
    use emulator_6502::Interface6502;

        let (mut cpu, mut ram) = emu::load(include_bytes!("../bin/line-clear-mod.nes"));
        ramsetup::init(&mut ram, 0x41, 0x12); // tetriminoY
        ramsetup::init(&mut ram, 0x49, 0x20); // vramRow
        ramsetup::init(&mut ram, 0xB9, 0x04); // playfieldAddr+1


        let mut i = 0;
        loop {
            cpu.cycle(&mut ram);
            i += 1;

            if ram.read(0xEF) == 0xff {
                println!("line-clear-mod: {:#?} cycles", i);
                break;
            }
        }

}
