module Addicted

/// all the status effect whose consumption is addictive
public func AddictiveStatusEffects() -> array<TweakDBID> {
    return [
        t"BaseStatusEffect.AlcoholDebuff",
        // t"BaseStatusEffect.CombatStim", // double-check
        t"BaseStatusEffect.FirstAidWhiffV0",
        t"BaseStatusEffect.FirstAidWhiffV1",
        t"BaseStatusEffect.FirstAidWhiffV2",
        t"BaseStatusEffect.BonesMcCoy70V0",
        t"BaseStatusEffect.BonesMcCoy70V1",
        t"BaseStatusEffect.BonesMcCoy70V2",
        t"BaseStatusEffect.BlackLaceV0",
        t"BaseStatusEffect.HealthBooster",
        t"BaseStatusEffect.CarryCapacityBooster",
        t"BaseStatusEffect.StaminaBooster",
        t"BaseStatusEffect.MemoryBooster",
        t"BaseStatusEffect.OxyBooster",
        // WE3D - Drugs of Night City
        t"BaseStatusEffect.BlackLace",
        t"BaseStatusEffect.RainbowPoppers",
        t"BaseStatusEffect.Glitter",
        t"BaseStatusEffect.FR3SH",
        t"BaseStatusEffect.SecondWind",
        t"BaseStatusEffect.Locus",
        t"BaseStatusEffect.Evade",
        t"BaseStatusEffect.BeRiteBack",
        t"BaseStatusEffect.Juice",
        t"BaseStatusEffect.Rara",
        t"BaseStatusEffect.Ullr",
        t"BaseStatusEffect.ArasakaReflexBooster",
        t"BaseStatusEffect.PurpleHaze",
        t"BaseStatusEffect.Donner",
        t"BaseStatusEffect.IC3C0LD",
        t"BaseStatusEffect.SyntheticBlood",
        t"BaseStatusEffect.RoaringPhoenix",
        t"BaseStatusEffect.Cleanser",
        t"BaseStatusEffect.GrisGris",
        t"BaseStatusEffect.Superjet",
        t"BaseStatusEffect.Deimos",
        t"BaseStatusEffect.Aspis",
        t"BaseStatusEffect.Brisky",
        t"BaseStatusEffect.Karanos"
    ];
}

/// is this a status effect a maxdoc ?
@addMethod(StatusEffectEvent)
public func IsMaxDOC() -> Bool {
    switch(this.staticData.GetID()) {
        case t"BaseStatusEffect.FirstAidWhiffV0":
        case t"BaseStatusEffect.FirstAidWhiffV1":
        case t"BaseStatusEffect.FirstAidWhiffV2":
            return true;
        default:
            break;
    }
    return false;
}

/// is this a status effect a bounce back ?
@addMethod(StatusEffectEvent)
public func IsBounceBack() -> Bool {
    switch(this.staticData.GetID()) {
        case t"BaseStatusEffect.BonesMcCoy70V0":
        case t"BaseStatusEffect.BonesMcCoy70V1":
        case t"BaseStatusEffect.BonesMcCoy70V2":
            return true;
        default:
            break;
    }
    return false;
}

/// is this a status effect which can trigger addiction ?
@addMethod(StatusEffectEvent)
public func IsAddictive() -> Bool {
    let list = AddictiveStatusEffects();
    let id = this.staticData.GetID();
    LogChannel(n"DEBUG", "RED:IsAddictive " + ToString(id) + " (" + ArrayContains(list, id) + ")");
    return ArrayContains(list, id);
}

/// is this a healing status effect ?
@addMethod(StatusEffectEvent)
public func IsHealer() -> Bool {
    switch(this.staticData.GetID()) {
        case t"BaseStatusEffect.FirstAidWhiffV0":
        case t"BaseStatusEffect.FirstAidWhiffV1":
        case t"BaseStatusEffect.FirstAidWhiffV2":
        case t"BaseStatusEffect.BonesMcCoy70V0":
        case t"BaseStatusEffect.BonesMcCoy70V1":
        case t"BaseStatusEffect.BonesMcCoy70V2":
        case t"BaseStatusEffect.HealthBooster":
            return true;
        default:
            break;
    }
    return false;
}

/// is the status effect from an inhaler ?
@addMethod(StatusEffectEvent)
public func IsInhaler() -> Bool {
    switch(this.staticData.GetID()) {
        case t"BaseStatusEffect.FirstAidWhiffV0":
        case t"BaseStatusEffect.FirstAidWhiffV1":
        case t"BaseStatusEffect.FirstAidWhiffV2":
        case t"BaseStatusEffect.BlackLaceV0":
            return true;
        default:
            break;
    }
    return false;
}

/// is the status effect from an injector ?
@addMethod(StatusEffectEvent)
public func IsInjector() -> Bool {
    switch(this.staticData.GetID()) {
        case t"BaseStatusEffect.BonesMcCoy70V0":
        case t"BaseStatusEffect.BonesMcCoy70V1":
        case t"BaseStatusEffect.BonesMcCoy70V2":
            return true;
        default:
            break;
    }
    return false;
}

/// is the status effect from a booster ?
@addMethod(StatusEffectEvent)
public func IsBooster() -> Bool {
    switch(this.staticData.GetID()) {
        case t"BaseStatusEffect.OxyBooster":
        case t"BaseStatusEffect.CarryCapacityBooster":
        case t"BaseStatusEffect.StaminaBooster":
        case t"BaseStatusEffect.HealthBooster":
        case t"BaseStatusEffect.MemoryBooster":
        case t"BaseStatusEffect.HeatUsingBoosterDummyEffect":
            return true;
        default:
            break;
    }
    return false;
}

/// is the status effect from a pill ?
@addMethod(StatusEffectEvent)
public func IsPill() -> Bool {
  switch(this.staticData.GetID()) {
        case t"BaseStatusEffect.CarryCapacityBooster":
        case t"BaseStatusEffect.StaminaBooster":
        case t"BaseStatusEffect.MemoryBooster":
            return true;
        default:
            break;
    }
    return false;
}

/// how addictive is the status effect when consuming ?
/// this is the opposite of resilience, on purpose
public func GetPotency(id: TweakDBID) -> Int32 {
    let category = GetCategory(id);
    switch(category) {
        case Category.Hard:
            return 2;
        case Category.Mild:
            return 1;
    }
}

/// how resilient is the status effect when weaning off ?
/// this is the opposite of potency, on purpose
public func GetResilience(id: TweakDBID) -> Int32 {
    let category = GetCategory(id);
    switch(category) {
        case Category.Hard:
            return 1;
        case Category.Mild:
            return 2;
    }
}

public func GetCategory(id: TweakDBID) -> Category {
    switch(id) {
        case t"BaseStatusEffect.BlackLaceV0":
        case t"BaseStatusEffect.FR3SH":
            return Category.Hard;
        // TODO: add missing
        default:
            break;
    }
    return Category.Mild;
}

@addMethod(ApplyStatusEffectEvent)
public func Reevaluate() -> Void {
    if this.IsHealer() && this.isNewApplication {
        if this.IsMaxDOC() {
            let package = this.staticData.GetPackagesItemHandle(0);
            let effector = package.GetEffectorsItemHandle(0);
            let updates = effector.GetStatPoolUpdatesItemHandle(0);
            // updates.statPoolValue = 20; // unreachable
            // update.StatPoolValue(); // only getter
            // TODO: update stats for maxdoc
        }
        if this.IsBounceBack() {
            // TODO: update stats for bounceback
        }
    }
}

@wrapMethod(ConsumeAction)
protected func ProcessStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>, gameInstance: GameInstance) -> Void {
    LogChannel(n"DEBUG", s"RED:ConsumeAction:ProcessStatusEffects: \(ToString(actionEffects)) \(ToString(gameInstance))");
    let idx = 0;
    for effect in actionEffects {
        if Equals(effect.GetID(), t"Items.FirstAidWhiffV0_inline2") {
            LogChannel(n"DEBUG", s"RED:ConsumeAction:ProcessStatusEffects:... this is MaxDOC");
            let replaced = TweakDBInterface.GetObjectActionEffectRecord(t"Items.FirstAidWhiffVMinus1_inline2");
            actionEffects[idx] = replaced;
        }
        idx += 1;
    }
    wrappedMethod(actionEffects, gameInstance);
}
