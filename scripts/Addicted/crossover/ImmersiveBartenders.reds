module Addicted.Crossover

import Addicted.System.AddictedSystem
import Addicted.Utils.{E,EI}

public class ImmersiveBartendersSubSystem extends ScriptableSystem {

    private let player: wref<PlayerPuppet>;

    private let listener: Uint32;
    private let fact: Int32;

    private func RegisterListeners(player: ref<PlayerPuppet>) -> Void {
		E(s"Immersive Bartenders: register listeners (\(ToString(GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(n"dec_dark_bartender"))))");
        this.fact = GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(n"dec_dark_bartender");
        this.listener = GameInstance.GetQuestsSystem(this.GetGameInstance()).RegisterListener(n"dec_dark_bartender", this, n"OnDrink");
    }

    private func UnregisterListeners(player: ref<PlayerPuppet>) -> Void {
        GameInstance.GetQuestsSystem(this.GetGameInstance()).UnregisterListener(n"dec_dark_bartender", this.listener);
        this.listener = 0u;
    }

    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
		E("Immersive Bartenders: on player attach");
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

    private final func OnDrink(value: Int32) -> Void {
		E(s"Immersive Bartenders: on drink (\(ToString(value)))");
        if Equals(this.fact, -1) && value < 4 { // -1 == Ready, 4 == Soda
            let tdbid: TweakDBID = GetAlcoholRecordFromImmersiveBartenderFactValue(value);
            if NotEquals(tdbid, TDBID.None()) {
                AddictedSystem.GetInstance(this.GetGameInstance()).OnConsumeItem(ItemID.FromTDBID(tdbid));
            }
        }
        this.fact = value;
    }
}

private func GetAlcoholRecordFromImmersiveBartenderFactValue(value: Int32) -> TweakDBID {
    E(s"Immersive Bartenders: fact \(ToString(value))");
    switch value {
        // whiskey
        case 1:
            return t"Items.MediumQualityAlcohol2"; // O'Dickin Whiskey
            break;
        // beer
        case 2:
            return t"Items.LowQualityAlcohol3"; // Broseph Ale
            break;
        // tequila
        case 3:
            return t"Items.LowQualityAlcohol9"; // Tequila Especial
            break;
        default:
            return TDBID.None();
            break;
    }
}
