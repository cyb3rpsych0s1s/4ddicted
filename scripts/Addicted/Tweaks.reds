module Addicted

import Addicted.System.AddictedSystem
import Addicted.Helper
import Addicted.Utils.{E,EI,F}

// decrease score on rest
@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    wrappedMethod(evt);
    let system = AddictedSystem.GetInstance(this.GetGame());
    let id = evt.staticData.GetID();
    EI(id, s"status effect applied");

    let board: ref<IBlackboard> = this.GetPlayerStateMachineBlackboard();
    board.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming, false);
    
    if !evt.isAppliedOnSpawn && Helper.IsHousing(id) {
      EI(id, s"housing");
      system.OnRested(id);
    }
}

// play hints on dissipation
@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    let system = AddictedSystem.GetInstance(this.GetGame());

    let id = evt.staticData.GetID();
    if evt.IsAddictive() {
      EI(id, s"addictive substance dissipated");
      system.OnDissipated(id);
    }
    return wrappedMethod(evt);
}

@addMethod(PlayerPuppet)
public func HasBiomonitor() -> Bool {
  let system = EquipmentSystem.GetInstance(this);
  let biomonitors = Helper.Biomonitors();
  for biomonitor in biomonitors {
    if system.IsEquipped(this, ItemID.FromTDBID(biomonitor)) {
      return true;
    }
  }
  return false;
}

// alter some effects based on addiction threshold
@wrapMethod(ConsumeAction)
protected func ProcessStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>, gameInstance: GameInstance) -> Void {
  let system = AddictedSystem.GetInstance(gameInstance);
  let effects = system.OnProcessStatusEffects(actionEffects);
  wrappedMethod(effects, gameInstance);
}

@wrapMethod(ConsumeAction)
public func CompleteAction(gameInstance: GameInstance) -> Void {
  E(s"complete action");
  wrappedMethod(gameInstance);
}

// increase score on consumption (catch direct consumption from quick slot)
@wrapMethod(ItemActionsHelper)
public final static func ConsumeItem(executor: wref<GameObject>, itemID: ItemID, fromInventory: Bool) -> Void {
  E(s"top level consume item");
  let player = executor as PlayerPuppet;
  E(s"is defined player ? \(ToString(IsDefined(player)))");
  if IsDefined(player) {
    let board: ref<IBlackboard> = player.GetPlayerStateMachineBlackboard();
    board.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming, true);
    let system = AddictedSystem.GetInstance(executor.GetGame());
    system.OnConsumeItem(itemID);
  } else { E(s"undefined player (consume item)"); }

  wrappedMethod(executor, itemID, fromInventory);
}

// increase score on consumption (catch interaction in backpack)
@wrapMethod(ItemActionsHelper)
public final static func PerformItemAction(executor: wref<GameObject>, itemID: ItemID) -> Void {
  let system = AddictedSystem.GetInstance(executor.GetGame());
  system.OnConsumeItem(itemID);

  wrappedMethod(executor, itemID);
}

@addMethod(StatusEffectEvent)
public func IsAddictive() -> Bool {
  let id = this.staticData.GetID();
  return Helper.IsAddictive(id);
}

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(itemID: ItemID) -> Void {
  let area: gamedataEquipmentArea = EquipmentSystem.GetEquipAreaType(itemID);
  let cyberware = InventoryDataManagerV2.IsEquipmentAreaCyberware(area);
  wrappedMethod(itemID);
  if cyberware {
    E(s"uninstalled by item id \(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)))");
    let id = ItemID.GetTDBID(itemID);
    let player = this.m_owner as PlayerPuppet;
    if IsDefined(player) && Helper.IsBiomonitor(id) {
      let system = AddictedSystem.GetInstance(player.GetGame());
      system.OnBiomonitorChanged(false);
    }
  }
}

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(equipAreaIndex: Int32, opt slotIndex: Int32) -> Void {
  let itemID: ItemID = this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID;
  let area: gamedataEquipmentArea = EquipmentSystem.GetEquipAreaType(itemID);
  let cyberware = InventoryDataManagerV2.IsEquipmentAreaCyberware(area);
  wrappedMethod(equipAreaIndex, slotIndex);
  if cyberware {
    E(s"uninstalled by index(es) \(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)))");
    let id = ItemID.GetTDBID(itemID);
    let player = this.m_owner as PlayerPuppet;
    if IsDefined(player) && Helper.IsBiomonitor(id) {
      let system = AddictedSystem.GetInstance(player.GetGame());
      system.OnBiomonitorChanged(false);
    }
  }
}

@wrapMethod(RipperDocGameController)
private final func EquipCyberware(itemData: wref<gameItemData>) -> Void {
  E(s"equip cyberware");
  let itemID: ItemID = itemData.GetID();
  let area: gamedataEquipmentArea = EquipmentSystem.GetEquipAreaType(itemID);
  let cyberware = InventoryDataManagerV2.IsEquipmentAreaCyberware(area);
  wrappedMethod(itemData);
  if cyberware {
    E(s"installed \(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)))");
    let id = ItemID.GetTDBID(itemID);
    if Helper.IsBiomonitor(id) {
      let system = AddictedSystem.GetInstance(this.m_player.GetGame());
      system.OnBiomonitorChanged(true);
    }
  }
}

@addField(PlayerStateMachineDef)
public let IsInDialogue: BlackboardID_Bool;

@addField(PlayerStateMachineDef)
public let IsConsuming: BlackboardID_Bool;

@addMethod(PlayerPuppet)
public func CanPlayOnomatopea() -> Bool {
  let board: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()) as IBlackboard;
  let swimming = board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming);
  let diving = Equals(swimming, EnumInt(gamePSMSwimming.Diving));
  if diving {
    E(s"can only play ambient onomatopea: currently diving");
    return false;
  }
  let scene = GameInstance.GetSceneSystem(this.GetGame());
  let interface = scene.GetScriptInterface();
  let chatting = interface.IsEntityInDialogue(this.GetEntityID());
  if chatting {
    E(s"cannot play onomatopea: currently chatting");
    return false;
  }
  return true;
}

@wrapMethod(TimeskipGameController)
private final func Apply() -> Void {
  if this.m_hoursToSkip > 0 {
    let system = AddictedSystem.GetInstance(this.m_gameInstance);
    system.restingSince = this.m_timeSystem.GetGameTimeStamp();
  }
  wrappedMethod();
}

// object action effects
//
// reduce boilerplate in YAML Tweaks
public class HealerTweaks extends ScriptableTweak {
  protected cb func OnApply() -> Void {
    let notably   = "NotablyWeakened";
    let severely  = "SeverelyWeakened";
    let prefixes  = [notably, severely];

    let maxdoc        = "FirstAidWhiff";
    let bounceback    = "BonesMcCoy70";
    let healthbooster = "HealthBooster";

    this.Derive(prefixes, maxdoc,       ["_inline2", "_inline6", "_inline6"]);
    this.Derive(prefixes, bounceback,   ["_inline2", "_inline2", "_inline6"]);
    this.Derive(prefixes, healthbooster,["_inline1"]);
  }

  // create object action effect for weakened healers :
  // e.g. Items.NotablyWeakenedActionEffectFirstAidWhiffV0 from Items.FirstAidWhiffV0_inline2
  // with status effect set as BaseStatusEffect.NotablyWeakenedFirstAidWhiffV0
  private func Derive(prefixes: array<String>, diminutive: String, versions: array<String>) -> Void {
    let size: Int32 = ArraySize(versions);
    let many = size > 1;
    let name: String;
    let suffix: String;
    let i = 0;
    for prefix in prefixes {
      for version in versions {
        if many {
          // consumables with versions, e.g. FirstAidWhiff
          name = diminutive + "V" + ToString(i);
          suffix = version;
        } else {
          // consumables without version, e.g. HealthBooster
          name = diminutive;
          suffix = "";
        }

        let original: String      = name + suffix;
        let variantItem: String   = prefix + "ActionEffect" + name;
        let variantEffect: String = prefix + name;

        let originalItemId: TweakDBID   = TDBID.Create(("Items." + original));

        let variantItemName: CName      = StringToName(("Items." + variantItem));
        let variantItemId: TweakDBID    = TDBID.Create(("Items." + variantItem));
        let variantEffectId: TweakDBID  = TDBID.Create("BaseStatusEffect." + variantEffect);

        let cloned = TweakDBManager.CloneRecord(variantItemName, originalItemId);
        if !cloned {
          F(s"unable to clone \(TDBID.ToStringDEBUG(originalItemId)) as \(NameToString(variantItemName))");
          return;
        }

        let item: ref<TweakDBRecord> = TweakDBInterface.GetRecord(variantItemId);
        let effect: ref<TweakDBRecord> = TweakDBInterface.GetRecord(variantEffectId);
        TweakDBManager.SetFlat(item.GetID() + t".statusEffect", effect.GetID());
        TweakDBManager.UpdateRecord(item.GetID());

        i += 1;
      }
    }
  }
}
