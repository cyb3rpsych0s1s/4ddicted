module Addicted.Crossover

import Addicted.System.AddictedSystem

public class ImmersiveBartendersSubSystem extends ScriptableSystem {

    private let player: wref<PlayerPuppet>;

    private let onImmersiveDrink: Uint32;
    private let lastImmersiveDrink: Int32 = 0;

    private func RegisterListeners(player: ref<PlayerPuppet>) -> Void {
        this.onImmersiveDrink = GameInstance.GetQuestsSystem(this.GetGameInstance()).RegisterListener(n"dec_dark_bartender", this, n"OnImmersiveDrink");
    }

    private func UnregisterListeners(player: ref<PlayerPuppet>) -> Void {
        GameInstance.GetQuestsSystem(this.GetGameInstance()).UnregisterListener(n"dec_dark_bartender", this.onImmersiveDrink);
    }

    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
        let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
        if IsDefined(player) {
            this.player = player;
            this.RegisterListeners(this.player);
        }
    }

    public final func OnPlayerDetach(player: ref<PlayerPuppet>) -> Void {
        this.UnregisterListeners(this.player);
        this.player = null;
    }

    private final func OnImmersiveDrink(value: Int32) -> Void {
        if Equals(this.lastImmersiveDrink, -1) && value < 4 { // -1 == Ready, 4 == Soda
            let tdbid: TweakDBID = GetAlcoholRecordFromImmersiveBartenderFactValue(value);
            if NotEquals(tdbid, t"") {
                AddictedSystem.GetInstance(this.GetGameInstance()).OnConsumeItem(ItemID.FromTDBID(tdbid));
            }
        }
        this.lastImmersiveDrink = value;
    }
}

private final static func GetAlcoholRecordFromImmersiveBartenderFactValue(value: Int32) -> TweakDBID {
    switch value {
        // whiskey
        case 1:
            return t"Items.LowQualityAlcohol";
            break;
        // beer
        case 2:
            return t"Items.LowQualityAlcohol";
            break;
        // tequila
        case 3:
            return t"Items.LowQualityAlcohol";
            break;
        default:
            return t"";
            break;
    }
}
