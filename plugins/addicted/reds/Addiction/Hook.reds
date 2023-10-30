module Addicted

private final static func ProcessUsedItemAction(executor: wref<GameObject>, actionID: TweakDBID, itemID: ItemID) -> Void {
  let actionType: CName = TweakDBInterface.GetObjectActionRecord(actionID).ActionName();
  if Equals(actionType, n"Consume") || Equals(actionType, n"Drink") || Equals(actionType, n"UseHealCharge") {
    let system = System.GetInstance(executor.GetGame());
    system.Consumed(itemID);
  }
}

// used at all times, once status effects have been processed
@wrapMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool) -> Bool {
  let used = wrappedMethod(gi, executor, itemData, actionID, fromInventory);
  if used {
    ProcessUsedItemAction(executor, actionID, itemData.GetID());
  }
  return used;
}

// used at all times, once status effects have been processed
@wrapMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool, quantity: Int32) -> Bool {
  let used = wrappedMethod(gi, executor, itemData, actionID, fromInventory, quantity);
  if used {
    ProcessUsedItemAction(executor, actionID, itemData.GetID());
  }
  return used;
}
