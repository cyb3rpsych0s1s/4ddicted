module Addicted

public class Consumptions extends IScriptable {
    private persistent let keys: array<TweakDBID>;
    private persistent let values: array<ref<Consumption>>;
    private let observers: array<Notify>;
    private func Keys() -> array<TweakDBID> { return this.keys; }
    private func Values() -> array<ref<Consumption>> {
        for v in this.values {
            LogChannel(n"DEBUG", s"\(IsDefined(v) ? "defined" : "null")");
        }
        return this.values;
    }
    private func OnConsumeOnce(once: ConsumeOnce) -> Void {
        LogChannel(n"DEBUG", s"once: score \(once.increase.score), when \(once.increase.when)");
        let consumption = new Consumption();
        consumption.current = once.increase.score;
        consumption.doses = [once.increase.when];
        ArrayPush(this.keys, once.id);
        ArrayPush(this.values, consumption);
    }
    private func OnConsumeAgain(again: ConsumeAgain) -> Void {
        LogChannel(n"DEBUG", s"again: score \(again.increase.score), when \(again.increase.when)");
        let consumption: ref<Consumption> = this.values[Cast<Int32>(again.which)];
        consumption.current = consumption.current + again.increase.score;
        ArrayPush(consumption.doses, again.increase.when);
    }
    private func OnWeanOff(off: WeanOff) -> Void {
        LogChannel(n"DEBUG", s"weanoff: off.size \(ArraySize(off.decrease))");
        let consumption: ref<Consumption>;
        for decrease in off.decrease {
            consumption = this.values[Cast<Int32>(decrease.which)];
            consumption.current = consumption.current - decrease.score;
            if ArraySize(decrease.doses) > 0 { consumption.doses = decrease.doses; }
        }
    }
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
