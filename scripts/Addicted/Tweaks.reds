module Addicted

import Codeware.Localization.LocalizationSystem
import Addicted.System.AddictedSystem
import Addicted.Helper
import Addicted.Utils.{E,EI,F}
import Addicted.Helpers.{Bits,Generic,Items,Effect,Translations}
import Addicted.Crossover.{AlterBlackLaceStatusEffects,AlterNeuroBlockerStatusEffects}
import Addicted.System.CheckWarnCallback

@addField(PlayerStateMachineDef)
public let IsConsuming: BlackboardID_Bool;

@addField(PlayerStateMachineDef)
public let WithdrawalSymptoms: BlackboardID_Uint;

@addMethod(PlayerPuppet)
public func IsPossessed() -> Bool {
  let system: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGame());
  let possessed: Bool = Cast<Bool>(system.GetFactStr("isPlayerPossessedByJohnny"));
  let replacer: Bool = this.GetRecordID() == t"Character.johnny_replacer";
  return replacer || possessed;
}

@addMethod(PlayerPuppet)
public func PastPrologue() -> Bool {
  let system: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGame());
  let fact: Int32 = system.GetFact(n"watson_prolog_unlock");
  return NotEquals(fact, 0);
}

// decrease score on rest
@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    wrappedMethod(evt);
    let system = AddictedSystem.GetInstance(this.GetGame());
    let id = evt.staticData.GetID();
    // EI(id, s"status effect applied");

    let board: ref<IBlackboard> = this.GetPlayerStateMachineBlackboard();
    board.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming, false);
    
    if !evt.isAppliedOnSpawn && Effect.IsHousing(id) {
      EI(id, s"housing");
      system.OnRested(id);
    }

    if Generic.IsBlackLace(id) {
      EI(id, s"consumed BlackLace");
      let threshold: Threshold = system.Threshold(Consumable.BlackLace);
      let insanity = StatusEffectHelper.GetStatusEffectByID(this, t"BaseStatusEffect.Insanity");
      E(s"is defined insanity: \(IsDefined(insanity))");
      E(s"insanity: \(TDBID.ToStringDEBUG(insanity.GetRecord().GetID()))");
      let count: Int32 = IsDefined(insanity) ? Cast<Int32>(insanity.GetStackCount()) : 0;
      this.HandleHumanityPenalty(count, threshold);
    }
}

// play hints on dissipation
@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    let system = AddictedSystem.GetInstance(this.GetGame());
    let id = evt.staticData.GetID();
    EI(id, s"status effect removed");

    if evt.IsAddictive() {
      EI(id, s"addictive substance dissipated");
      system.OnDissipated(id);
    }

    // when V get out of Ripperdoc's chair
    if Equals(id, t"BaseStatusEffect.CyberwareInstallationAnimation") {
      // if just equipped, trigger warning since V might be already addicted
      // and didn't have a chance previously to get warned about

      // a slight delay is required also to get out of the animation
      // and avoid the UI disappearing briefly from screen
      let callback = new CheckWarnCallback();
      callback.system = system;
      GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(callback, 2.5, true);
    }

    return wrappedMethod(evt);
}

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
  wrappedMethod(action, consumer);
  let pressed = Equals(EnumInt(ListenerAction.GetType(action)), EnumInt(gameinputActionType.BUTTON_PRESSED));
  let chosen = Equals(ListenerAction.GetName(action), n"Choice1_Release");
  if pressed && chosen {
    E(s"pressed F to dismiss biomonitor");
    let system = AddictedSystem.GetInstance(this.GetGame());
    system.DismissBiomonitor();
  }
}

@addMethod(PlayerPuppet)
public func HasBiomonitor() -> Bool {
  let data: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(this);
  let biomonitors: array<TweakDBID> = Helper.Biomonitors();
  let item: ItemID;
  let equipped: Bool;
  for biomonitor in biomonitors {
    item = ItemID.CreateQuery(biomonitor);
    equipped = data.IsEquipped(item);
    E(s"\(TDBID.ToStringDEBUG(biomonitor)): equipped -> \(ToString(equipped))");
    if equipped {
      return true;
    }
  }
  return false;
}

@addMethod(PlayerPuppet)
public func HasDetoxifier() -> Bool {
  let data: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(this);
  let detox = ItemID.CreateQuery(t"Items.ToxinCleanser");
  let equipped = data.IsEquipped(detox);
  return equipped;
}

@addMethod(PlayerPuppet)
public func HasMetabolicEditor() -> Bool {
  let data: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(this);
  let editor = ItemID.CreateQuery(t"Items.ReverseMetabolicEnhancer");
  let equipped = data.IsEquipped(editor);
  return equipped;
}

@addMethod(PlayerPuppet)
public func CyberwareImmunity() -> Int32 {
  let resilience = 0;
  if this.HasMetabolicEditor() { resilience += 4; }
  if this.HasDetoxifier() { resilience += 2; }
  return resilience;
}

@addMethod(PlayerPuppet)
public func IsWithdrawing(consumable: Consumable) -> Bool {
  let blackboard: ref<IBlackboard> = this.GetPlayerStateMachineBlackboard();
  let symptoms = blackboard.GetUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms);
  return Bits.Has(symptoms, EnumInt(consumable));
}

@addMethod(PlayerPuppet)
public func Threshold(consumable: Consumable) -> Threshold {
  let system = AddictedSystem.GetInstance(this.GetGame());
  return system.Threshold(consumable);
}

@addMethod(PlayerPuppet)
public func Reacts(reaction: CName) -> Void {
  E(s"reacts: reaction (\(NameToString(reaction)))");
  if !IsNameValid(reaction) { return; }
  let game = this.GetGame();
  let localization = LocalizationSystem.GetInstance(game);
  let spoken = localization.GetVoiceLanguage();
  E(s"reacts: voice language (\(NameToString(spoken)))");
  // if spoken language is not available, abort
  if !IsLanguageSupported(spoken) { return; }
  GameInstance.GetAudioSystem(this.GetGame()).Play(reaction, this.GetEntityID(), n"V");
}

/// replace existing status effect with modified one
/// ObjectActionEffect_Record are immutable but actionEffects can be swapped
private func AlterStatusEffects(const actionEffects: script_ref<array<wref<ObjectActionEffect_Record>>>, gameInstance: GameInstance) -> Void {
  let system = AddictedSystem.GetInstance(gameInstance);
  let altered: ref<ObjectActionEffect_Record>;
  let consumable: Consumable;
  let addiction: Addiction;
  let threshold: Threshold = Threshold.Clean;
  let others: Threshold;
  let i: Int32 = 0;
  while i < ArraySize(Deref(actionEffects)) {
      E(s"effect ID: \(TDBID.ToStringDEBUG(Deref(actionEffects)[i].GetID()))");
      consumable = Generic.Consumable(Deref(actionEffects)[i].GetID());
      addiction = Generic.Addiction(consumable);
      if Equals(addiction, Addiction.Healers) {
        threshold = system.Threshold(consumable);
        others = system.Threshold(addiction);
        if EnumInt(threshold) < EnumInt(others) {
          threshold = others;
        }
        if Equals(threshold, Threshold.Notably)       { altered = TweakDBInterface.GetObjectActionEffectRecord(Deref(actionEffects)[i].GetID() + t"_notably_weakened");  }
        else if Equals(threshold, Threshold.Severely) { altered = TweakDBInterface.GetObjectActionEffectRecord(Deref(actionEffects)[i].GetID() + t"_severely_weakened"); }
        
        if IsDefined(altered) { Deref(actionEffects)[i] = altered; }
        else if Helper.IsSerious(threshold) {
          F(s"unknown weakened variant for \(TDBID.ToStringDEBUG(Deref(actionEffects)[i].GetID()))");
        }
      } else if Equals(consumable, Consumable.BlackLace) {
        threshold = system.Threshold(consumable);
        if Helper.IsSerious(threshold) {
          AlterBlackLaceStatusEffects(actionEffects, gameInstance);
        }
      } else if Equals(consumable, Consumable.NeuroBlocker) {
        threshold = system.Threshold(consumable);
        if Helper.IsSerious(threshold) {
          AlterNeuroBlockerStatusEffects(actionEffects, gameInstance);
        }
      }
      i += 1;
  }
}

@wrapMethod(UseHealChargeAction)
protected func ProcessStatusEffects(const actionEffects: script_ref<array<wref<ObjectActionEffect_Record>>>, gameInstance: GameInstance) -> Void {
    E("on UseHealChargeAction.ProcessStatusEffects");
    AlterStatusEffects(actionEffects, gameInstance);
    wrappedMethod(actionEffects, gameInstance);
}

@wrapMethod(ConsumeAction)
protected func ProcessStatusEffects(const actionEffects: script_ref<array<wref<ObjectActionEffect_Record>>>, gameInstance: GameInstance) -> Void {
    E("on ConsumeAction.ProcessStatusEffects");
    AlterStatusEffects(actionEffects, gameInstance);
    wrappedMethod(actionEffects, gameInstance);
}

@wrapMethod(ConsumeAction)
public func CompleteAction(gameInstance: GameInstance) -> Void {
  E(s"complete action");
  wrappedMethod(gameInstance);
}

@wrapMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool) -> Bool {
  E(s"process item action");
  let actionUsed: Bool = wrappedMethod(gi, executor, itemData, actionID, fromInventory);
  let system: ref<AddictedSystem>;
  let itemID: ItemID;
  if actionUsed {
    system = AddictedSystem.GetInstance(gi);
    itemID = itemData.GetID();
    system.OnConsumeItem(itemID);
  }
  return actionUsed;
}

@wrapMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool, quantity: Int32) -> Bool {
  E(s"process item action (x\(ToString(quantity)))");
  let actionUsed = wrappedMethod(gi, executor, itemData, actionID, fromInventory, quantity);
  let system: ref<AddictedSystem>;
  let itemID: ItemID;
  let i: Int32;
  if actionUsed && quantity >= 1 {
    system = AddictedSystem.GetInstance(gi);
    itemID = itemData.GetID();
    i = quantity;
    while i > 0 {
      system.OnConsumeItem(itemID);
      i -= 1;
    }
  }
  return actionUsed;
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
  return Generic.IsAddictive(id);
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
    if IsDefined(player) && Generic.IsBiomonitor(id) {
      let system = AddictedSystem.GetInstance(player.GetGame());
      system.OnBiomonitorChanged(false);
      return;
    }
    if IsDefined(player) && Items.IsDetoxifier(id) {
      let system = AddictedSystem.GetInstance(player.GetGame());
      system.OnDetoxifierChanged(false);
      return;
    }
    if IsDefined(player) && Items.IsMetabolicEditor(id) {
      let system = AddictedSystem.GetInstance(player.GetGame());
      system.OnMetabolicEditorChanged(false);
      return;
    }
  }
}

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(equipAreaIndex: Int32, opt slotIndex: Int32, opt forceRemove: Bool) -> Void {
  let itemID: ItemID = this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID;
  let area: gamedataEquipmentArea = EquipmentSystem.GetEquipAreaType(itemID);
  let cyberware = InventoryDataManagerV2.IsEquipmentAreaCyberware(area);
  wrappedMethod(equipAreaIndex, slotIndex);
  if cyberware {
    E(s"uninstalled by index(es) \(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)))");
    let id = ItemID.GetTDBID(itemID);
    let player = this.m_owner as PlayerPuppet;
    if IsDefined(player) && Generic.IsBiomonitor(id) {
      let system = AddictedSystem.GetInstance(player.GetGame());
      system.OnBiomonitorChanged(false);
      return;
    }
    if IsDefined(player) && Items.IsDetoxifier(id) {
      let system = AddictedSystem.GetInstance(player.GetGame());
      system.OnDetoxifierChanged(false);
      return;
    }
    if IsDefined(player) && Items.IsMetabolicEditor(id) {
      let system = AddictedSystem.GetInstance(player.GetGame());
      system.OnMetabolicEditorChanged(false);
      return;
    }
  }
}

@wrapMethod(RipperDocGameController)
private final func EquipCyberware(itemData: wref<gameItemData>) -> Bool {
  E(s"equip cyberware");
  let itemID: ItemID = itemData.GetID();
  let area: gamedataEquipmentArea = EquipmentSystem.GetEquipAreaType(itemID);
  let cyberware = InventoryDataManagerV2.IsEquipmentAreaCyberware(area);
  let equipped = wrappedMethod(itemData);
  if cyberware && equipped {
    E(s"installed \(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)))");
    let id = ItemID.GetTDBID(itemID);
    if Generic.IsBiomonitor(id) {
      let system = AddictedSystem.GetInstance(this.m_player.GetGame());
      system.OnBiomonitorChanged(true);
    }
    if Items.IsDetoxifier(id) {
      let system = AddictedSystem.GetInstance(this.m_player.GetGame());
      system.OnDetoxifierChanged(true);
    }
    if Items.IsMetabolicEditor(id) {
      let system = AddictedSystem.GetInstance(this.m_player.GetGame());
      system.OnMetabolicEditorChanged(true);
    }
  }
  return equipped;
}

@wrapMethod(TimeskipGameController)
private final func Apply() -> Void {
  if this.m_hoursToSkip > 0 {
    let system = AddictedSystem.GetInstance(this.m_gameInstance);
    system.OnSkipTime();
  }
  wrappedMethod();
}
