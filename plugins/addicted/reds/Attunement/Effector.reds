import Addicted.Threshold
import Addicted.System
import Martindale.MartindaleSystem

// modify health stat pool update based on addiction, directly overriden on vanilla
public class ModifyStatPoolValueBasedOnAddictionEffector extends ModifyStatPoolValueEffector {
    private let addicted: TweakDBID;
    protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
        super.Initialize(record, game, parentRecord);
        LogChannel(n"DEBUG", s"parentRecord: \(TDBID.ToStringDEBUG(parentRecord))");
        let system = MartindaleSystem.GetInstance(game);
        let effector = TweakDBInterface.GetEffectorRecord(record);
        if system.IsMaxDOCEffector(effector) {
            this.addicted = t"BaseStatusEffect.MaxDOCAddict";
        } else if system.IsBounceBackEffector(effector) {
            this.addicted = t"BaseStatusEffect.BounceBackAddict";
        } else {
            LogChannel(n"ASSERT", s"unknown addicted status effect (\(TDBID.ToStringDEBUG(record)))");
        }
    }
    private final func ProcessEffector(owner: ref<GameObject>) -> Void {
        if !TDBID.IsValid(this.addicted) { 
            super.ProcessEffector(owner);
            return;
        }
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
        let addict = TweakDBInterface.GetStatusEffectRecord(this.addicted);
        threshold = System.GetInstance(owner.GetGame()).GetThresholdFromAppliedEffects(addict);
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
            if Equals(statPoolType, gamedataStatPoolType.Health) {
                LogChannel(n"DEBUG", s"threshold on modify health stat pool: \(ToString(threshold))");
                if Equals(threshold, Threshold.Notably)       { statPoolValue -= 0.3; }
                else if Equals(threshold, Threshold.Severely) { statPoolValue -= 0.7; }
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

// modify status effect duration based on addiction, applyied on addiction status effect itself
public class ModifyStatusEffectDurationBasedOnAddictionEffector extends ModifyStatusEffectDurationEffector {
    private let addicted: TweakDBID;
    protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
        super.Initialize(record, game, parentRecord);
        switch parentRecord {
            case t"Packages.ShortenHealthBoosterDuration":
                this.addicted = t"BaseStatusEffect.HealthBoosterAddict";
                break;
            case t"Packages.ShortenNeuroBlockerDuration":
                this.addicted = t"BaseStatusEffect.NeuroBlockerAddict";
                break;
            default:
                LogChannel(n"ASSERT", s"unknown addicted status effect (\(TDBID.ToStringDEBUG(parentRecord)))");
                break;
        }
    }
    public final func ProcessAction(owner: ref<GameObject>) -> Void {
        let player: ref<PlayerPuppet> = owner as PlayerPuppet;
        if !IsDefined(player) || !TDBID.IsValid(this.addicted) { 
            super.ProcessAction(owner);
            return;
        }

        let system = MartindaleSystem.GetInstance(player.GetGame());
        let addict = TweakDBInterface.GetStatusEffectRecord(this.addicted);
        let threshold = System.GetInstance(owner.GetGame()).GetThresholdFromAppliedEffects(addict);
        this.m_change = 100.;
        if Equals(threshold, Threshold.Notably)       { this.m_change = 30; }
        else if Equals(threshold, Threshold.Severely) { this.m_change = 70; }
        if this.m_change == 100. { return; }

        let applied: array<ref<StatusEffect>>;
        if this.addicted == t"BaseStatusEffect.HealthBoosterAddict" {
            applied = system.GetAppliedEffectsForHealthBooster(player);
        }
        else if this.addicted == t"BaseStatusEffect.NeuroBlockerAddict" {
            applied = system.GetAppliedEffectsForNeuroBlocker(player);
        }
        let i: Int32 = 0;
        let remaining: Float;
        let change: Float;
        let value: Float;
        let duration: wref<StatModifierGroup_Record>;
        let modifiers: array<wref<StatModifier_Record>>;

        while i < ArraySize(applied) {
            remaining = applied[i].GetRemainingDuration();
            if remaining <= 0.00 {
            } else {
                duration = applied[i].GetRecord().Duration();
                duration.StatModifiers(modifiers);
                value = RPGManager.CalculateStatModifiers(modifiers, this.m_gameInstance, owner, Cast<StatsObjectID>(owner.GetEntityID()));
                change = value * this.m_change / 100.00;
                remaining = MaxF(0.00, remaining + change);
                GameInstance.GetStatusEffectSystem(this.m_gameInstance).SetStatusEffectRemainingDuration(owner.GetEntityID(), applied[i].GetRecord().GetID(), remaining);
            }
            i += 1;
        }
    }
}