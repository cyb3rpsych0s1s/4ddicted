module Addicted

import Addicted.System.AddictedSystem
import Addicted.Utils.F

public class IncreaseNeuroBlockerEffector extends Effector {
    protected func ActionOn(owner: ref<GameObject>) -> Void {
        let system = AddictedSystem.GetInstance(owner.GetGame());
        // grant a unique ID to differentiate: see Generic.IsNeuroBlocker
        system.OnConsumeItem(ItemID.FromTDBID(t"Items.ripperdoc_med_contraindication"), true);
    }
}
