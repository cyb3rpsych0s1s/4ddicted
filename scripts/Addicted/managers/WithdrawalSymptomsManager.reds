module Addicted.Manager

import Addicted.*
import Addicted.Utils.*
import Addicted.Helpers.{Effect}

public abstract class WithdrawalSymptomsManager extends IScriptable {

  protected let owner: wref<PlayerPuppet>;
  private let onWithdrawing: ref<CallbackHandle>;

  protected abstract func UpdateSymptoms(symptoms: Int32) -> Bool;
  protected abstract func InvalidateState() -> Void;

  public func Register(player: ref<PlayerPuppet>) -> Void {
    E(s"register withdrawal symptoms manager");
    let board: ref<IBlackboard>;
    if player != null {
      this.owner = player;
      board = this.owner.GetPlayerStateMachineBlackboard();
      if IsDefined(board) {
        let symptoms = board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms);
        this.UpdateSymptoms(symptoms);
        if !IsDefined(this.onWithdrawing) {
          this.onWithdrawing = board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms, this, n"OnWithdrawalSymptomsChanged", true);
        }
      }
    }
    this.InvalidateState();
  }

  public func Unregister(player: ref<PlayerPuppet>) -> Void {
    E(s"unregister withdrawal symptoms manager");
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
    let invalidate: Bool = this.UpdateSymptoms(value);
    if invalidate {
      this.InvalidateState();
    }
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