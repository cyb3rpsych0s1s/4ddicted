module Addicted

public func CoughAudios(gender: CName) -> array<CName> {
    LogChannel(n"DEBUG", "RED:CoughAudios" + " " + ToString(gender));
    if Equals(gender, n"Female") {
        return [
            n"q203_sc_01_v_female_cough",
            n"q114_sc_02_v_vo_cough",
            n"q115_sc_00b_vo_v_cough"
        ];
    }
    return [
        n"g_sc_v_sickness_cough_light",
        n"g_sc_v_sickness_cough_hard",
        n"g_sc_v_sickness_cough_blood"
    ];
}

@addMethod(PlayerPuppet)
public func Cough() -> Void {
    let audios = CoughAudios(this.GetGender());
    let count = ArraySize(audios);
    let idx = RandRange(0, count - 1);
    let name = audios[idx];
    let evt = new SoundPlayEvent();
    evt.soundName = name;
    this.QueueEvent(evt);
}

@addMethod(PlayerPuppet)
public func GetAddictionSystem() -> ref<PlayerAddictionSystem> {
    let container = GameInstance.GetScriptableSystemsContainer(this.GetGame());
    return container.Get(n"Addicted.PlayerAddictionSystem") as PlayerAddictionSystem;
}

@addMethod(PlayerPuppet)
public func FeelsDizzy() -> Void {
    GameObject.SetAudioParameter(this, n"vfx_fullscreen_drunk_level", 3.00);
    StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.MaxDOCMirage");
}

@addMethod(PlayerPuppet)
public func SlowStun() -> Void {
    StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.SlowStun");
}

@addMethod(PlayerPuppet)
public func IsAddicted(substanceID: TweakDBID) -> Bool {
    let system = this.GetAddictionSystem();
    let threshold = system.GetThreshold(substanceID);
    return EnumInt(threshold) >= EnumInt(Threshold.Mildly);
}

@addMethod(PlayerPuppet)
public func HasAnyAddiction() -> Bool {
    let consumables = AddictiveConsumables();
    for consumable in consumables {
        if this.IsAddicted(consumable) { return true; }
    }
    return false;
}

public func AddictiveConsumables() -> array<TweakDBID> {
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

@addMethod(StatusEffectEvent)
public func IsAddictive() -> Bool {
    return ArrayContains(
        AddictiveConsumables(),
        this.staticData.GetID());
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let output = wrappedMethod(evt);
    let addictionSystem = this.GetAddictionSystem();
    // increase score on consumption
    if evt.isNewApplication && evt.IsAddictive() {
        addictionSystem.OnAddictiveSubstanceConsumed(evt.staticData.GetID());
    }
    // decrease score on rest
    if evt.staticData.GetID() == t"HousingStatusEffect.Rested" {
        let timeSystem = GameInstance.GetTimeSystem(this.GetGame());
        addictionSystem.OnRested(timeSystem.GetGameTimeStamp());
    }
    return output;
}
