module Martindale

public class inkRecords extends inkHashMap {
    public func Insert(value: ref<TweakDBRecord>) -> Void {
        if !this.KeyExist(value) {
            this.Insert(TDBID.ToNumber(value.GetID()), value);
        }
    }
    public func KeyExist(value: ref<TweakDBRecord>) -> Bool {
        return this.KeyExist(TDBID.ToNumber(value.GetID()));
    }
    public func GetValues(out records: array<ref<TweakDBRecord>>) -> Void {
        let values: array<wref<IScriptable>>;
        this.GetValues(values);
        ArrayClear(records);
        for value in values {
            ArrayPush(records, value as TweakDBRecord);
        }
    }
}
