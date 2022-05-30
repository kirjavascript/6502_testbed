use crate::emu;

pub fn print_transition_lines() {
    use emulator_6502::Interface6502;

    for level in 0..=255 {

        let (mut cpu, mut ram) = emu::load(include_bytes!("../bin/lines-level.nes"));

        ram.write(0xF, level); // level
        ram.write(0x10, 0);
        ram.write(0x11, 0);


        loop {
            cpu.execute_instruction(&mut ram);

            if ram.read(0xEF) == 0xff {
                break;
            }
        }

        println!("level {} lines {:02x}{:02x}", level, ram.read(0x11), ram.read(0x10));
    }

}
