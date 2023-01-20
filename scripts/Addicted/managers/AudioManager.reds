module Addicted.Manager

import Addicted.System.AddictedSystem
import Addicted.Utils.E
import Addicted.*

public class HintProgressCallback extends DelayCallback {
  public let manager: wref<AudioManager>;
  public func Call() -> Void {
    E(s"on hint progress callback ...");
    if this.manager.ambient != null && !this.manager.ambient.playing {
      this.manager.Play(this.manager.ambient);
    }
    if ArraySize(this.manager.oneshot) > 0 {
      let size = ArraySize(this.manager.oneshot);
      let tracked: ref<TrackedHintRequest>;
      if size == 1 || this.manager.oneshot[0].played == 0 { tracked = this.manager.oneshot[0]; }
      else {
        let random = RandRangeF(0, 1);
        tracked = this.manager.oneshot[Cast<Int32>(random)];
      }
      this.manager.Play(tracked);
    }
    this.manager.Update();
  }
}

public class TrackedHintRequest {
  public let got: ref<HintRequest>;
  public let played: Int32 = 0;
  public let playing: Bool = false;
  public static func Wrap(request: ref<HintRequest>) -> ref<TrackedHintRequest> {
    let track = new TrackedHintRequest();
    track.got = request;
    return track;
  }
}

public class AudioManager extends IScriptable {

  private let owner: wref<PlayerPuppet>;
  private let playing: Bool = false;

  private let swimming: Int32;
  private let consuming: Bool;
  private let tier: Int32;
  private let onDiving: ref<CallbackHandle>;
  private let onConsuming: ref<CallbackHandle>;
  private let onTierChanged: ref<CallbackHandle>;

  private let ambient: ref<TrackedHintRequest>;
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
        this.swimming = board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming);
        if !IsDefined(this.onDiving) {
          this.onDiving = board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming, this, n"OnDivingChanged", true);
        }
        this.consuming = board.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming);
        if !IsDefined(this.onConsuming) {
          this.onConsuming = board.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming, this, n"OnConsumingChanged", true);
        }
        this.tier = board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier);
        if !IsDefined(this.onTierChanged) {
          this.onTierChanged = board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier, this, n"OnSceneTierChanged", true);
        }
      }
      E(s"listeners defined ? \(IsDefined(this.onDiving)) \(IsDefined(this.onConsuming)) \(IsDefined(this.onTierChanged))");
    }
    this.InvalidateState();
  }

  public func Unregister(player: ref<PlayerPuppet>) -> Void {
    E(s"unregister audio manager");

    let board: ref<IBlackboard>;
    if player != null {
      this.Shutdown();
      board = player.GetPlayerStateMachineBlackboard();
      if IsDefined(board) {
        if IsDefined(this.onDiving)     { board.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming, this.onDiving); }
        if IsDefined(this.onConsuming)  { board.UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsConsuming, this.onConsuming); }
        if IsDefined(this.onTierChanged)   { board.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier, this.onTierChanged); }
      }
      this.onDiving = null;
      this.onConsuming = null;
      this.onTierChanged = null;
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
            this.Stop(sfx.GetSoundName());
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
    E(s"hint");
    if request.IsLoop() {
      E(s"loopin...");
      this.Loop(request);
    }
    else
    {
      if ArraySize(this.oneshot) == 0 {
        E(s"no ono, addin...");
        this.Add(request);
      }
      if ArraySize(this.oneshot) == 1 {
        E(s"single ono found");
        let matches = this.Augment(request);
        if !matches {
          E(s"a different ono, so addin...");
          this.Add(request);
        }
      }
      if ArraySize(this.oneshot) == 2 {
        E(s"2 onos found");
        let matches = this.Augment(request);
        if !matches {
          E(s"a brand new ono, so swapin' last...");
          this.SwapLast(request);
        }
      }
    }
    this.Interrupt();
    this.Schedule();
  }

  public func Play(tracked: ref<TrackedHintRequest>) -> Void {
    let policy = this.ToPolicy();
    E(s"-----------------------------------------------");
    E(s"play");
    E(s"policy \(ToString(policy))");
    E(s"tracked.playing \(ToString(tracked.playing))");
    if EnumInt(policy) == EnumInt(PlaySoundPolicy.AmbientOnly) { return; }
    if tracked.playing { return; }

    GameInstance.GetAudioSystem(this.owner.GetGame())
      .Play(tracked.got.Sound(), this.owner.GetEntityID(), n"Addicted");
    E(s"tracked.played (before) \(ToString(tracked.played))");
    tracked.played += 1;
    tracked.playing = tracked.got.IsLoop();
    E(s"tracked.played (after) \(ToString(tracked.played))");
    E(s"tracked.playing \(ToString(tracked.playing))");
    E(s"-----------------------------------------------");
  }

  public func Stop(sound: CName) -> Void {
    GameInstance.GetAudioSystem(this.owner.GetGame())
      .Stop(sound, this.owner.GetEntityID(), n"Addicted");
  }

  public func StopAll() -> Void {
    if IsDefined(this.ambient) {
      this.Stop(this.ambient.got.Sound());
    }
    for ono in this.oneshot {
      this.Stop(ono.got.Sound());
    }
  }

  private func Shutdown() -> Void {
    this.StopAll();
    this.ambient = null;
    this.ambientSFX = null;
    ArrayClear(this.oneshot);
    ArrayClear(this.oneshotSFX);
  }

  public func Update() -> Void {
    E(s"on update");
    let now = GameInstance
      .GetTimeSystem(this.owner.GetGame())
      .GetGameTimeStamp();
    if IsDefined(this.ambient) && this.Done(this.ambient, now) {
      E(s"now: \(now)");
      E(s"ambient is done, stopin... \(ToString(this.ambient.got.until))");
      this.Stop(this.ambient.got.Sound());
      this.ambientSFX = null;
      this.ambient = null;
    }
    if ArraySize(this.oneshot) > 0 {
      let size = ArraySize(this.oneshot);
      E(s"has \(ToString(size)) ono(s) (\(ToString(now)))");
      if size == 2 {
        if this.Done(this.oneshot[1], now) {
          E(s"now: \(now)");
          E(s"secondary ono is done, popin... \(ToString(this.oneshot[1].got.until))");
          this.Pop();
        }
      }
      if this.Done(this.oneshot[0], now) {
        E(s"now: \(now)");
        E(s"primary ono is done, popin... \(ToString(this.oneshot[0].got.until))");
        this.Pop();
      }
    }
    if !IsDefined(this.ambient) && ArraySize(this.oneshot) == 0 {
      E(s"terminate!");
      this.Terminate();
    } else {
      E(s"reschedule...");
      this.Schedule();
    }
  }

  private func Loop(request: ref<HintRequest>) -> Void {
    if IsDefined(this.ambient)
    {
      if Equals(this.ambient.got.Sound(), request.Sound())
      {
        if request.until > this.ambient.got.until {
          this.ambient.got.until = request.until;
        }
        return;
      }
      if !this.ambient.playing
      {
        let sfx = new PlaySoundEvent();
        sfx.SetSoundName(request.Sound());
        let lastSFX = this.ambientSFX;
        this.ambient = TrackedHintRequest.Wrap(request);
        this.ambientSFX = sfx;
        GameInstance.GetAudioSystem(this.owner.GetGame())
          .Switch(lastSFX.GetSoundName(), sfx.GetSoundName(), this.owner.GetEntityID(), n"Addicted");
      }
    }
    else
    {
      let sfx = new PlaySoundEvent();
      sfx.SetSoundName(request.Sound());
      this.ambient = TrackedHintRequest.Wrap(request);
      this.ambientSFX = sfx;
    }
  }

  private func Add(request: ref<HintRequest>) -> Void {
    let sfx = new PlaySoundEvent();
    sfx.SetSoundName(request.Sound());
    let tracked = TrackedHintRequest.Wrap(request);
    ArrayPush(this.oneshot, tracked);
    ArrayPush(this.oneshotSFX, sfx);
  }

  private func Augment(request: ref<HintRequest>) -> Bool {
    let matches = false;
    for shot in this.oneshot {
      if Equals(shot.got.Sound(), request.Sound()) {
        E(s"same ono, augmenting initial request...");
        if request.until > shot.got.until {
          E(s"will last to \(ToString(request.until)) instead of \(ToString(shot.got.until))");
          shot.got.until = request.until;
        }
        if shot.got.times < Cast<Int32>(request.AtMost()) {
          E(s"times increased: \(ToString(shot.got.times)) -> \(ToString(shot.got.times+1))");
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
    let tracked = TrackedHintRequest.Wrap(request);
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
    if request.got.IsLoop() { return this.Outdated(request.got, now); }
    return this.Finished(request) || this.Outdated(request.got, now);
  }

  private func Scheduled() -> Bool {
    return !Equals(this.callbackID, GetInvalidDelayID());
  }

  private func Interrupt() -> Void {
    GameInstance.GetDelaySystem(this.owner.GetGame())
      .CancelCallback(this.callbackID);
  }

  private func Terminate() -> Void {
    if this.Scheduled() {
      this.Interrupt();
      this.callbackID = GetInvalidDelayID();
    }
  }

  private func Schedule() {
    let callback: ref<HintProgressCallback> = new HintProgressCallback();
    callback.manager = this;
    let delay = RandRangeF(3, 5);
    this.callbackID = GameInstance.GetDelaySystem(this.owner.GetGame())
      .DelayCallback(callback, delay, true);
  }

  protected final func ToPolicy() -> PlaySoundPolicy {
    if this.consuming || this.IsDiving() || this.IsChatting() { return PlaySoundPolicy.AmbientOnly; }
    return PlaySoundPolicy.All;
  }

  protected final func IsDiving() -> Bool {
    return this.swimming == EnumInt(gamePSMSwimming.Diving);
  }

  protected final func IsChatting() -> Bool {
    return this.tier != EnumInt(GameplayTier.Tier1_FullGameplay) &&
      this.tier != EnumInt(GameplayTier.Tier2_StagedGameplay);
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

  protected cb func OnTierChanged(value: Int32) -> Bool {
    if !Equals(this.tier, value) {
      E(s"chatting status changed: \(ToString(value))");
      this.tier = value;
      this.InvalidateState();
    }
  }
}