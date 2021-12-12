mod emu;

// (cd asm && make) && cargo run

fn main() {

use emulator_6502::Interface6502;

    let (mut cpu, mut ram) = emu::load();

    ram.write(0x01, 0xC); // pushdown
    ram.write(0x02, 0x0); // score

    loop {
        cpu.execute_instruction(&mut ram);

        if ram.read(0xEF) == 0xFF {
            break;
        }
    }


    println!("pdp {:x} high {:x} low {:x}",
        ram.read(0x01),
        ram.read(0x03),
        ram.read(0x02),
    );

}
