mod emu;
// mod seed;
// mod btype;

// (cd asm && make) && cargo run


fn main() {
    // seed::test();
    // btype::test();

    use emulator_6502::Interface6502;

    let (mut cpu, mut ram) = emu::load();

    let spawn_count = 3;
    let seed = 0x8988;

    // reset
    ram.write(0x19, 7); // spawnID
    ram.write(0xBF, 7); // nextPiece
    ram.write(0xEF, 0); // iter

    // set initial seed
    ram.write(0x17, seed as u8 & 0xFF);
    ram.write(0x18, (seed >> 8) as u8);
    // spawn count
    ram.write(0x1A, spawn_count as u8);
    // spawn ID

    let mut last_iter = 0;

    loop {
        cpu.execute_instruction(&mut ram);

        let iter = ram.read(0xEF);

        if iter != last_iter {
            last_iter = iter;



            if ram.read(0x17) == 0x6c && ram.read(0x18) == 00 {
                println!("{:#?}, {:02x}", iter, ram.read(0x19));
            }
        }
    }
}
