module Addicted

public class Consumption extends IScriptable {
    private persistent let current: Int32;
    private persistent let doses: array<Float>;
    public func Current() -> Int32 { return this.current; }
    public func Doses() -> array<Float> { return this.doses; }
    public func Threshold() -> Threshold { return GetThreshold(this.current); }
}
