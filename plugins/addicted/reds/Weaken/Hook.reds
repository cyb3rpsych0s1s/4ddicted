module Addicted

@wrapMethod(UseHealChargeAction)
protected func ProcessStatusEffects(const actionEffects: script_ref<array<wref<ObjectActionEffect_Record>>>, gameInstance: GameInstance) -> Void {
    LogChannel(n"DEBUG", "on UseHealChargeAction.ProcessStatusEffects");
    let system = System.GetInstance(gameInstance);
    let threshold: Threshold = Threshold.Clean;
    let i: Int32 = 0;
    while i < ArraySize(Deref(actionEffects)) {
        LogChannel(n"DEBUG", s"effect ID: \(TDBID.ToStringDEBUG(Deref(actionEffects)[i].GetID()))");
        switch(Deref(actionEffects)[i].GetID()) {
            case t"Items.FirstAidWhiffV0_inline3":
            case t"Items.FirstAidWhiffV1_inline3":
            case t"Items.FirstAidWhiffV2_inline3":
            case t"Items.FirstAidWhiffVEpic_inline3":
            case t"Items.FirstAidWhiffVUncommon_inline3":
                threshold = system.GetCumulatedThreshold(Consumable.MaxDOC);
                break;
            case t"Items.BonesMcCoy70V0_inline3":
            case t"Items.BonesMcCoy70V1_inline3":
            case t"Items.BonesMcCoy70V2_inline3":
            case t"Items.BonesMcCoy70VEpic_inline8":
            case t"Items.BonesMcCoy70VUncommon_inline8":
                threshold = system.GetCumulatedThreshold(Consumable.BounceBack);
                break;
        }
        if Equals(threshold, Threshold.Notably)       { Deref(actionEffects)[i] = TweakDBInterface.GetObjectActionEffectRecord(Deref(actionEffects)[i].GetID() + t"_notably_weakened");  }
        else if Equals(threshold, Threshold.Severely) { Deref(actionEffects)[i] = TweakDBInterface.GetObjectActionEffectRecord(Deref(actionEffects)[i].GetID() + t"_severely_weakened"); }
        i += 1;
    }
    wrappedMethod(actionEffects, gameInstance);
}

@wrapMethod(ConsumeAction)
protected func ProcessStatusEffects(const actionEffects: script_ref<array<wref<ObjectActionEffect_Record>>>, gameInstance: GameInstance) -> Void {
    LogChannel(n"DEBUG", "on ConsumeAction.ProcessStatusEffects");
    let system = System.GetInstance(gameInstance);
    let threshold: Threshold = Threshold.Clean;
    let i: Int32 = 0;
    while i < ArraySize(Deref(actionEffects)) {
        LogChannel(n"DEBUG", s"effect ID: \(TDBID.ToStringDEBUG(Deref(actionEffects)[i].GetID()))");
        switch(Deref(actionEffects)[i].GetID()) {
            case t"Items.HealthBooster_inline1":
            case t"Items.Blackmarket_HealthBooster_inline1":
                threshold = system.GetCumulatedThreshold(Consumable.HealthBooster);
                break;
        }
        if Equals(threshold, Threshold.Notably)       { Deref(actionEffects)[i] = TweakDBInterface.GetObjectActionEffectRecord(Deref(actionEffects)[i].GetID() + t"_notably_weakened");  }
        else if Equals(threshold, Threshold.Severely) { Deref(actionEffects)[i] = TweakDBInterface.GetObjectActionEffectRecord(Deref(actionEffects)[i].GetID() + t"_severely_weakened"); }
        i += 1;
    }
    wrappedMethod(actionEffects, gameInstance);
}