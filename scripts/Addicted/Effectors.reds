module Addicted

import Addicted.System.AddictedSystem
import Addicted.Utils.F

// prevents deadlock on System.CalculateConsumptionModifier (GLPS.GetAppliedPackages)
public class ContraindicationCallback extends DelayCallback {
    public let system: wref<AddictedSystem>;
    public func Call() -> Void {
        this.system.OnContraindication(ItemID.FromTDBID(t"Items.ripperdoc_med_contraindication"));
    }
}

public class IncreaseNeuroBlockerEffector extends Effector {
    protected func ActionOn(owner: ref<GameObject>) -> Void {
        let system = AddictedSystem.GetInstance(owner.GetGame());
        let scheduler = GameInstance.GetDelaySystem(owner.GetGame());
        // use a fake ID to differentiate, see:
        // - Generic.IsNeuroBlocker
        // - Generic.IsContraindicated
        // - Consumptions.Items
        // - NeuroBlockerTweaks
        let callback: ref<ContraindicationCallback> = new ContraindicationCallback();
        callback.system = system;
        scheduler.DelayCallbackNextFrame(callback);
    }
}
