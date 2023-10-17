module Addicted

public class CrossThresholdEvent extends Event {
    private let former: Threshold;
    private let latter: Threshold;
    public func Former() -> Threshold { return this.former; }
    public func Latter() -> Threshold { return this.latter; }
    static func Create(former: Threshold, latter: Threshold) -> ref<CrossThresholdEvent> {
        let me: ref<CrossThresholdEvent> = new CrossThresholdEvent();
        me.former = former;
        me.latter = latter;
        return me;
    }
}