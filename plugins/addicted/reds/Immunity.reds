module Addicted

import Addicted.System

native func OnUnequipItem(system: ref<System>, data: ref<EquipmentSystemPlayerData>, equipAreaIndex: Int32, slotIndex: Int32, forceRemove: Bool) -> Void;

@wrapMethod(RipperDocGameController)
private final func EquipCyberware(itemData: wref<gameItemData>) -> Bool {
    return wrappedMethod(itemData);
}

@wrapMethod(RipperDocGameController)
private final func UnequipCyberware(itemData: wref<gameItemData>, opt skipRefresh: Bool) -> Bool {
    return wrappedMethod(itemData, skipRefresh);
}

@wrapMethod(EquipmentSystem)
public final func OnUnequipRequest(request: ref<UnequipRequest>) -> Void {
    wrappedMethod(request);
}

@wrapMethod(EquipmentSystem)
public final func OnEquipRequest(request: ref<EquipRequest>) -> Void {
    wrappedMethod(request);
}

@wrapMethod(EquipmentSystem)
public final func OnGameplayEquipRequest(request: ref<GameplayEquipRequest>) -> Void {
    wrappedMethod(request);
}

@wrapMethod(EquipmentSystemPlayerData)
public final func EquipItem(itemID: ItemID, opt blockActiveSlotsUpdate: Bool, opt forceEquipWeapon: Bool) -> Void {
    wrappedMethod(itemID, blockActiveSlotsUpdate, forceEquipWeapon);
}

@wrapMethod(EquipmentSystemPlayerData)
private final func EquipItem(itemID: ItemID, slotIndex: Int32, opt blockActiveSlotsUpdate: Bool, opt forceEquipWeapon: Bool) -> Void {
    wrappedMethod(itemID, slotIndex, blockActiveSlotsUpdate, forceEquipWeapon);
}

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(itemID: ItemID) -> Void {
    wrappedMethod(itemID);
}

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(equipAreaIndex: Int32, slotIndex: Int32, opt forceRemove: Bool) -> Void {
    wrappedMethod(equipAreaIndex, slotIndex, forceRemove);
    
    let system = System.GetInstance(this.m_owner.GetGame());
    OnUnequipItem(system, this, equipAreaIndex, slotIndex, forceRemove);

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

// no equip counterpart, see above
// @wrapMethod(EquipmentSystemPlayerData)
// private final func UnequipCyberwareParts(cyberwareData: wref<gameItemData>) -> Void {
//     wrappedMethod(cyberwareData);
// }
