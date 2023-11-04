module Martindale

public func IsMemoryBooster(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.MemoryBooster);
}

public func IsNeuroBlocker(consumable: ref<ConsumableItem_Record>) -> Bool {
    return ArrayContains(consumable.Tags(), n"NeuroBlocker");
}

public func IsNeuro(consumable: ref<ConsumableItem_Record>) -> Bool {
    let vanilla = IsMemoryBooster(consumable);
    let wannabe = IsNeuroBlocker(consumable);
    let mods = ArrayContains(consumable.Tags(), n"NeuroTransmitter");
    return vanilla || wannabe || mods;
}