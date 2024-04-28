module Addicted

import Addicted.System.AddictedSystem
import Addicted.Utils.F

public class IncreaseNeuroBlockerEffector extends Effector {
    protected func ActionOn(owner: ref<GameObject>) -> Void {
        let system = AddictedSystem.GetInstance(owner.GetGame());
        // use a fake ID to differentiate, see:
        // - Generic.IsNeuroBlocker
        // - Generic.IsContraindicated
        // - Consumptions.Items
        // - NeuroBlockerTweaks
        system.OnContraindication(ItemID.FromTDBID(t"Items.ripperdoc_med_contraindication"));
    }
}
