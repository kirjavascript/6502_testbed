mod emu;

// (cd asm && make) && cargo run

fn main() {

    for score in 0..105 {
        pushdown(13, score);
    }

}

fn _pushdown(pushdown: u8, score: u16) -> u16 {
    let mut newscore = (score % 10) as u8 + (pushdown - 1);
    if newscore & 0b1111 > 9 {
        newscore += 6;
    }
    ((newscore & 0b11110000) / 16 * 10) as u16 + (newscore & 0b1111) as u16 + (score - (score % 10))
}

// fn _pushdown(pushdown: u8, score: u8) -> u8 {
//     if pushdown > 7 {
//         if pushdown > 16 || score % 10 > 10 - (pushdown - 6) {
//             return pushdown - 7
//         }
//     }

//     pushdown - 1
// }


fn dec_bcd(val: u16) -> u16 {
    (val/10*16) + (val%10)
}
fn bcd_dec(val: u8) -> u8 {
   (val/16*10) + (val%16)
}

fn pushdown(pushdown: u8, score: u16) {

    use emulator_6502::Interface6502;

    let (mut cpu, mut ram) = emu::load();

    ram.write(0x01, pushdown); // pushdown
    let bcd_high = i64::from_str_radix(&format!("{:04}", score)[0..2], 16).unwrap();
    let bcd_low = i64::from_str_radix(&format!("{:04}", score)[2..4], 16).unwrap();

    ram.write(0x02, bcd_low as u8);
    ram.write(0x03, bcd_high as u8);

    loop {
        cpu.execute_instruction(&mut ram);

        if ram.read(0xEF) == 0xFF {
            break;
        }
    }
    let bcd = format!("{:02x}{:02x}", ram.read(0x03), ram.read(0x02));
    let newScore = bcd.parse::<u16>().unwrap();


    let added = if newScore >= score {
        format!("{}", newScore - score)
    } else {
        format!("{} {}", newScore, score)
    };


    // print!("{}", bcd);

    print!("score {} PDP {} Actual PDP {}",
        score,
        ram.read(0x01),
        added,
    );
    println!(" -- score {} PDP {} Actual PDP {}",
        score,
        ram.read(0x01),
        _pushdown(ram.read(0x01), score) - score,
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
