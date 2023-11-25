module Martindale
import Addicted.Consumable

public func Is(record: ref<Item_Record>, consumable: Consumable) -> Bool {
    if record.IsExactlyA(n"gamedataConsumableItem_Record") {
        return Is(record as ConsumableItem_Record, consumable);
    }
    if record.IsExactlyA(n"gamedataItem_Record") {
        return Is(record, consumable);
    }
    return false;
}

public func Is(record: ref<ConsumableItem_Record>, consumable: Consumable) -> Bool {
    switch(consumable) {
        case Consumable.Alcohol:
            return IsAlcohol(record);
        case Consumable.MaxDOC:
            return IsMaxDOC(record);
        case Consumable.BounceBack:
            return IsBounceBack(record);
        case Consumable.HealthBooster:
            return IsHealthBooster(record);
        case Consumable.StaminaBooster:
            return IsStaminaBooster(record);
        case Consumable.CarryCapacityBooster:
            return IsCarryCapacityBooster(record);
        case Consumable.MemoryBooster:
            return IsMemoryBooster(record);
        case Consumable.NeuroBlocker:
            return IsNeuroBlocker(record);
        default:
            break;
    }
    return false;
}

public func Is(record: ref<Item_Record>, consumable: Consumable) -> Bool {
    switch(consumable) {
        case Consumable.Tobacco:
            return IsCigarette(record) || IsCigar(record);
        default:
            break;
    }
    return false;
}
