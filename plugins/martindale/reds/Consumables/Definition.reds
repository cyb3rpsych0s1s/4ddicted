module Martindale

public func IsFood(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.Edible);
}
public func IsDrink(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.Drinkable);
}
public func IsProp(item: ref<Item_Record>) -> Bool {
    return Equals(item.ItemType().Type(), gamedataItemType.Gen_Misc)
    && ArrayContains(item.Tags(), n"Prop");
}
public func IsDrug(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableType().Type(), gamedataConsumableType.Drug);
}
public func IsAddictive(consumable: ref<ConsumableItem_Record>) -> Bool {
    return IsHealer(consumable)
    || IsAnabolic(consumable)
    || IsNeuro(consumable)
    || IsBlackLace(consumable)
    || IsCigar(consumable)
    || IsCigarette(consumable)
    || IsAlcohol(consumable);
}
