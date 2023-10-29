module Addicted

native func IsLosingPotency(system: ref<System>, item: ItemID) -> Bool;

@wrapMethod(PlayerPuppet)
protected func StartStatusEffectVFX(evt: ref<ApplyStatusEffectEvent>) -> Void {
    let vfxs: array<wref<StatusEffectFX_Record>> = [];
    evt.staticData.VFX(vfxs);
    for vfx in vfxs {
        LogChannel(n"DEBUG", s"name: \(NameToString(vfx.Name())), should reapply: \(vfx.ShouldReapply())");
    }
    wrappedMethod(evt);
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
