module Addicted.Crossover

import Addicted.System.AddictedSystem

public class IdleAnywhereSubSystem extends ScriptableSystem {

    private let player: wref<PlayerPuppet>;

    private let onDrink: Uint32;
    private let lastDrink: Int32 = 0;

    private let onImmersiveDrink: Uint32;
    private let lastImmersiveDrink: Int32 = 0;

    private func RegisterListeners(player: ref<PlayerPuppet>) -> Void {
        this.onDrink = GameInstance.GetQuestsSystem(this.GetGameInstance()).RegisterListener(n"dec_dark_alco", this, n"OnDrink");
        this.onImmersiveDrink = GameInstance.GetQuestsSystem(this.GetGameInstance()).RegisterListener(n"dec_dark_bartender", this, n"OnImmersiveDrink");
    }

    private func UnregisterListeners(player: ref<PlayerPuppet>) -> Void {
        GameInstance.GetQuestsSystem(this.GetGameInstance()).UnregisterListener(n"dec_dark_alco", this.onDrink);
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

    private final func OnDrink(value: Int32) -> Void {
        if Equals(this.lastDrink, -1) && value >= 0 { // -1 == Ready, >= 0 == Alcohol Consumed
            let tdbid: TweakDBID = GetAlcoholRecordFromIdleAnywhereFactValue(value);
            if NotEquals(tdbid, t"") {
                AddictedSystem.GetInstance(this.GetGameInstance()).OnConsumeItem(ItemID.FromTDBID(tdbid));
            }
        }
        this.lastDrink = value;
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

private final static func GetAlcoholRecordFromIdleAnywhereFactValue(value: Int32) -> TweakDBID {
	switch value {
		case 0:
			return t"Items.LowQualityAlcohol";
			break;
		case 1:
			return t"Items.LowQualityAlcohol1";
			break;
		case 2:
			return t"Items.LowQualityAlcohol2";
			break;
		case 3:
			return t"Items.LowQualityAlcohol3";
			break;
		case 4:
			return t"Items.LowQualityAlcohol4";
			break;
		case 5:
			return t"Items.LowQualityAlcohol5";
			break;
		case 6:
			return t"Items.LowQualityAlcohol6";
			break;
		case 7:
			return t"Items.LowQualityAlcohol7";
			break;
		case 8:
			return t"Items.LowQualityAlcohol8";
			break;
		case 9:
			return t"Items.LowQualityAlcohol9";
			break;
		case 10:
			return t"Items.MediumQualityAlcohol";
			break;
		case 11:
			return t"Items.MediumQualityAlcohol1";
			break;
		case 12:
			return t"Items.MediumQualityAlcohol2";
			break;
		case 13:
			return t"Items.MediumQualityAlcohol3";
			break;
		case 14:
			return t"Items.MediumQualityAlcohol4";
			break;
		case 15:
			return t"Items.MediumQualityAlcohol5";
			break;
		case 16:
			return t"Items.MediumQualityAlcohol6";
			break;
		case 17:
			return t"Items.MediumQualityAlcohol7";
			break;
		case 18:
			return t"Items.GoodQualityAlcohol";
			break;
		case 19:
			return t"Items.GoodQualityAlcohol1";
			break;
		case 20:
			return t"Items.GoodQualityAlcohol2";
			break;
		case 21:
			return t"Items.GoodQualityAlcohol3";
			break;
		case 22:
			return t"Items.GoodQualityAlcohol4";
			break;
		case 23:
			return t"Items.GoodQualityAlcohol5";
			break;
		case 24:
			return t"Items.GoodQualityAlcohol6";
			break;
		case 25:
			return t"Items.TopQualityAlcohol";
			break;
		case 26:
			return t"Items.TopQualityAlcohol1";
			break;
		case 27:
			return t"Items.TopQualityAlcohol2";
			break;
		case 28:
			return t"Items.TopQualityAlcohol3";
			break;
		case 29:
			return t"Items.TopQualityAlcohol4";
			break;
		case 30:
			return t"Items.TopQualityAlcohol5";
			break;
		case 31:
			return t"Items.TopQualityAlcohol6";
			break;
		case 32:
			return t"Items.TopQualityAlcohol7";
			break;
		case 33:
			return t"Items.TopQualityAlcohol8";
			break;
		case 34:
			return t"Items.TopQualityAlcohol9";
			break;
		case 35:
			return t"Items.TopQualityAlcohol10";
			break;
		case 36:
			return t"Items.ExquisiteQualityAlcohol";
			break;
		case 37:
			return t"Items.NomadsAlcohol1";
			break;
		case 38:
			return t"Items.NomadsAlcohol2";
			break;
		default:
			return t"";
			break;
	}
}
