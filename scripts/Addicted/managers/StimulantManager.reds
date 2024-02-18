module Addicted.Manager

import Addicted.*
import Addicted.Utils.*
import Addicted.Helpers.{Bits,Effect}

public class StimulantManager extends WithdrawalSymptomsManager {

  private let withdrawingFromStaminaBooster: Bool;
  private let withdrawingFromCarryCapacityBooster: Bool;
  private let withdrawingFromMemoryBooster: Bool;

  public func Register(player: ref<PlayerPuppet>) -> Void {
    E(s"register stimulants manager");
    super.Register(player);
  }

  public func Unregister(player: ref<PlayerPuppet>) -> Void {
    E(s"unregister stimulants manager");
    super.Unregister(player);
  }

  protected func UpdateSymptoms(symptoms: Uint32) -> Bool {
    let stamina: Bool = Bits.Has(symptoms, EnumInt(Consumable.StaminaBooster));
    let capacity: Bool = Bits.Has(symptoms, EnumInt(Consumable.CarryCapacityBooster));
    let memory: Bool = Bits.Has(symptoms, EnumInt(Consumable.MemoryBooster));
    let invalidate: Bool = false;
    E(s"update stimulants symptom: stamina booster  (current \(this.withdrawingFromStaminaBooster), incoming (\(stamina))");
    E(s"update stimulants symptom: capacity booster (current \(this.withdrawingFromCarryCapacityBooster), incoming (\(capacity))");
    E(s"update stimulants symptom: memory booster   (current \(this.withdrawingFromMemoryBooster), incoming (\(memory))");

    if NotEquals(this.withdrawingFromStaminaBooster, stamina) {
      this.withdrawingFromStaminaBooster = stamina;
      invalidate = true;
    }
    if NotEquals(this.withdrawingFromCarryCapacityBooster, capacity) {
      this.withdrawingFromCarryCapacityBooster = capacity;
      invalidate = true;
    }
    if NotEquals(this.withdrawingFromMemoryBooster, memory) {
      this.withdrawingFromMemoryBooster = memory;
      invalidate = true;
    }

    return invalidate;
  }

  protected func InvalidateState() -> Void {
    E(s"invalidate stimulants manager state");
    
    let stamina = [
      t"BaseStatusEffect.NotablyWithdrawnFromStaminaBooster",
      t"BaseStatusEffect.SeverelyWithdrawnFromStaminaBooster"
    ];
    let capacity = [
      t"BaseStatusEffect.NotablyWithdrawnFromCarryCapacityBooster",
      t"BaseStatusEffect.SeverelyWithdrawnFromCarryCapacityBooster"
    ];
    let memory = [
      t"BaseStatusEffect.NotablyWithdrawnFromMemoryBooster",
      t"BaseStatusEffect.SeverelyWithdrawnFromMemoryBooster"
    ];

    let applied: array<ref<StatusEffect>>;
    StatusEffectHelper.GetAppliedEffectsWithTag(this.owner, n"WithdrawalSymptom", applied);

    this.Invalidate(Consumable.StaminaBooster, this.withdrawingFromStaminaBooster, applied, stamina);
    this.Invalidate(Consumable.CarryCapacityBooster, this.withdrawingFromCarryCapacityBooster, applied, capacity);
    this.Invalidate(Consumable.MemoryBooster, this.withdrawingFromMemoryBooster, applied, memory);
  }

  protected func Invalidate(consumable: Consumable, withdrawing: Bool, applied: array<ref<StatusEffect>>, applicables: array<TweakDBID>) -> Void {
    let effects: array<ref<StatusEffect>>;
    let threshold: Threshold;
    let has: Bool = false;

    super.Invalidate(consumable, withdrawing, applied, applicables);
    
    if EnumInt(consumable) == EnumInt(Consumable.MemoryBooster) {
      threshold = this.owner.Threshold(consumable);
      if EnumInt(threshold) == EnumInt(Threshold.Severely) {
        effects = StatusEffectHelper.GetAppliedEffects(this.owner);
        for effect in effects {
          if Equals(effect.GetRecord().GetID(), t"BaseStatusEffect.PhotoSensitive") {
            has = true;
            break;
          }
        }
        if !has {
          StatusEffectHelper.ApplyStatusEffect(this.owner, t"BaseStatusEffect.PhotoSensitive", 0.2);
        }
      }
    }
  }
}