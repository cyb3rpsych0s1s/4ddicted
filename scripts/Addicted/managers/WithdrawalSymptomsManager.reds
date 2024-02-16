module Addicted.Manager

import Addicted.*
import Addicted.Utils.*
import Addicted.Helpers.{Effect}

public abstract class WithdrawalSymptomsManager extends IScriptable {

  protected let owner: wref<PlayerPuppet>;
  private let onWithdrawing: ref<CallbackHandle>;
  private let onCombatChange: ref<CallbackHandle>;
  private let lastCombatState: Int32;

  protected abstract func UpdateSymptoms(symptoms: Uint32) -> Bool;
  protected abstract func InvalidateState() -> Void;

  public func Register(player: ref<PlayerPuppet>) -> Void {
    E(s"register withdrawal symptoms manager");
    let board: ref<IBlackboard>;
    if player != null {
      this.owner = player;
      board = this.owner.GetPlayerStateMachineBlackboard();
      if IsDefined(board) {
        let symptoms = board.GetUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms);
        this.UpdateSymptoms(symptoms);
        if !IsDefined(this.onWithdrawing) {
          this.onWithdrawing = board.RegisterListenerUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms, this, n"OnWithdrawalSymptomsChanged", true);
        }
        if !IsDefined(this.onCombatChange) {
          this.onCombatChange = board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Combat, this, n"OnCombatChange");
        }
      }
    }
    this.InvalidateState();
    E(s"listener: \(ToString(IsDefined(this.onWithdrawing)))");
  }

  public func Unregister(player: ref<PlayerPuppet>) -> Void {
    E(s"unregister withdrawal symptoms manager");
    let board: ref<IBlackboard>;
    if player != null {
      board = player.GetPlayerStateMachineBlackboard();
      if IsDefined(board) {
        if IsDefined(this.onWithdrawing) { board.UnregisterListenerUint(GetAllBlackboardDefs().PlayerStateMachine.WithdrawalSymptoms, this.onWithdrawing); }
      }
      if IsDefined(board) {
        if IsDefined(this.onCombatChange) { board.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Combat, this.onCombatChange); }
      }
      this.onWithdrawing = null;
    }
    this.owner = null;
  }

  protected cb func OnWithdrawalSymptomsChanged(value: Uint32) -> Bool {
    E(s"on withdrawal symptoms changed: \(ToString(value))");
    let invalidate: Bool = this.UpdateSymptoms(value);
    if invalidate {
      this.InvalidateState();
    }
  }

  protected cb func OnCombatChange(value: Int32) -> Bool {
    if NotEquals(value, this.lastCombatState) {
      let current_state = IntEnum<gamePSMCombat>(this.lastCombatState);
      let new_state = IntEnum<gamePSMCombat>(value);
      let entered_combat = Equals(new_state, gamePSMCombat.InCombat);
      let left_combat_no_stealth = Equals(new_state, gamePSMCombat.OutOfCombat)
      && NotEquals(current_state, gamePSMCombat.Stealth);
      if (entered_combat || left_combat_no_stealth) {
        E(s"on combat change (\(ToString(current_state)) -> \(ToString(new_state)))");
        this.InvalidateState();
      }
      this.lastCombatState = value;
    }
  }

  protected func Invalidate(consumable: Consumable, withdrawing: Bool, applied: array<ref<StatusEffect>>, applicables: array<TweakDBID>) -> Void {
    let sizeApplied = ArraySize(applied);
    let sizeApplicable = ArraySize(applicables);
    if sizeApplied == 0 || sizeApplicable > 2 { return; }

    if !withdrawing {
      let id: TweakDBID;
      let i = 0;
      while i < sizeApplicable {
        id = applicables[i];
        if Effect.IsApplied(applied, id) {
          StatusEffectHelper.RemoveStatusEffect(this.owner, id);
        } 
        i += 1;
      }
    } else {
      if !Effect.AreApplied(applied, applicables) {
        let threshold = this.owner.Threshold(consumable);
        if sizeApplicable == 1 {
          switch (threshold) {
            case Threshold.Severely:
            case Threshold.Notably:
              StatusEffectHelper.ApplyStatusEffect(this.owner, applicables[0]);
              break;
          }
        } else {
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
}