use emulator_6502::{MOS6502, Interface6502};

struct Ram{
    ram: Box<[u8; u16::max_value() as usize + 1]> //The maximum address range of the 6502
}

impl Ram {
    fn load_program(&mut self, start: usize, data: &Vec<u8>){
        for (i, value) in data.iter().enumerate() {
            self.ram[start + i] = *value;
        }
    }
}

impl Interface6502 for Ram{
    fn read(&mut self, address: u16) -> u8{
        self.ram[address as usize]
    }

    fn write(&mut self, address: u16, data: u8){
        self.ram[address as usize] = data
    }
}

fn main() {
    let mut ram = Ram{ ram: Box::new([0; u16::max_value() as usize + 1]) };

    let prg: Vec<u8> = include_bytes!("./../asm/main.nes").to_vec();

    ram.load_program(0x0, &prg);


    let mut cpu = MOS6502::new();
    cpu.set_program_counter(0x0400);

    let mut last_iter = 0;

    loop {
        cpu.execute_instruction(&mut ram);

        let iter = ram.read(0xEF);

        if iter != last_iter {
            last_iter = iter;
            print!("{:?}", Block::from(ram.read(0xBF)));
            // std::thread::sleep(std::time::Duration::from_secs(1));
        }

        // if iter > 20 {
        //     break;
        // }
    }
}

#[derive(Debug)]
enum Block {
    T, J, Z, O, S, L, I, Unknown(u8)
}

impl Block {
    fn from(value: u8) -> Self {
        match value {
            0x2 => Block::T,
            0x7 => Block::J,
            0x8 => Block::Z,
            0xA => Block::O,
            0xB => Block::S,
            0xE => Block::L,
            0x12 => Block::I,
            _ => Block::Unknown(value),
        }
    }
}
