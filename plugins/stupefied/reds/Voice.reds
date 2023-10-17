module Stupefied

import Stupefied.CompanionSystem

@addField(PlayerStateMachineDef)
public let IsConsuming: BlackboardID_Bool;

// native func OnConsumingItem(system: ref<CompanionSystem>) -> Void;
// native func OnConsumedItem(system: ref<CompanionSystem>) -> Void;

final static func OnUsedQuickSlotItem(executor: wref<GameObject>, actionID: TweakDBID) -> Void {
  let actionType: CName = TweakDBInterface.GetObjectActionRecord(actionID).ActionName();
  if Equals(actionType, n"Consume") || Equals(actionType, n"Drink") || Equals(actionType, n"UseHealCharge") {
    // let system = System.GetInstance(executor.GetGame());
    // OnConsumingItem(system);
  }
}

// method seems unused after patch 2.0
@wrapMethod(ItemActionsHelper)
public final static func ConsumeItem(executor: wref<GameObject>, itemID: ItemID, fromInventory: Bool) -> Void {
    let player = executor as PlayerPuppet;
    if IsDefined(player) {
        // let system = System.GetInstance(executor.GetGame());
        // OnConsumingItem(system);
    }

    wrappedMethod(executor, itemID, fromInventory);
}

// used at all times
// fromInventory is true even from quick slot
@wrapMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool) -> Bool {
  let used = wrappedMethod(gi, executor, itemData, actionID, fromInventory);
  if used {
    OnUsedQuickSlotItem(executor, actionID);
  }
  return used;
}

// used at all times
// fromInventory is true even from quick slot
@wrapMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool, quantity: Int32) -> Bool {
  let used = wrappedMethod(gi, executor, itemData, actionID, fromInventory, quantity);
  if used {
    OnUsedQuickSlotItem(executor, actionID);
  }
  return used;
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let applied = wrappedMethod(evt);

    if !evt.isAppliedOnSpawn {
        // let system = System.GetInstance(this.GetGame());
        // OnConsumedItem(system);
    }

    return applied;
}
