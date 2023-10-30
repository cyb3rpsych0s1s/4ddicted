module Addicted

abstract public class AddictionEvent extends Event {
    private let item: ItemID;
    public func Item() -> ItemID { return this.item; }
}
abstract public class CrossThresholdEvent extends AddictionEvent {
    private let former: Threshold;
    private let latter: Threshold;
    public func Former() -> Threshold { return this.former; }
    public func Latter() -> Threshold { return this.latter; }
}
public class IncreaseThresholdEvent extends CrossThresholdEvent {}
public class DecreaseThresholdEvent extends CrossThresholdEvent {}
public class ConsumeEvent extends AddictionEvent {
    private let score: Int32;
    public func Score() -> Int32 { return this.score; }
}

struct Notify {
    let target: wref<ScriptableSystem>;
    let function: CName;
}