module Addicted.Manager

import Addicted.System.AddictedSystem
import Addicted.Utils.E
import Addicted.*

public class CheckSoundEvent extends TickableEvent {}

// @addField(PlayerPuppet)
// public let onomatopeaEventID: DelayID;

// public class PlayOnomotopeaEvent extends Event {
//   public let player: wref<PlayerPuppet>;
//   public let sound: CName;
//   public let duration: Float;
// }

public class AudioManager extends IScriptable {

  private let owner: wref<PlayerPuppet>;
  private let playing: Bool = false;

  private let swimming: Int32;
  private let consuming: Bool;
  private let chatting: Bool;
  private let onDiving: ref<CallbackHandle>;
  private let onConsuming: ref<CallbackHandle>;
  private let onChatting: ref<CallbackHandle>;
  private let board: ref<IBlackboard>;

  public func Register(player: ref<PlayerPuppet>) -> Void {
    E(s"register audio manager");
    this.owner = player;
    E(s"register listeners...");
    this.board = this.owner.GetPlayerStateMachineBlackboard();
    E(s"board is defined ? \(IsDefined(this.board))");
    if IsDefined(this.board) {
      this.swimming     = this.board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming);
      this.chatting     = this.board.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInDialogue);
      this.consuming    = this.board.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming);
      this.onDiving     = this.board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming, this, n"OnDivingChanged", true);
      this.onConsuming  = this.board.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming, this, n"OnConsumingChanged", true);
      this.onChatting   = this.board.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsInDialogue, this, n"OnChattingChanged", true);
    }
    E(s"listeners defined ? \(IsDefined(this.onDiving)) \(IsDefined(this.onConsuming)) \(IsDefined(this.onChatting))");
    this.InvalidateState();
  }

  public func Unregister() -> Void {
    E(s"unregister audio manager");
    if IsDefined(this.board) {
      this.board.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming, this.onDiving);
      this.board.UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming, this.onConsuming);
      this.board.UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsInDialogue, this.onChatting);
      this.board = null;
    }
    this.owner = null;
  }

  protected func InvalidateState() -> Void {
    E(s"invalidate state");
    let policy = this.ToPolicy();
    switch(policy) {
      case PlaySoundPolicy.AmbientOnly:
        E(s"policy to AMBIENT_ONLY");
        break;
      case PlaySoundPolicy.None:
        E(s"policy to NONE");
        break;
      default:
        E(s"policy to ALL");
        break;
    }
  }

  protected final func ToPolicy() -> PlaySoundPolicy {
    if this.consuming || this.IsDiving() || this.chatting { return PlaySoundPolicy.AmbientOnly; }
    return PlaySoundPolicy.All;
  }

  protected final func IsDiving() -> Bool {
    return this.swimming == EnumInt(gamePSMSwimming.Diving);
  }

  protected cb func OnDivingChanged(value: Int32) -> Bool {
    if !Equals(this.swimming, value) {
      let state: gamePSMSwimming = IntEnum(value);
      E(s"swimming status changed: \(ToString(state))");
      this.swimming = value;
      this.InvalidateState();
    }
  }

  protected cb func OnConsumingChanged(value: Bool) -> Bool {
    if !Equals(this.consuming, value) {
      E(s"consuming status changed: \(ToString(value))");
      this.consuming = value;
      this.InvalidateState();
    }
  }

  protected cb func OnChattingChanged(value: Bool) -> Bool {
    if !Equals(this.chatting, value) {
      E(s"chatting status changed: \(ToString(value))");
      this.chatting = value;
      this.InvalidateState();
    }
  }

  public func IsPlaying() -> Bool { return this.playing; }
}