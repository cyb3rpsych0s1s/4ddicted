module Addicted

import Addicted.System

native func PluginOnConsumeItem(system: ref<System>, item: ItemID) -> Void;

@addField(PlayerStateMachineDef)
public let IsConsuming: BlackboardID_Bool;

// unused ? or in-custscene/anims ? (bound to interaction choice)
@wrapMethod(ItemActionsHelper)
public final static func EatItem(executor: wref<GameObject>, itemID: ItemID, fromInventory: Bool) -> Void {
  LogChannel(n"DEBUG", "EatItem");
  let system = System.GetInstance(executor.GetGame());
  PluginOnConsumeItem(system, itemID);

  wrappedMethod(executor, itemID, fromInventory);
}

// unused ? or in-custscene/anims ? (bound to interaction choice)
@wrapMethod(ItemActionsHelper)
public final static func DrinkItem(executor: wref<GameObject>, itemID: ItemID, fromInventory: Bool) -> Void {
  LogChannel(n"DEBUG", "DrinkItem");
  let system = System.GetInstance(executor.GetGame());
  PluginOnConsumeItem(system, itemID);

  wrappedMethod(executor, itemID, fromInventory);
}

// unused ?
@wrapMethod(ItemActionsHelper)
public final static func UseItem(executor: wref<GameObject>, itemID: ItemID) -> Void {
  LogChannel(n"DEBUG", "UseItem");
  let system = System.GetInstance(executor.GetGame());
  PluginOnConsumeItem(system, itemID);

  wrappedMethod(executor, itemID);
}

// used : MaxDOC / BounceBack
@wrapMethod(ItemActionsHelper)
public final static func UseHealCharge(executor: wref<GameObject>, itemID: ItemID) -> Void {
  LogChannel(n"DEBUG", "UseHealCharge");
  let system = System.GetInstance(executor.GetGame());
  PluginOnConsumeItem(system, itemID);

  wrappedMethod(executor, itemID);
}

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

// unused ?
@wrapMethod(ItemActionsHelper)
public final static func ConsumeItem(executor: wref<GameObject>, itemID: ItemID, fromInventory: Bool) -> Void {
  LogChannel(n"DEBUG", "ConsumeItem");
  let system = System.GetInstance(executor.GetGame());
  PluginOnConsumeItem(system, itemID);

  wrappedMethod(executor, itemID, fromInventory);
}

// used at all times
@wrapMethod(ItemActionsHelper)
public final static func PerformItemAction(executor: wref<GameObject>, itemID: ItemID) -> Void {
  LogChannel(n"DEBUG", "PerformItemAction");
  let system = System.GetInstance(executor.GetGame());
  PluginOnConsumeItem(system, itemID);

  wrappedMethod(executor, itemID);
}