module Martindale

// public func HasCompletionEffect(action: ref<ObjectAction_Record>) -> Bool {
//     return action.GetCompletionEffectsCount() > 0;
// }

// public func IsValidStatusEffect(status: ref<StatusEffect_Record>) -> Bool {
//     return status.GameplayTagsContains(n"Buff") && status.GetPackagesCount() > 0;
// }

public abstract class Infos extends IScriptable {
    public abstract func IsValidConsumableItem(consumable: ref<ConsumableItem_Record>) -> Bool;
    protected abstract func IsValidObjectActionEffect(action: ref<ObjectAction_Record>) -> Bool;
    protected abstract func IsValidStatusEffect(status: ref<StatusEffect_Record>) -> Bool;
    protected abstract func IsValidGameplayLogicPackage(package: ref<GameplayLogicPackage_Record>) -> Bool;
    protected abstract func IsValidEffector(effector: ref<Effector_Record>) -> Bool;
    protected abstract func IsValidStatModifier(modifier: ref<StatModifier_Record>) -> Bool;
}

public abstract class Consumable extends Infos {
    private let item: ref<ConsumableItem_Record>;
    private let statuses: ref<inkRecords>;
    private let effectors: ref<inkRecords>;
    private let stats: ref<inkRecords>;
    private let updates: ref<inkRecords>;
    public func Scan(consumable: ref<ConsumableItem_Record>) -> Void {
        let actions: array<wref<ObjectAction_Record>>;
        let completions: array<wref<ObjectActionEffect_Record>>;
        let status: ref<StatusEffect_Record>;
        let packages: array<wref<GameplayLogicPackage_Record>>;
        let effectors: array<wref<Effector_Record>>;
        let stats: array<wref<StatModifier_Record>>;
        ArrayClear(actions);
        consumable.ObjectActions(actions);
        for action in actions {
            if this.IsValidObjectActionEffect(action) {
                ArrayClear(completions);
                action.CompletionEffects(completions);
                for completion in completions {
                    status = completion.StatusEffect();
                    if this.IsValidStatusEffect(status) {
                        ArrayClear(packages);
                        status.Packages(packages);
                        for package in packages {
                            if this.IsValidGameplayLogicPackage(package) {
                                ArrayClear(effectors);
                                package.Effectors(effectors);
                                for effector in effectors {
                                    if this.IsValidEffector(effector) {
                                        // TODO ...
                                    }
                                }
                                ArrayClear(stats);
                                package.Stats(stats);
                                for stat in stats {
                                    if this.IsValidStatModifier(stat) {
                                        // TODO ...
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

public abstract class Consumables extends Consumable {
    private let items: ref<inkRecords>;
    public func Scan(consumables: array<ref<ConsumableItem_Record>>) -> Void {
        // let items = new inkRecords();
        for consumable in consumables {
            super.Scan(consumable);
        }
    }
}

public abstract class Category extends Consumables {
    private let consumables: ref<inkRecords>;
    public abstract func AreValidConsumableItems(consumables: array<wref<ConsumableItem_Record>>) -> Bool;
    public func Scan(consumables: array<ref<ConsumableItem_Record>>) -> Void {}
}

private func LogIDs(map: ref<inkHashMap>, title: String) -> Void {
    let values: array<wref<IScriptable>>;
    let record: ref<TweakDBRecord>;
    map.GetValues(values);
    let message: String = title + ":\n";
    let idx = 0;
    for v in values {
        record = v as TweakDBRecord;
        message = message + "\n" + TDBID.ToStringDEBUG(record.GetID());
        idx += 1;
    }
    LogChannel(n"DEBUG", s"\(message)\n-------");
}
