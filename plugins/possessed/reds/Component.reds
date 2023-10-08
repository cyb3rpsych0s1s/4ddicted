module Possessed

import Codeware.*

native func CreateGimmick(player: wref<PlayerPuppet>, spec: ref<DynamicEntitySpec>) -> EntityID;

public class GimmickComponent extends ScriptableComponent {
    private let owner: wref<PlayerPuppet>;
    private let gimmick: EntityID;

    private final func Create(spec: ref<DynamicEntitySpec>) -> EntityID {
        return CreateGimmick(this.owner, spec);
    }

    public final func OnGameAttach() -> Void {}
}

// look into: idle
// - not in combat
// - not in stealth
// - not in vehicle
// - not on a mission
// - not puchasing (e.g. from seller)
// - not in a game menu
// - not chased by police
// - not in dialog
// - not on the phone
// - not controlling device
// - not underwater
// - not in braindance
// - not in workspot
// - not hacking
// - not hit by car
// - scanner usage ?
// forced consumption if Johnny is possessing ?
// ---- player
// protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool;
// public final static func GetCurrentLocomotionState(player: wref<PlayerPuppet>) -> gamePSMLocomotionStates;
// protected cb func OnStoppedBeingTrackedAsHostile(evt: ref<StoppedBeingTrackedAsHostile>) -> Bool;

// private let inCombat: Int32;
// private let handle: ref<CallbackHandle>;

// public final func RegisterListener() -> Void {
//     let blackboard: ref<IBlackboard> = this.owner.GetPlayerStateMachineBlackboard();
//     this.handle = blackboard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Combat, this, n"OnCombatStateChanged");
// }
// public final func UnregisterListener() -> Void {
//     let blackboard: ref<IBlackboard> = this.owner.GetPlayerStateMachineBlackboard();
//     blackboard.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Combat, this.handle);
// }
// protected cb func OnCombatStateChanged(newState: Int32) -> Bool {
//     let wasInCombat: Bool = this.inCombat == EnumInt(gamePSMCombat.InCombat);
//     let notAnymore: Bool = newState == EnumInt(gamePSMCombat.Default) || newState == EnumInt(gamePSMCombat.OutOfCombat);
//     let health: Float = GameInstance.GetStatPoolsSystem(this.owner.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(this.owner.GetEntityID()), gamedataStatPoolType.Health);
//     let lowHealthThreshold: Float = PlayerPuppet.GetLowHealthThreshold();
//     if wasInCombat && notAnymore && (health <= lowHealthThreshold) {
//         // trigger compulsion
//     }
// }