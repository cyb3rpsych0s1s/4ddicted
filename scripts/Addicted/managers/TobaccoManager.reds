module Addicted.Manager

import Addicted.System.AddictedSystem
import Addicted.Helpers.Generic

public class CigaretteAttachment extends AttachmentSlotsScriptCallback {
    public let owner: ref<PlayerPuppet>;
    public func OnItemEquipped(slot: TweakDBID, item: ItemID) -> Void {
        let system: ref<AddictedSystem>;
        if Generic.IsTobacco(ItemID.GetTDBID(item)) {
            system = AddictedSystem.GetInstance(this.owner.GetGame());
            system.OnConsumeItem(item);
        }
    }
}

public class TobaccoManager extends IScriptable {
    private let listener: ref<AttachmentSlotsScriptListener>;
    public func Register(player: ref<PlayerPuppet>) -> Void {
        let transactions: ref<TransactionSystem>;
        if player != null && !IsDefined(this.listener) {
            transactions = GameInstance.GetTransactionSystem(player.GetGame());
            let callback = new CigaretteAttachment();
            callback.owner = player;
            this.listener = transactions.RegisterAttachmentSlotListener(player, callback);
        }
    }
    public func Unregister(player: ref<PlayerPuppet>) -> Void {
        let transactions: ref<TransactionSystem>;
        if player != null && IsDefined(this.listener) {
            transactions = GameInstance.GetTransactionSystem(player.GetGame());
            transactions.UnregisterAttachmentSlotListener(player, this.listener);
        }
    }
}