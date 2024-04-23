module Addicted

import Addicted.System.AddictedSystem
import Addicted.Utils.F

public class IncreaseNeuroBlockerEffector extends Effector {
    private let item: ItemID;
    protected func ActionOn(owner: ref<GameObject>) -> Void {
        let system = AddictedSystem.GetInstance(owner.GetGame());
        if ItemID.IsValid(this.item) {
            system.OnConsumeItem(ItemID.FromTDBID(t"Items.ripperdoc_med_common"), true);
        }
    }
}