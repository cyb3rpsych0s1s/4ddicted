module Addicted

import Addicted.Consumable

public func GetMinimumSleepRequired(itemID: ItemID) -> Int32 { return 6; }

public func IsSerious(threshold: Threshold) -> Bool {
    return Equals(threshold, Threshold.Notably) || Equals(threshold, Threshold.Severely);
}

public func GetBaseName(itemID: ItemID) -> gamedataConsumableBaseName {
    return GetBaseName(ItemID.GetTDBID(itemID));
}
public func GetBaseName(status: ref<StatusEffect_Record>) -> gamedataConsumableBaseName {
    let name = TDBID.ToStringDEBUG(status.GetID());
    if StrContains(name, "FirstAidWhiff") { return gamedataConsumableBaseName.FirstAidWhiff; }
    if StrContains(name, "BonesMcCoy70") { return gamedataConsumableBaseName.BonesMcCoy70; }
    if StrContains(name, "HealthBooster") { return gamedataConsumableBaseName.HealthBooster; }
    if StrContains(name, "CarryCapacityBooster") { return gamedataConsumableBaseName.CarryCapacityBooster; }
    if StrContains(name, "StaminaBooster") { return gamedataConsumableBaseName.StaminaBooster; }
    if StrContains(name, "MemoryBooster") { return gamedataConsumableBaseName.MemoryBooster; }
    if StrContains(name, "Alcohol") { return gamedataConsumableBaseName.Alcohol; }
    return gamedataConsumableBaseName.Invalid;
}
// WARNING: only for ItemID inner TweakDBID
private func GetBaseName(id: TweakDBID) -> gamedataConsumableBaseName {
    let consumable = TweakDBInterface.GetConsumableItemRecord(id);
    if IsDefined(consumable) { return consumable.ConsumableBaseName().Type(); }
    return gamedataConsumableBaseName.Invalid;
}
// WARNING: only for ItemID inner TweakDBID
private func GetConsumable(id: TweakDBID) -> Consumable {
    let base = GetBaseName(id);
    if NotEquals(base, gamedataConsumableBaseName.Invalid) {
        return GetConsumable(base);
    }
    switch(id) {
        // FIXME
        case t"Items.neuro_blocker":
            return Consumable.NeuroBlocker;
    }
    return Consumable.Invalid;
}

private func GetConsumable(status: ref<StatusEffect_Record>) -> Consumable {
    let base = GetBaseName(status);
    if NotEquals(base, gamedataConsumableBaseName.Invalid) { return GetConsumable(base); }
    let name = TDBID.ToStringDEBUG(status.GetID());
    if StrContains(name, "RipperDocMed") { return Consumable.NeuroBlocker; }
    return Consumable.Invalid;
}

// FIXME: add missing
public func GetConsumables(category: Category) -> array<Consumable> {
    switch (category) {
        case Category.Healers:
            return [Consumable.MaxDOC, Consumable.BounceBack, Consumable.HealthBooster];
        case Category.Neuros:
            return [Consumable.MemoryBooster, Consumable.NeuroBlocker];
        case Category.Anabolics:
            return [Consumable.CarryCapacityBooster, Consumable.StaminaBooster];
        case Category.Alcohol:
            return [Consumable.Alcohol];
    }
    return [];
}

public func GetConsumable(base: gamedataConsumableBaseName) -> Consumable {
    switch(base) {
        case gamedataConsumableBaseName.FirstAidWhiff:
            return Consumable.MaxDOC;
        case gamedataConsumableBaseName.BonesMcCoy70:
            return Consumable.BounceBack;
        case gamedataConsumableBaseName.HealthBooster:
            return Consumable.HealthBooster;
        case gamedataConsumableBaseName.CarryCapacityBooster:
            return Consumable.CarryCapacityBooster;
        case gamedataConsumableBaseName.StaminaBooster:
            return Consumable.StaminaBooster;
        case gamedataConsumableBaseName.MemoryBooster:
            return Consumable.MemoryBooster;
        default:
            break;
    }
    LogChannel(n"ASSERT", s"unknown consumable for base \(ToString(base))");
    return Consumable.Invalid;
}

public func GetGameplayTag(item: ItemID) -> CName {
    return n"None";
}

public func GetStatusEffect(item: ItemID) -> TweakDBID {
    switch (GetConsumable(ItemID.GetTDBID(item))) {
        case Consumable.MaxDOC:
            return t"BaseStatusEffect.AddictToFirstAidWhiff";
        case Consumable.BounceBack:
            return t"BaseStatusEffect.AddictToBonesMcCoy70";
        case Consumable.HealthBooster:
            return t"BaseStatusEffect.AddictToHealthBooster";
        case Consumable.CarryCapacityBooster:
            return t"BaseStatusEffect.AddictToCarryCapacityBooster";
        case Consumable.StaminaBooster:
            return t"BaseStatusEffect.AddictToStaminaBooster";
        case Consumable.MemoryBooster:
            return t"BaseStatusEffect.AddictToMemoryBooster";
        case Consumable.Alcohol:
            return t"BaseStatusEffect.AddictToAlcohol";
        case Consumable.Tobacco:
            return t"BaseStatusEffect.AddictToTobacco";
    }
    return TDBID.None();
}
