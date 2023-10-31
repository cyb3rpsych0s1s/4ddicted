import Addicted.System
import Addicted.Threshold

// DebugAddictTo(Game.GetPlayer());
public func DebugAddictTo(player: wref<PlayerPuppet>) -> Void {
    let system = GameInstance.GetStatusEffectSystem(player.GetGame());
    system.ApplyStatusEffect(
        player.GetEntityID(),
        t"BaseStatusEffect.AddictToFirstAidWhiff",
        t"Addiction",
        player.GetEntityID(),
        1u);
    // System.GetInstance(player.GetGame()).UpdateEffect(ItemID.FromTDBID(t"Items.BonesMcCoy70V0"), Threshold.Severely);
}

// GameInstance.GetGameplayLogicPackageSystem(this.GetGame()).ApplyPackage()
// GameInstance.GetStatPoolsSystem(this.GetGame()). RequestSettingStatPoolValue / RequestChangingStatPoolValue
// class ConvertDamageToDoTEffector

// DebugCustomStat(Game.GetPlayer());
public func DebugCustomStat(player: wref<PlayerPuppet>) -> Void {
    let debuff:Float;
    let stats = GameInstance.GetStatsSystem(player.GetGame());

    debuff = stats.GetStatValue(Cast<StatsObjectID>(player.GetEntityID()), IntEnum<gamedataStatType>(EnumValueFromName(n"gamedataStatType", n"BaseStats.InjectorBaseHealingDebuff"))); 
    LogChannel(n"DEBUG", s"before: \(ToString(debuff))");

    DebugAddictTo(player);

    debuff = stats.GetStatValue(Cast<StatsObjectID>(player.GetEntityID()), IntEnum<gamedataStatType>(EnumValueFromName(n"gamedataStatType", n"BaseStats.InjectorBaseHealingDebuff"))); 
    LogChannel(n"DEBUG", s"after: \(ToString(debuff))");
}