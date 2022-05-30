use crate::emu;
use emulator_6502::{MOS6502, Interface6502};

#[derive(Debug, PartialEq)]
pub enum Block {
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

pub struct GymSPS {
    cpu: MOS6502,
    ram: emu::Ram,
    last_iter: u8,
}

impl GymSPS {
    pub fn new() -> Self {
        let (cpu, ram) = emu::load(include_bytes!("../bin/gym-sps.nes"));

        GymSPS {
            cpu, ram, last_iter: 0,
        }
    }

    pub fn _reset(&mut self) {
        self.ram.write(0x19, 0); // spawnID
        self.ram.write(0xBF, 0); // nextPiece
        self.ram.write(0xEF, 0); // iter
    }

    pub fn set_input(&mut self, a: u8, b: u8, c: u8) {
        self.ram.write(0x37, a);
        self.ram.write(0x38, b);
        self.ram.write(0x39, c);
    }

    pub fn next(&mut self) -> Block {
        loop {
            self.cpu.execute_instruction(&mut self.ram);

            let iter = self.ram.read(0xef);

            if iter != self.last_iter {
                self.last_iter = iter;
                return Block::from(self.ram.read(0x19));
            }
        }
    }

}
