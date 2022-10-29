module Addicted

// @if(ModuleExists("Toxicity"))
// @wrapMethod(PlayerPuppet)
// protected cb func OnGameAttached() -> Bool {
//     Log("OK Toxicity found");
//     LogChannel(n"DEBUG", "pppppppppppppppppppppppppppppppppppppppppppp");
//     wrappedMethod();
// }

// // @if(!ModuleExists("WE3D - Drugs of Night City"))
// // @wrapMethod(PlayerPuppet)
// // protected cb func OnGameAttached() -> Bool {
// //     Log("Addicted mod requires WE3D - Drugs of Night City mod");
// //     wrappedMethod();
// // }

// @if(!ModuleExists("Toxicity"))
// @wrapMethod(PlayerPuppet)
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    LogChannel(n"DEBUG", "test Addicted");
    wrappedMethod();
}

// @addField(NPCPuppet)
// let testfield: Bool;