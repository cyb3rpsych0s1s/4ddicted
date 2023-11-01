module Martindale

public class MartindaleSystem extends ScriptableSystem {
    private let registry: ref<Registry>;
    private func OnAttach() -> Void {
        LogChannel(n"DEBUG", "[Martindale.System][OnAttach] creating registry...");
        this.registry = Registry.Create();
        ScanStatPoolUpdates(this.registry);
        ScanModifyStatPoolValueEffectors(this.registry);
        ScanStatusEffects(this.registry);
        ScanConsumables(this.registry);
        LogChannel(n"DEBUG", "[Martindale.System][OnAttach] registry created successfully!");
    }
    private func OnDetach() -> Void {
        this.registry.Clear();
        this.registry = null;
        LogChannel(n"DEBUG", "[Martindale.System][OnDetach] deleted registry");
    }
    
    public func DebugRegistry() -> Void {
        this.registry.DebugConsumables();
    }
    public final static func GetInstance(game: GameInstance) -> ref<MartindaleSystem> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return container.Get(n"Martindale.MartindaleSystem") as MartindaleSystem;
    }
}

public class Registry extends IScriptable {
    private let healthPoolUpdates: ref<inkHashMap>;
    private let healthEffectors: ref<inkHashMap>;
    private let healthStatusEffects: ref<inkHashMap>;
    private let healthConsumables: ref<inkHashMap>;
    public func HealthPoolUpdatesContains(id: TweakDBID) -> Bool {
        return IsDefined(this.healthPoolUpdates.Get(TDBID.ToNumber(id)));
    }
    public func HealthEffectorsContains(id: TweakDBID) -> Bool {
        return IsDefined(this.healthEffectors.Get(TDBID.ToNumber(id)));
    }
    public func HealthStatusEffectsContains(id: TweakDBID) -> Bool {
        return IsDefined(this.healthStatusEffects.Get(TDBID.ToNumber(id)));
    }
    private func InsertPoolUpdate(update: ref<StatPoolUpdate_Record>) -> Void {
        if this.healthPoolUpdates.KeyExist(TDBID.ToNumber(update.GetID())) { return; }
        this.healthPoolUpdates.Insert(TDBID.ToNumber(update.GetID()), update);
    }
    private func InsertPoolValueEffector(modify: ref<ModifyStatPoolValueEffector_Record>) -> Void {
        if this.healthEffectors.KeyExist(TDBID.ToNumber(modify.GetID())) { return; }
        this.healthEffectors.Insert(TDBID.ToNumber(modify.GetID()), modify);
    }
    private func InsertStatusEffect(status: ref<StatusEffect_Record>) -> Void {
        if this.healthStatusEffects.KeyExist(TDBID.ToNumber(status.GetID())) { return; }
        this.healthStatusEffects.Insert(TDBID.ToNumber(status.GetID()), status);
    }
    private func InsertConsumable(consumable: ref<ConsumableItem_Record>) -> Void {
        if this.healthConsumables.KeyExist(TDBID.ToNumber(consumable.GetID())) { return; }
        this.healthConsumables.Insert(TDBID.ToNumber(consumable.GetID()), consumable);
    }
    private func Clear() -> Void {
        this.healthConsumables.Clear();
        this.healthStatusEffects.Clear();
        this.healthEffectors.Clear();
        this.healthPoolUpdates.Clear();
    }
    public func DebugConsumables() -> Void {
        let message: String;
        let values: array<wref<IScriptable>>;
        let consumable: ref<ConsumableItem_Record>;
        let name: String;
        this.healthConsumables.GetValues(values);
        let idx = 0u;
        LogChannel(n"DEBUG", s"registry contains \(ArraySize(values)) consumable(s)");
        for value in values {
            consumable = value as ConsumableItem_Record;
            name = TDBID.ToStringDEBUG(consumable.GetID());
            if idx >= 1u { message = message + "\n" + name; }
            else         { message = name; }
            idx += 1u;
        }
        LogChannel(n"DEBUG", message);
    }
    private final static func Create() -> ref<Registry> {
        let me = new Registry();
        me.healthPoolUpdates = new inkHashMap();
        me.healthEffectors = new inkHashMap();
        me.healthStatusEffects = new inkHashMap();
        me.healthConsumables = new inkHashMap();
        return me;
    }
}

public func ScanStatPoolUpdates(registry: ref<Registry>) -> Void {
    let records = TweakDBInterface.GetRecords(n"StatPoolUpdate");
    LogChannel(n"DEBUG", s"scan \(ToString(ArraySize(records))) stat pool update(s)");
    let update: ref<StatPoolUpdate_Record>;
    for record in records {
        update = record as StatPoolUpdate_Record;
        if BasedOnHealth(update) {
            registry.InsertPoolUpdate(update);
        }
    }
    LogChannel(n"DEBUG", s"completed stat pool updates registration");
}

public func BasedOnHealth(update: ref<StatPoolUpdate_Record>) -> Bool {
    return Equals(update.StatPoolType().StatPoolType(), gamedataStatPoolType.Health);
}

public func ScanModifyStatPoolValueEffectors(registry: ref<Registry>) -> Void {
    let records = TweakDBInterface.GetRecords(n"ModifyStatPoolValueEffector");
    LogChannel(n"DEBUG", s"scan \(ToString(ArraySize(records))) modify stat pool value effector(s)");
    let effector: ref<ModifyStatPoolValueEffector_Record>;
    let updates: array<wref<StatPoolUpdate_Record>>;
    for record in records {
        effector = record as ModifyStatPoolValueEffector_Record;
        ArrayClear(updates);
        effector.StatPoolUpdates(updates);
        for update in updates {
            if registry.HealthPoolUpdatesContains(update.GetID()) {
                registry.InsertPoolValueEffector(effector);
            }
        }
    }
    LogChannel(n"DEBUG", s"completed stat pool value effectors registration");
}

public func BasedOnModifyStatPoolValueEffector(effector: ref<Effector_Record>) -> Bool {
    return Equals(effector.EffectorClassName(), n"ModifyStatPoolValueEffector");
}

public func ScanStatusEffects(registry: ref<Registry>) -> Void {
    let records = TweakDBInterface.GetRecords(n"StatusEffect");
    LogChannel(n"DEBUG", s"scan \(ToString(ArraySize(records))) status effect(s)");
    let status: ref<StatusEffect_Record>;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let effectors: array<wref<Effector_Record>>;
    for record in records {
        status = record as StatusEffect_Record;
        if BasedOnMisc(status) {
            ArrayClear(packages);
            status.Packages(packages);
            LogChannel(n"DEBUG", s"scanning \(ToString(ArraySize(packages))) package(s)...");
            for package in packages {
                if BasedOnEffectorsOrModifiers(package) {
                    ArrayClear(effectors);
                    package.Effectors(effectors);
                    LogChannel(n"DEBUG", s"scanning \(ToString(ArraySize(effectors))) effector(s)...");
                    for effector in effectors {
                        if registry.HealthEffectorsContains(effector.GetID()) {
                            registry.InsertStatusEffect(status);
                        }
                    }
                }
            }
        }
    }
    LogChannel(n"DEBUG", s"completed status effects registration");
}

public func BasedOnMisc(status: ref<StatusEffect_Record>) -> Bool {
    return Equals(status.StatusEffectType().Type(), gamedataStatusEffectType.Misc);
}

public func BasedOnEffectorsOrModifiers(package: ref<GameplayLogicPackage_Record>) -> Bool {
    return package.GetEffectorsCount() > 0 || package.GetStatsCount() > 0;
}

public func BasedOnHealChargeOrConsume(object: ref<ObjectAction_Record>) -> Bool {
    let item = object as ItemAction_Record;
    return IsDefined(item) && (Equals(item.ActionName(), n"UseHealCharge") || Equals(item.ActionName(), n"Consume"));
}

public func ScanConsumables(registry: ref<Registry>) -> Void {
    let records = TweakDBInterface.GetRecords(n"ConsumableItem");
    LogChannel(n"DEBUG", s"scan \(ToString(ArraySize(records))) consumable item(s)");
    let consumable: ref<ConsumableItem_Record>;
    let actions: array<wref<ObjectAction_Record>>;
    let completions: array<wref<ObjectActionEffect_Record>>;
    for record in records {
        consumable = record as ConsumableItem_Record;
        if BasedOnHealer(consumable) {
            consumable.ObjectActions(actions);
            for action in actions {
                if BasedOnHealChargeOrConsume(action) {
                    action.CompletionEffects(completions);
                    for completion in completions {
                        if registry.HealthStatusEffectsContains(completion.StatusEffect().GetID()) {
                            registry.InsertConsumable(consumable);
                        }
                    }
                }
            }
        }
    }
    LogChannel(n"DEBUG", s"completed consumables registration");
}

public func BasedOnMaxDOC(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.FirstAidWhiff);
}

public func BasedOnBounceBack(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.BonesMcCoy70);
}

public func BasedOnHealthBooster(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.HealthBooster);
}

public func BasedOnHealer(consumable: ref<ConsumableItem_Record>) -> Bool {
    return BasedOnMaxDOC(consumable) || BasedOnBounceBack(consumable) || BasedOnHealthBooster(consumable);
}
