module Addicted

struct Increase {
    let score: Int32;
    let when: Float;
}
struct Decrease {
    let which: Uint32;
    let score: Int32;
    let doses: array<Float>;
}
struct ConsumeOnce {
    let id: TweakDBID;
    let increase: Increase;
}
struct ConsumeAgain {
    let which: Uint32;
    let increase: Increase;
}
struct WeanOff {
    let decrease: array<Decrease>;
}