use ntools::gym_sps;
use ntools::block::Block;

fn main() {
    // tetris-toolkit

    // debug_ram
    // render_playfield / b-type
    // hard drop

    let mut sps = gym_sps::GymSPS::new();
    sps.print_start_repeats(Block::T);
}
