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

    let out = ((ram.read(0x21) as usize) << 8)
        + ram.read(0x20) as usize;

    println!("{} lines {} PPL", lines, out);
    println!("{:x} {:x} {:x}",
        ram.read(0x20),
        ram.read(0x21),
        ram.read(0x22),
    );
}

pub fn dump_ppl() {
    for i in 1..=23 {
        ppl(i*10);
    }
}
