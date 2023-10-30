module Addicted

public class Consumption extends IScriptable {
    private persistent let current: Int32;
    private persistent let doses: array<Float>;
    public func Current() -> Int32 { return this.current; }
    public func Doses() -> array<Float> { return this.doses; }
    public func Threshold() -> Threshold { return GetThreshold(this.current); }
}

enum Threshold {
    Clean = 0,
    Occasionally = 1,
    Barely = 10,
    Mildly = 20,
    Notably = 40,
    Severely = 60,
}

public func GetThreshold(value: Int32) -> Threshold {
    if value >= EnumInt(Threshold.Severely) { return Threshold.Severely; }
    if value >= EnumInt(Threshold.Notably) { return Threshold.Notably; }
    if value >= EnumInt(Threshold.Mildly) { return Threshold.Mildly; }
    if value >= EnumInt(Threshold.Barely) { return Threshold.Barely; }
    if value >= EnumInt(Threshold.Occasionally) { return Threshold.Occasionally; }
    return Threshold.Clean;
}

public func GetAddictivity(itemID: ItemID) -> Int32 {
    switch (ItemID.GetTDBID(itemID)) {
        case t"Items.BlacklaceV0":
        case t"Items.BlacklaceV1":
            return 2;
        default:
            break;
    }
    return 1;
}

public func GetResilience(itemID: ItemID) -> Int32 {
    switch (ItemID.GetTDBID(itemID)) {
        case t"Items.BlacklaceV0":
        case t"Items.BlacklaceV1":
            return 1;
        default:
            break;
    }
    return 2;
}

public func GetMinimumSleepRequired(itemID: ItemID) -> Int32 { return 6; }

public func GetBaseName(itemID: ItemID) -> gamedataConsumableBaseName {
    return GetBaseName(ItemID.GetTDBID(itemID));
}
private func GetBaseName(id: TweakDBID) -> gamedataConsumableBaseName {
    switch(id) {
        case t"Items.FirstAidWhiffV0":
            return gamedataConsumableBaseName.FirstAidWhiff;
    }
    return gamedataConsumableBaseName.Invalid;
}

public func GetHighestThreshold(keys: array<TweakDBID>, values: array<ref<Consumption>>, itemID: ItemID) -> Threshold {
    let highest: Int32 = 0;
    let idx = 0;
    let base = GetBaseName(itemID);
    for value in values {
        if Equals(GetBaseName(keys[idx]), base) && value.current > highest { highest = value.current; }
        idx += 1;
    }
    return GetThreshold(highest);
}

public class RegistryEntry extends IScriptable {
    public let id: ItemID;
    public let base: gamedataConsumableBaseName;
    public let type: gamedataConsumableType;
    public let kind: Kind;
    public let category: Category;
}

public func GetRegistryEntry(consumable: ref<ConsumableItem_Record>) -> ref<RegistryEntry> {
    let entry: ref<RegistryEntry>;
    let base: gamedataConsumableBaseName = consumable.ConsumableBaseName().Type();
    let id: TweakDBID = consumable.GetID();
    if Equals(base, gamedataConsumableBaseName.FirstAidWhiff)
    || Equals(base, gamedataConsumableBaseName.BonesMcCoy70)
    || Equals(base, gamedataConsumableBaseName.HealthBooster) {
        entry = new RegistryEntry();
        entry.id = ItemID.FromTDBID(id);
        entry.base = base;
        entry.type = consumable.ConsumableType().Type();
        entry.kind = Equals(consumable.ItemType().Type(), gamedataItemType.Con_Inhaler)
        ? Kind.Inhaler
        : Equals(consumable.ItemType().Type(), gamedataItemType.Con_Injector)
        ? Kind.Injector
        : Kind.Kit;
        entry.category = Category.Healers;
        return entry;
    }
    if Equals(base, gamedataConsumableBaseName.CarryCapacityBooster)
    || Equals(base, gamedataConsumableBaseName.StaminaBooster) {
        entry = new RegistryEntry();
        entry.id = ItemID.FromTDBID(id);
        entry.base = base;
        entry.type = consumable.ConsumableType().Type();
        entry.kind = Kind.Pill;
        entry.category = Category.Healers;
        return entry;
    }
    if Equals(base, gamedataConsumableBaseName.Alcohol) {
        entry = new RegistryEntry();
        entry.id = ItemID.FromTDBID(id);
        entry.base = base;
        entry.type = consumable.ConsumableType().Type();
        entry.kind = Kind.Drinkable;
        entry.category = Category.Healers;
        return entry;
    }
    return null;
}

enum Category {
    Healers = 0,
    Anabolics = 1,
    Neuros = 2,
    Alcohol = 3,
    Count = 4,
    Unknown = 5,
}

enum Kind {
    Inhaler = 0,
    Injector = 1,
    Pill = 2,
    Kit = 3,
    Drinkable = 4,
    Edible = 5,
    Smokable = 6,
    Count = 7,
    Unknown = 8,
}
