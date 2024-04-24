module Addicted

import Addicted.System.AddictedSystem
import Addicted.Utils.F

public class IncreaseNeuroBlockerEffector extends Effector {
    protected func ActionOn(owner: ref<GameObject>) -> Void {
        let system = AddictedSystem.GetInstance(owner.GetGame());
        let id = TDBID.Create("Items.ripperdoc_med_contraindication");
        // grant a unique ID to differentiate: see Generic.IsNeuroBlocker && Generic.IsContraindicated
        system.OnContraindication(ItemID.CreateQuery(id));
    }
}
