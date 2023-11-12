module Martindale

public func IsStaminaBooster(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.StaminaBooster);
}
public func IsCarryCapacityBooster(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.CarryCapacityBooster);
}

public func IsAnabolic(consumable: ref<ConsumableItem_Record>) -> Bool {
    let vanilla = IsStaminaBooster(consumable)
    || IsCarryCapacityBooster(consumable);
    let mods = Equals(consumable.ConsumableType().Type(), gamedataConsumableType.Invalid)
    && Equals(consumable.ConsumableType().EnumName(), n"Anabolic");
    return vanilla || mods;
}