module Martindale

public class MartindaleSystem extends ScriptableSystem {
    private let registry: ref<Registry>;
    private let callbacks: ref<CallbackSystem>;
    private func OnAttach() -> Void {
        LogChannel(n"DEBUG", "[Martindale.System][OnAttach]");
        this.callbacks = GameInstance.GetCallbackSystem();
        this.callbacks.RegisterCallback(n"Session/Ready", this, n"OnSessionReady");
    }
    private func OnDetach() -> Void {
        if IsDefined(this.callbacks) {
            this.callbacks.UnregisterCallback(n"Session/Ready", this, n"OnSessionReady");
            this.callbacks = null;
        }
        if IsDefined(this.registry) {
            this.registry = null;
        }
        LogChannel(n"DEBUG", "[Martindale.System][OnDetach] deleted registry");
    }
    private cb func OnSessionReady(event: ref<GameSessionEvent>) {
        LogChannel(n"DEBUG", "[Martindale.System][OnSessionReady] creating registry...");

        this.registry = new Registry();
        this.registry.Scan();
        PatchMaxDOC(this.registry.MaxDOC());

        LogChannel(n"DEBUG", "[Martindale.System][OnSessionReady] registry created successfully!");
    }
    public func DebugRegistry() -> Void {
        this.registry.Debug();
    }
    public final static func GetInstance(game: GameInstance) -> ref<MartindaleSystem> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return container.Get(n"Martindale.MartindaleSystem") as MartindaleSystem;
    }
    public func IsHealerStatusEffect(record: ref<StatusEffect_Record>) -> Bool {
        let consumables: array<ref<RegisteredConsumable>>;
        this.registry.entries.GetValues(consumables);
        for consumable in consumables {
            if (IsMaxDOC(consumable.item) || IsBounceBack(consumable.item) || IsHealthBooster(consumable.item))
            && consumable.statuses.KeyExist(record) { return true; }
        }
        return false;
    }
    public func IsNeuroBlockerStatusEffect(record: ref<StatusEffect_Record>) -> Bool {
        let consumables: array<ref<RegisteredConsumable>>;
        this.registry.entries.GetValues(consumables);
        for consumable in consumables {
            if IsNeuroBlocker(consumable.item)
            && consumable.statuses.KeyExist(record) { return true; }
        }
        return false;
    }
    public func IsMaxDOCEffector(record: ref<Effector_Record>) -> Bool {
        let consumables: array<ref<RegisteredConsumable>>;
        this.registry.entries.GetValues(consumables);
        for consumable in consumables {
            if IsMaxDOC(consumable.item)
            && consumable.effectors.KeyExist(record) { return true; }
        }
        return false;
    }
    public func IsBounceBackEffector(record: ref<Effector_Record>) -> Bool {
        let consumables: array<ref<RegisteredConsumable>>;
        this.registry.entries.GetValues(consumables);
        for consumable in consumables {
            if IsBounceBack(consumable.item)
            && consumable.effectors.KeyExist(record) { return true; }
        }
        return false;
    }
    public func GetAppliedEffectsForHealthBooster(player: ref<PlayerPuppet>) -> array<ref<StatusEffect>> {
        let applied: array<ref<StatusEffect>> = StatusEffectHelper.GetAppliedEffects(player);
        let filtered: array<ref<StatusEffect>> = [];
        let record: ref<StatusEffect_Record>;
        let consumables: array<ref<RegisteredConsumable>>;
        this.registry.entries.GetValues(consumables);
        for status in applied {
            record = status.GetRecord();
            for consumable in consumables {
                if IsHealthBooster(consumable.item) && consumable.statuses.KeyExist(record) {
                    ArrayPush(filtered, status);
                }
            }
        }
        return filtered;
    }
    public func GetAppliedEffectsForNeuroBlocker(player: ref<PlayerPuppet>) -> array<ref<StatusEffect>> {
        let applied: array<ref<StatusEffect>> = StatusEffectHelper.GetAppliedEffects(player);
        let filtered: array<ref<StatusEffect>> = [];
        let record: ref<StatusEffect_Record>;
        let consumables: array<ref<RegisteredConsumable>>;
        this.registry.entries.GetValues(consumables);
        for status in applied {
            record = status.GetRecord();
            for consumable in consumables {
                if IsNeuroBlocker(consumable.item) && consumable.statuses.KeyExist(record) {
                    ArrayPush(filtered, status);
                }
            }
        }
        return filtered;
    }
}

public func PatchMaxDOC(maxdoc: array<ref<RegisteredConsumable>>) -> Void {
    LogChannel(n"DEBUG", "PatchMaxDOC");
    let raw: String = "BaseStatusEffect.MaxDOCAddict";
    let name: CName = StringToName(raw);
    let id: TweakDBID = TDBID.Create(raw);
    TweakDBManager.CreateRecord(name, n"StatusEffect_Record");
    TweakDBManager.SetFlat(id + t".duration", t"BaseStats.InfiniteDuration");
    TweakDBManager.SetFlat(id + t".gameplayTags", ["Debuff"]);
    TweakDBManager.SetFlat(id + t".maxStacks", t"BaseStatusEffect.StackTwice");
    TweakDBManager.SetFlat(id + t".statusEffectType", t"BaseStatusEffectTypes.PassiveDebuff");
    TweakDBManager.SetFlat(id + t".removeOnStoryTier", false);
    TweakDBManager.SetFlat(id + t".replicated", false);
    TweakDBManager.SetFlat(id + t".savable", false);

    TweakDBManager.SetFlat(id + t".packages", [t"Packages.LessenFirstAidWhiff"]);
    
    TweakDBManager.UpdateRecord(id);
}
