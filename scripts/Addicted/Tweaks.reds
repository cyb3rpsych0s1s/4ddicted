module Addicted

import Codeware.Localization.LocalizationSystem
import Addicted.System.AddictedSystem
import Addicted.Helper
import Addicted.Utils.{E,EI,F}
import Addicted.Helpers.{Bits,Generic,Items,Effect,Translations}

@addField(PlayerStateMachineDef)
public let IsConsuming: BlackboardID_Bool;

@addField(PlayerStateMachineDef)
public let WithdrawalSymptoms: BlackboardID_Uint;

@addField(PlayerPuppet)
public let hideSubtitleCallback: DelayID;

public class HideSubtitleCallback extends DelayCallback {
  private let player: wref<PlayerPuppet>;
  public func Call() -> Void {
    E(s"hide subtitle");
    let game = this.player.GetGame();
    GameInstance
    .GetDelaySystem(game)
    .CancelCallback(this.player.hideSubtitleCallback);
    let board: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UIGameData);
    board.SetVariant(GetAllBlackboardDefs().UIGameData.HideDialogLine, [this.player.ReactionID()], true);
  }
}

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
  return NotEquals(fact, 1);
}

// decrease score on rest
@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    wrappedMethod(evt);
    let system = AddictedSystem.GetInstance(this.GetGame());
    let id = evt.staticData.GetID();
    EI(id, s"status effect applied");

    let board: ref<IBlackboard> = this.GetPlayerStateMachineBlackboard();
    board.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming, false);
    
    if !evt.isAppliedOnSpawn && Effect.IsHousing(id) {
      EI(id, s"housing");
      system.OnRested(id);
    }

    if Generic.IsBlackLace(id) {
      EI(id, s"consumed BlackLace");
      let threshold: Threshold = system.HighestThreshold(Consumable.BlackLace);
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
  let system = EquipmentSystem.GetInstance(this);
  let biomonitors = Helper.Biomonitors();
  for biomonitor in biomonitors {
    if system.IsEquipped(this, ItemID.FromTDBID(biomonitor)) {
      return true;
    }
  }
  return false;
}

@addMethod(PlayerPuppet)
public func HasDetoxifier() -> Bool {
  let system = EquipmentSystem.GetInstance(this);
  return system.IsEquipped(this, ItemID.FromTDBID(t"Items.ToxinCleanser"));
}

@addMethod(PlayerPuppet)
public func HasMetabolicEditor() -> Bool {
  let system = EquipmentSystem.GetInstance(this);
  return system.IsEquipped(this, ItemID.FromTDBID(t"Items.ReverseMetabolicEnhancer"));
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
  let language = localization.GetVoiceLanguage();
  E(s"reacts: voice language (\(NameToString(language)))");
  if !StrBeginsWith(NameToString(language), "en-") { return; }
  let board: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UIGameData);
  let key: String = Translations.SubtitleKey(NameToString(reaction), NameToString(language));
  E(s"reacts: subtitle key (\(key))");
  let subtitle: String = localization.GetSubtitle(key);
  E(s"reacts: subtitle (\(subtitle))");
  if StrLen(key) > 0 && NotEquals(key, subtitle) {
    let duration: Float = 3.0;
    let line: scnDialogLineData;
    line.duration = duration;
    line.id = this.ReactionID();
    line.isPersistent = false;
    line.speaker = this;
    line.speakerName = "V";
    line.text = subtitle;
    line.type = scnDialogLineType.Regular;
    board.SetVariant(GetAllBlackboardDefs().UIGameData.ShowDialogLine, ToVariant([line]), true);
    let callback: ref<HideSubtitleCallback> = new HideSubtitleCallback();
    callback.player = this;
    this.hideSubtitleCallback = GameInstance
    .GetDelaySystem(game)
    .DelayCallback(callback, duration);
  }
  GameObject.PlaySound(this, reaction);
}

@addMethod(PlayerPuppet)
private func ReactionID() -> CRUID { return CreateCRUID(12345ul); }

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
private final func UnequipItem(equipAreaIndex: Int32, opt slotIndex: Int32) -> Void {
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
private final func EquipCyberware(itemData: wref<gameItemData>) -> Void {
  E(s"equip cyberware");
  let itemID: ItemID = itemData.GetID();
  let area: gamedataEquipmentArea = EquipmentSystem.GetEquipAreaType(itemID);
  let cyberware = InventoryDataManagerV2.IsEquipmentAreaCyberware(area);
  wrappedMethod(itemData);
  if cyberware {
    E(s"installed \(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)))");
    let id = ItemID.GetTDBID(itemID);
    if Generic.IsBiomonitor(id) {
      let system = AddictedSystem.GetInstance(this.m_player.GetGame());
      system.OnBiomonitorChanged(true);
      return;
    }
    if Items.IsDetoxifier(id) {
      let system = AddictedSystem.GetInstance(this.m_player.GetGame());
      system.OnDetoxifierChanged(true);
      return;
    }
    if Items.IsMetabolicEditor(id) {
      let system = AddictedSystem.GetInstance(this.m_player.GetGame());
      system.OnMetabolicEditorChanged(true);
      return;
    }
  }
}

@wrapMethod(TimeskipGameController)
private final func Apply() -> Void {
  if this.m_hoursToSkip > 0 {
    let system = AddictedSystem.GetInstance(this.m_gameInstance);
    system.OnSkipTime();
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
    for prefix in prefixes {
      let i = 0;
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
        if cloned {
          let item: ref<TweakDBRecord> = TweakDBInterface.GetRecord(variantItemId);
          let effect: ref<TweakDBRecord> = TweakDBInterface.GetRecord(variantEffectId);
          TweakDBManager.SetFlat(item.GetID() + t".statusEffect", effect.GetID());
          TweakDBManager.UpdateRecord(item.GetID());
        }
        
        i += 1;
      }
    }
  }
}