module Addicted

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(itemID: ItemID) -> Void {
    wrappedMethod(itemID);
}

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(equipAreaIndex: Int32, slotIndex: Int32, opt forceRemove: Bool) -> Void {
    wrappedMethod(equipAreaIndex, slotIndex, forceRemove);
}

@wrapMethod(EquipmentSystemPlayerData)
public final func EquipItem(itemID: ItemID, opt blockActiveSlotsUpdate: Bool, opt forceEquipWeapon: Bool) -> Void {
    wrappedMethod(itemID, blockActiveSlotsUpdate, forceEquipWeapon);
}

@wrapMethod(EquipmentSystemPlayerData)
private final func EquipItem(itemID: ItemID, slotIndex: Int32, opt blockActiveSlotsUpdate: Bool, opt forceEquipWeapon: Bool) -> Void {
    wrappedMethod(itemID, slotIndex, blockActiveSlotsUpdate, forceEquipWeapon);
}

// no equip counterpart, see above
@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipCyberwareParts(cyberwareData: wref<gameItemData>) -> Void {
    wrappedMethod(cyberwareData);
}
