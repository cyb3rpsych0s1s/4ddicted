module Martindale

public func IsCigar(consumable: ref<ConsumableItem_Record>) -> Bool {
    return IsProp(consumable)
    && ArrayContains([
        "cigar",
        "crowd_cigar"], consumable.FriendlyName());
}
public func IsCigarette(consumable: ref<ConsumableItem_Record>) -> Bool {
    return IsProp(consumable)
    && ArrayContains([
        "cigarette_i_stick",
        "locomotion_crowd_cigarette_i_stick",
        "Evelyn's Cigarette Case"], consumable.FriendlyName());
}
