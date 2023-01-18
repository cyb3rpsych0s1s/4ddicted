module Addicted.Manager

import Addicted.System.AddictedSystem
import Addicted.Utils.E
import Addicted.*

public class HintProgressCallback extends DelayCallback {
  public let owner: wref<AudioManager>;
  public func Call() -> Void {
    E(s"on hint progress callback ...");
  }
}

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

  private let ambient: ref<HintRequest>;
  private let oneshot: array<ref<HintRequest>>;
  private let ambientSFX: ref<PlaySoundEvent>;
  private let oneshotSFX: array<ref<PlaySoundEvent>>;

  private let callbackID: DelayID;

  public func Register(player: ref<PlayerPuppet>) -> Void {
    E(s"register audio manager");
    this.owner = player;
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
        if ArraySize(this.oneshotSFX) > 0 {
          for sfx in this.oneshotSFX {
            sfx.SetStatusEffect(ESoundStatusEffects.SUPRESS_NOISE);
          }
        }
        break;
      default:
        E(s"policy to ALL");
        if ArraySize(this.oneshotSFX) > 0 {
          for sfx in this.oneshotSFX {
            sfx.SetStatusEffect(ESoundStatusEffects.NONE);
          }
        }
        break;
    }
  }

  public func Hint(request: ref<HintRequest>) -> Void {
    if request.IsLoop() {
      this.Loop(request);
    }
    else
    {
      if ArraySize(this.oneshot) == 0 {
        this.Add(request);
      }
      if ArraySize(this.oneshot) == 1 {
        let matches = this.Augment(request);
        if !matches {
          this.Add(request);
        }
      }
      if ArraySize(this.oneshot) == 2 {
        let matches = this.Augment(request);
        if !matches {
          this.SwapLast(request);
        }
      }
    }
    this.Interrupt();
    this.Schedule();
  }

  public func Update() -> Void {
    if ArraySize(this.oneshot) > 0 {
      let now = GameInstance
        .GetTimeSystem(this.owner.GetGame())
        .GetGameTimeStamp();
      let size = ArraySize(this.oneshot);
      if size == 2 {
        if this.Expired(this.oneshot[1], now) {
          this.Pop();
        }
      }
      if this.Expired(this.oneshot[0], now) {
        this.Pop();
      }
    }
    if ArraySize(this.oneshot) == 0 {
      this.Terminate();
    } else {
      this.Schedule();
    }
  }

  private func Loop(request: ref<HintRequest>) -> Void {
    if IsDefined(this.ambient) {
      let sfx = new PlaySoundEvent();
      sfx.SetSoundName(request.Sound());
      let lastSFX = this.ambientSFX;
      this.ambient = request;
      this.ambientSFX = sfx;
      GameInstance.GetAudioSystem(this.owner.GetGame())
        .Switch(lastSFX.GetSoundName(), sfx.GetSoundName(), this.owner.GetEntityID(), n"Addicted");
    }
    else
    {
      let sfx = new PlaySoundEvent();
      sfx.SetSoundName(request.Sound());
      this.ambient = request;
      this.ambientSFX = sfx;
      GameInstance.GetAudioSystem(this.owner.GetGame())
        .Play(sfx.GetSoundName(), this.owner.GetEntityID(), n"Addicted");
    }
  }

  private func Add(request: ref<HintRequest>) -> Void {
    let sfx = new PlaySoundEvent();
    sfx.SetSoundName(request.Sound());
    ArrayPush(this.oneshot, request);
    ArrayPush(this.oneshotSFX, sfx);
    GameInstance.GetAudioSystem(this.owner.GetGame())
      .Play(sfx.GetSoundName(), this.owner.GetEntityID(), n"Addicted");
  }

  private func Augment(request: ref<HintRequest>) -> Bool {
    let matches = false;
    for shot in this.oneshot {
      if Equals(shot.Sound(), request.Sound()) {
        if request.until > shot.until {
          shot.until = request.until;
        }
        if shot.times <= 3 {
          shot.times += 1;
        }
        matches = true;
        break;
      }
    }
    return matches;
  }

  private func SwapLast(request: ref<HintRequest>) -> Void {
    let sfx = new PlaySoundEvent();
    sfx.SetSoundName(request.Sound());
    ArrayPop(this.oneshot);
    let lastSFX = ArrayPop(this.oneshotSFX);
    GameInstance.GetAudioSystem(this.owner.GetGame())
      .Switch(lastSFX.GetSoundName(), sfx.GetSoundName(), this.owner.GetEntityID(), n"Addicted");
  }

  private func Pop() -> Void {
    ArrayPop(this.oneshot);
    ArrayPop(this.oneshotSFX);
  }

  private func Expired(request: ref<HintRequest>, now: Float) -> Bool {
    return request.times == 3 || request.until <= now;
  }

  private func Scheduled() -> Bool {
    return !Equals(this.callbackID, GetInvalidDelayID());
  }

  private func Interrupt() -> Void {
    if this.Scheduled() {
      GameInstance.GetDelaySystem(this.owner.GetGame())
        .CancelCallback(this.callbackID);
    }
  }

  private func Terminate() -> Void {
    if this.Scheduled() {
      this.Interrupt();
      this.callbackID = GetInvalidDelayID();
    }
  }

  private func Schedule() {
    let callback: ref<HintProgressCallback> = new HintProgressCallback();
    callback.owner = this;
    this.callbackID = GameInstance.GetDelaySystem(this.owner.GetGame())
      .DelayCallback(callback, 3, true);
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