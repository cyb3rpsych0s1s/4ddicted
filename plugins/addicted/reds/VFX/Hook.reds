module Addicted

@replaceMethod(GameObject)
protected func StartStatusEffectVFX(evt: ref<ApplyStatusEffectEvent>) -> Void {
    let threshold: Threshold;
    let i: Int32;
    let vfxList: array<wref<StatusEffectFX_Record>>;
    evt.staticData.VFX(vfxList);
    i = 0;
    threshold = System.GetInstance(this.GetGame()).GetThresholdFromAppliedEffects(evt.staticData);
    while i < ArraySize(vfxList) {
        if evt.isNewApplication || vfxList[i].ShouldReapply() {
            GameObjectEffectHelper.StartEffectEvent(this, GetVFXName(threshold, vfxList[i].Name()));
        };
        i += 1;
    };
}

@replaceMethod(GameObject)
protected func StopStatusEffectVFX(evt: ref<RemoveStatusEffect>) -> Void {
    let threshold: Threshold;
    let i: Int32;
    let vfxList: array<wref<StatusEffectFX_Record>>;
    evt.staticData.VFX(vfxList);
    i = 0;
    threshold = System.GetInstance(this.GetGame()).GetThresholdFromAppliedEffects(evt.staticData);
    while i < ArraySize(vfxList) {
        if evt.isFinalRemoval {
            GameObjectEffectHelper.BreakEffectLoopEvent(this, GetVFXName(threshold, vfxList[i].Name()));
        };
        i += 1;
    };
}
