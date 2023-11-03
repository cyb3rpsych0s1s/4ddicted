module Martindale

public func BasedOnConsumable(consumable: ref<ConsumableItem_Record>, base: gamedataConsumableBaseName) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), base);
}
public func BasedOnHealChargeOrConsume(object: ref<ObjectAction_Record>) -> Bool {
    let item = object as ItemAction_Record;
    return IsDefined(item) && (Equals(item.ActionName(), n"UseHealCharge") || Equals(item.ActionName(), n"Consume"));
}

private func Healer(recorded: ref<inkHashMap>, base: gamedataConsumableBaseName) -> array<ref<ConsumableItem_Record>> {
    let records = TweakDBInterface.GetRecords(n"ConsumableItem");
    let consumable: ref<ConsumableItem_Record>;
    let actions: array<wref<ObjectAction_Record>>;
    let completions: array<wref<ObjectActionEffect_Record>>;
    let consumables: array<ref<ConsumableItem_Record>> = [];
    for record in records {
        consumable = record as ConsumableItem_Record;
        if BasedOnConsumable(consumable, base) {
            consumable.ObjectActions(actions);
            for action in actions {
                if BasedOnHealChargeOrConsume(action) {
                    action.CompletionEffects(completions);
                    for completion in completions {
                        if Recorded(recorded, completion.StatusEffect()) && !ArrayContains(consumables, consumable) {
                            ArrayPush(consumables, consumable);
                        }
                    }
                }
            }
        }
    }
    return consumables;
}
public func MaxDOC(recorded: ref<inkHashMap>) -> array<ref<ConsumableItem_Record>> {
    return Healer(recorded, gamedataConsumableBaseName.FirstAidWhiff);
}
public func BounceBack(recorded: ref<inkHashMap>) -> array<ref<ConsumableItem_Record>> {
    return Healer(recorded, gamedataConsumableBaseName.BonesMcCoy70);
}
public func HealthBooster(recorded: ref<inkHashMap>) -> array<ref<ConsumableItem_Record>> {
    return Healer(recorded, gamedataConsumableBaseName.HealthBooster);
}