module Addicted

//// TODO: remove board implementation
//// reason: we don't want other mods to alter them and cause inconsistencies

public class AddictionsThresholdDef extends BlackboardDefinition {
  public let MaxDOC: BlackboardID_Int;
  public let BounceBack: BlackboardID_Int;
  public let HealthBooster: BlackboardID_Int;
  public let CarryCapacityBooster: BlackboardID_Int;
  public let StaminaBooster: BlackboardID_Int;
  public let MemoryBooster: BlackboardID_Int;
  public let NeuroBlocker: BlackboardID_Int;
  public let Alcohol: BlackboardID_Int;
}

@addField(PlayerStateMachineDef)
public let Thresholds: ref<AddictionsThresholdDef>;

@addField(PlayerStateMachineDef)
public let WithdrawalSymptoms: BlackboardID_Uint;

private func GetBoardPin(base: gamedataConsumableBaseName) -> BlackboardID_Int {
  switch (base) {
    case gamedataConsumableBaseName.FirstAidWhiff:
      return GetAllBlackboardDefs().PlayerStateMachine.Thresholds.MaxDOC;
    case gamedataConsumableBaseName.BonesMcCoy70:
      return GetAllBlackboardDefs().PlayerStateMachine.Thresholds.BounceBack;
    case gamedataConsumableBaseName.HealthBooster:
      return GetAllBlackboardDefs().PlayerStateMachine.Thresholds.HealthBooster;
    case gamedataConsumableBaseName.CarryCapacityBooster:
      return GetAllBlackboardDefs().PlayerStateMachine.Thresholds.CarryCapacityBooster;
    case gamedataConsumableBaseName.StaminaBooster:
      return GetAllBlackboardDefs().PlayerStateMachine.Thresholds.StaminaBooster;
    case gamedataConsumableBaseName.MemoryBooster:
      return GetAllBlackboardDefs().PlayerStateMachine.Thresholds.MemoryBooster;
    case gamedataConsumableBaseName.Alcohol:
      return GetAllBlackboardDefs().PlayerStateMachine.Thresholds.Alcohol;
  }
}

private func GetBoardPin(itemID: ItemID) -> BlackboardID_Int {
  let consumable = TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(itemID));
  if !IsDefined(consumable) { LogChannel(n"ASSERT", s"unknown board for \(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)))"); }
  let base = consumable.ConsumableBaseName().Type();
  return GetBoardPin(base);
}