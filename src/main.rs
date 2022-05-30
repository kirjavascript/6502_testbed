mod emu;
mod gym_sps;
// mod transition_lines;



fn main() {
    // tetris-toolkit

    // debug_ram
    // render_playfield / b-type
    // hard drop

    let mut sps = gym_sps::GymSPS::new();

    sps.set_input(0x12, 0x34, 0x0);

    println!("{:?}", sps.next());
    println!("{:?}", sps.next());
    println!("{:?}", sps.next());
    println!("{:?}", sps.next());

}
