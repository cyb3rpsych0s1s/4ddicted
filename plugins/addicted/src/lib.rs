use red4ext_rs::prelude::*;
use system::System;

mod system;

define_plugin! {
    name: "addicted",
    author: "Roms1383",
    version: 0:1:0,
    on_register: {
        register_function!("Addicted.TestRED4ext", test_red4ext);
        register_function!("Addicted.TestSystem", test_system);
    }
}

fn test_red4ext(v: i32) {
    info!("TestRED4ext: {v:#?}");
}

fn test_system(system: System) {
    info!("calling System.HelloWorld from plugin");
    system.hello_world();
}
