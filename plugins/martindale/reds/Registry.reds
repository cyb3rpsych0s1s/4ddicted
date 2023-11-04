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
    public func Scan(consumable: ref<ConsumableItem_Record>) -> ref<Consumable> {
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
        return null;
    }
}

public abstract class Consumables extends Consumable {
    private let items: ref<inkConsumables>;
    public func IsValid(consumable: ref<ConsumableItem_Record>) -> Bool;
    public func Scan(consumable: ref<ConsumableItem_Record>) -> Bool {
        let scanned = super.Scan(consumable);
        if IsDefined(scanned) {
            this.items.Insert(scanned);
            return true;
        }
        return false;
    }
}

public abstract class Category extends Consumables {
    public func Scan(consumable: ref<ConsumableItem_Record>) -> Bool {
        let registries: array<ref<Consumables>>;
        let ty: ref<ReflectionType> = Reflection.GetTypeOf(this);
        let cls: ref<ReflectionClass> = ty.GetInnerType().AsClass();
        let fields: array<ref<ReflectionProp>> = cls.GetProperties();
        for field in fields {
            if field.IsA(n"Martindale.Consumables") {
                ArrayPush(registries, FromVariant(field.GetValue(ToVariant(this))));
            }
        }
        for registry in registries {
            if registry.IsValid(consumable) { return registry.Scan(consumable); }
        }
        return false;
    }
}

public class MaxDOC extends Consumables {
    public func IsValid(consumable: ref<ConsumableItem_Record>) -> Bool {
        return IsMaxDOC(consumable);
    }
}

public class BounceBack extends Consumables {
    public func IsValid(consumable: ref<ConsumableItem_Record>) -> Bool {
        return IsBounceBack(consumable);
    }
}

public class HealthBooster extends Consumables {
    public func IsValid(consumable: ref<ConsumableItem_Record>) -> Bool {
        return IsHealthBooster(consumable);
    }
}

public class Healers extends Category {
    private let maxdocs: ref<MaxDOC>;
    private let bouncebacks: ref<Consumables>;
    private let healthboosters: ref<Consumables>;
    private let medicals: ref<Consumables>;
    public func IsValid(consumable: ref<ConsumableItem_Record>) -> Bool {
        return IsHealer(consumable);
    }
}

public class Anabolics extends Category {
    private let staminaboosters: ref<Consumables>;
    private let carrycapacityboosters: ref<Consumables>;
    public func IsValid(consumable: ref<ConsumableItem_Record>) -> Bool {
        return IsAnabolic(consumable);
    }
}

public class Registry extends IScriptable {
    private let healers: ref<Healers>;
    private let anabolics: ref<Anabolics>;
    public func Scan() -> Void {
        let records = TweakDBInterface.GetRecords(n"ConsumableItem");
        let consumable: ref<ConsumableItem_Record>;
        let found: Bool;
        for record in records {
            consumable = record as ConsumableItem_Record;
            found = false;
            for registry in [this.healers, this.anabolics] {
                if registry.IsValid(consumable) { found = registry.Scan(consumable); break; }
            }
            if !found { /* TODO: keep record in uncategorized map ? */ }
        }
    }
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
