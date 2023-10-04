module Addicted

import Addicted.System

native func OnUnequipItem(system: ref<System>, data: ref<EquipmentSystemPlayerData>, equipAreaIndex: Int32, slotIndex: Int32, forceRemove: Bool) -> Void;

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(itemID: ItemID) -> Void {
    wrappedMethod(itemID);
}

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(equipAreaIndex: Int32, slotIndex: Int32, opt forceRemove: Bool) -> Void {
    wrappedMethod(equipAreaIndex, slotIndex, forceRemove);
    
    let item: ItemID = this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID;
    let area: gamedataEquipmentArea = EquipmentSystem.GetEquipAreaType(item);
    let cyberware = InventoryDataManagerV2.IsEquipmentAreaCyberware(area);
    let data = RPGManager.GetItemData(this.m_owner.GetGame(), this.m_owner, item);
    if !forceRemove && IsDefined(data) && data.HasTag(n"UnequipBlocked") {
        return;
    };

    // if cyberware {
    //     let id = ItemID.GetTDBID(itemID);
    //     let player = this.m_owner as PlayerPuppet;
    //     if IsDefined(player) && Generic.IsBiomonitor(id) {
    //         let system = AddictedSystem.GetInstance(player.GetGame());
    //         system.OnBiomonitorChanged(false);
    //         return;
    //     }
    //     if IsDefined(player) && Items.IsDetoxifier(id) {
    //         let system = AddictedSystem.GetInstance(player.GetGame());
    //         system.OnDetoxifierChanged(false);
    //         return;
    //     }
    //     if IsDefined(player) && Items.IsMetabolicEditor(id) {
    //         let system = AddictedSystem.GetInstance(player.GetGame());
    //         system.OnMetabolicEditorChanged(false);
    //         return;
    //     }
    // }
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
// @wrapMethod(EquipmentSystemPlayerData)
// private final func UnequipCyberwareParts(cyberwareData: wref<gameItemData>) -> Void {
//     wrappedMethod(cyberwareData);
// }
