use ntools::gym_sps;
use ntools::block::Block;

fn main() {
    // debug_ram
    // render_playfield / b-type
    // hard drop

    // let mut sps = gym_sps::GymSPS::new();
    // sps.print_start_repeats(Block::T);

    let mut sps = gym_sps::GymSPS::new();
    let mut highest = 0;

    for i in 0..=255 {
        for j in 0..255 {
            for k in 0..255 {
                sps.reset();
                sps.set_input(i, j, k);

                let mut count = 0;

                for I in 0..=100 {
                    if sps.next() == Block::O {
                        count += 1;
                        if count > highest {
                            highest = count;
                            println!( "{:02x}{:02x}{:02x} index: {} streak: {}", i, j, k, I, highest);
                        }
                    } else {
                        count = 0
                    }

                }
            }
        }
        println!("{}/255", i);
    }
}
