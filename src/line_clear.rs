use crate::emu;

mod ramsetup {
    use emulator_6502::Interface6502;

    pub fn init(ram: &mut crate::emu::Ram, addr: u16, value: u8) {
        ram.write(addr, value);
    }
}

fn print(cpu: &mut emulator_6502::MOS6502, ram: &mut crate::emu::Ram, test_target: &str) {
    use emulator_6502::Interface6502;

    ramsetup::init(ram, 0x0041, 0x12); // tetriminoY
    ramsetup::init(ram, 0x0049, 0x20); // vramRow
    ramsetup::init(ram, 0x00b9, 0x04); // playfieldAddr+1

    let mut i = 0;
    loop {
        cpu.cycle(ram);
        i += 1;

        if ram.read(0xef) == 0xff {
            println!("{}: {:#?} cycles", test_target, i);
            break;
        }
    }
}

pub fn print_line_clears() {
    let (mut cpu, mut ram) = emu::load(include_bytes!("../bin/line-clear.nes"));
    print(&mut cpu, &mut ram, "line-clear");

    let (mut cpu, mut ram) = emu::load(include_bytes!("../bin/line-clear-crash.nes"));
    print(&mut cpu, &mut ram, "line-clear-crash");

    let (mut cpu, mut ram) = emu::load(include_bytes!("../bin/line-clear-mod.nes"));
    print(&mut cpu, &mut ram, "line-clear-mod");
}
