module Addicted.Manager

import Addicted.*
import Addicted.Utils.*
import Addicted.Helpers.{Bits,Effect}

public class AlcoholManager extends WithdrawalSymptomsManager {

  private let withdrawingFromAlcohol: Bool;

  public func Register(player: ref<PlayerPuppet>) -> Void {
    E(s"register alcohols manager");
    super.Register(player);
  }

  public func Unregister(player: ref<PlayerPuppet>) -> Void {
    E(s"unregister alcohols manager");
    super.Unregister(player);
  }

  protected func UpdateSymptoms(symptoms: Uint32) -> Bool {
    let alcohol: Bool = Bits.Has(symptoms, EnumInt(Consumable.Alcohol));
    let invalidate: Bool = false;
    E(s"update alcohol symptom: (current \(this.withdrawingFromAlcohol), incoming (\(alcohol))");

    if NotEquals(this.withdrawingFromAlcohol, alcohol) {
      this.withdrawingFromAlcohol = alcohol;
      invalidate = true;
    }

    return invalidate;
  }

  protected func InvalidateState() -> Void {
    E(s"invalidate alcohol manager state");
    
    let alcohol = [
      t"BaseStatusEffect.Jitters"
    ];

    let applied: array<ref<StatusEffect>>;
    StatusEffectHelper.GetAppliedEffectsWithTag(this.owner, n"WithdrawalSymptom", applied);

    this.Invalidate(Consumable.Alcohol, this.withdrawingFromAlcohol, applied, alcohol);
  }
}
