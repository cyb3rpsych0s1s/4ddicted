module Addicted

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