module Addicted

enum Threshold {
    Clean = 0,
    Barely = 10,
    Mildly = 20,
    Notably = 40,
    Severely = 60,
}

public class Addiction {
    public persistent let id: TweakDBID;
    public persistent let consumption: Int32;
}

public class CheckAddictionStateRequest extends ScriptableSystemRequest {}
public class PlayAddictionEffectRequest extends ScriptableSystemRequest {
    public let effects: array<TweakDBID>;
}

public class PlayerAddictionSystem extends ScriptableSystem {
    private persistent let m_addictions: array<ref<Addiction>>;
    private persistent let m_lastRestTimestamp: Float;
    public persistent let m_startRestingAtTimestamp: Float;
    public let m_checkDelayID: DelayID;
    public let m_playDelayID: DelayID;

    private func OnAttach() -> Void {
        super.OnAttach();
        LogChannel(n"DEBUG", s"RED:OnAttach");
        this.Reschedule();
    }

    // testing, but base for a correct rescheduling
    private func Reschedule() -> Void {
        let system = GameInstance.GetDelaySystem(this.GetGameInstance());
        if this.m_checkDelayID != GetInvalidDelayID() {
            system.CancelDelay(this.m_checkDelayID);
            this.m_checkDelayID = GetInvalidDelayID();
        }
        let request = new CheckAddictionStateRequest();
        this.m_checkDelayID = system.DelayScriptableSystemRequest(this.GetClassName(), request, 15, false);
    }

    public func Plan(effects: array<TweakDBID>) -> Void {
        if this.m_playDelayID != GetInvalidDelayID() {
            return;
        }
        let system = GameInstance.GetDelaySystem(this.GetGameInstance());
        let request = new PlayAddictionEffectRequest();
        request.effects = effects;
        this.m_playDelayID = system.DelayScriptableSystemRequest(this.GetClassName(), request, 0.5, true);
    }

    protected final func OnPlayAddictionEffectRequest(request: ref<PlayAddictionEffectRequest>) -> Void {
        let system = GameInstance.GetDelaySystem(this.GetGameInstance());
        system.CancelDelay(this.m_playDelayID);
        if ArraySize(request.effects) > 0 {
            let next = ArrayPop(request.effects);
            StatusEffectHelper.ApplyStatusEffect(GetPlayer(this.GetGameInstance()), next);
            this.m_playDelayID = system.DelayScriptableSystemRequest(this.GetClassName(), request, 3, true);
        }
    }

    protected final func OnCheckAdditionStateRequest(request: ref<CheckAddictionStateRequest>) -> Void {
        LogChannel(n"DEBUG", "RED:OnCheckAdditionStateRequest");
        // ok, this works
        // GetPlayer(this.GetGameInstance()).FeelsDizzy();
        // this.Reschedule();
    }

    public func OnAddictiveSubstanceConsumed(substanceID: TweakDBID) -> Void {
        for addiction in this.m_addictions {
            if addiction.id == substanceID {
                addiction.consumption += (this.AddictionPotency(substanceID) * this.AddictionMultiplier(substanceID));
                LogChannel(n"DEBUG", s"RED:OnAddictiveSubstanceConsumed: \(TDBID.ToStringDEBUG(addiction.id)) current consumption: \(ToString(addiction.consumption))");
                return;
            }
        }
        LogChannel(n"DEBUG", s"RED:OnAddictiveSubstanceConsumed: \(TDBID.ToStringDEBUG(substanceID)) first consumption");
        let addiction = new Addiction();
        addiction.id = substanceID;
        addiction.consumption = this.AddictionPotency(substanceID);
        ArrayPush(this.m_addictions, addiction);
    }

    public func OnAddictiveSubstanceWeanOff() -> Void {
        for addiction in this.m_addictions {
            if addiction.consumption > 0 {
                addiction.consumption -= 1;
                LogChannel(n"DEBUG", s"RED:OnAddictiveSubstanceWeanOff: \(TDBID.ToStringDEBUG(addiction.id)) current consumption: \(ToString(addiction.consumption))");
            } else {
                LogChannel(n"DEBUG", s"RED:OnAddictiveSubstanceWeanOff: \(TDBID.ToStringDEBUG(addiction.id)) completely weaned off!");
                ArrayRemove(this.m_addictions, addiction);
            }
        }
    }

    public func OnRested(timestamp: Float) -> Void {
        let diff = timestamp - this.m_startRestingAtTimestamp;
        let diffInHours = RoundF(diff / 3600.0);
        LogChannel(n"DEBUG", s"RED:OnRested: rested since: \(ToString(this.m_startRestingAtTimestamp)), rested until: \(ToString(timestamp)), diff in hours (rounded): \(ToString(diffInHours)), last rest: \(ToString(this.m_lastRestTimestamp))");
        let day = (24.0 * 3600.0);
        let cycle = (8.0 * 3600.0);
        let initial = (timestamp == 0.0);
        let scarce = (timestamp >= (this.m_lastRestTimestamp + day + cycle));
        if initial || scarce {
            this.OnAddictiveSubstanceWeanOff();
            this.m_lastRestTimestamp = timestamp;
        }
    }

    private func GetConsumption(substanceID: TweakDBID) -> Int32 {
        for addiction in this.m_addictions {
            if addiction.id == substanceID {
                return addiction.consumption;
            }
        }
        return -1;
    }

    private func GetThreshold(substanceID: TweakDBID) -> Threshold {
        for addiction in this.m_addictions {
            if addiction.id == substanceID {
                if addiction.consumption > EnumInt(Threshold.Severely) {
                    return Threshold.Severely;
                }
                if addiction.consumption > EnumInt(Threshold.Notably) && addiction.consumption <= EnumInt(Threshold.Severely) {
                    return Threshold.Notably;
                }
                if addiction.consumption > EnumInt(Threshold.Mildly) && addiction.consumption <= EnumInt(Threshold.Notably) {
                    return Threshold.Notably;
                }
                if addiction.consumption > EnumInt(Threshold.Barely) && addiction.consumption <= EnumInt(Threshold.Mildly) {
                    return Threshold.Mildly;
                }
                if addiction.consumption > EnumInt(Threshold.Clean) {
                    return Threshold.Barely;
                }
                return Threshold.Clean;
            }
        }
        return Threshold.Clean;
    }

    public func AddictionMultiplier(substanceID: TweakDBID) -> Int32 {
        let threshold = this.GetThreshold(substanceID);
        switch (threshold) {
            case Threshold.Severely:
            case Threshold.Notably:
                return 2;
            default:
                return 1;
        }
        return 1;
    }

    private func AddictionPotency(substanceID: TweakDBID) -> Int32 {
        switch(substanceID) {
            case t"BaseStatusEffect.FirstAidWhiffV0":
                return 1;
            case t"BaseStatusEffect.BonesMcCoy70V0":
                return 2;
            case t"BaseStatusEffect.FR3SH":
                return 2;
            // TODO: add missing
            default:
                return 1;
        }
    }
}