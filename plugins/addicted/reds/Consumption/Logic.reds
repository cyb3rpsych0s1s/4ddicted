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
    return GetConsumable(GetBaseName(id));
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
