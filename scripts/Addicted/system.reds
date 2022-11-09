module Addicted

public class Addiction {
    public let id: TweakDBID;
    public let consumption: Int32;
    public let threshold: Int32;
}

public class PlayerAddictionSystem extends ScriptableSystem {
    private persistent let m_addictions: array<ref<Addiction>>;
    private persistent let m_lastRestTimestamp: Float;

    public func OnAddictiveSubstanceConsumed(substanceID: TweakDBID) -> Void {
        for addiction in this.m_addictions {
            if addiction.id == substanceID {
                addiction.consumption += 1;
                LogChannel(n"DEBUG", s"RED:OnAddictiveSubstanceConsumed: \(TDBID.ToStringDEBUG(addiction.id)) current consumption: \(ToString(addiction.consumption))");
                let next = this.GetNextThreshold(addiction.id);
                if next != -1 && addiction.threshold < 3 && addiction.consumption >= next {
                    addiction.threshold += 1;
                    LogChannel(n"DEBUG", s"RED:OnAddictiveSubstanceConsumed: \(TDBID.ToStringDEBUG(addiction.id)) threshold increased: \(ToString(addiction.threshold)) :(");
                }
                return;
            }
        }
        LogChannel(n"DEBUG", s"RED:OnAddictiveSubstanceConsumed: \(TDBID.ToStringDEBUG(substanceID)) first consumption");
        let addiction = new Addiction();
        addiction.id = substanceID;
        addiction.consumption = 1;
        addiction.threshold = 0;
        ArrayPush(this.m_addictions, addiction);
    }

    public func OnAddictiveSubstanceWeanOff() -> Void {
        for addiction in this.m_addictions {
            if addiction.consumption > 0 {
                addiction.consumption -= 1;
                LogChannel(n"DEBUG", s"RED:OnAddictiveSubstanceWeanOff: \(TDBID.ToStringDEBUG(addiction.id)) current consumption: \(ToString(addiction.consumption))");
                let previous = this.GetPreviousThreshold(addiction.id);
                if previous != -1 && addiction.threshold > 0 && addiction.consumption < previous {
                    addiction.threshold -= 1;
                    LogChannel(n"DEBUG", s"RED:OnAddictiveSubstanceWeanOff: \(TDBID.ToStringDEBUG(addiction.id)) threshold decreased: \(ToString(addiction.threshold)) :)");
                }
            } else {
                if addiction.threshold == 0 {
                    LogChannel(n"DEBUG", s"RED:OnAddictiveSubstanceWeanOff: \(TDBID.ToStringDEBUG(addiction.id)) completely weaned off!");
                    ArrayRemove(this.m_addictions, addiction);
                }
            }
        }
    }

    public func OnRested(timestamp: Float) -> Void {
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

    private func GetThreshold(substanceID: TweakDBID) -> Int32 {
        for addiction in this.m_addictions {
            if addiction.id == substanceID {
                return addiction.threshold;
            }
        }
        return -1;
    }

    public func GetNextThreshold(substanceID: TweakDBID) -> Int32 {
        let current = this.GetThreshold(substanceID);
        switch(substanceID) {
            case t"BaseStatusEffect.FirstAidWhiffV0":
                if current > 60 {
                    return -1;
                }
                if current > 40 {
                    return 60;
                }
                return 20;
            case t"BaseStatusEffect.BonesMcCoy70V0":
                if current > 60 {
                    return -1;
                }
                if current > 40 {
                    return 60;
                }
                return 20;
            case t"BaseStatusEffect.FR3SH":
                if current > 60 {
                    return -1;
                }
                if current > 40 {
                    return 60;
                }
                return 20;
            default:
                return -1;
        }
    }

    public func GetPreviousThreshold(substanceID: TweakDBID) -> Int32 {
        let current = this.GetThreshold(substanceID);
        switch(substanceID) {
            case t"BaseStatusEffect.FirstAidWhiffV0":
                if current >= 60 {
                    return 40;
                }
                if current >= 40 {
                    return 20;
                }
                return 0;
            case t"BaseStatusEffect.BonesMcCoy70V0":
                if current >= 60 {
                    return 40;
                }
                if current >= 40 {
                    return 20;
                }
                return 0;
            case t"BaseStatusEffect.FR3SH":
                if current >= 60 {
                    return 40;
                }
                if current >= 40 {
                    return 20;
                }
                return 0;
            default:
                return -1;
        }
    }
}