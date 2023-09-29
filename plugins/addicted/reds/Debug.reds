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