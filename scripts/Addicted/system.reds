module Addicted

public class PlayerAddictionSystem extends ScriptableSystem {
    private persistent let m_maxdocThreshold: Int32;
    private persistent let m_bouncebackThreshold: Int32;
    private persistent let m_fr3shThreshold: Int32;

    public final static func GetInstance(owner: wref<GameObject>) -> ref<PlayerAddictionSystem> {
        let PAS: ref<PlayerAddictionSystem> = GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"PlayerAddictionSystem") as PlayerAddictionSystem;
        return PAS;
    }

    private func OnAttach() -> Void {
        LogChannel(n"DEBUG", "RED:PlayerAddictionSystem::OnAttach");
    }

    private func OnDetach() -> Void {
        LogChannel(n"DEBUG", "RED:PlayerAddictionSystem::OnDetach");
    }

    private final func OnWithdrawalSymptom(request: ref<BlockAmmoDrop>) -> Void {
        LogChannel(n"DEBUG", "RED:PlayerAddictionSystem::OnWithdrawalSymptom");
    }

    public func OnAddictiveSubstanceConsumed(substanceID: TweakDBID) -> Void {
        LogChannel(n"DEBUG", "RED:PlayerAddictionSystem::OnAddictiveSubstanceConsumed");
    }
}