module Addicted

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

native func OnProcessStatusEffect(actionEffects: array<wref<ObjectActionEffect_Record>>) -> Void;
native func IsLosingPotency(system: ref<System>, item: ItemID) -> Bool;

@wrapMethod(ConsumeAction)
protected func ProcessStatusEffects(const actionEffects: script_ref<array<wref<ObjectActionEffect_Record>>>, gameInstance: GameInstance) -> Void {
    LogChannel(n"DEBUG", "[ConsumeAction] ProcessStatusEffects...");
    let i: Int32 = 0;
    while i < ArraySize(Deref(actionEffects)) {
        LogChannel(n"DEBUG", TDBID.ToStringDEBUG(Deref(actionEffects)[i].StatusEffect().GetID()));
        i += 1;
    }
    LogChannel(n"DEBUG", "---------------------------------------------");
    wrappedMethod(actionEffects, gameInstance);
}

@wrapMethod(UseHealChargeAction)
protected func ProcessStatusEffects(const actionEffects: script_ref<array<wref<ObjectActionEffect_Record>>>, gameInstance: GameInstance) -> Void {
    LogChannel(n"DEBUG", "[UseHealChargeAction] ProcessStatusEffects...");
    let i: Int32;
    i = 0;
    // LogChannel(n"DEBUG", "------------------BEFORE---------------------");
    while i < ArraySize(Deref(actionEffects)) {
        LogChannel(n"DEBUG", TDBID.ToStringDEBUG(Deref(actionEffects)[i].StatusEffect().GetID()));
        i += 1;
    }
    // i = 0;
    // while i < ArraySize(Deref(actionEffects)) {
    //     if Deref(actionEffects)[i].StatusEffect().GetID() == t"BaseStatusEffect.FirstAidWhiffVEpic" {
    //         Deref(actionEffects)[i] = TweakDBInterface.GetObjectActionEffectRecord(t"BaseStatusEffect.BlackLaceV1");
    //     }
    //     i += 1;
    // }
    // i = 0;
    // LogChannel(n"DEBUG", "------------------AFTER----------------------");
    // while i < ArraySize(Deref(actionEffects)) {
    //     LogChannel(n"DEBUG", TDBID.ToStringDEBUG(Deref(actionEffects)[i].StatusEffect().GetID()));
    //     i += 1;
    // }
    LogChannel(n"DEBUG", "---------------------------------------------");
    wrappedMethod(actionEffects, gameInstance);
}

@wrapMethod(BaseScriptableAction)
protected func ProcessStatusEffects(const actionEffects: script_ref<array<wref<ObjectActionEffect_Record>>>, gameInstance: GameInstance) -> Void {
    LogChannel(n"DEBUG", "[BaseScriptableAction] ProcessStatusEffects...");
    let i: Int32 = 0;
    while i < ArraySize(Deref(actionEffects)) {
        LogChannel(n"DEBUG", TDBID.ToStringDEBUG(Deref(actionEffects)[i].StatusEffect().GetID()));
        i += 1;
    }
    LogChannel(n"DEBUG", "---------------------------------------------");
    wrappedMethod(actionEffects, gameInstance);
}