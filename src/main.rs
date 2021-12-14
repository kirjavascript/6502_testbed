mod emu;

// (cd asm && make) && cargo run

fn main() {

    for pdp in 12..13 {
        println!("PDP {}", pdp);
        for score in 4096..4196 {
            let refadded = pushdown_ref(pdp, score);
            let asmadded = pushdown_new(pdp, score);
            assert_eq!(refadded, asmadded.unwrap());

            // println!("score {} PDP {} ASM PDP {} Ref PDP {}",
            //     score,
            //     pdp,
            //     asmadded.expect("asm fail"),
            //     refadded,
            // );
        }
    }
}

fn pushdown_ref(pushdown: u8, score: u16) -> u16 {
    let ones = score % 10;
    let hundredths = score % 100;
    let mut newscore = ones as u8 + (pushdown - 1);
    if newscore & 0xF > 9 {
        newscore += 6;
    }

    let low = (newscore & 0xF) as u16;
    let high = ((newscore & 0xF0) / 16 * 10) as u16;

    let mut newscore = high + (hundredths - ones);
    let nextscore = newscore + low;

    if nextscore <= 100 {
        newscore = nextscore;
    }

    newscore + (score-hundredths) - score
}

fn pushdown_new(pushdown: u8, score: u16) -> Option<u16> {

    use emulator_6502::Interface6502;

    let (mut cpu, mut ram) = emu::load();

    ram.write(0x01, pushdown); // pushdown
    let bcd_str = format!("{:04}", score);
    let bcd_high = i64::from_str_radix(&bcd_str[0..2], 16).unwrap();
    let bcd_low = i64::from_str_radix(&bcd_str[2..4], 16).unwrap();

    ram.write(0x02, bcd_low as u8);
    ram.write(0x03, bcd_high as u8);
    ram.write(0x80, score as u8);
    ram.write(0x81, (score >> 8) as u8);

    loop {
        cpu.execute_instruction(&mut ram);
        if ram.read(0xEF) == 0xFF {
            break;
        }
    }

    // return Some(ram.read(0x13) as u16);

    let next_score = ram.read(0x80) as u16 + ((ram.read(0x81) as u16) << 8);

    // println!("{:02x}{:02x}", ram.read(0x81), ram.read(0x80));

    if next_score >= score {
        Some(next_score - score)
    } else {
        None
    }
}

fn pushdown(pushdown: u8, score: u16) -> Option<u16> {

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
    let next_score = bcd.parse::<u16>().unwrap_or_else(|e| {
        println!("{:#?} {} {}", bcd, score, pushdown);
        0
    });


    if next_score >= score {
        Some(next_score - score)
    } else {
        None
    }
}
