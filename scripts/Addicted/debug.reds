module Addicted
import Addicted.Utils.E

@addMethod(PlayerPuppet)
public func FeelsDizzy() -> Void {
    GameObject.SetAudioParameter(this, n"vfx_fullscreen_drunk_level", 3.00);
    StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.MaxDOCMirage");
}

@wrapMethod(RestedEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let system = GameInstance.GetTimeSystem(scriptInterface.GetGame());
    E(s"RestedEvents:OnEnter \(ToString(system.GetGameTimeStamp()))");
    wrappedMethod(stateContext, scriptInterface);
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    E(s"PlayerPuppet:OnStatusEffectApplied \(TDBID.ToStringDEBUG(evt.staticData.GetID())) \(ToString(evt.staticData.StatusEffectType().Type())) (remains: \(evt.staticData.Duration()))");
    return wrappedMethod(evt);
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    if evt.IsAddictive() {
        E("PlayerPuppet:OnStatusEffectRemoved (IsAddictive)");
    }
    return wrappedMethod(evt);
}

@wrapMethod(ScriptableSystem)
private func OnAttach() -> Void {
    E(s"ScriptableSystem:OnAttach");
    wrappedMethod();
}

@wrapMethod(TimeskipGameController)
private final func Apply() -> Void {
  if this.m_hoursToSkip > 0 {
    E(s"TimeskipGameController:Apply: \(this.m_hoursToSkip) hour(s) to skip");
  } else {
    E(s"TimeskipGameController:Apply: less than one hour to skip");
  }
  wrappedMethod();
}

// Game.GetPlayer():JustSomeSound(CName.new('vfx_fullscreen_memory_boost_activate'))
// Game.GetPlayer():JustSomeSound(CName.new('quickhack_sonic_shock'))
// Game.GetPlayer():JustSomeSound(CName.new('quickhack_request_backup'))
// Game.GetPlayer():JustSomeSound(CName.new('quickhack_synapse_burnout'))
// Game.GetPlayer():JustSomeSound(CName.new('ono_freak_f_pain_long_set_04'))
@addMethod(PlayerPuppet)
public func JustSomeSound(sound: CName) -> Void {
    // e.g. n"vfx_fullscreen_memory_boost_activate"
    GameObject.PlaySoundEvent(this, sound);
}

// Game.GetPlayer():JustSomeVisual(CName.new('reflex_buster'))
// Game.GetPlayer():JustSomeVisual(CName.new('splinter_buff'))
// Game.GetPlayer():JustSomeVisual(CName.new('mask_explode'))
// Game.GetPlayer():JustSomeVisual(CName.new('status_blinded'))
// Game.GetPlayer():JustSomeVisual(CName.new('status_bleeding'))
// Game.GetPlayer():JustSomeVisual(CName.new('hacks_overheat_lvl2'))
// gamedataStatusEffectFX_Record
@addMethod(PlayerPuppet)
public func JustSomeVisual(visual: CName) -> Void {
    GameObjectEffectHelper.StartEffectEvent(this, visual);
}

// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.Overload'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.PlayerPoisoned'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.PlayerExhausted'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.QuickHackBlind'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.HeartAttack')) // lethal!
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.BorgStun'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.Stun'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.DrillingShakeNormal'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.AutoLocomotion'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.DrillingShakeMedium'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.WithdrawalCrisis'))
// Game.GetPlayer():JustSomeEffect(TweakDBID.new('BaseStatusEffect.MaxDOCMirage'))
@addMethod(PlayerPuppet)
public func JustSomeEffect(effect: TweakDBID) -> Void {
    StatusEffectHelper.ApplyStatusEffect(this, effect);
}

// Game.GetPlayer():ClearEffect(TweakDBID.new('BaseStatusEffect.DrillingShakeMedium'))
@addMethod(PlayerPuppet)
public func ClearEffect(effect: TweakDBID) -> Void {
    StatusEffectHelper.RemoveStatusEffect(this, effect);
}

// Game.GetPlayer():JustADopeFiend()
// Game.GetPlayer():SlowStun()
@addMethod(PlayerPuppet)
public func JustADopeFiend() -> Void {
    // doesn't work for some reason (but works if manually planned, see addiction system)
    // StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.BreathingHeavy");
    // let breath = new ApplyNewStatusEffectEvent();
    // breath.effectID = t"BaseStatusEffect.BreathingNormal";
    // let stun = new ApplyNewStatusEffectEvent();
    // stun.effectID = t"BaseStatusEffect.BorgStun";
    // let shake = new ApplyNewStatusEffectEvent();
    // shake.effectID = t"BaseStatusEffect.DrillingShakeMedium";
    // let system = GameInstance.GetDelaySystem(this.GetGame());
    // system.DelayEvent(this, stun, 3.0, true);
    // system.DelayEvent(this, stun, 6.0, true);
    // system.DelayEvent(this, breath, 12.0, true);
}

@wrapMethod(AISubActionGameplayLogicPackage_Record_Implementation)
public final static func ApplyGameplayLogicPackage(context: ScriptExecutionContext, record: wref<AISubActionGameplayLogicPackage_Record>) -> Void {
    E(s"AISubActionGameplayLogicPackage_Record_Implementation:ApplyGameplayLogicPackage \(ToString(record))");
    wrappedMethod(context, record);
}

// Game.GetPlayer():DebugAllStatusEffects()
@addMethod(PlayerPuppet)
public func DebugAllStatusEffects() -> Void {
    let count = 1;
    let effects = StatusEffectHelper.GetAppliedEffects(this);
    for effect in effects {
        E(s"\(count) => \(effect.GetRecord().StatusEffectType().Type()) \(EntityID.ToDebugString(effect.GetInstigatorEntityID())) \(TDBID.ToStringDEBUG(effect.GetInstigatorStaticDataID())) (\(effect.GetRemainingDuration()))");
        count += 1;
    }
}

// Game.GetPlayer():DebugClearAllStatusEffects()
@addMethod(PlayerPuppet)
public func DebugClearAllStatusEffects() -> Void {
    let effects = StatusEffectHelper.GetAppliedEffects(this);
    for effect in effects {
        StatusEffectHelper.RemoveStatusEffect(this, effect);
    }
}