module Addicted

public class System extends ScriptableSystem {
    private persistent let keys: array<TweakDBID>;
    private persistent let values: array<ref<Consumption>>;
    private let observers: array<Notify>;
    private let restingSince: GameTime;
    private let lastResilience: GameTime;

    //// consumptions

    private func Consumed(itemID: ItemID) -> Void {
        let id = ItemID.GetTDBID(itemID);
        let position = this.Position(id);
        let on = this.TimeSystem().GetGameTimeStamp();
        let before: Int32;
        let after: Int32;
        if position != -1 {
            before = this.values[position].current;
            after = before + GetAddictivity(itemID);
            if after > 100 { after = 100; }
            this.values[position].current = after;
            ArrayPush(this.values[position].doses, on);
        } else {
            before = 0;
            after = before + GetAddictivity(itemID);
            let value = new Consumption();
            value.current = after;
            value.doses = [on];
            ArrayPush(this.keys, id);
            ArrayPush(this.values, value);
        }
        let former = GetThreshold(before);
        let latter = GetThreshold(after);
        if NotEquals(former, latter) {
            this.Notify(former, latter);
        }
    }
    private func Rested() -> Void {
        let now = this.TimeSystem().GetGameTime();
        let idx = 0;
        let minimum: Int32;
        let since: GameTime;
        for key in this.keys {
            minimum = GetMinimumSleepRequired(ItemID.FromTDBID(key));
            since = GameTime.MakeGameTime(GameTime.Days(this.restingSince), GameTime.Hours(this.restingSince) + minimum, GameTime.Minutes(this.restingSince));
            if GameTime.IsAfter(now, since) {
                this.WeanOff(key);
            }
            idx += 1;
        }
    }
    private func Refreshed() -> Void {
        let now = this.TimeSystem().GetGameTime();
        let last = GameTime.MakeGameTime(GameTime.Days(this.lastResilience), GameTime.Hours(this.lastResilience) + 12, GameTime.Minutes(this.lastResilience));
        if GameTime.IsAfter(now, last) {
            let idx = 0;
            for key in this.keys {
                this.WeanOff(key);
                idx += 1;
            }
        }
    }
    private func Energized() -> Void {
        this.Refreshed();
    }
    private func WeanOff(id: TweakDBID) -> Void {
        let idx = this.Position(id);
        if idx == -1 { return; }
        let before = this.values[idx].current;
        let after = before - GetResilience(ItemID.FromTDBID(id));
        if after < 0 { after = 0; }
        let former = GetThreshold(before);
        let latter = GetThreshold(after);
        this.values[idx].current = after;
        this.lastResilience = this.TimeSystem().GetGameTime();
        if NotEquals(former, latter) {
            this.Notify(former, latter);
        }
    }
    private func Position(id: TweakDBID) -> Int32 {
        let idx = 0;
        for key in this.keys {
            if key == id { return idx; }
            idx += 1;
        }
        return -1;
    }

    //// notifications

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

    //// helper methods
    
    public final static func GetInstance(game: GameInstance) -> ref<System> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return container.Get(n"Addicted.System") as System;
    }
    public func TimeSystem() -> ref<TimeSystem> { return GameInstance.GetTimeSystem(this.GetGameInstance()); }
    public func BoardSystem() -> ref<BlackboardSystem> { return GameInstance.GetBlackboardSystem(this.GetGameInstance()); }
}