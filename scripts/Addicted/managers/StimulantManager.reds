module Addicted.Manager

import Addicted.*
import Addicted.Utils.*
import Addicted.Helpers.{Bits,Effect}

public class StimulantManager extends WithdrawalSymptomsManager {

  private let withdrawingFromStaminaBooster: Bool;
  private let withdrawingFromCarryCapacityBooster: Bool;
  private let withdrawingFromMemoryBooster: Bool;

  protected func UpdateSymptoms(symptoms: Int32) -> Bool {
    let stamina: Bool = Bits.Has(symptoms, EnumInt(Consumable.StaminaBooster));
    let capacity: Bool = Bits.Has(symptoms, EnumInt(Consumable.CarryCapacityBooster));
    let memory: Bool = Bits.Has(symptoms, EnumInt(Consumable.MemoryBooster));
    let invalidate: Bool = false;
    if this.withdrawingFromStaminaBooster != stamina {
      this.withdrawingFromStaminaBooster = stamina;
      invalidate = true;
    }
    if this.withdrawingFromCarryCapacityBooster != capacity {
      this.withdrawingFromCarryCapacityBooster = capacity;
      invalidate = true;
    }
    if this.withdrawingFromMemoryBooster != memory {
      this.withdrawingFromMemoryBooster = memory;
      invalidate = true;
    }
    return invalidate;
  }

  public func Register(player: ref<PlayerPuppet>) -> Void {
    E(s"register stimulant manager");
  }

  public func Unregister(player: ref<PlayerPuppet>) -> Void {
    E(s"unregister stimulant manager");
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
}