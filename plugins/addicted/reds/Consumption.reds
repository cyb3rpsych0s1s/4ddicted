module Addicted

public class Consumption extends IScriptable {
    private persistent let current: Int32;
    private persistent let doses: array<Float>;
    public func Current() -> Int32 { return this.current; }
    public func Doses() -> array<Float> { return this.doses; }
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
    switch (ItemID.GetTDBID(ItemID)) {
        case t"Items.BlacklaceV0":
        case t"Items.BlacklaceV1":
            return 2;
        default:
            break;
    }
    return 1;
}

public func GetResilience(itemID: ItemID) -> Int32 {
    switch (ItemID.GetTDBID(ItemID)) {
        case t"Items.BlacklaceV0":
        case t"Items.BlacklaceV1":
            return 1;
        default:
            break;
    }
    return 2;
}

public func GetMinimumSleepRequired(itemID: ItemID) -> Int32 { return 6; }