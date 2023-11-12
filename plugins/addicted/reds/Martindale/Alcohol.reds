module Martindale

public func IsAlcohol(consumable: ref<ConsumableItem_Record>) -> Bool {
    return Equals(consumable.ConsumableBaseName().Type(), gamedataConsumableBaseName.Alcohol);
}
