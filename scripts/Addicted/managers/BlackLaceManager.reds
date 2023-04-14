module Addicted.Manager

import Addicted.*
import Addicted.Utils.*
import Addicted.Helpers.{Bits,Effect,Generic}

public class BlackLaceManager extends WithdrawalSymptomsManager {

  private let withdrawing: Bool;

  public func Register(player: ref<PlayerPuppet>) -> Void {
    E(s"register black lace manager");
    super.Register(player);
  }

  public func Unregister(player: ref<PlayerPuppet>) -> Void {
    E(s"unregister black lace manager");
    super.Unregister(player);
  }

  protected func UpdateSymptoms(symptoms: Uint32) -> Bool {
    let blacklace = Bits.Has(symptoms, EnumInt(Consumable.BlackLace));
    E(s"update black lace symptom: current (\(this.withdrawing)) incoming (\(blacklace))");
    let invalidate: Bool = false;

    if NotEquals(blacklace, this.withdrawing) {
      this.withdrawing = blacklace;
      invalidate = true;
    }

    return invalidate;
  }

  protected func InvalidateState() -> Void {
    E(s"invalidate black lace manager state");
    
    let applicables = [
      t"BaseStatusEffect.NotablyWithdrawnFromBlackLace",
      t"BaseStatusEffect.SeverelyWithdrawnFromBlackLace"
    ];

    let applied: array<ref<StatusEffect>>;
    StatusEffectHelper.GetAppliedEffectsWithTag(this.owner, n"WithdrawalSymptom", applied);

    this.Invalidate(Consumable.BlackLace, this.withdrawing, applied, applicables);
  }

  /// append status effect to existing one(s)
  /// this is because actionEffects are immutable
  protected func AlterBlackLaceStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>) -> array<wref<ObjectActionEffect_Record>> {
    let insanity = TweakDBInterface.GetObjectActionEffectRecord(t"Items.BlacklaceInsanityObjectActionEffect");
    let depot = GameInstance.GetResourceDepot();
    let edgerunner = depot.ArchiveExists("WannabeEdgerunner.archive");
    if !IsDefined(insanity) { F(s"could not find Items.BlacklaceInsanityObjectActionEffect"); }
    else {
      if edgerunner && !ArrayContains(actionEffects, insanity) {
        E(s"about to grow action effects array...");
        ArrayGrow(actionEffects, 1);
        ArrayInsert(actionEffects, ArraySize(actionEffects) -1, insanity);
        E(s"add insanity object action effect record to blacklace's existing one(s)");
      }
    }
    return actionEffects;
  }

  public func ContainsBlackLaceStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>) -> Bool {
    for record in actionEffects {
      if Generic.IsBlackLace(record.GetID()) {
        return true;
      }
    }
    return false;
  }

  public func ContainsNeuroBlockerStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>) -> Bool {
    let neuroblockers = [
      t"BaseStatusEffect.RipperDocMedBuff",
      t"BaseStatusEffect.RipperDocMedBuffUncommon",
      t"BaseStatusEffect.RipperDocMedBuffCommon"
    ];
    for record in actionEffects {
      if ArrayContains(neuroblockers, record.GetID()) {
        return true;
      }
    }
    return false;
  }
}