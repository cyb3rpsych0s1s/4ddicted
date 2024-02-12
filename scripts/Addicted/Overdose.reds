public class SporadicAttackDelay extends DelayCallback {
    public let effector: wref<TriggerSporadicAttackOnOwnerEffect>;
    public let owner: wref<GameObject>;
    public func Call() -> Void {
        if IsDefined(this.effector) && IsDefined(this.effector) {
            if this.effector.once < 5 {
                this.effector.DirectRepeatedAction(this.owner);
                this.effector.delay = Schedule(this.effector, this.owner, RandF() * 3.0);
                this.effector.once += 1;
            } else {
                GameInstance.GetDelaySystem(this.owner.GetGame()).CancelCallback(this.effector.delay);
                this.effector.delay = GetInvalidDelayID();
                this.effector.once = 0;
            }
        }
    }
}

private func Schedule(effector: ref<TriggerSporadicAttackOnOwnerEffect>, owner: ref<GameObject>, delay: Float) -> DelayID {
    let callback = new SporadicAttackDelay();
    let delay = RandF() * 3.0;
    let id = GameInstance.GetDelaySystem(owner.GetGame()).DelayCallback(callback, delay, true);
    return id;
}

public class TriggerSporadicAttackOnOwnerEffect extends TriggerAttackOnOwnerEffect {
    public let delay: DelayID;
    public let once: Int32 = 0;
    protected func RepeatedAction(owner: ref<GameObject>) -> Void {
        LogChannel(n"DEBUG", "[TriggerSporadicAttackOnOwnerEffect] RepeatedAction");
        if this.once == 0 {
            this.DirectRepeatedAction(owner);
            this.once += 1;
        } else if Equals(this.delay, GetInvalidDelayID()) {
            this.delay = Schedule(this, owner, RandF() * 3.0);
        }
    }
    private func DirectRepeatedAction(owner: ref<GameObject>) -> Void {
        LogChannel(n"DEBUG", "[TriggerSporadicAttackOnOwnerEffect] DirectRepeatedAction");
        super.RepeatedAction(owner);
    }
}