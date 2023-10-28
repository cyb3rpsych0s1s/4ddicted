module Addicted

native func IsLosingPotency(system: ref<System>, item: ItemID) -> Bool;

// used at all times, before status effects are processed
@wrapMethod(ConsumeAction)
protected func ProcessStatusEffects(const actionEffects: script_ref<array<wref<ObjectActionEffect_Record>>>, gameInstance: GameInstance) -> Void {
    LogChannel(n"DEBUG", "[ConsumeAction] ProcessStatusEffects...");
    let i: Int32 = 0;
    while i < ArraySize(Deref(actionEffects)) {
        LogChannel(n"DEBUG", TDBID.ToStringDEBUG(Deref(actionEffects)[i].StatusEffect().GetID()));
        i += 1;
    }
    LogChannel(n"DEBUG", "--------------------------------------------");
    wrappedMethod(actionEffects, gameInstance);
}

// used at all times, before status effects are processed
@wrapMethod(UseHealChargeAction)
protected func ProcessStatusEffects(const actionEffects: script_ref<array<wref<ObjectActionEffect_Record>>>, gameInstance: GameInstance) -> Void {
    LogChannel(n"DEBUG", "[UseHealChargeAction] ProcessStatusEffects...");
    let i: Int32;
    i = 0;
    while i < ArraySize(Deref(actionEffects)) {
        LogChannel(n"DEBUG", s"BEFORE: \(TDBID.ToStringDEBUG(Deref(actionEffects)[i].StatusEffect().GetID()))");
        if Deref(actionEffects)[i].StatusEffect().GetID() == t"BaseStatusEffect.FirstAidWhiffVEpic" {
            Deref(actionEffects)[i] = TweakDBInterface.GetObjectActionEffectRecord(t"Items.SeverelyWeakenedActionEffectFirstAidWhiffVEpic");
        } else if Deref(actionEffects)[i].StatusEffect().GetID() == t"BaseStatusEffect.BonesMcCoy70V0" {
            Deref(actionEffects)[i] = TweakDBInterface.GetObjectActionEffectRecord(t"Items.SeverelyWeakenedActionEffectBonesMcCoy70V0");
        }
        LogChannel(n"DEBUG", s"AFTER: \(TDBID.ToStringDEBUG(Deref(actionEffects)[i].StatusEffect().GetID()))");
        i += 1;
    }
    LogChannel(n"DEBUG", "--------------------------------------------");
    wrappedMethod(actionEffects, gameInstance);
}

/*

private final func OnStatusEffectUsedHealingItemOrCyberwareApplied() -> Void
ItemActionsHelper.UseHealCharge
private final const func CompareWithPlayerHealingItemsQuality(itemStack: script_ref<SItemStack>) -> Bool
func OnStatusEffectUsedHealingItemOrCyberwareApplied
protected final func ChangeConsumableAnimFeature(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, newState: Bool) -> Void
public class ConsumableStartupEvents extends ConsumableTransitions
public class PlayerHandicapSystem extends IPlayerHandicapSystem
public importonly struct PlayerBioMonitor
public class UI_PlayerStatsDef extends BlackboardDefinition
protected cb func OnHealthUpdateEvent(evt: ref<HealthUpdateEvent>) -> Bool
private final func SetHealthProgress(value: Float) -> Void

public class UseConsumableEffector extends Effector
protected func ProcessStatusEffects(const actionEffects: script_ref<array<wref<ObjectActionEffect_Record>>>, gameInstance: GameInstance) -> Void
public class ModifyStatPoolModifierEffector extends Effector : this is the one responsible for setting health
StatRecord
RequestSettingModifierWithRecord / RequestChangingStatPoolValue

BaseStatusEffect.FirstAidWhiff_inline3
    statModifiers
        CombinedStatModifier_Record: BaseStats.InhalerBaseHealing > BaseStatPools.Health

BaseStatusEffect.BonesMcCoy70VEpic
    BaseStatusEffect.BonesMcCoy70V0_inline1
        ModiyStatPoolModifier_Record: BaseStats.InjectorBaseOverTheTimeHealing > BaseStats.InjectorBaseOverTheTimeHealing

*/
