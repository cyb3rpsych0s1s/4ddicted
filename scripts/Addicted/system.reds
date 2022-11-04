module Addicted.System

public class PlayerAddictionSystem extends ScriptableSystem {
    private let m_canExperienceWithdrawalSymptom: Bool;

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
        // TODO
    }
}