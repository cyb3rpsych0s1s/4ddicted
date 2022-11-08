module Addicted

public class PlayerAddictionSystem extends ScriptableSystem {
    private persistent let m_maxdocConsumed: Int32;
    private persistent let m_bouncebackConsumed: Int32;
    private persistent let m_fr3shConsumed: Int32;

    private func OnAttach() -> Void {
        // LogChannel(n"DEBUG", "RED:PlayerAddictionSystem::OnAttach");
    }

    private func OnDetach() -> Void {
        // LogChannel(n"DEBUG", "RED:PlayerAddictionSystem::OnDetach");
    }

    public func GetMaxdocConsumed() -> Int32 { return this.m_maxdocConsumed; }
    public func GetBouncebackConsumed() -> Int32 { return this.m_bouncebackConsumed; }
    public func GetFr3shConsumed() -> Int32 { return this.m_fr3shConsumed; }

    public func OnAddictiveSubstanceConsumed(substanceID: TweakDBID) -> Void {
        // LogChannel(n"DEBUG", "RED:PlayerAddictionSystem::OnAddictiveSubstanceConsumed");
        if substanceID == t"BaseStatusEffect.FirstAidWhiffV0" {
            this.m_maxdocConsumed += 1;
        }
        if substanceID == t"BaseStatusEffect.BonesMcCoy70V0" {
            this.m_bouncebackConsumed += 1;
        }
        if substanceID == t"BaseStatusEffect.FR3SH" {
            this.m_fr3shConsumed += 1;
        }
    }

    private func GetConsumption(substanceID: TweakDBID) -> Int32 {
        switch(substanceID) {
            case t"BaseStatusEffect.FirstAidWhiffV0":
                return this.m_maxdocConsumed;
            case t"BaseStatusEffect.BonesMcCoy70V0":
                return this.m_bouncebackConsumed;
            case t"BaseStatusEffect.FR3SH":
                return this.m_fr3shConsumed;
            default:
                return -1;
        }
    }

    private func GetThreshold(substanceID: TweakDBID) -> Int32 {
        switch(substanceID) {
            case t"BaseStatusEffect.FirstAidWhiffV0":
                return 3;
            case t"BaseStatusEffect.BonesMcCoy70V0":
                return 3;
            case t"BaseStatusEffect.FR3SH":
                return 6;
            default:
                return -1;
        }
    }

    public func IsSlippin(substanceID: TweakDBID) -> Bool {
        let threshold = this.GetThreshold(substanceID);
        let current = this.GetConsumption(substanceID);
        if current == -1 || threshold == -1 {
            return false;
        }
        return current < threshold;
    }
}