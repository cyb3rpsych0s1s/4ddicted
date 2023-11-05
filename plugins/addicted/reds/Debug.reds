import Addicted.System
import Addicted.Threshold
import Martindale.MartindaleSystem

native func WriteToFile(lines: array<String>, filename: String) -> Void;

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

// DebugMartindaleRegistry(Game.GetPlayer());
public func DebugMartindaleRegistry(player: wref<PlayerPuppet>) -> Void {
    let system = MartindaleSystem.GetInstance(player.GetGame());
    system.DebugRegistry();
}

public func DebugStatusEffectPrereq() -> Void {
    let records = TweakDBInterface.GetRecords(n"StatusEffectPrereq");
    let prereq: ref<StatusEffectPrereq_Record>;
    let lines: array<String> = [];
    let line: String;
    LogChannel(n"DEBUG", s"StatusEffectPrereq");
    for record in records {
        prereq = record as StatusEffectPrereq_Record;
        line = s"\(TDBID.ToStringDEBUG(prereq.GetID())):\nstatus effect ID:\(TDBID.ToStringDEBUG(prereq.StatusEffect().GetID()))\ncheck type: \(prereq.CheckType().EnumName())";
        LogChannel(n"DEBUG", line);
        ArrayPush(lines, line);
    }
    WriteToFile(lines, "StatusEffectPrereq");
}
