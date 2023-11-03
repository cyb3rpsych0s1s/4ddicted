module Martindale

public class Registry extends IScriptable {
    private let healthModifiers: ref<inkHashMap>;
    private let healthEffectors: ref<inkHashMap>;
    private let healthStatuses: ref<inkHashMap>;
    private let maxdocs: ref<inkHashMap>;
    private let bouncebacks: ref<inkHashMap>;
    private let healthboosters: ref<inkHashMap>;
    private let initialized: Bool = false;
    public func Scan() -> Void {
        this.healthModifiers = HealthModifiers();
        this.healthEffectors = HealthEffectors(this.healthModifiers);
        this.healthStatuses = HealthStatuses(this.healthEffectors);
        this.maxdocs = MaxDOC(this.healthStatuses);
        this.bouncebacks = BounceBack(this.healthStatuses);
        this.healthboosters = HealthBooster(this.healthStatuses);
    }
}
