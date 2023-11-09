import Addicted.Threshold
import Addicted.System
import Addicted.Consumable
import Martindale.MartindaleSystem
import Addicted.IsConsumable

// modify health stat pool update based on addiction, directly overriden on vanilla
public class ModifyStatPoolValueBasedOnAddictionEffector extends ModifyStatPoolValueEffector {
    private let addicted: TweakDBID;
    protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
        super.Initialize(record, game, parentRecord);
        LogChannel(n"DEBUG", s"parentRecord: \(TDBID.ToStringDEBUG(parentRecord))");
        let main = System.GetInstance(game);
        let martindale = MartindaleSystem.GetInstance(game);
        let effector = TweakDBInterface.GetEffectorRecord(record);
        if martindale.IsMaxDOCEffector(effector) {
            this.addicted = main.GetAddictStatusEffectID(Consumable.MaxDOC);
        } else if martindale.IsBounceBackEffector(effector) {
            this.addicted = main.GetAddictStatusEffectID(Consumable.BounceBack);
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

public class OnStatusEffectBasedOnAddictionAppliedListener extends ScriptStatusEffectListener {
    public let m_effector: wref<ModifyStatusEffectDurationBasedOnAddictionEffector>;
    public let m_owner: wref<GameObject>;

    public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
        let item = MartindaleSystem.GetInstance(this.m_owner.GetGame()).GetConsumableItemFromStatusEffect(statusEffect);
        if IsConsumable(item, this.m_effector.Consumable()) {
            this.m_effector.ProcessAction(this.m_owner);
        }
    }
}

// modify status effect duration based on addiction, applyied on addiction status effect itself
public class ModifyStatusEffectDurationBasedOnAddictionEffector extends Effector {
    private let m_statusEffectListener: ref<OnStatusEffectBasedOnAddictionAppliedListener>;
    public let m_change: Float;
    public let m_gameInstance: GameInstance;
    private let m_consumable: Consumable;

    public func Consumable() -> Consumable { return this.m_consumable; }
    protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
        LogChannel(n"DEBUG", "initialize ModifyStatusEffectDurationBasedOnAddictionEffector");
        this.m_change = 100.;
        this.m_gameInstance = game;
        // cases MUST match YAML definitions
        switch parentRecord {
            case t"Packages.ShortenHealthBoosterDuration":
                this.m_consumable = Consumable.HealthBooster;
                break;
            case t"Packages.ShortenNeuroBlockerDuration":
                this.m_consumable = Consumable.NeuroBlocker;
                break;
            default:
                this.m_consumable = Consumable.Invalid;
                LogChannel(n"ASSERT", s"unknown addicted status effect (\(TDBID.ToStringDEBUG(parentRecord)))");
                break;
        }
        LogChannel(n"DEBUG", s"ModifyStatusEffectDurationBasedOnAddictionEffector.m_consumable = \(ToString(this.m_consumable))");
    }
    public final func ProcessAction(owner: ref<GameObject>) -> Void {
        LogChannel(n"DEBUG", "process action ModifyStatusEffectDurationBasedOnAddictionEffector");
        let player: ref<PlayerPuppet> = owner as PlayerPuppet;
        if !IsDefined(player) || Equals(this.m_consumable, Consumable.Invalid) { 
            return;
        }

        let main = System.GetInstance(owner.GetGame());
        let addict = TweakDBInterface.GetStatusEffectRecord(main.GetAddictStatusEffectID(this.m_consumable));
        let threshold = System.GetInstance(owner.GetGame()).GetThresholdFromAppliedEffects(addict);
        this.m_change = 100.;
        LogChannel(n"DEBUG", s"threshold from \(TDBID.ToStringDEBUG(addict.GetID())): \(ToString(threshold))");
        if Equals(threshold, Threshold.Notably)       { this.m_change = 30; }
        else if Equals(threshold, Threshold.Severely) { this.m_change = 70; }
        if this.m_change == 100. { return; }

        let applied: array<ref<StatusEffect>> = StatusEffectHelper.GetAppliedEffectsForConsumable(owner, this.m_consumable);
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
                LogChannel(n"DEBUG", s"shortening duration for \(TDBID.ToStringDEBUG(applied[i].GetRecord().GetID())) \(applied[i].GetRemainingDuration()) -> \(remaining)");
                GameInstance.GetStatusEffectSystem(this.m_gameInstance).SetStatusEffectRemainingDuration(owner.GetEntityID(), applied[i].GetRecord().GetID(), remaining);
            }
            i += 1;
        }
    }

    protected func ActionOn(owner: ref<GameObject>) -> Void {
        LogChannel(n"DEBUG", "action on ModifyStatusEffectDurationBasedOnAddictionEffector");
        this.ProcessAction(owner);
        this.m_statusEffectListener = new OnStatusEffectBasedOnAddictionAppliedListener();
        this.m_statusEffectListener.m_owner = owner;
        this.m_statusEffectListener.m_effector = this;
        GameInstance
        .GetStatusEffectSystem(this.m_gameInstance)
        .RegisterListener(owner.GetEntityID(), this.m_statusEffectListener);
    }

    protected func RepeatedAction(owner: ref<GameObject>) -> Void {
        LogChannel(n"DEBUG", "repeated action ModifyStatusEffectDurationBasedOnAddictionEffector");
        this.ProcessAction(owner);
    }

    protected func ActionOff(owner: ref<GameObject>) -> Void {
        LogChannel(n"DEBUG", "action off ModifyStatusEffectDurationBasedOnAddictionEffector");
        this.m_statusEffectListener = null;
    }
}