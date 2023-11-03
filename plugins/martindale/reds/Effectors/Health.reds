module Martindale

public func BasedOnModifyStatPoolValueEffector(effector: ref<Effector_Record>) -> Bool {
    return Equals(effector.EffectorClassName(), n"ModifyStatPoolValueEffector");
}
public func HealthModifyStatPoolValue(recorded: ref<inkHashMap>) -> array<ref<ModifyStatPoolValueEffector_Record>> {
    let effectors: array<ref<ModifyStatPoolValueEffector_Record>>;
    let records = TweakDBInterface.GetRecords(n"ModifyStatPoolValueEffector");
    let effector: ref<ModifyStatPoolValueEffector_Record>;
    let updates: array<wref<StatPoolUpdate_Record>>;
    for record in records {
        effector = record as ModifyStatPoolValueEffector_Record;
        ArrayClear(updates);
        effector.StatPoolUpdates(updates);
        for update in updates {
            if Recorded(recorded, update) && !ArrayContains(effectors, effector) {
                ArrayPush(effectors, effector);
            }
        }
    }
    return effectors;
}