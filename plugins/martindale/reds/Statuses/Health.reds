module Martindale

public func BasedOnMisc(status: ref<StatusEffect_Record>) -> Bool {
    return Equals(status.StatusEffectType().Type(), gamedataStatusEffectType.Misc);
}
public func BasedOnEffectorsOrModifiers(package: ref<GameplayLogicPackage_Record>) -> Bool {
    return package.GetEffectorsCount() > 0 || package.GetStatsCount() > 0;
}
public func HealthStatuses(recorded: ref<inkHashMap>) -> ref<inkHashMap> {
    let records = TweakDBInterface.GetRecords(n"StatusEffect");
    let status: ref<StatusEffect_Record>;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let effectors: array<wref<Effector_Record>>;
    let statuses = new inkHashMap();
    for record in records {
        status = record as StatusEffect_Record;
        if BasedOnMisc(status) {
            ArrayClear(packages);
            status.Packages(packages);
            for package in packages {
                if BasedOnEffectorsOrModifiers(package) {
                    ArrayClear(effectors);
                    package.Effectors(effectors);
                    for effector in effectors {
                        if Recorded(recorded, effector) && !statuses.KeyExist(TDBID.ToNumber(status.GetID())) {
                            statuses.Insert(TDBID.ToNumber(status.GetID()), status);
                        }
                    }
                }
            }
        }
    }
    return statuses;
}