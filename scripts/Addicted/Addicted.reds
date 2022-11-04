module Addicted

@addField(PlayerPuppet)
let consumed: Int32;

@addMethod(StatusEffectEvent)
public func IsAddictive() -> Bool {
    return ArrayContains(
        [
            t"BaseStatusEffect.FirstAidWhiffV0",
            t"BaseStatusEffect.BonesMcCoy70V0"
            // TODO: add missing
        ],
        this.staticData.GetID());
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    LogChannel(n"DEBUG", "RED:Addicted:OnGameAttached");
    return wrappedMethod();
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    // LogChannel(n"DEBUG", s"RED:Addicted:OnStatusEffectApplied \(TDBID.ToStringDEBUG(evt.staticData.GetID()))");
    if evt.isNewApplication && evt.IsAddictive() {
        this.consumed += 1;
        LogChannel(n"DEBUG","RED:Addicted once again: " + this.consumed);
    }
    return wrappedMethod(evt);
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    // LogChannel(n"DEBUG", s"RED:Addicted:OnStatusEffectRemoved \(TDBID.ToStringDEBUG(evt.staticData.GetID()))");
    if evt.IsAddictive() {
        LogChannel(n"DEBUG","RED:Addicted:OnStatusEffectRemoved (IsAddictive)");
    }
  return wrappedMethod(evt);
}

// works
// Game.GetPlayer():JustPlayOneSound()
// Game.GetPlayer():JustPlayOneSound(CName.new('vfx_fullscreen_memory_boost_activate'))
@addMethod(PlayerPuppet)
public func JustPlayOneSound(sound: CName) -> Void {
    // e.g. n"vfx_fullscreen_memory_boost_activate"
    GameObject.PlaySoundEvent(this, sound);
}

// doesnt look like it work
// Game.GetPlayer():JustShockwave()
@addMethod(PlayerPuppet)
public func JustShockwave() -> Void {
    GameInstance.GetAudioSystem(this.GetGame()).PlayShockwave(n"explosion", this.GetWorldPosition());
}

// works
// Game.GetPlayer():JustDrunk()
@addMethod(PlayerPuppet)
public func JustDrunk() -> Void {
    GameObjectEffectHelper.StartEffectEvent(this, n"status_drunk_level_3");
    GameObject.SetAudioParameter(this, n"vfx_fullscreen_drunk_level", 3.00);
}

// works
// Game.GetPlayer():JustHigh()
@addMethod(PlayerPuppet)
public func JustHigh() -> Void {
    GameObjectEffectHelper.StartEffectEvent(this, n"status_drugged_heavy");
    GameObject.SetAudioParameter(this, n"vfx_fullscreen_drugged_level", 3.00);
}

// does not seem to work
// Game.GetPlayer():JustSick()
@addMethod(PlayerPuppet)
public func JustSick() -> Void {
    GameObjectEffectHelper.StartEffectEvent(this, n"p_digital_sickness");
}

// works
// Game.GetPlayer():SoberAgain()
@addMethod(PlayerPuppet)
public func SoberAgain() -> Void {
    GameObjectEffectHelper.BreakEffectLoopEvent(this, n"status_drunk_level_3");
    GameObject.SetAudioParameter(this, n"vfx_fullscreen_drunk_level", 0.00);
    GameObjectEffectHelper.BreakEffectLoopEvent(this, n"status_drugged_heavy");
    GameObject.SetAudioParameter(this, n"vfx_fullscreen_drugged_level", 0.00);
}


@addField(PlayerPuppet)
let wiped: Bool = true;

// does not seem to do anything
// Game.GetPlayer():MemoryTrick()
@addMethod(PlayerPuppet)
public func MemoryTrick() -> Void {
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(this.GetGame());
    let statusEffectID: TweakDBID = t"BaseStatusEffect.MemoryWipeLevel2";
    if Equals(this.wiped, true) && !statusEffectSystem.HasStatusEffect(this.GetEntityID(), statusEffectID) {
      statusEffectSystem.ApplyStatusEffect(this.GetEntityID(), statusEffectID, this.GetRecordID(), this.GetEntityID());
      this.wiped = false;
    } else {
      if Equals(this.wiped, false) && statusEffectSystem.HasStatusEffect(this.GetEntityID(), statusEffectID) {
        statusEffectSystem.RemoveStatusEffect(this.GetEntityID(), statusEffectID);
      };
    };
}

// works
// slight camera effect
// Game.GetPlayer():BreathHeavy()
@addMethod(PlayerPuppet)
public func BreathHeavy() -> Void {
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(this.GetGame());
    let statusEffectID: TweakDBID = t"BaseStatusEffect.BreathingHeavy";
    statusEffectSystem.ApplyStatusEffect(this.GetEntityID(), statusEffectID, this.GetRecordID(), this.GetEntityID());
}

// also these especially:
// - BaseStatusEffect.PlayerExhausted

// works
// and very well
// Game.GetPlayer():BreathSick()
@addMethod(PlayerPuppet)
public func BreathSick() -> Void {
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(this.GetGame());
    let statusEffectID: TweakDBID = t"BaseStatusEffect.BreathingSick";
    statusEffectSystem.ApplyStatusEffect(this.GetEntityID(), statusEffectID, this.GetRecordID(), this.GetEntityID());
}

// works
// like a glitching effet
// Game.GetPlayer():JustOverload()
@addMethod(PlayerPuppet)
public func JustOverload() -> Void {
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(this.GetGame());
    let statusEffectID: TweakDBID = t"BaseStatusEffect.Overload";
    statusEffectSystem.ApplyStatusEffect(this.GetEntityID(), statusEffectID, this.GetRecordID(), this.GetEntityID());
}

// does not seem to do anything
// Game.GetPlayer():Craving()
@addMethod(PlayerPuppet)
public func Craving() -> Void {
    GameObjectEffectHelper.StartEffectEvent(this, n"status_craving");
}

// does not seem to do anything
// Game.GetPlayer():Poisoned()
// but PlayerPoisoned does some kind of metallic noise with a brief light
@addMethod(PlayerPuppet)
public func Poisoned() -> Void {
    GameObjectEffectHelper.StartEffectEvent(this, n"status_poisoned_heavy");
}

// works
// a glitching effect in an eye blink
// Game.GetPlayer():Glitching()
@addMethod(PlayerPuppet)
public func Glitching() -> Void {
    let blackboard: ref<worldEffectBlackboard> = new worldEffectBlackboard();
    GameObjectEffectHelper.StartEffectEvent(this, n"transition_glitch_loop", false, blackboard);
}

// 
// Game.GetPlayer():JustSecondHeart()
@addMethod(PlayerPuppet)
public func JustSecondHeart() -> Void {
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(this.GetGame());
    let statusEffectID: TweakDBID = t"BaseStatusEffect.SecondHeart";
    statusEffectSystem.ApplyStatusEffect(this.GetEntityID(), statusEffectID, this.GetRecordID(), this.GetEntityID());
}

// 
// Game.GetPlayer():JustJohnny()
@addMethod(PlayerPuppet)
public func JustJohnny() -> Void {
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(this.GetGame());
    let statusEffectID: TweakDBID = t"BaseStatusEffect.JohnnySicknessHeavy";
    statusEffectSystem.ApplyStatusEffect(this.GetEntityID(), statusEffectID, this.GetRecordID(), this.GetEntityID());
}

@addField(PlayerPuppet)
let deaf: Bool;

// does not seem to do anything on V
// Game.GetPlayer():JustDeaf()
@addMethod(PlayerPuppet)
public func JustDeaf() -> Void {
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(this.GetGame());
    let statusEffectID: TweakDBID = t"BaseStatusEffect.Deaf";
    if Equals(this.deaf, false) && !statusEffectSystem.HasStatusEffect(this.GetEntityID(), statusEffectID) {
      statusEffectSystem.ApplyStatusEffect(this.GetEntityID(), statusEffectID, this.GetRecordID(), this.GetEntityID());
      this.deaf = true;
    } else {
      if Equals(this.deaf, true) && statusEffectSystem.HasStatusEffect(this.GetEntityID(), statusEffectID) {
        statusEffectSystem.RemoveStatusEffect(this.GetEntityID(), statusEffectID);
        this.deaf = false;
      };
    };
}

// works
// Game.GetPlayer():JustAnythingReally(TweakDBID.new('BaseStatusEffect.JohnnySicknessHeavy'))
@addMethod(PlayerPuppet)
public func JustAnythingReally(effect: TweakDBID) -> Void {
    GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(this.GetEntityID(), effect, this.GetRecordID(), this.GetEntityID());
}

// these two methods above and below are probably the same

// works
// Game.GetPlayer():JustAlternateReally(TweakDBID.new('BaseStatusEffect.Overload'))
@addMethod(PlayerPuppet)
public func JustAlternateReally(effect: TweakDBID) -> Void {
    StatusEffectHelper.ApplyStatusEffect(this, effect);
}

// wasn't called on interaction with Fast Travel
// wasn't called on interaction with vending machine
// wasn't called on interaction giving homeless some eddies
// wasn't called on disassemble pant
// @wrapMethod(PlayerPuppet)
// protected cb func OnWorkspotStartedEvent(evt: ref<WorkspotStartedEvent>) -> Bool {
//     LogChannel(n"DEBUG", "RED:Addicted:OnWorkspotStartedEvent");
//     // LogChannel(n"DEBUG", "tags: " + concatenate(evt.tags));
//     return wrappedMethod(evt);
// }

// @wrapMethod(PlayerPuppet)
// protected cb func OnWorkspotFinishedEvent(evt: ref<WorkspotFinishedEvent>) -> Bool {
//     LogChannel(n"DEBUG", "RED:Addicted:OnWorkspotFinishedEvent");
//     // LogChannel(n"DEBUG", "tags: " + concatenate(evt.tags));
//     return wrappedMethod(evt);
// }

// does not seem to work with the given examples
// works with the usuals (e.g. 'status_drugged_heavy')
// Game.GetPlayer():JustStartEffect(CName.new('smoke_puff'))
// e.g. for name: ch_sniffing_drugs_01 ch_sniffing_drugs_02 smoke_puff
@addMethod(PlayerPuppet)
public func JustStartEffect(name: CName) -> Void {
    let blackboard: ref<worldEffectBlackboard> = new worldEffectBlackboard();
    GameObjectEffectHelper.StartEffectEvent(this, name, false, blackboard);
}

// see above
// Game.GetPlayer():JustStopEffect(CName.new('smoke_puff'))
@addMethod(PlayerPuppet)
public func JustStopEffect(name: CName) -> Void {
    GameObjectEffectHelper.StopEffectEvent(this, name);
}

// @wrapMethod(NameplateVisualsLogicController)
// public final func SetVisualData(puppet: ref<GameObject>, incomingData: NPCNextToTheCrosshair, opt isNewNpc: Bool) -> Void {
//     wrappedMethod(puppet, incomingData, isNewNpc);
//     LogChannel(n"DEBUG", "RED:Addicted:SetVisualData");
//     if !IsDefined(puppet) {
//         LogChannel(n"DEBUG", "RED:Addicted:SetVisualData (but no puppet)");
//         return;
//     }
//     GameObjectEffectHelper.StartEffectEvent(puppet, n"ch_sniffing_drugs_01", true);
// }

private func concatenate(elems: array<CName>) -> String {
    let i = 0;
    let buf = "";
    let elem: CName;

    while i < ArraySize(elems) {
        elem = elems[i];
        if (i != 0) {
            buf += ", " + ToString(elem);
        } else {
            buf = ToString(elem);
        }
        i += 1;
    }

    return buf;
}

// gamedataStatusEffect_Record :
// <TDBID:7407D72D:20> BaseStatusEffect.FirstAidWhiffV0 (MAXdoc MK.1)
// <TDBID:5D9829EE:1F> BaseStatusEffect.BonesMcCoy70V0 (BounceBack MK.1)

// <TDBID:C28B034A:16> BaseStatusEffect.Sated (after drinking e.g. soda)

// LogChannel(n"DEBUG", "RED:Addicted:OnStatusEffectApplied");
// let someID: TweakDBID = t"BaseStatusEffect.Drugged";
// let moreCommonID: TweakDBID = t"BaseStatusEffect.FirstAidWhiffV0";
// LogChannel(n"DEBUG", s"Its UIData is \(GetLocalizedText(evt.staticData.UiData().DisplayName()))");

// let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
// GameInstance.GetStatusEffectSystem(gameInstance).ApplyStatusEffect(player.GetEntityID(), t"BaseStatusEffect.BreathingHeavy", player.GetRecordID(), player.GetEntityID());

// StopStatusEffectVFX(evt: ref<RemoveStatusEffect>) -> Void
// StopStatusEffectSFX(evt: ref<RemoveStatusEffect>) -> Void
// StartStatusEffectSFX(evt: ref<ApplyStatusEffectEvent>) -> Void
// StartStatusEffectVFX(evt: ref<ApplyStatusEffectEvent>) -> Void
// > GameObjectEffectHelper.StartEffectEvent(this, vfxList[i].Name());
// > > StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.DontShootAtMe");

// GameObjectEffectHelper.StartStatusEffectVFX(...)

// GameObjectEffectHelper.StartEffectEvent(this.GetVehicle(), n"overheating", false, this.m_overheatEffectBlackboard);
// GameObjectEffectHelper.BreakEffectLoopEvent(this.GetVehicle(), n"overheating");

// bioMonitorBB = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_PlayerBioMonitor);
// bioMonitorBB.SetVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.Cooldowns, ToVariant(cooldowns));

// ProcessBreathingEffectApplication(evt: ref<StatusEffectEvent>) -> Void

// base\fx\player\p_digital_sickness\p_digital_sickness.effect
// ch_status_emp
// d_emp_status_big
// status_craving

// BaseStatusEffect.MemoryWipeLevel2
// DamageSystem private final func IsImmune(target: ref<GameObject>, statusEffectID: TweakDBID) -> Bool {}

// let blackboard: ref<worldEffectBlackboard> = new worldEffectBlackboard();
// GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"transition_glitch_loop", false, blackboard);

// BaseStatusEffect.AlcoholDebuff
// BaseStatusEffect.SecondHeart
// BaseStatusEffect.Blind
// BaseStatusEffect.Grappled

// GameObject.PlayVoiceOver(ScriptExecutionContext.GetOwner(context), n"hit_reaction_heavy", n"Scripts:KnockdownReactionTask");

// StatusEffectHelper.ApplyStatusEffect(this.GetOwner(), t"BaseStatusEffect.CrippledLegLeft");

// maintenancePanel.swift
// let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(activator.GetGame());
// workspotSystem.PlayInDeviceSimple(this, activator, freeCamera, componentName, n"deviceWorkspot");
// base\gameplay\devices\disassemblable\maintenance_panel.workspot
// base\workspots\quest\main_quests\part1\q101\01_covered_in_trash\player__lie__2h_down__crawling__16.workspot

// log these: see workspots.swift
// FTLog("[WorkspotFunctionalTestsDebugListener:OnWorkspotSetup] EntityID: " + EntityID.ToDebugString(this.m_entityId) + " path: " + path);
