module Martindale

public func IsFood(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.Edible);
}
public func IsDrink(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.Drinkable);
}
public func IsProp(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ItemType().Type(), gamedataItemType.Gen_Misc)
    && ArrayContains(consumable.Tags(), n"Prop");
}
public func IsDrug(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableType().Type(), gamedataConsumableType.Drug);
}
public func IsAddictive(consumable: ref<ConsumableItem_Record>) -> Bool {
    return !ArrayContains(consumable.Tags(), n"NonAddictive")
    && (
        IsHealer(consumable)
        || IsAnabolic(consumable)
        || IsNeuro(consumable)
        || IsBlackLace(consumable)
        || IsCigar(consumable)
        || IsCigarette(consumable)
        || IsAlcohol(consumable));
}
