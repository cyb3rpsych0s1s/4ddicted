module Martindale

public func IsMaxDOC(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.FirstAidWhiff);
}
public func IsBounceBack(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.BonesMcCoy70);
}
public func IsHealthBooster(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.HealthBooster);
}

public func IsMedical(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableType().Type(), gamedataConsumableType.Medical);
}

public func IsHealer(consumable: ref<ConsumableItem_Record>) -> Bool {
    return IsMaxDOC(consumable)
    || IsBounceBack(consumable)
    || IsHealthBooster(consumable)
    || IsMedical(consumable);
}