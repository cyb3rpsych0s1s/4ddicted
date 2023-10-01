module Addicted

public class Consumptions extends IScriptable {
    private persistent let keys: array<TweakDBID>;
    private persistent let values: array<ref<Consumption>>;
    public func Keys() -> array<TweakDBID> { return this.keys; }
    public func Values() -> array<ref<Consumption>> { return this.values; }
    public func SetKeys(keys: array<TweakDBID>) -> Void { this.keys = keys; }
    public func SetValues(values: array<ref<IScriptable>>) -> Void {
        ArrayClear(this.values);
        this.values = [];
        for value in values {
            ArrayPush(this.values, value as Consumption);
        }
    }
    public func CreateConsumption(score: Int32, when: Float) -> ref<Consumption> {
        let consumption = new Consumption();
        consumption.current = score;
        consumption.doses = [when];
        return consumption;
    }
}
public class Consumption extends IScriptable {
    public persistent let current: Int32;
    public persistent let doses: array<Float>;
    public func Current() -> Int32 { return this.current; }
    public func SetCurrent(value: Int32) -> Void { this.current = value; }
    public func Doses() -> array<Float> { return this.doses; }
    public func SetDoses(value: array<Float>) -> Void { this.doses = value; }
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
