module Martindale

public func Recorded(map: ref<inkHashMap>, searched: ref<TweakDBRecord>) -> Bool {
    if !IsDefined(map) { return false; }
    if !IsDefined(searched) { return false; }
    let records: array<ref<TweakDBRecord>> = GetValuesAsRecords(map);
    if ArraySize(records) == 0 { return false; }
    for record in records {
        if Equals(record.GetID(), searched.GetID()) { return true; }
    }
    return false;
}
public func GetValuesAsRecords(map: ref<inkHashMap>) -> array<ref<TweakDBRecord>> {
    if !IsDefined(map) { return []; }
    let values: array<wref<IScriptable>>;
    map.GetValues(values);
    if ArraySize(values) == 0 { return []; }
    let records: array<ref<TweakDBRecord>> = [];
    for value in values {
        ArrayPush(records, value as TweakDBRecord);
    }
    return records;
}