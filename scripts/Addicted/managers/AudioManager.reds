module Addicted.Manager

import Addicted.System.AddictedSystem
import Addicted.Utils.E
import Addicted.*

public class HintProgressCallback extends DelayCallback {
  public let owner: wref<AudioManager>;
  public func Call() -> Void {
    E(s"on hint progress callback ...");
    this.owner.Update();
  }
}

public class TrackedHintRequest {
  public let got: ref<HintRequest>;
  public let played: Int32;
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

  private let ambient: ref<HintRequest>;
  private let oneshot: array<ref<TrackedHintRequest>>;
  private let ambientSFX: ref<PlaySoundEvent>;
  private let oneshotSFX: array<ref<PlaySoundEvent>>;

  private let callbackID: DelayID;

  public func Register(player: ref<PlayerPuppet>) -> Void {
    E(s"register audio manager");
    let board: ref<IBlackboard>;
    if player != null {
      this.owner = player;
      board = this.owner.GetPlayerStateMachineBlackboard();
      E(s"board is defined ? \(IsDefined(board))");
      if IsDefined(board) {
        if !IsDefined(this.onDiving) {
          this.swimming     = board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming);
          this.onDiving     = board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming, this, n"OnDivingChanged", true);
        }
        if !IsDefined(this.onConsuming) {
          this.consuming    = board.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming);
          this.onConsuming  = board.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming, this, n"OnConsumingChanged", true);
        }
        if !IsDefined(this.onChatting) {
          this.chatting     = board.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInDialogue);
          this.onChatting   = board.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsInDialogue, this, n"OnChattingChanged", true);
        }
      }
      E(s"listeners defined ? \(IsDefined(this.onDiving)) \(IsDefined(this.onConsuming)) \(IsDefined(this.onChatting))");
    }
    this.InvalidateState();
  }

  public func Unregister(player: ref<PlayerPuppet>) -> Void {
    E(s"unregister audio manager");
    let board: ref<IBlackboard>;
    if player != null {
      board = player.GetPlayerStateMachineBlackboard();
      if IsDefined(board) {
        if IsDefined(this.onDiving)     { board.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming, this.onDiving); }
        if IsDefined(this.onConsuming)  { board.UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming, this.onConsuming); }
        if IsDefined(this.onChatting)   { board.UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsInDialogue, this.onChatting); }
      }
      this.onDiving = null;
      this.onConsuming = null;
      this.onChatting = null;
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
    E(s"on update");
    if ArraySize(this.oneshot) > 0 {
      let now = GameInstance
        .GetTimeSystem(this.owner.GetGame())
        .GetGameTimeStamp();
      let size = ArraySize(this.oneshot);
      if size == 2 {
        if this.Done(this.oneshot[1], now) {
          this.Pop();
        }
      }
      if this.Done(this.oneshot[0], now) {
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
    let tracked = new TrackedHintRequest();
    tracked.got = request;
    tracked.played = 0;
    ArrayPush(this.oneshot, tracked);
    ArrayPush(this.oneshotSFX, sfx);
    GameInstance.GetAudioSystem(this.owner.GetGame())
      .Play(sfx.GetSoundName(), this.owner.GetEntityID(), n"Addicted");
  }

  private func Augment(request: ref<HintRequest>) -> Bool {
    let matches = false;
    for shot in this.oneshot {
      if Equals(shot.got.Sound(), request.Sound()) {
        if request.until > shot.got.until {
          shot.got.until = request.until;
        }
        if shot.got.times <= this.Max(request.threshold) {
          shot.got.times += 1;
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
    let tracked = new TrackedHintRequest();
    tracked.got = request;
    tracked.played = 0;
    ArrayPop(this.oneshot);
    ArrayPush(this.oneshot, tracked);
    let lastSFX = ArrayPop(this.oneshotSFX);
    ArrayPush(this.oneshotSFX, sfx);
    GameInstance.GetAudioSystem(this.owner.GetGame())
      .Switch(lastSFX.GetSoundName(), sfx.GetSoundName(), this.owner.GetEntityID(), n"Addicted");
  }

  private func Pop() -> Void {
    ArrayPop(this.oneshot);
    ArrayPop(this.oneshotSFX);
  }

  private func Finished(request: ref<TrackedHintRequest>) -> Bool {
    return request.played == request.got.times;
  }

  private func Outdated(request: ref<HintRequest>, now: Float) -> Bool {
    return request.until <= now;
  }

  private func Done(request: ref<TrackedHintRequest>, now: Float) -> Bool {
    return this.Finished(request) || this.Outdated(request.got, now);
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

  protected func Max(threshold: Threshold) -> Int32 {
    if EnumInt(threshold) == EnumInt(Threshold.Severely) {
      return 5;
    }
    return 3;
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