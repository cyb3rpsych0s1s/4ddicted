module Martindale

public func BasedOnHealth(modifier: ref<StatPoolUpdate_Record>) -> Bool {
    return Equals(modifier.StatPoolType().StatPoolType(), gamedataStatPoolType.Health);
}
public func HealthModifiers() -> array<ref<StatPoolUpdate_Record>> {
    let modifiers: array<ref<StatPoolUpdate_Record>> = [];
    let records = TweakDBInterface.GetRecords(n"StatPoolUpdate");
    LogChannel(n"DEBUG", s"scan \(ToString(ArraySize(records))) stat pool update(s)");
    let update: ref<StatPoolUpdate_Record>;
    for record in records {
        update = record as StatPoolUpdate_Record;
        if BasedOnHealth(update) {
            ArrayPush(modifiers, update);
        }
    }
    return modifiers;
}