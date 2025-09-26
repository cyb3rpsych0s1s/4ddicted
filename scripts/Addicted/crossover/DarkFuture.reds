module Addicted.Crossover

public class AddiquitTweaks extends ScriptableTweak {
  protected cb func OnApply() -> Void {
    let depot = GameInstance.GetResourceDepot();
    let darkfuture = depot.ArchiveExists("Dark Future.archive");

    if darkfuture {
      this.AppendCautionNotice();
    }
  }

  // append caution notice in inventory tooltip
  private func AppendCautionNotice() -> Void {
    let caution = t"Package.AddiquitCaution";
    let consumable: wref<ConsumableItem_Record>;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let ids: array<TweakDBID>;
    let j: Int32;
    consumable = TweakDBInterface.GetConsumableItemRecord(t"DarkFutureItem.AddictionTreatmentDrug");
    consumable.OnEquip(packages);
    j = 0;
    ids = [];
    while j < ArraySize(packages) {
      ArrayPush(ids, packages[j].GetID());
      j += 1;
    }
    ArrayPush(ids, caution);
    TweakDBManager.SetFlat(t"DarkFutureItem.AddictionTreatmentDrug.OnEquip", ids);
    TweakDBManager.UpdateRecord(t"DarkFutureItem.AddictionTreatmentDrug");
  }
}
