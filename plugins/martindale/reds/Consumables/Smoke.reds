module Martindale

public func IsCigar(item: ref<Item_Record>) -> Bool {
    return IsProp(item)
    && ArrayContains([
        "cigar",
        "crowd_cigar"], item.FriendlyName());
}
public func IsCigarette(item: ref<Item_Record>) -> Bool {
    return IsProp(item)
    && ArrayContains([
        "cigarette_i_stick",
        "locomotion_crowd_cigarette_i_stick",
        "Evelyn's Cigarette Case"], item.FriendlyName());
}
