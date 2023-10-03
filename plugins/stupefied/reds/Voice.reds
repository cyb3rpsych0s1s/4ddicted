module Stupefied

import Stupefied.System

@addField(PlayerStateMachineDef)
public let IsConsuming: BlackboardID_Bool;

native func OnConsumingItem(system: ref<System>) -> Void;
native func OnStatusEffectApplied(system: ref<System>) -> Void;

// catch direct consumption from quick slot
@wrapMethod(ItemActionsHelper)
public final static func ConsumeItem(executor: wref<GameObject>, itemID: ItemID, fromInventory: Bool) -> Void {
    let player = executor as PlayerPuppet;
    if IsDefined(player) {
        let system = System.GetInstance(executor.GetGame());
        OnConsumingItem(system);
    }

    wrappedMethod(executor, itemID, fromInventory);
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let applied = wrappedMethod(evt);

    let system = System.GetInstance(this.GetGame());
    OnStatusEffectApplied(system);

    return applied;
}
