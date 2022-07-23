use crate::emu;

mod playfield {
    use emulator_6502::Interface6502;
    pub fn clear(ram: &mut crate::emu::Ram) {
        for addr in 0x400..0x500 {
            ram.write(addr, 0xef);
        }
    }
    pub fn print(ram: &mut crate::emu::Ram) {
        for y in 0..20 {
                for x in 0..10 {
                let index = ((y * 10) + x) + 0x400;

                print!("{}",
                    if ram.read(index) == 0xEF { " " } else { "#" }
                );
            }
            print!("\n");
        }
    }
    pub fn set(ram: &mut crate::emu::Ram, x: u16, y: u16, value: u8) {
        let index = ((y * 10) + x) + 0x400;
        ram.write(index, value);
    }
    pub fn fill_line(ram: &mut crate::emu::Ram, y: u16) {
        for x in 0..10 {
            self::set(ram, x, y, 0x7b);
        }
    }
    pub fn set_str(ram: &mut crate::emu::Ram, playfield: &str) {
        playfield.trim_start_matches('\n').split("\n").enumerate().for_each(|(y, line)| {
            line.chars().enumerate().for_each(|(x, ch)| {
                self::set(ram, x as _, y as _, if ch == '#' { 0x7b } else { 0xef });
            });
        });
    }
}

pub fn print() {
    use emulator_6502::Interface6502;


        let (mut cpu, mut ram) = emu::load(include_bytes!("../bin/hard-drop.nes"));

        playfield::clear(&mut ram);

        playfield::set_str(&mut ram, r##"
      #
       #
        #
         #

#







### #
####
#####
##########
##########
##########
##########"##);


        playfield::set_str(&mut ram, r##"
#










 #   #
## ###
## #####
#########
#########
##########
##########
##########
##########"##);

        playfield::print(&mut ram);


        let mut i = 0;
        loop {
            cpu.cycle(&mut ram);
            i += 1;

            if ram.read(0xEF) == 0xff {
                println!("{:#?} cycles", i);
                playfield::print(&mut ram);

                for i in 0x500..0x500 + 20 {
                    print!("{:02x} ", ram.read(i));
                }
                print!("\n");

                println!("{}", ram.read(0x20));
                break;
            }
        }


}
