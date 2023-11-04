module Martindale

public class Registry extends IScriptable {
    public func Scan() -> Void {
    }
    private func Clear() -> Void {
    }
    public func DebugConsumables() -> Void {
    }
}

private func LogIDs(map: ref<inkHashMap>, title: String) -> Void {
    let values: array<wref<IScriptable>>;
    let record: ref<TweakDBRecord>;
    map.GetValues(values);
    let message: String = title + ":\n";
    let idx = 0;
    for v in values {
        record = v as TweakDBRecord;
        message = message + "\n" + TDBID.ToStringDEBUG(record.GetID());
        idx += 1;
    }
    LogChannel(n"DEBUG", s"\(message)\n-------");
}
