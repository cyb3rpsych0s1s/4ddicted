module Martindale

public class Registry extends IScriptable {
    private let healthModifiers: ref<inkHashMap>;
    private let healthEffectors: ref<inkHashMap>;
    private let healthStatuses: ref<inkHashMap>;
    private let maxdocs: ref<inkHashMap>;
    private let bouncebacks: ref<inkHashMap>;
    private let healthboosters: ref<inkHashMap>;
    public func Scan() -> Void {
        this.healthModifiers = HealthModifiers();
        this.healthEffectors = HealthEffectors(this.healthModifiers);
        this.healthStatuses = HealthStatuses(this.healthEffectors);
        this.maxdocs = MaxDOC(this.healthStatuses);
        this.bouncebacks = BounceBack(this.healthStatuses);
        this.healthboosters = HealthBooster(this.healthStatuses);

        LogIDs(this.maxdocs, "MaxDOC"); 
        LogIDs(this.bouncebacks, "BounceBack"); 
        LogIDs(this.healthboosters, "HealthBooster");
        LogIDs(this.healthStatuses, "StatusEffect");
        LogIDs(this.healthEffectors, "Effector");
        LogIDs(this.healthModifiers, "Modifier");
    }
    private func Clear() -> Void {
        this.healthModifiers = null;
        this.healthEffectors = null;
        this.healthStatuses = null;
        this.maxdocs = null;
        this.bouncebacks = null;
        this.healthboosters = null;
    }
    public func DebugConsumables() -> Void {
        LogIDs(this.maxdocs, "MaxDOC");
        LogIDs(this.bouncebacks, "BounceBack");
        LogIDs(this.healthboosters, "HealthBooster");
        LogIDs(this.healthStatuses, "StatusEffect");
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
