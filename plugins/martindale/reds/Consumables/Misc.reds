module Martindale

public func IsBlackLace(consumable: ref<ConsumableItem_Record>) -> Bool {
    let vanilla = ArrayContains(
        [t"Items.BlackLaceV0", t"Items.BlackLaceV1"],
        consumable.GetID());
    let mods = Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.Invalid)
    && Equals(consumable.ConsumableBaseName().EnumName(), n"BlackLace");
    return vanilla || mods;
}
