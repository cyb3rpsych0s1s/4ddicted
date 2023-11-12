module Addicted

@wrapMethod(UseHealChargeAction)
protected func ProcessStatusEffects(const actionEffects: script_ref<array<wref<ObjectActionEffect_Record>>>, gameInstance: GameInstance) -> Void {
    LogChannel(n"DEBUG", "on ProcessStatusEffect inside UseHealChargeAction");
    let system = System.GetInstance(gameInstance);
    let threshold: Threshold = Threshold.Clean;
    let idx: Int32 = 0;
    while idx < ArraySize(Deref(actionEffects)) {
        LogChannel(n"DEBUG", s"effect ID: \(TDBID.ToStringDEBUG(Deref(actionEffects)[idx].GetID()))");
        switch(Deref(actionEffects)[idx].GetID()) {
            case t"Items.FirstAidWhiffV0_inline3":
            case t"Items.FirstAidWhiffV1_inline3":
            case t"Items.FirstAidWhiffV2_inline3":
            case t"Items.FirstAidWhiffVEpic_inline3":
            case t"Items.FirstAidWhiffVUncommon_inline3":
                threshold = system.Threshold(Consumable.MaxDOC);
                break;
            case t"Items.BonesMcCoy70V0_inline3":
            case t"Items.BonesMcCoy70V1_inline3":
            case t"Items.BonesMcCoy70V2_inline3":
            case t"Items.BonesMcCoy70VEpic_inline8":
            case t"Items.BonesMcCoy70VUncommon_inline8":
                threshold = system.Threshold(Consumable.BounceBack);
                break;
        }
        if Equals(threshold, Threshold.Notably)       { Deref(actionEffects)[idx] = TweakDBInterface.GetObjectActionEffectRecord(Deref(actionEffects)[idx].GetID() + t"_notably_weakened");  }
        else if Equals(threshold, Threshold.Severely) { Deref(actionEffects)[idx] = TweakDBInterface.GetObjectActionEffectRecord(Deref(actionEffects)[idx].GetID() + t"_severely_weakened"); }
        idx += 1;
    }
    wrappedMethod(actionEffects, gameInstance);
}