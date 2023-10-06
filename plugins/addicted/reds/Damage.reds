module Addicted

@wrapMethod(DamageSystem)
private final func FillInDamageBlackboard(hitEvent: ref<gameHitEvent>) -> Void {
    let data: ref<AttackData>               = hitEvent.attackData;
    let weapon: ref<WeaponObject>           = data.weapon;
    let item: wref<gameItemData>            = weapon.GetItemData();
    let record: ref<WeaponItem_Record>      = weapon.GetWeaponRecord();
    let name: CName                         = item.GetName();
    let attackType: gamedataAttackType      = data.GetAttackType();
    let damageType: wref<DamageType_Record> = record.DamageType();
    let effectiveRangeFalloff: CName        = record.EffectiveRangeFalloffCurve();
    let effectiveRange: CName               = record.EffectiveRangeCurve();
    let projectileEaseOut: CName            = record.ProjectileEaseOutCurveName();
    LogChannel(n"DEBUG", s"-----------------------------------------");
    LogChannel(n"DEBUG", s"WEAPON: \(NameToString(name))");
    LogChannel(n"DEBUG", s"attack type: \(ToString(attackType))");
    LogChannel(n"DEBUG", s"damage type: \(damageType.EnumName())");
    LogChannel(n"DEBUG", s"curves:");
    LogChannel(n"DEBUG", s"> effective range falloff: \(NameToString(effectiveRangeFalloff))");
    LogChannel(n"DEBUG", s"> effective range: \(NameToString(effectiveRange))");
    LogChannel(n"DEBUG", s"> projectile ease out: \(NameToString(projectileEaseOut))");
    LogChannel(n"DEBUG", s"-----------------------------------------");
    wrappedMethod(hitEvent);
}