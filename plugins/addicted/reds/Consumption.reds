module Addicted

public class Increase extends Event {
    public let id: TweakDBID;
    public let score: Int32;
}

public class Consumptions extends IScriptable {
    private persistent let keys: array<TweakDBID>;
    private persistent let values: array<ref<Consumption>>;
    public func Keys() -> array<TweakDBID> { return this.keys; }
    public func Values() -> array<ref<Consumption>> {
        for v in this.values {
            LogChannel(n"DEBUG", s"\(IsDefined(v) ? "defined" : "null")");
        }
        return this.values; }
    private func SetKeys(keys: array<TweakDBID>) -> Void {
        ArrayResize(this.keys, ArraySize(keys));
        this.keys = keys;
    }
    private func SetValues(values: array<ref<Consumption>>) -> Void {
        ArrayResize(this.values, ArraySize(values));
        let idx = 0;
        for value in values {
            ArrayInsert(this.values, idx, value as Consumption);
            idx += 1;
        }
    }
    private func CreateConsumption(score: Int32, when: Float) -> ref<Consumption> {
        let consumption = new Consumption();
        consumption.current = score;
        consumption.doses = [when];
        return consumption;
    }
}
public class Consumption extends IScriptable {
    private persistent let current: Int32;
    private persistent let doses: array<Float>;
    public func Current() -> Int32 { return this.current; }
    private func SetCurrent(value: Int32) -> Void { this.current = value; }
    public func Doses() -> array<Float> { return this.doses; }
    private func SetDoses(doses: array<Float>) -> Void {
        ArrayResize(this.doses, ArraySize(doses));
        this.doses = doses;
    }
}

enum Threshold {
    Clean = 0,
    Barely = 10,
    Mildly = 20,
    Notably = 40,
    Severely = 60,
}

enum Kind {
    Mild = 1,
    Hard = 2,
}

enum Substance {
    Unknown = -1,
    Alcohol = 1,
    MaxDOC = 2,     // FirstAidWhiff
    BounceBack = 3, // BonesMcCoy
    HealthBooster = 4,
    MemoryBooster = 5,
    StaminaBooster = 7,
    BlackLace = 8,
    CarryCapacityBooster = 9,
    NeuroBlocker = 10,
}
