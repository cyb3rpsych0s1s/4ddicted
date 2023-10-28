module Addicted

public class Consumptions extends IScriptable {
    private persistent let keys: array<TweakDBID>;
    private persistent let values: array<ref<Consumption>>;
    private let observers: array<Notify>;
    private func Keys() -> array<TweakDBID> { return this.keys; }
    private func Values() -> array<ref<Consumption>> { return this.values; }
    public func RegisterCallback(target: ref<ScriptableSystem>, function: CName) -> Void {
        ArrayPush(this.observers, new Notify(target, function));
    }
    public func UnregisterCallback(target: ref<ScriptableSystem>, function: CName) -> Void {
        let idx = ArraySize(this.observers) - 1;
        while idx > -1 {
            let observer = this.observers[idx];
            if observer.target == target && Equals(observer.function, function) {
                ArrayErase(this.observers, idx);
            }
            idx = idx - 1;
        }
    }
    private func FireCallbacks(event: ref<CrossThresholdEvent>) {
        for observer in this.observers {
            if IsDefined(observer.target) {
                Reflection.GetClassOf(observer.target)
                    .GetFunction(observer.function)
                    .Call(observer.target, [event]);
            }
        }
    }
    private func Notify(former: Threshold, latter: Threshold) -> Void {
        let evt: ref<CrossThresholdEvent> = CrossThresholdEvent.Create(former, latter);
        this.FireCallbacks(evt);
    }
}
public class Consumption extends IScriptable {
    private persistent let current: Int32;
    private persistent let doses: array<Float>;
    private func Current() -> Int32 { return this.current; }
    private func Doses() -> array<Float> { return this.doses; }
    private final static func Create(score: Int32, tms: Float) -> ref<Consumption> {
        let instance = new Consumption();
        instance.current = score;
        instance.doses = [tms];
        return instance;
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
