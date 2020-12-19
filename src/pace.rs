use super::emu;
use emulator_6502::Interface6502;

pub fn ppl(lines: u8) {
    let (mut cpu, mut ram) = emu::load();

    ram.write(0x10, lines);

    loop {
        cpu.execute_instruction(&mut ram);

        if ram.read(0xEF) == 0xFF {
            break;
        }

    }

    println!("{} lines {} PPL", lines, (
        ((ram.read(0x21) as usize) << 8)
        + ram.read(0x20) as usize
    ));
}

pub fn dump_ppl() {
    ppl(10);

    // for i in 1..23 {
    //     i * 10
    // }
}
