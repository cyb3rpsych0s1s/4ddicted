module Addicted

import Martindale.MartindaleSystem

public class System extends ScriptableSystem {
    private persistent let keys: array<TweakDBID>;
    private persistent let values: array<ref<Consumption>>;
    private let registry: ref<inkHashMap>;
    private let observers: array<Notify>;
    private let restingSince: GameTime;
    private let lastWeanOff: GameTime;
    private let player: wref<PlayerPuppet>;

    //// consumptions

    private func Consumed(itemID: ItemID) -> Void {
        let id = ItemID.GetTDBID(itemID);
        let position = this.Position(id);
        let on = this.TimeSystem().GetGameTimeStamp();
        let before: Int32;
        let after: Int32;
        if position != -1 {
            before = this.values[position].current;
            after = before + GetIncreaseFactor(itemID);
            if after > 100 { after = 100; }
            this.values[position].current = after;
            ArrayPush(this.values[position].doses, on);
        } else {
            before = 0;
            after = before + GetIncreaseFactor(itemID);
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
        let after = before - GetDecreaseFactor(ItemID.FromTDBID(id));
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
        let size = ArraySize(this.observers);
        if size == 0 { return; }
        for observer in this.observers {
            if IsDefined(observer.target) {
                Reflection.GetClassOf(observer.target)
                    .GetFunction(observer.function)
                    .Call(observer.target, [event]);
            }
        }
    }
    // TODO: remove board implementation
    // reason: we don't want other mods to alter them and cause inconsistencies
    private func UpdateBoard(item: ItemID, score: Int32) -> Void {
        let def: ref<AddictionsThresholdDef> = GetAllBlackboardDefs().PlayerStateMachine.Thresholds;
        let system = this.BoardSystem();
        let board = system.Get(def);
        let pin: BlackboardID_Int = GetBoardPin(item);
        let current = board.GetInt(pin);
        let next = this.GetHighestScore(item);
        if NotEquals(current, next) {
            board.SetInt(pin, next);
            board.SignalInt(pin);
        }
    }
    private func UpdateEffect(item: ItemID, threshold: Threshold) -> Void {
        let effect = GetStatusEffect(item);
        if !TDBID.IsValid(effect) { return; }
        let system = this.EffectSystem();
        let applied: array<ref<StatusEffect>>;
        let current: Int32;
        let next: Int32 = Equals(threshold, Threshold.Notably)
        ? 1
        : Equals(threshold, Threshold.Severely)
          ? 2
          : 0;
        let count: Int32;
        system.GetAppliedEffectsWithID(this.player.GetEntityID(), effect, applied);
        current = ArraySize(applied);
        count = next - current;
        if count > 0 {
            system.ApplyStatusEffect(this.player.GetEntityID(), effect, t"Addiction", this.player.GetEntityID(), Cast<Uint32>(count));
        } else if current < 0 {
            system.RemoveStatusEffect(this.player.GetEntityID(), effect, Cast<Uint32>(Abs(count)));
        }
    }
    private func Notify(item: ItemID, before: Int32, after: Int32) -> Void {
        let consume: ref<ConsumeEvent> = new ConsumeEvent();
        consume.item = item;
        consume.score = after;
        this.FireEvent(consume);
        this.UpdateBoard(item, after);

        let former: Threshold = GetThreshold(before);
        let latter: Threshold = GetThreshold(after);
        if NotEquals(former, latter) {
            let cross: ref<CrossThresholdEvent>;
            if before < after { cross = new IncreaseThresholdEvent(); }
            else              { cross = new DecreaseThresholdEvent(); }
            cross.item   = item;
            cross.former = former;
            cross.latter = latter;
            this.FireEvent(cross);
            this.UpdateEffect(item, latter);
        }
    }

    //// initialization methods

    private func OnAttach() -> Void {
        let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
        if IsDefined(player) {
            this.player = player;
        }
    }

    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
        let player: ref<PlayerPuppet> = request.owner as PlayerPuppet;
        if IsDefined(player) {
            this.player = player;
        }
    }
    private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
        this.player = null;
    }

    //// helper methods

    private func Keys(category: Category) -> array<TweakDBID> {
        let items: array<TweakDBID> = [];
        let bases: array<Consumable> = GetConsumables(category);
        for key in this.keys {
            if ArrayContains(bases, GetConsumable(key)) { ArrayPush(items, key); }
        }
        return items;
    }
    public func GetHighestScore(base: gamedataConsumableBaseName) -> Int32 {
        let highest: Int32 = 0;
        let idx = 0;
        for value in this.values {
            if Equals(GetBaseName(this.keys[idx]), base) && value.current > highest { highest = value.current; }
            idx += 1;
        }
        return highest;
    }
    public func GetHighestScore(consumable: Consumable) -> Int32 {
        let highest: Int32 = 0;
        let idx = 0;
        for value in this.values {
            if Equals(GetConsumable(this.keys[idx]), consumable) && value.current > highest { highest = value.current; }
            idx += 1;
        }
        return highest;
    }
    public func GetHighestScore(itemID: ItemID) -> Int32 {
        return this.GetHighestScore(GetBaseName(itemID));
    }
    public func GetHighestScore(category: Category) -> Int32 {
        let highest: Int32 = 0;
        let idx = 0;
        let consumables = this.Keys(category);
        for value in this.values {
            if ArrayContains(consumables, this.keys[idx]) && value.current > highest { highest = value.current; }
            idx += 1;
        }
        return highest;
    }
    public func GetHighestThreshold(itemID: ItemID) -> Threshold {
        return GetThreshold(this.GetHighestScore(GetBaseName(itemID)));
    }
    public func GetHighestThreshold(consumable: Consumable) -> Threshold {
        return GetThreshold(this.GetHighestScore(consumable));
    }
    public func GetHighestThreshold(category: Category) -> Threshold {
        return GetThreshold(this.GetHighestScore(category));
    }
    public func GetHighestThreshold(status: ref<StatusEffect_Record>) -> Threshold {
        if IsDefined(status) {
            if this.IsHealer(status) { return this.GetHighestThreshold(Category.Healers); }
            else { return this.GetHighestThreshold(GetConsumable(status)); }
        }
        return Threshold.Clean;
    }
    public func GetThresholdFromAppliedEffects(status: ref<StatusEffect_Record>) -> Threshold {
        let applied: array<ref<StatusEffect>>;
        this.EffectSystem().GetAppliedEffects(this.player.GetEntityID(), applied);
        if Equals(ArraySize(applied), 0) { return Threshold.Clean; }
        let count: Uint32 = 0u;
        let times: Uint32;
        if this.IsHealer(status) {
            for id in [
                t"BaseStatusEffect.MaxDOCAddict",
                t"BaseStatusEffect.BounceBackAddict",
                t"BaseStatusEffect.HealthBoosterAddict"] {
                if count >= 2u { break; }
                times = 0u;
                for effect in applied {
                    if effect.GetRecord().GetID() == id { times += effect.GetStackCount(); }
                }
                if times > count { count = times; }
            }
        } else if this.IsNeuroBlocker(status) {
            count = 0u;
            for effect in applied {
                if effect.GetRecord().GetID() == t"BaseStatusEffect.RipperdocMedAddict" { count += effect.GetStackCount(); }
                if count >= 2u { break; }
            }
        }
        return count == 0u
        ? Threshold.Clean
        : count == 1u
          ? Threshold.Notably
          : Threshold.Severely;
    }
    public func IsHealer(status: ref<StatusEffect_Record>) -> Bool {
        let name = TDBID.ToStringDEBUG(status.GetID());
        return StrContains(name, "FirstAidWhiff")
        || StrContains(name, "BonesMcCoy70")
        || StrContains(name, "HealthBooster");
    }
    public func IsNeuroBlocker(status: ref<StatusEffect_Record>) -> Bool {
        let name = TDBID.ToStringDEBUG(status.GetID());
        return StrContains(name, "RipperdocMed");
    }
    
    public final static func GetInstance(game: GameInstance) -> ref<System> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return container.Get(n"Addicted.System") as System;
    }
    public func TimeSystem() -> ref<TimeSystem> { return GameInstance.GetTimeSystem(this.player.GetGame()); }
    public func BoardSystem() -> ref<BlackboardSystem> { return GameInstance.GetBlackboardSystem(this.player.GetGame()); }
    public func EffectSystem() -> ref<StatusEffectSystem> { return GameInstance.GetStatusEffectSystem(this.player.GetGame()); }
}