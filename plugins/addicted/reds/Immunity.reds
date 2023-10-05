module Addicted

import Addicted.System

native func OnUnequipItem(system: ref<System>, data: ref<EquipmentSystemPlayerData>, equipAreaIndex: Int32, slotIndex: Int32, forceRemove: Bool) -> Void;

@wrapMethod(RipperDocGameController)
private final func EquipCyberware(itemData: wref<gameItemData>) -> Bool {
    LogChannel(n"DEBUG", s"[RipperDocGameController][EquipCyberware] \(ToString(itemData))");
    return wrappedMethod(itemData);
}

@wrapMethod(RipperDocGameController)
private final func UnequipCyberware(itemData: wref<gameItemData>, opt skipRefresh: Bool) -> Bool {
    LogChannel(n"DEBUG", s"[RipperDocGameController][UnequipCyberware] \(ToString(itemData)) \(ToString(skipRefresh))");
    return wrappedMethod(itemData, skipRefresh);
}

@wrapMethod(EquipmentSystem)
public final func OnUnequipRequest(request: ref<UnequipRequest>) -> Void {
    LogChannel(n"DEBUG", s"[EquipmentSystem][OnUnequipRequest] \(ToString(request))");
    wrappedMethod(request);
}

@wrapMethod(EquipmentSystem)
public final func OnEquipRequest(request: ref<EquipRequest>) -> Void {
    LogChannel(n"DEBUG", s"[EquipmentSystem][OnEquipRequest] \(ToString(request))");
    wrappedMethod(request);
}

@wrapMethod(EquipmentSystem)
public final func OnGameplayEquipRequest(request: ref<GameplayEquipRequest>) -> Void {
    LogChannel(n"DEBUG", s"[EquipmentSystem][OnGameplayEquipRequest] \(ToString(request))");
    wrappedMethod(request);
}

@wrapMethod(EquipmentSystemPlayerData)
public final func EquipItem(itemID: ItemID, opt blockActiveSlotsUpdate: Bool, opt forceEquipWeapon: Bool) -> Void {
    LogChannel(n"DEBUG", s"[EquipmentSystemPlayerData][EquipItem] \(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID))), \(ToString(blockActiveSlotsUpdate)), \(ToString(forceEquipWeapon))");
    wrappedMethod(itemID, blockActiveSlotsUpdate, forceEquipWeapon);
}

@wrapMethod(EquipmentSystemPlayerData)
private final func EquipItem(itemID: ItemID, slotIndex: Int32, opt blockActiveSlotsUpdate: Bool, opt forceEquipWeapon: Bool) -> Void {
    LogChannel(n"DEBUG", s"[EquipmentSystemPlayerData][EquipItem] \(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID))), \(ToString(slotIndex)), \(ToString(blockActiveSlotsUpdate)), \(ToString(forceEquipWeapon))");
    wrappedMethod(itemID, slotIndex, blockActiveSlotsUpdate, forceEquipWeapon);
}

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(itemID: ItemID) -> Void {
    LogChannel(n"DEBUG", s"[EquipmentSystemPlayerData][UnequipItem] \(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)))");
    wrappedMethod(itemID);
}

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(equipAreaIndex: Int32, slotIndex: Int32, opt forceRemove: Bool) -> Void {
    LogChannel(n"DEBUG", s"[EquipmentSystemPlayerData][UnequipItem] \(ToString(equipAreaIndex)), \(ToString(slotIndex)), \(ToString(forceRemove))");
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
@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipCyberwareParts(cyberwareData: wref<gameItemData>) -> Void {
    LogChannel(n"DEBUG", s"[EquipmentSystemPlayerData][UnequipCyberwareParts] \(ToString(cyberwareData))");
    wrappedMethod(cyberwareData);
}

/* 

example on Vik's first meeting:

Basic Kiroshi Optics:
[RipperDocGameController][EquipCyberware]
[EquipmentSystem][OnEquipRequest] [gameEquipRequest]
[EquipmentSystemPlayerData][EquipItem] Items.AdvancedKiroshiOptics_q001_1, 0, false, true
[EquipmentSystemPlayerData][UnequipItem] 19, 0, false

Ballistic Coprocessor:
[RipperDocGameController][EquipCyberware]
[EquipmentSystem][OnEquipRequest] [gameEquipRequest]
[EquipmentSystemPlayerData][EquipItem] Items.AdvancedPowerGrip_q001_1, 0, false, true
[EquipmentSystemPlayerData][UnequipItem] 26, 0, false

Subdermal Armor:
[RipperDocGameController][EquipCyberware] 
[EquipmentSystem][OnEquipRequest] [gameEquipRequest]
[EquipmentSystemPlayerData][EquipItem] Items.AdvancedBoringPlating_Q001, 0, false, true
[EquipmentSystemPlayerData][UnequipItem] 25, 0, false

Subdermal Armor: Upgrade to Tier 1+
[EquipmentSystemPlayerData][UnequipItem] 25, 0, false
[EquipmentSystemPlayerData][UnequipCyberwareParts] 
[EquipmentSystemPlayerData][EquipItem] Items.AdvancedBoringPlatingCommonPlus, 0, false, false
[EquipmentSystemPlayerData][UnequipItem] 25, 0, false

Threatevac:
[RipperDocGameController][EquipCyberware] 
[EquipmentSystem][OnEquipRequest] [gameEquipRequest]
[EquipmentSystemPlayerData][EquipItem] Items.AdvancedCatchMeIfYouCanCommon, 0, false, true
[EquipmentSystemPlayerData][UnequipItem] 23, 0, false

*/
