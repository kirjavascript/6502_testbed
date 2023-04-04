mod emu;
mod line_clear;

fn main() {
    line_clear::print_line_clear();
    line_clear::print_line_clear_crash();
    line_clear::print_line_clear_mod();
}

