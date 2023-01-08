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

/// is this a status effect which can trigger addiction ?
@addMethod(StatusEffectEvent)
public func IsAddictive() -> Bool {
    return ArrayContains(AddictiveStatusEffects(), this.staticData.GetID());
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
        case t"BaseStatusEffect.StaminaBooster":
        case t"BaseStatusEffect.HeatUsingBoosterDummyEffect":
            return true;
        default:
            break;
    }
    return false;
}