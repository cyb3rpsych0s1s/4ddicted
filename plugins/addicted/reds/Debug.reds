import Addicted.System
import Addicted.OnStatusEffectNotAppliedOnSpawn
import Addicted.Consumptions
import Addicted.Consumption

native func WriteToFile(names: array<String>, filename: String) -> Void;

public func SearchConsumables() -> Void {
    let names: array<String> = [];
    let consumable: ref<ConsumableItem_Record>;
    for record in TweakDBInterface.GetRecords(n"ConsumableItem_Record") {
        consumable = record as ConsumableItem_Record;
        ArrayPush(names, s"\(TDBID.ToStringDEBUG(consumable.GetID())) (\(consumable.FriendlyName()) | \(consumable.LocalizedName())): \(NameToString(consumable.ConsumableType().EnumName()))");
    }
    WriteToFile(names, "consumables");
}

public func SearchItems() -> Void {
    let names: array<String> = [];
    let item: ref<Item_Record>;
    for record in TweakDBInterface.GetRecords(n"Item_Record") {
        item = record as Item_Record;
        if Equals(item.ItemType().Type(), gamedataItemType.Con_Edible)
        || Equals(item.ItemType().Type(), gamedataItemType.Con_Inhaler)
        || Equals(item.ItemType().Type(), gamedataItemType.Con_Injector)
        || Equals(item.ItemType().Type(), gamedataItemType.Con_LongLasting)
        || Equals(item.ItemType().Type(), gamedataItemType.Gen_Misc)
        {
            ArrayPush(names, s"\(TDBID.ToStringDEBUG(item.GetID())) (\(item.FriendlyName()) | \(item.LocalizedName())): \(ToString(item.ItemType().Type()))");
        }
    }
    WriteToFile(names, "items");
}

// [C] ui data: icon path asskick, ID Items.Blackmarket_HealthBooster, record ID Items.Blackmarket_HealthBooster
// [C] ui data: icon path ram_nugs, ID Items.Blackmarket_MemoryBooster, record ID Items.Blackmarket_MemoryBooster
// [C] ui data: icon path ol_donkey, ID Items.Blackmarket_CarryCapacityBooster, record ID Items.Blackmarket_CarryCapacityBooster
// [C] ui data: icon path stamina_tube, ID Items.Blackmarket_StaminaBooster, record ID Items.Blackmarket_StaminaBooster
// try like: SearchIconOwner("asskick");
public func SearchIconOwner(name: String) -> Void {
    let ses = TweakDBInterface.GetRecords(n"StatusEffectUIData");
    let se: ref<StatusEffectUIData_Record>;
    for record in ses {
        se = record as StatusEffectUIData_Record;
        if Equals(se.IconPath(), name) { LogChannel(n"DEBUG", s"[SE] ui data: icon path \(se.IconPath()), ID \(TDBID.ToStringDEBUG(se.GetID())), record ID \(TDBID.ToStringDEBUG(se.GetRecordID()))"); }
    }
    let glps = TweakDBInterface.GetRecords(n"GameplayLogicPackageUIData");
    let glp: ref<GameplayLogicPackageUIData_Record>;
    for record in glps {
        glp = record as GameplayLogicPackageUIData_Record;
        if Equals(glp.IconPath(), StringToName(name)) { LogChannel(n"DEBUG", s"[GLP] ui data: icon path \(glp.IconPath()), ID \(TDBID.ToStringDEBUG(glp.GetID())), record ID \(TDBID.ToStringDEBUG(glp.GetRecordID()))"); }
    }
    let is = TweakDBInterface.GetRecords(n"Item");
    let i: ref<Item_Record>;
    for record in is {
        i = record as Item_Record;
        if Equals(i.IconPath(), name) { LogChannel(n"DEBUG", s"[I] ui data: icon path \(i.IconPath()), ID \(TDBID.ToStringDEBUG(i.GetID())), record ID \(TDBID.ToStringDEBUG(i.GetRecordID()))"); }
    }
    let cs = TweakDBInterface.GetRecords(n"ConsumableItem");
    let c: ref<ConsumableItem_Record>;
    for record in cs {
        c = record as ConsumableItem_Record;
        if Equals(c.IconPath(), name) { LogChannel(n"DEBUG", s"[C] ui data: icon path \(c.IconPath()), ID \(TDBID.ToStringDEBUG(c.GetID())), record ID \(TDBID.ToStringDEBUG(c.GetRecordID()))"); }
    }
}
