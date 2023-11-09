module Addicted

import Martindale.IsMaxDOC
import Martindale.IsBounceBack
import Martindale.IsHealthBooster
import Martindale.Consumable

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
