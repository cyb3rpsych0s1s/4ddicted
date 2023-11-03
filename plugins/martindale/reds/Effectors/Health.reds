module Martindale

public func BasedOnModifyStatPoolValueEffector(effector: ref<Effector_Record>) -> Bool {
    return Equals(effector.EffectorClassName(), n"ModifyStatPoolValueEffector");
}
public func HealthEffectors(recorded: ref<inkHashMap>) -> ref<inkHashMap> {
    let effectors = new inkHashMap();
    let records = TweakDBInterface.GetRecords(n"ModifyStatPoolValueEffector");
    let effector: ref<ModifyStatPoolValueEffector_Record>;
    let updates: array<wref<StatPoolUpdate_Record>>;
    for record in records {
        effector = record as ModifyStatPoolValueEffector_Record;
        ArrayClear(updates);
        effector.StatPoolUpdates(updates);
        for update in updates {
            if Recorded(recorded, update) && !effectors.KeyExist(TDBID.ToNumber(effector.GetID())) {
                effectors.Insert(TDBID.ToNumber(effector.GetID()), effector);
            }
        }
    }
    return effectors;
}