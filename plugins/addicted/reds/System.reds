module Addicted

public class System extends ScriptableSystem {
    private persistent let keys: array<TweakDBID>;
    private persistent let values: array<ref<Consumption>>;
    private let registry: ref<inkHashMap>;
    private let observers: array<Notify>;
    private let restingSince: GameTime;
    private let lastWeanOff: GameTime;

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
        this.Notify(itemID, before, after);
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
        let last = GameTime.MakeGameTime(GameTime.Days(this.lastWeanOff), GameTime.Hours(this.lastWeanOff) + 12, GameTime.Minutes(this.lastWeanOff));
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
        this.values[idx].current = after;
        this.lastWeanOff = this.TimeSystem().GetGameTime();
        this.Notify(ItemID.FromTDBID(id), before, after);
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
    private func FireEvent(event: ref<AddictionEvent>) {
        if ArraySize(this.observers) == 0 { return; }
        for observer in this.observers {
            if IsDefined(observer.target) {
                Reflection.GetClassOf(observer.target)
                    .GetFunction(observer.function)
                    .Call(observer.target, [event]);
            }
        }
    }
    private func UpdateBoard(item: ItemID, score: Int32) -> Void {
        let def: ref<AddictionsThresholdDef> = GetAllBlackboardDefs().PlayerStateMachine.Thresholds;
        let system = this.BoardSystem();
        let board = system.Get(def);
        let id: BlackboardID_Variant;
        let found = false;
        switch(ItemID.GetTDBID(item)) {
            case t"Items.FirstAidWhiffV0":
                id = GetAllBlackboardDefs().PlayerStateMachine.Thresholds.MaxDOC;
                found = true;
                break;
        }
        if found {
            let current = FromVariant<Threshold>(board.GetVariant(GetAllBlackboardDefs().PlayerStateMachine.Thresholds.MaxDOC));
            let next = GetHighestThreshold(this.keys, this.values, item);
            if NotEquals(current, next) {
                board.SetVariant(GetAllBlackboardDefs().PlayerStateMachine.Thresholds.MaxDOC, ToVariant(next));
                board.SignalVariant(id);
            }
        }
    }
    private func Notify(item: ItemID, before: Int32, after: Int32) -> Void {
        let consume: ref<ConsumeEvent> = new ConsumeEvent();
        consume.item = item;
        consume.score = after;
        this.FireEvent(consume);

        let former: Threshold = GetThreshold(before);
        let latter: Threshold = GetThreshold(after);
        if NotEquals(former, latter) {
            let evt: ref<CrossThresholdEvent>;
            if before < after { evt = new IncreaseThresholdEvent(); }
            else              { evt = new DecreaseThresholdEvent(); }
            evt.item   = item;
            evt.former = former;
            evt.latter = latter;
            this.FireEvent(evt);
        }
    }

    //// initialization methods

    private func CreateRegistry() -> Void {
        this.registry = new inkHashMap();
        let records = TweakDBInterface.GetRecords(n"ConsumableItem");
        let consumable: ref<ConsumableItem_Record>;
        let entry: ref<RegistryEntry>;
        for record in records {
            consumable = record as ConsumableItem_Record;
            entry = GetRegistryEntry(consumable);
            if IsDefined(entry) {
                this.registry.Insert(TDBID.ToNumber(ItemID.GetTDBID(entry.id)), entry);
            }
        }
    }

    //// helper methods
    
    public final static func GetInstance(game: GameInstance) -> ref<System> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return container.Get(n"Addicted.System") as System;
    }
    public func TimeSystem() -> ref<TimeSystem> { return GameInstance.GetTimeSystem(this.GetGameInstance()); }
    public func BoardSystem() -> ref<BlackboardSystem> { return GameInstance.GetBlackboardSystem(this.GetGameInstance()); }
}