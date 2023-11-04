module Martindale

public func IsInhaler(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ItemType().Type(), gamedataItemType.Con_Inhaler);
}
public func IsInjector(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ItemType().Type(), gamedataItemType.Con_Injector);
}
public func IsPill(consumable: ref<ConsumableItem_Record>) -> Bool {
    let vanilla = Equals(consumable.ItemType().Type(), gamedataItemType.Con_LongLasting); // && well known
    let mods = Equals(consumable.ItemType().Type(), gamedataItemType.Invalid) && Equals(consumable.ItemType().Name(), n"Con_Pill");
    return vanilla || mods;
}
public func IsKit(consumable: ref<ConsumableItem_Record>) -> Bool {
    let vanilla = Equals(consumable.ItemType().Type(), gamedataItemType.Con_LongLasting); // && well known
    let mods = Equals(consumable.ItemType().Type(), gamedataItemType.Invalid)
    && Equals(consumable.ItemType().Name(), n"Con_Kit");
    return vanilla || mods;
}
public func IsEdible(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ItemType().Type(), gamedataItemType.Con_Edible);
}