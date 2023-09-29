# research

```yaml
// ???
Items.sts_wat_kab_01_inhaler
Items.drug_inhaler
Items.CombatFood1

// it's probably all in the name...
TEST.InstantFullHealInhaler
TEST.OverPoweredInhaler

// interesting enough
+ Items.mq036_unmarked_bd_cartridge // addiction to braindance

// junk items, but some could be interestingly turned into real consumables
Items.Endotrisine
Items.PseudoEndotrisine

// these provide inheritance mechanism, not really meant to be spawned
Items.Alcohol
Items.Drug
Items.Injector
Items.Inhaler
Items.BlackmarketLongLasting
```

How to turn a non-consumable item into a fully consumable one ?

```swift
// backpack_main.swift

// lead
SetInventoryItemButtonHintsHoverOver
SetInventoryItemButtonHintsHoverOut
// e.g.
this.m_buttonHintsController.AddButtonHint(n"use_item", GetLocalizedText("UI-UserActions-Use"));
// and then
isUsable = IsDefined(ItemActionsHelper.GetConsumeAction(InventoryItemData.GetGameItemData(displayingData).GetID())) || IsDefined(ItemActionsHelper.GetEatAction(InventoryItemData.GetGameItemData(displayingData).GetID())) || IsDefined(ItemActionsHelper.GetDrinkAction(InventoryItemData.GetGameItemData(displayingData).GetID()));
// but especially
ItemDisplayHoverOverEvent
private final func NewShowItemHints(itemData: wref<UIInventoryItem>) -> Void
// then on confirmation
protected cb func OnItemDisplayClick(evt: ref<ItemDisplayClickEvent>) -> Bool
UIInventoryItem
// additionally gets checked by
InventoryGPRestrictionHelper
// ends up in
ItemActionsHelper.PerformItemAction // which is perfect ! :)
```
