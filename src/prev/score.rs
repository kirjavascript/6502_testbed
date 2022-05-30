mod emu;

fn test() {

    // for pdp in 9..10 {
    //     println!("PDP {}", pdp);
    //     for score in 23569..23570 {
    //         let refadded = pushdown_ref(pdp, score);
    //         let asmadded = score_binary(0, 0, pdp, score);
    //         assert_eq!(refadded, asmadded.unwrap());

    //         println!("score {} PDP {} ASM PDP {} Ref PDP {}",
    //             score,
    //             pdp,
    //             asmadded.expect("asm fail"),
    //             refadded,
    //         );
    //     }
    // }

    for level in 0..=255 {
        score_bcd(4, level, 0, 0);
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

fn score_binary(lines: u8, level: u8, pushdown: u8, score: u16) -> Option<u16> {

    use emulator_6502::Interface6502;

    let (mut cpu, mut ram) = emu::load();

    ram.write(0x01, pushdown); // pushdown
    let bcd_str = format!("{:06}", score);
    let bcd_a = i64::from_str_radix(&bcd_str[0..2], 16).unwrap();
    let bcd_b = i64::from_str_radix(&bcd_str[2..4], 16).unwrap();
    let bcd_c = i64::from_str_radix(&bcd_str[4..6], 16).unwrap();

    ram.write(0x04, bcd_a as u8);
    ram.write(0x03, bcd_b as u8);
    ram.write(0x02, bcd_c as u8);
    ram.write(0x80, score as u8);
    ram.write(0x81, (score >> 8) as u8);

    ram.write(0x200, lines);
    ram.write(0x201, level);

    let mut i = 0;

    loop {
        // cpu.execute_instruction(&mut ram);
        cpu.cycle(&mut ram);
        i += 1;
        if ram.read(0xEF) == 0xFF {
            break;
        }
    }

    println!("{:#?}", i);

    let next_score = ram.read(0x80) as u16 + ((ram.read(0x81) as u16) << 8);

    if next_score >= score {
        Some(next_score - score)
    } else {
        None
    }
}

fn score_bcd(lines: u8, level: u8, pushdown: u8, score: u16) -> Option<u16> {

    use emulator_6502::Interface6502;

    let (mut cpu, mut ram) = emu::load();

    ram.write(0x01, pushdown); // pushdown
    let bcd_str = format!("{:06}", score);
    let bcd_a = i64::from_str_radix(&bcd_str[0..2], 16).unwrap();
    let bcd_b = i64::from_str_radix(&bcd_str[2..4], 16).unwrap();
    let bcd_c = i64::from_str_radix(&bcd_str[4..6], 16).unwrap();

    ram.write(0x04, bcd_a as u8);
    ram.write(0x03, bcd_b as u8);
    ram.write(0x02, bcd_c as u8);

    ram.write(0x200, lines);
    ram.write(0x201, level);

    let mut i = 0;

    loop {
        // cpu.execute_instruction(&mut ram);

        cpu.cycle(&mut ram);
        i += 1;

        if ram.read(0xEF) == 0xFF {
            break;
        }
    }

    println!("{:#?},", i);

    let bcd = format!("{:02x}{:02x}{:02x}", ram.read(0x04), ram.read(0x03), ram.read(0x02));

    let next_score = bcd.parse::<u32>().unwrap_or_else(|e| {
        println!("{:#?} {} {}", bcd, score, pushdown);
        0
    }) as u16;

    if next_score >= score {
        Some(next_score - score)
    } else {
        None
    }
}
