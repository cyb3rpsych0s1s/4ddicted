module Addicted.Manager

import Addicted.*
import Addicted.Utils.*
import Addicted.Helpers.{Bits,Effect}

public class BlackLaceManager extends IScriptable {

 private let owner: wref<PlayerPuppet>;

 private let onWithdrawing: ref<CallbackHandle>;
 private let withdrawing: Bool;

 public func Register(player: ref<PlayerPuppet>) -> Void {
    E(s"register black lace manager");
    let board: ref<IBlackboard>;
    if player != null {
      this.owner = player;
      board = this.owner.GetPlayerStateMachineBlackboard();
      if IsDefined(board) {
        let symptoms = board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms);
        this.withdrawing = Bits.Has(symptoms, EnumInt(Consumable.BlackLace));
        if !IsDefined(this.onWithdrawing) {
          this.onWithdrawing = board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms, this, n"OnWithdrawalSymptomsChanged", true);
        }
      }
    }
    this.InvalidateState();
  }

  public func Unregister(player: ref<PlayerPuppet>) -> Void {
    E(s"unregister black lace manager");

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
   let blacklace = Bits.Has(value, EnumInt(Consumable.BlackLace));
   let invalidate: Bool = false;
   if NotEquals(blacklace, this.withdrawing) {
    this.withdrawing = blacklace;
    invalidate = true;
   }
   if invalidate {
    this.InvalidateState();
   }
 }

  protected func InvalidateState() -> Void {
    E(s"invalidate state");
    
    let blacklace = [
     t"BaseStatusEffect.NotablyWithdrawnFromBlackLace",
     t"BaseStatusEffect.SeverelyWithdrawnFromBlackLace"
    ];

    let applied: array<ref<StatusEffect>>;
    StatusEffectHelper.GetAppliedEffectsWithTag(this.owner, n"WithdrawalSymptom", applied);

    this.Invalidate(Consumable.BlackLace, this.withdrawing, applied, blacklace);
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