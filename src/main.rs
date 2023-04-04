use std::thread;
use std::time::Duration;
use std::ops::Range;

fn search(range: Range<u32>) {

        let mut sps = ntools::gym_sps::GymSPS::new();

        for i in range {
            for j in 0..=255 {
                for k in 0..=255 {
                    sps.reset();
                    sps.set_input(i as u8, j, k);
                    if sps.next() == ntools::block::Block::I {
                        if sps.next() == ntools::block::Block::O {
                        if sps.next() == ntools::block::Block::L {
                        if sps.next() == ntools::block::Block::Z {
                        if sps.next() == ntools::block::Block::T {
                        if sps.next() == ntools::block::Block::J {
                        if sps.next() == ntools::block::Block::L {
                        if sps.next() == ntools::block::Block::T {
                        if sps.next() == ntools::block::Block::S {
                        if sps.next() == ntools::block::Block::Z {
                        println!(
                            "{:02x}{:02x}{:02x}",
                            i,
                            j,
                            k,
                        );
                        }}}}}}}}}
                    }

                }
            }
            println!("{}/255", i);
        }
}

fn main() {

    let threads = 8;
    let size = 255 / threads;
    let mut count = 0;

    loop {

        if count > 255 { break; }

        let start = count;

        thread::spawn(move || {
            search(start..start+size);
        });

        count += size;
    }

    loop {
    }
}
