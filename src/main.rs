mod rng;
mod emu;

fn main() {
    println!("{:#?}", rng::generate_blocks(0x8889, 0));
}
