module Addicted.Manager

import Addicted.*
import Addicted.Utils.*
import Addicted.Helpers.Effect

public class StimulantManager extends IScriptable {

 private let owner: wref<PlayerPuppet>;

 private let onWithdrawing: ref<CallbackHandle>;
 private let withdrawingFromStaminaBooster: Bool;
 private let withdrawingFromCarryCapacityBooster: Bool;
 private let withdrawingFromMemoryBooster: Bool;

 public func Register(player: ref<PlayerPuppet>) -> Void {
    E(s"register stimulant manager");
    let board: ref<IBlackboard>;
    if player != null {
      this.owner = player;
      board = this.owner.GetPlayerStateMachineBlackboard();
      if IsDefined(board) {
        let symptoms = board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms);
        this.withdrawingFromStaminaBooster = Bits.Has(symptoms, EnumInt(Consumable.StaminaBooster));
        this.withdrawingFromCarryCapacityBooster = Bits.Has(symptoms, EnumInt(Consumable.CarryCapacityBooster));
        this.withdrawingFromMemoryBooster = Bits.Has(symptoms, EnumInt(Consumable.MemoryBooster));
        if !IsDefined(this.onWithdrawing) {
          this.onWithdrawing = board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms, this, n"OnWithdrawalSymptomsChanged", true);
        }
      }
    }
    this.InvalidateState();
  }

  public func Unregister(player: ref<PlayerPuppet>) -> Void {
    E(s"unregister stimulant manager");

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
   let memory = Bits.Has(value, EnumInt(Consumable.MemoryBooster));
   let invalidate: Bool = false;
   if !Equals(stamina, this.withdrawingFromStaminaBooster) {
    this.withdrawingFromStaminaBooster = stamina;
    invalidate = true;
   }
   if !Equals(capacity, this.withdrawingFromCarryCapacityBooster) {
    this.withdrawingFromCarryCapacityBooster = capacity;
    invalidate = true;
   }
   if !Equals(capacity, this.withdrawingFromMemoryBooster) {
    this.withdrawingFromMemoryBooster = memory;
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
    let sizeApplied = ArraySize(applied);
    let sizeApplicable = ArraySize(applicables);
    if sizeApplied == 0 || sizeApplicable != 2 { return; }

    if !withdrawing {
      let id: TweakDBID;
      let i = 0;
      while i < sizeApplicable {
        id = applicables[i];
        if !withdrawing && Effect.IsApplied(applied, id) {
          StatusEffectHelper.RemoveStatusEffect(this.owner, id);
        } 
        i += 1;
      }
    } else {
      if !Effect.AreApplied(applied, applicables) {
        let threshold = this.owner.Threshold(consumable);
        switch (threshold) {
        case Threshold.Severely:
          StatusEffectHelper.ApplyStatusEffect(this.owner, applicables[1]);
          break;
        case Threshold.Notably:
          StatusEffectHelper.ApplyStatusEffect(this.owner, applicables[0]);
          break;
        }
      }
    }
  }
}