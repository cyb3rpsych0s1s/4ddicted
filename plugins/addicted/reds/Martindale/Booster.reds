module Martindale

public func IsOxyBooster(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.OxyBooster);
}

public func IsBooster(consumable: ref<ConsumableItem_Record>) -> Bool {
    let vanilla = IsStaminaBooster(consumable)
    || IsCarryCapacityBooster(consumable)
    || IsMemoryBooster(consumable)
    || IsOxyBooster(consumable);
    let mods = ArrayContains(consumable.Tags(), n"Booster");
    return vanilla || mods;
}