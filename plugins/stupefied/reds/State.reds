module Stupefied

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

abstract class EnhancedSystem extends ScriptableSystem {
    private let player: wref<PlayerPuppet>;
    private let board: ref<IBlackboard>;
    private let onCombat: ref<CallbackHandle>;
    private let onInteraction: ref<CallbackHandle>;
    private let onSwim: ref<CallbackHandle>;
    private let onBraindance: ref<CallbackHandle>;
    private let onWorkspot: ref<CallbackHandle>;
    public final func CombatListener(enable: Bool) -> Void {
        let system: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.player.GetGame());
        let board: ref<IBlackboard> = system.GetLocalInstanced(this.player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
        if enable {
            this.onCombat = board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Combat, this, n"OnCombatChanged", true);
        } else {
            board.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Combat, this.onCombat);
            this.onCombat = null;
        }
    }
    public final func InteractionsListener(enable: Bool) -> Void {
        let system: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.player.GetGame());
        let board: ref<IBlackboard> = system.Get(GetAllBlackboardDefs().UIInteractions);
        if enable {
            this.onInteraction = board.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UIInteractions.DialogChoiceHubs, this, n"OnInteractionChanged");
        } else {
            board.UnregisterDelayedListener(GetAllBlackboardDefs().UIInteractions.DialogChoiceHubs, this.onInteraction);
            this.onInteraction = null;
        }
    }
    public final func SwimmingListener(enable: Bool) -> Void {
        let system: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.player.GetGame());
        let board: ref<IBlackboard> = system.GetLocalInstanced(this.player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
        if enable {
            this.onSwim = board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming, this, n"OnSwimmingChanged");
        } else {
            board.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming, this.onSwim);
            this.onSwim = null;
        }
    }
    public final func BraindanceListener(enable: Bool) -> Void {
        let system: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.player.GetGame());
        let board: ref<IBlackboard> = system.Get(GetAllBlackboardDefs().Braindance);
        if enable {
            this.onBraindance = board.RegisterDelayedListenerBool(GetAllBlackboardDefs().Braindance.IsActive, this, n"OnBraindanceChanged");
        } else {
            board.UnregisterDelayedListener(GetAllBlackboardDefs().Braindance.IsActive, this.onBraindance);
            this.onBraindance = null;
        }
    }
    public final func WorkspotListener(enable: Bool) -> Void {
        let system: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.player.GetGame());
        let board: ref<IBlackboard> = system.GetLocalInstanced(this.player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
        if enable {
            this.onWorkspot = board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.IsInWorkspot, this, n"OnWorkspotChanged");
        } else {
            board.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.IsInWorkspot, this.onWorkspot);
            this.onWorkspot = null;
        }
    }
    protected cb func OnCombatChanged(value: Int32) -> Bool {
        // update bitwise
    }
    protected cb func OnInteractionChanged(value: Variant) -> Bool {
        // update bitwise
    }
    protected cb func OnSwimmingChanged(value: Int32) -> Bool {
        // update bitwise
    }
    protected cb func OnBraindanceChanged(value: Bool) -> Bool {
        // update bitwise
    }
    protected cb func OnWorkspotChanged(value: Int32) -> Bool {
        // update bitwise
    }
}