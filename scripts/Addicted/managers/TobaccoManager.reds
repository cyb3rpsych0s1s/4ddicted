module Addicted.Manager

import Addicted.System.AddictedSystem
import Addicted.Helper
import Addicted.Helpers.Generic
import Addicted.{Threshold, Addiction, Consumable}

public class CigaretteAttachment extends AttachmentSlotsScriptCallback {
    public let owner: ref<PlayerPuppet>;
    public func OnItemEquipped(slot: TweakDBID, item: ItemID) -> Void {
        let system: ref<AddictedSystem>;
        let threshold: Threshold;
        let notable: Bool;
        let severe: Bool;
        let id: TweakDBID;
        if Generic.IsTobacco(ItemID.GetTDBID(item)) {
            system = AddictedSystem.GetInstance(this.owner.GetGame());
            system.OnConsumeItem(item);
            threshold = system.Threshold(Addiction.Tobacco);
            notable = EnumInt(threshold) == EnumInt(Threshold.Notably);
            severe = EnumInt(threshold) == EnumInt(Threshold.Severely);
            if notable || severe {
                if notable { id = t"BaseStatusEffect.ShortBreath"; }
                else       { id = t"BaseStatusEffect.BreathLess"; }
                StatusEffectHelper.ApplyStatusEffect(this.owner, id, 0.2);
            }
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