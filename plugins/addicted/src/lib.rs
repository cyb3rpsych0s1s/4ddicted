use red4ext_rs::prelude::*;

mod system;

define_plugin! {
    name: "addicted",
    author: "Roms1383",
    version: 0:1:0,
    on_register: {
        register_function!("Addicted.TestRED4ext", test_red4ext);
    }
}

fn test_red4ext(v: i32) {
    info!("TestRED4ext: {v:#?}");
}