module Addicted

import Addicted.System

native func OnIngestedItem(system: ref<System>, item: ItemID) -> Void;

@addField(PlayerStateMachineDef)
public let WithdrawalSymptoms: BlackboardID_Uint;

final static func ProcessUsedItemAction(executor: wref<GameObject>, actionID: TweakDBID, itemID: ItemID) -> Void {
  let actionType: CName = TweakDBInterface.GetObjectActionRecord(actionID).ActionName();
  // LogChannel(n"DEBUG", s"process used item action \(NameToString(actionType)) for item \(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)))");
  if Equals(actionType, n"Consume") || Equals(actionType, n"Drink") || Equals(actionType, n"UseHealCharge") {
    let system = System.GetInstance(executor.GetGame());
    OnIngestedItem(system, itemID);
  }
}

// used at all times
@wrapMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool) -> Bool {
  LogChannel(n"DEBUG", s"process item action \(TDBID.ToStringDEBUG(actionID))");
  let used = wrappedMethod(gi, executor, itemData, actionID, fromInventory);
  if used {
    ProcessUsedItemAction(executor, actionID, itemData.GetID());
  }
  return used;
}

// used at all times
@wrapMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool, quantity: Int32) -> Bool {
  LogChannel(n"DEBUG", s"process item action \(TDBID.ToStringDEBUG(actionID))");
  let used = wrappedMethod(gi, executor, itemData, actionID, fromInventory, quantity);
  if used {
    ProcessUsedItemAction(executor, actionID, itemData.GetID());
  }
  return used;
}
