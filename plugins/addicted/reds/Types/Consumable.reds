module Addicted

import Martindale.IsMaxDOC
import Martindale.IsBounceBack
import Martindale.IsHealthBooster

enum Consumable {
    MaxDOC = 0,
    BounceBack = 1,
    HealthBooster = 2,
    StaminaBooster = 3,
    CarryCapacityBooster = 4,
    MemoryBooster = 5,
    NeuroBlocker = 6,
    Alcohol = 7,
    Tobacco = 8,
    Count = 9,
    Invalid = 10,
}

public func IsConsumable(record: ref<ConsumableItem_Record>, consumable: Consumable) -> Bool {
    switch(consumable) {
        case Consumable.MaxDOC:
            return IsMaxDOC(record);
        case Consumable.BounceBack:
            return IsBounceBack(record);
        case Consumable.HealthBooster:
            return IsHealthBooster(record);
        default:
            break;
    }
    return false;
}
