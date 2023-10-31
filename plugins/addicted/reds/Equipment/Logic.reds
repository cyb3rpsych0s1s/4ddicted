import Addicted.Threshold
import Addicted.System

public abstract class ModifyStatPoolWeakenableValueEffector extends ModifyStatPoolValueEffector {
    protected func GetTargetStat() -> gamedataStatPoolType;
    protected func GetTargetStatusEffect() -> ref<StatusEffect_Record>;
    private final func ProcessEffector(owner: ref<GameObject>) -> Void {
        let applicationTargetID: EntityID;
        let i: Int32;
        let poolSys: ref<StatPoolsSystem>;
        let statModifiers: array<wref<StatModifier_Record>>;
        let statPoolType: gamedataStatPoolType;
        let statPoolValue: Float;
        let threshold: Threshold;
        if !this.GetApplicationTarget(owner, this.m_applicationTarget, applicationTargetID) {
            return;
        };
        threshold = System.GetInstance(owner.GetGame()).GetThresholdFromAppliedEffects(this.GetTargetStatusEffect());
        poolSys = GameInstance.GetStatPoolsSystem(owner.GetGame());
        i = 0;
        while i < ArraySize(this.m_statPoolUpdates) {
            statPoolType = this.m_statPoolUpdates[i].StatPoolType().StatPoolType();
            if this.m_statPoolUpdates[i].GetStatModifiersCount() > 0 {
                ArrayClear(statModifiers);
                this.m_statPoolUpdates[i].StatModifiers(statModifiers);
                statPoolValue = GameInstance.GetStatsSystem(owner.GetGame()).CalculateModifierListValue(Cast<StatsObjectID>(applicationTargetID), statModifiers);
            } else {
                statPoolValue = this.m_statPoolUpdates[i].StatPoolValue();
            };
            if Equals(statPoolType, this.GetTargetStat()) {
                if Equals(threshold, Threshold.Notably)  { statPoolValue -= 0.3; }
                if Equals(threshold, Threshold.Severely) { statPoolValue -= 0.7; }
            }
            if this.m_setValue {
                poolSys.RequestSettingStatPoolValue(Cast<StatsObjectID>(applicationTargetID), statPoolType, statPoolValue, owner, this.m_usePercent);
            } else {
                poolSys.RequestChangingStatPoolValue(Cast<StatsObjectID>(applicationTargetID), statPoolType, statPoolValue, owner, false, this.m_usePercent);
            };
            i += 1;
        };
    }
}

public class ModifyAddictToFirstAidWhiffStatPoolValueEffector extends ModifyStatPoolWeakenableValueEffector {
    protected func GetTargetStat() -> gamedataStatPoolType { return gamedataStatPoolType.Health; }
    protected func GetTargetStatusEffect() -> ref<StatusEffect_Record> { return TweakDBInterface.GetStatusEffectRecord(t"BaseStatusEffect.AddictToFirstAidWhiff"); }
}

public class ModifyAddictToBonesMcCoy70StatPoolValueEffector extends ModifyStatPoolWeakenableValueEffector {
    protected func GetTargetStat() -> gamedataStatPoolType { return gamedataStatPoolType.Health; }
    protected func GetTargetStatusEffect() -> ref<StatusEffect_Record> { return TweakDBInterface.GetStatusEffectRecord(t"BaseStatusEffect.AddictToBonesMcCoy70"); }
}