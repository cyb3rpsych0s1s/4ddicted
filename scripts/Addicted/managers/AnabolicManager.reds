module Addicted.Manager

import Addicted.System.AddictedSystem
import Addicted.*
import Addicted.Utils.*

public class AnabolicManager extends IScriptable {

 private let owner: wref<PlayerPuppet>;

 private let onWithdrawing: ref<CallbackHandle>;
 private let withdrawingFromStaminaBooster: Bool;
 private let withdrawingFromCarryCapacityBooster: Bool;

 public func Register(player: ref<PlayerPuppet>) -> Void {
    E(s"register anabolic manager");
    let board: ref<IBlackboard>;
    if player != null {
      this.owner = player;
      board = this.owner.GetPlayerStateMachineBlackboard();
      if IsDefined(board) {
        let symptoms = board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms);
        this.withdrawingFromStaminaBooster = Bits.Has(symptoms, EnumInt(Consumable.StaminaBooster));
        this.withdrawingFromCarryCapacityBooster = Bits.Has(symptoms, EnumInt(Consumable.CarryCapacityBooster));
        if !IsDefined(this.onWithdrawing) {
          this.onWithdrawing = board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms, this, n"OnWithdrawalSymptomsChanged", true);
        }
      }
    }
    this.InvalidateState();
  }

  public func Unregister(player: ref<PlayerPuppet>) -> Void {
    E(s"unregister anabolic manager");

    let board: ref<IBlackboard>;
    if player != null {
      board = player.GetPlayerStateMachineBlackboard();
      if IsDefined(board) {
       if IsDefined(this.onWithdrawing) { board.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms, this.onWithdrawing); }
      }
      this.onWithdrawing = null;
    }
    this.owner = null;
  }

  protected cb func OnWithdrawalSymptomsChanged(value: Int32) -> Bool {
   let stamina = Bits.Has(value, EnumInt(Consumable.StaminaBooster));
   let capacity = Bits.Has(value, EnumInt(Consumable.CarryCapacityBooster));
   let invalidate: Bool = false;
   if !Equals(stamina, this.withdrawingFromStaminaBooster) {
    this.withdrawingFromStaminaBooster = stamina;
    invalidate = true;
   }
   if !Equals(capacity, this.withdrawingFromCarryCapacityBooster) {
    this.withdrawingFromCarryCapacityBooster = capacity;
    invalidate = true;
   }
   if invalidate {
    this.InvalidateState();
   }
 }

  protected func InvalidateState() -> Void {
    E(s"invalidate state");
    
    let stamina = [
     t"BaseStatusEffect.NotablyWithdrawnFromStaminaBooster",
     t"BaseStatusEffect.SeverelyWithdrawnFromStaminaBooster"
    ];
    let capacity = [
     t"BaseStatusEffect.NotablyWithdrawnFromCarryCapacityBooster",
     t"BaseStatusEffect.SeverelyWithdrawnFromCarryCapacityBooster"
    ];

    let applied: array<ref<StatusEffect>>;
    StatusEffectHelper.GetAppliedEffectsWithTag(this.owner, n"WithdrawalSymptom", applied);
    
    if !this.withdrawingFromStaminaBooster && Helper.IsApplied(applied, stamina[0]) {
     StatusEffectHelper.RemoveStatusEffect(this.owner, stamina[0]);
    }
    if !this.withdrawingFromStaminaBooster && Helper.IsApplied(applied, stamina[1]) {
     StatusEffectHelper.RemoveStatusEffect(this.owner, stamina[1]);
    }
    if this.withdrawingFromStaminaBooster && !Helper.AreApplied(applied, stamina) {
     let threshold = (this.owner as PlayerPuppet).Threshold(Consumable.StaminaBooster);
     switch (threshold) {
      case Threshold.Severely:
       StatusEffectHelper.ApplyStatusEffect(this.owner, stamina[1]);
       break;
      case Threshold.Notably:
       StatusEffectHelper.ApplyStatusEffect(this.owner, stamina[0]);
       break;
     }
    }

    if !this.withdrawingFromCarryCapacityBooster && Helper.IsApplied(applied, capacity[0]) {
     StatusEffectHelper.RemoveStatusEffect(this.owner, capacity[0]);
    }
    if !this.withdrawingFromCarryCapacityBooster && Helper.IsApplied(applied, capacity[1]) {
     StatusEffectHelper.RemoveStatusEffect(this.owner, capacity[1]);
    }
    if this.withdrawingFromCarryCapacityBooster && !Helper.AreApplied(applied, capacity) {
     let threshold = (this.owner as PlayerPuppet).Threshold(Consumable.CarryCapacityBooster);
     switch (threshold) {
      case Threshold.Severely:
       StatusEffectHelper.ApplyStatusEffect(this.owner, capacity[1]);
       break;
      case Threshold.Notably:
       StatusEffectHelper.ApplyStatusEffect(this.owner, capacity[0]);
       break;
     }
    }
  }
}