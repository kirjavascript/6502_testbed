mod emu;
mod gym_sps;
// mod transition_lines;



fn main() {
    // tetris-toolkit

    // debug_ram
    // render_playfield / b-type
    // hard drop

    let mut sps = gym_sps::GymSPS::new();

    sps.print_start_repeats(gym_sps::Block::I);

}
