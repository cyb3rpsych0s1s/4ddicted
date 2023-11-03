module Martindale

public func BasedOnMisc(status: ref<StatusEffect_Record>) -> Bool {
    return Equals(status.StatusEffectType().Type(), gamedataStatusEffectType.Misc);
}
public func BasedOnEffectorsOrModifiers(package: ref<GameplayLogicPackage_Record>) -> Bool {
    return package.GetEffectorsCount() > 0 || package.GetStatsCount() > 0;
}
public func HealthStatusEffect(recorded: ref<inkHashMap>) -> array<ref<StatusEffect_Record>> {
    let records = TweakDBInterface.GetRecords(n"StatusEffect");
    let status: ref<StatusEffect_Record>;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let effectors: array<wref<Effector_Record>>;
    let statuses: array<ref<StatusEffect_Record>> = [];
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
                        if Recorded(recorded, effector) && !ArrayContains(statuses, status) {
                            ArrayPush(statuses, status);
                        }
                    }
                }
            }
        }
    }
    return statuses;
}