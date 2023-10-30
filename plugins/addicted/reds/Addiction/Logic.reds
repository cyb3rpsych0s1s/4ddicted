module Addicted

public func GetIncreaseFactor(itemID: ItemID) -> Int32 {
    switch (ItemID.GetTDBID(itemID)) {
        case t"Items.BlacklaceV0":
        case t"Items.BlacklaceV1":
            return 2;
        default:
            break;
    }
    return 1;
}

public func GetDecreaseFactor(itemID: ItemID) -> Int32 {
    switch (ItemID.GetTDBID(itemID)) {
        case t"Items.BlacklaceV0":
        case t"Items.BlacklaceV1":
            return 1;
        default:
            break;
    }
    return 2;
}
