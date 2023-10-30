module Addicted

public func GetMinimumSleepRequired(itemID: ItemID) -> Int32 { return 6; }

public func GetBaseName(itemID: ItemID) -> gamedataConsumableBaseName {
    return GetBaseName(ItemID.GetTDBID(itemID));
}

private func GetBaseName(id: TweakDBID) -> gamedataConsumableBaseName {
    let consumable = TweakDBInterface.GetConsumableItemRecord(id);
    if IsDefined(consumable) { return consumable.ConsumableBaseName().Type(); }
    return gamedataConsumableBaseName.Invalid;
}

private func GetConsumable(id: TweakDBID) -> Consumable {
    let base = GetBaseName(id);
    if NotEquals(base, gamedataConsumableBaseName.Invalid) {
        return GetConsumable(base);
    }
    switch(id) {
        case t"Items.neuro_blocker":
            return Consumable.NeuroBlocker;
    }
    return Consumable.Invalid;
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
    }
    LogChannel(n"ASSERT", s"unknown consumable for base \(ToString(base))");
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
