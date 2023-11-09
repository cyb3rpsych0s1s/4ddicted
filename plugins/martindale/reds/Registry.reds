module Martindale

public class RegisteredConsumable extends IScriptable {
    private let item: ref<ConsumableItem_Record>;
    private let statuses: ref<inkRecords>;
    private let effectors: ref<inkRecords>;
    private let stats: ref<inkRecords>;
    public func Debug() -> Void {
        LogChannel(n"DEBUG", TDBID.ToStringDEBUG(this.item.GetID()));
        LogChannel(n"DEBUG", "statuses:");
        this.statuses.Debug();
        LogChannel(n"DEBUG", "effectors:");
        this.effectors.Debug();
        LogChannel(n"DEBUG", "stats:");
        this.stats.Debug();
    }
    public func ContainsStatus(status: ref<StatusEffect_Record>) -> Bool {
        return this.statuses.KeyExist(status);
    }
}

public class Registry extends IScriptable {
    private let entries: ref<inkConsumables>;
    public func Scan() -> Void {
        this.entries = new inkConsumables();
        let records = TweakDBInterface.GetRecords(n"ConsumableItem");
        let consumable: ref<ConsumableItem_Record>;
        let entry: ref<RegisteredConsumable>;
        let actions: array<wref<ObjectAction_Record>>;
        let completions: array<wref<ObjectActionEffect_Record>>;
        let status: ref<StatusEffect_Record>;
        let packages: array<wref<GameplayLogicPackage_Record>>;
        let effectors: array<wref<Effector_Record>>;
        let stats: array<wref<StatModifier_Record>>;
        for record in records {
            consumable = record as ConsumableItem_Record;
            entry = new RegisteredConsumable();
            entry.item = consumable;
            entry.statuses = new inkRecords();
            entry.effectors = new inkRecords();
            entry.stats = new inkRecords();
            this.entries.Insert(entry);
            ArrayClear(actions);
            consumable.ObjectActions(actions);
            for action in actions {
                if action.GetCompletionEffectsCount() > 0 {
                    ArrayClear(completions);
                    action.CompletionEffects(completions);
                    for completion in completions {
                        status = completion.StatusEffect();
                        if IsDefined(status) && status.GetPackagesCount() > 0 {
                            entry.statuses.Insert(status);
                            ArrayClear(packages);
                            status.Packages(packages);
                            for package in packages {
                                if package.GetEffectorsCount() > 0 {
                                    ArrayClear(effectors);
                                    package.Effectors(effectors);
                                    for effector in effectors {
                                        entry.effectors.Insert(effector);
                                    }
                                }
                                if package.GetStatsCount() > 0 {
                                    ArrayClear(stats);
                                    package.Stats(stats);
                                    for stat in stats {
                                        entry.stats.Insert(stat);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    public func Debug() -> Void {
        LogChannel(n"DEBUG", NameToString(this.GetClassName()));
        let consumables: array<ref<RegisteredConsumable>>;
        this.entries.GetValues(consumables);
        for consumable in consumables {
            consumable.Debug();
        }
    }
    public func MaxDOC() -> array<ref<RegisteredConsumable>> {
        let consumables: array<ref<RegisteredConsumable>>;
        let maxdoc: array<ref<RegisteredConsumable>> = [];
        this.entries.GetValues(consumables);
        for consumable in consumables {
            if IsMaxDOC(consumable.item) { ArrayPush(maxdoc, consumable); }
        }
        return maxdoc;
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
