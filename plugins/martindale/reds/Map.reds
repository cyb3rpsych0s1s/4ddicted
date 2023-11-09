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
    public func Size() -> Int32 {
        let values: array<wref<IScriptable>>;
        this.GetValues(values);
        let size = ArraySize(values);
        return size;
    }
    public func Debug() -> Void {
        let records: array<ref<TweakDBRecord>>;
        this.GetValues(records);
        for record in records {
            LogChannel(n"DEBUG", TDBID.ToStringDEBUG(record.GetID()));
        }
    }
}

public class inkConsumables extends inkHashMap {
    public func Insert(value: ref<RegisteredConsumable>) -> Void {
        if !this.KeyExist(value) {
            this.Insert(TDBID.ToNumber(value.item.GetID()), value);
        }
    }
    public func KeyExist(value: ref<RegisteredConsumable>) -> Bool {
        return this.KeyExist(TDBID.ToNumber(value.item.GetID()));
    }
    public func GetValues(out records: array<ref<RegisteredConsumable>>) -> Void {
        let values: array<wref<IScriptable>>;
        this.GetValues(values);
        ArrayClear(records);
        for value in values {
            ArrayPush(records, value as RegisteredConsumable);
        }
    }
    public func Size() -> Int32 {
        let values: array<wref<IScriptable>>;
        this.GetValues(values);
        let size = ArraySize(values);
        return size;
    }
}
