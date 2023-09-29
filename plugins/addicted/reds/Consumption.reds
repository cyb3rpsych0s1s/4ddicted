module Addicted

import Addicted.System

native func PluginOnConsumeItem(system: ref<System>, item: ItemID) -> Void;

@addField(PlayerStateMachineDef)
public let IsConsuming: BlackboardID_Bool;

// used at all times
@wrapMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool) -> Bool {
  LogChannel(n"DEBUG", "ProcessItemAction");
  let system = System.GetInstance(executor.GetGame());
  PluginOnConsumeItem(system, itemData.GetID());

  return wrappedMethod(gi, executor, itemData, actionID, fromInventory);
}

// used at all times
@wrapMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool, quantity: Int32) -> Bool {
  LogChannel(n"DEBUG", "ProcessItemAction (with quantity)");
  let system = System.GetInstance(executor.GetGame());
  PluginOnConsumeItem(system, itemData.GetID());

  return wrappedMethod(gi, executor, itemData, actionID, fromInventory, quantity);
}
