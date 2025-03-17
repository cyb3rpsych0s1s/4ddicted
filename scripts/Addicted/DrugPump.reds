module DrugPump

public class DrugPumpConsumptionEffector extends ApplyStatusEffectEffector {

	public let m_effectorChanceMods: array<wref<StatModifier_Record>>;

	protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
		let player: ref<PlayerPuppet> = GetPlayer(game);
		this.m_record				= TweakDBInterface.GetApplyStatusEffectEffectorRecord(record).StatusEffect().GetID();
		this.m_applicationTarget	= TweakDBInterface.GetCName(record + t".applicationTarget", player.GetName());
		this.m_removeWithEffector	= TweakDBInterface.GetBool(record + t".removeWithEffector", false);
		this.m_inverted				= TweakDBInterface.GetBool(record + t".inverted", false);
		this.m_count				= TweakDBInterface.GetFloat(record + t".count", 1.00);
		this.m_instigator			= TweakDBInterface.GetString(record + t".instigator", "");
		this.m_useCountWhenRemoving	= TweakDBInterface.GetBool(record + t".useCountWhenRemoving", false);
		TweakDBInterface.GetApplyStatusEffectByChanceEffectorRecord(record).EffectorChance(this.m_effectorChanceMods);
	}

	protected func ActionOn(owner: ref<GameObject>) -> Void {
		let game: GameInstance = owner.GetGame();
		let player: ref<PlayerPuppet> = GetPlayer(game);
		let playerID: EntityID = player.GetEntityID();
		if  GameInstance.GetStatusEffectSystem(game).HasStatusEffect(playerID, t"BaseStatusEffect.BlackLaceV1") || 
			GameInstance.GetStatusEffectSystem(game).HasStatusEffect(playerID, t"BaseStatusEffect.BlackLaceV0") ||
			!this.GetApplicationTarget(player, this.m_applicationTarget, playerID) {
		//	LogChannel(n"DEBUG", "HasStatusEffect or no applicationTarget, Returning");
			return;
		};
		if this.UseAndConsumeItem(game, player, playerID, this.GetPlayerDrugByTDBID(game, t"Items.BlackLaceV1"), t"BaseStatusEffect.BlackLaceV1") {
			return;
		};
		if this.UseAndConsumeItem(game, player, playerID, this.GetPlayerDrugByTDBID(game, t"Items.BlackLaceV0"), t"BaseStatusEffect.BlackLaceV0") {
			return;
		};
	}

	protected func UseAndConsumeItem(game: GameInstance, player: ref<PlayerPuppet>, playerID: EntityID, itemID: ItemID, tdbid: TweakDBID) -> Bool {
		if !Equals(itemID, ItemID.None()) && Equals(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).ItemType().Type(), gamedataItemType.Con_Inhaler) {
			StatusEffectHelper.ApplyStatusEffectOnSelf(game, tdbid, playerID);
		//	LogChannel(n"DEBUG", "Applied Status Effect: " + TDBID.ToStringDEBUG(tdbid));
			if RandF() <= (RPGManager.CalculateStatModifiers(this.m_effectorChanceMods, game, player, Cast<StatsObjectID>(playerID)) / 100.0) {
			//	LogChannel(n"DEBUG", "Removing Item: " + TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)));
				GameInstance.GetTransactionSystem(game).RemoveItem(player, itemID, 1);
			};
			return true;
		};
		return false;
	}

	protected func GetPlayerDrugByTDBID(game: GameInstance, matchTDBID: TweakDBID) -> ItemID {
		let playersItems: array<wref<gameItemData>>;
		GameInstance.GetTransactionSystem(game).GetItemListByTag(GetPlayer(game), n"Drug", playersItems);
		let itemID: ItemID = ItemID.None();
		let i: Int32 = 0;
		let iS: Int32 = ArraySize(playersItems);
		while i < iS {
			itemID = playersItems[i].GetID();
			if Equals(matchTDBID, ItemID.GetTDBID(itemID)) {
				return itemID;
			};
			i += 1;
		};
		return ItemID.None();
	}

}
