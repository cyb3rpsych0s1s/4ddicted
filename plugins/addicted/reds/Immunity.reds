module Addicted

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(itemID: ItemID) -> Void {
    wrappedMethod(itemID);
}

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(equipAreaIndex: Int32, slotIndex: Int32, opt forceRemove: Bool) -> Void {
    wrappedMethod(equipAreaIndex, slotIndex, forceRemove);
}

// no equip counterpart, see above
@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipCyberwareParts(cyberwareData: wref<gameItemData>) -> Void {
    wrappedMethod(cyberwareData);
}
