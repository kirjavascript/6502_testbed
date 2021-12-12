mod emu;

// (cd asm && make) && cargo run

fn main() {

    for score in 0..50 {
        pushdown(14, score);
    }

}

fn _pushdown(pushdown: u8, score: u8) -> u8 {
    if pushdown > 7 && pushdown < 17 {
        let offset = score % 10;
        if offset > 10 - (pushdown - 6) {
            return pushdown - 7
        }
    }

    pushdown - 1
}

fn dec_bcd(val: u8) -> u8 {
    (val/10*16) + (val%10)
}
fn bcd_dec(val: u8) -> u8 {
   (val/16*10) + (val%16)
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

    let added = format!("{:x}", ram.read(0x02)).parse::<u8>().unwrap() - score;

    print!("score {} PDP {} Actual PDP {}",
        score,
        ram.read(0x01),
        added,
    );
    println!(" -- score {} PDP {} Actual PDP {}",
        score,
        ram.read(0x01),
        _pushdown(ram.read(0x01), score),
    );

    // println!("PDP {} Added PDP {} start score {}:{} end score {:x}:{:x} ",
    //     ram.read(0x01),
    //     added,
    //     score,
    //     dec_bcd(score),
    //     ram.read(0x03),
    //     ram.read(0x02),
    // );

}
