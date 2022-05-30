use emulator_6502::{MOS6502, Interface6502};

pub struct Ram {
    ram: Box<[u8; u16::max_value() as usize + 1]> //The maximum address range of the 6502
}

impl Ram {
    pub fn load_program(&mut self, start: usize, data: &[u8]){
        for (i, value) in data.iter().enumerate() {
            self.ram[start + i] = *value;
        }
    }
}

impl Interface6502 for Ram {
    fn read(&mut self, address: u16) -> u8{
        self.ram[address as usize]
    }

    fn write(&mut self, address: u16, data: u8){
        self.ram[address as usize] = data
    }
}

pub fn load(prg: &[u8]) -> (MOS6502, Ram) {
    let mut ram = Ram{ ram: Box::new([0; u16::max_value() as usize + 1]) };
    ram.load_program(0x0, &prg.to_vec());

    let mut cpu = MOS6502::new();
    cpu.set_program_counter(0x8000);

    (cpu, ram)
}
