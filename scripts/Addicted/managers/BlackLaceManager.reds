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

  public func ContainsBlackLaceStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>) -> Bool {
    for record in actionEffects {
      if Generic.IsBlackLace(record.GetID()) {
        return true;
      }
    }
    return false;
  }

  public func ContainsNeuroBlockerStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>) -> Bool {
    for record in actionEffects {
      if Generic.IsNeuroBlocker(record.GetID()) {
        return true;
      }
    }
    return false;
  }
}