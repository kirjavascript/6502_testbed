mod emu;

// (cd asm && make) && cargo run

fn main() {

    // TODO: handle BCD
    for score in 0..50 {

        pushdown(0xC, score);
    }

}

fn dec_bcd(val: u8) -> u8 {
    (val/10*16) + (val%10)
}

fn pushdown(pushdown: u8, score: u8) {

    use emulator_6502::Interface6502;

    let (mut cpu, mut ram) = emu::load();

    ram.write(0x01, pushdown); // pushdown
    ram.write(0x02, dec_bcd(score)); // score
    ram.write(0x03, 0); // score

    loop {
        cpu.execute_instruction(&mut ram);

        if ram.read(0xEF) == 0xFF {
            break;
        }
    }


    println!("pdp {} s0: {}-{:x} high {:x} low {:x}",
        ram.read(0x01),
        score,
        score,
        ram.read(0x03),
        ram.read(0x02),
    );

}
