module Martindale

public func BasedOnStaminaRegenRateMult(modifier: ref<ConstantStatModifier_Record>) -> Bool {
    return Equals(modifier.StatType().StatType(), gamedataStatType.StaminaRegenRateMult) && modifier.Value() > 0.;
}
public func StaminaRegenRateMultModifiers() -> array<ref<ConstantStatModifier_Record>> {
    let modifiers: array<ref<ConstantStatModifier_Record>> = [];
    let records = TweakDBInterface.GetRecords(n"ConstantStatModifier");
    LogChannel(n"DEBUG", s"scan \(ToString(ArraySize(records))) constant stat modifier(s)");
    let modifier: ref<ConstantStatModifier_Record>;
    for record in records {
        modifier = record as ConstantStatModifier_Record;
        if BasedOnStaminaRegenRateMult(modifier) {
            ArrayPush(modifiers, modifier);
        }
    }
    return modifiers;
}
