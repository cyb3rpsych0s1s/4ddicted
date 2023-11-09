import Addicted.System
import Martindale.Consumable
import Addicted.Threshold
import Martindale.MartindaleSystem

native func WriteToFile(lines: array<String>, filename: String) -> Void;

public func DebugHealthBoosterAddiction(gi: GameInstance) -> Void {
    let system = System.GetInstance(gi);
    let effect = TDBID.ToStringDEBUG(system.GetAddictStatusEffectID(Consumable.HealthBooster));
    ApplyEffectOnPlayer(gi, effect);
    PrintEffectsOnPlayer(gi);
    AddToInventory(gi, "Items.HealthBooster");
    ItemActionsHelper_ConsumeItem(GetPlayer(gi), ItemID.FromTDBID(t"Items.HealthBooster"), true);
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

public func DebugStatPoolUpdate() -> Void {
    let records = TweakDBInterface.GetRecords(n"StatPoolUpdate");
    let update: ref<StatPoolUpdate_Record>;
    let modifiers: array<wref<StatModifier_Record>>;
    let constant: ref<ConstantStatModifier_Record>;
    let combined: ref<CombinedStatModifier_Record>;
    let substat: ref<SubStatModifier_Record>;
    let random: ref<RandomStatModifier_Record>;
    let curve: ref<CurveStatModifier_Record>;
    let lines: array<String> = [];
    let line: String;
    let size: Int32;
    LogChannel(n"DEBUG", s"StatPoolUpdate");
    for record in records {
        line = "";
        update = record as StatPoolUpdate_Record;
        ArrayClear(modifiers);
        update.StatModifiers(modifiers);
        size = ArraySize(modifiers);
        if size == 0 { line = line + s"\(TDBID.ToStringDEBUG(update.GetID())) (no modifier)\n\n"; }
        else         { line = line + s"\(TDBID.ToStringDEBUG(update.GetID())):\n"; }
        
        for modifier in modifiers {
            line = line + s"[\(NameToString(modifier.GetClassName()))]\n";
            line = line + s"modifier type: \(NameToString(modifier.ModifierType()))\n";
            line = line + s"stat type: \(ToString(modifier.StatType().StatType()))\n";
            if modifier.IsExactlyA(n"gamedataConstantStatModifier_Record") {
                constant = modifier as ConstantStatModifier_Record;
                line = line + s"value: \(ToString(constant.Value()))\n";
            }
            if modifier.IsExactlyA(n"gamedataCombinedStatModifier_Record") {
                combined = modifier as CombinedStatModifier_Record;
                line = line + s"ref stat: \(ToString(combined.RefStat().StatType()))\n";
                line = line + s"ref object: \(NameToString(combined.RefObject()))\n";
                line = line + s"op symbol: \(NameToString(combined.OpSymbol()))\n";
                line = line + s"value: \(ToString(combined.Value()))\n";
            }
            if modifier.IsExactlyA(n"gamedataSubStatModifier_Record") {
                substat = modifier as SubStatModifier_Record;
                line = line + s"ref stat: \(ToString(substat.RefStat().StatType()))\n";
                line = line + s"ref object: \(NameToString(substat.RefObject()))\n";
            }
            if modifier.IsExactlyA(n"gamedataRandomStatModifier_Record") {
                random = modifier as RandomStatModifier_Record;
                line = line + s"min: \(ToString(random.Min()))\n";
                line = line + s"max: \(ToString(random.Max()))\n";
                line = line + s"use controlled random: \(ToString(random.UseControlledRandom()))\n";
            }
            if modifier.IsExactlyA(n"gamedataCurveStatModifier_Record") {
                curve = modifier as CurveStatModifier_Record;
                line = line + s"id: \(curve.Id())\n";
                line = line + s"column: \(curve.Column())\n";
                line = line + s"ref stat: \(ToString(curve.RefStat().StatType()))\n";
                line = line + s"ref object: \(NameToString(curve.RefObject()))\n";
            }
        }
        LogChannel(n"DEBUG", line);
        ArrayPush(lines, line);
    }
    WriteToFile(lines, "StatPoolUpdate");
}

// BUG: attempt to read inacessible 0xC
// public func DebugStatModifier() -> Void {
//     let kinds: array<CName> = [
//         n"ConstantStatModifier",
//         n"CombinedStatModifier",
//         n"SubStatModifier",
//         n"RandomStatModifier",
//         n"CurveStatModifier"];
//     let records: array<ref<TweakDBRecord>>;
//     let modifier: ref<StatModifier_Record>;
//     let constant: ref<ConstantStatModifier_Record>;
//     let combined: ref<CombinedStatModifier_Record>;
//     let substat: ref<SubStatModifier_Record>;
//     let random: ref<RandomStatModifier_Record>;
//     let curve: ref<CurveStatModifier_Record>;
//     let size: Int32;
//     let lines: array<String> = [];
//     let line: String;
//     for kind in kinds {
//         records = TweakDBInterface.GetRecords(kind);
//         size = ArraySize(records);
//         LogChannel(n"DEBUG", s"\(NameToString(kind)) has \(ToString(size)) record(s)");
//         // for record in records {
//         //     line = "";
//         //     modifier = record as StatModifier_Record;
//         //     line = line + s"\(TDBID.ToStringDEBUG(modifier.GetID())) [\(NameToString(modifier.GetClassName()))]\n";
//         //     line = line + s"modifier type: \(NameToString(modifier.ModifierType()))\n";
//         //     line = line + s"stat type: \(ToString(modifier.StatType().StatType()))\n";
//         //     if modifier.IsExactlyA(n"gamedataConstantStatModifier_Record") {
//         //         constant = modifier as ConstantStatModifier_Record;
//         //         line = line + s"value: \(ToString(constant.Value()))\n";
//         //     }
//         //     if modifier.IsExactlyA(n"gamedataCombinedStatModifier_Record") {
//         //         combined = modifier as CombinedStatModifier_Record;
//         //         line = line + s"ref stat: \(ToString(combined.RefStat().StatType()))\n";
//         //         line = line + s"ref object: \(NameToString(combined.RefObject()))\n";
//         //         line = line + s"op symbol: \(NameToString(combined.OpSymbol()))\n";
//         //         line = line + s"value: \(ToString(combined.Value()))\n";
//         //     }
//         //     if modifier.IsExactlyA(n"gamedataSubStatModifier_Record") {
//         //         substat = modifier as SubStatModifier_Record;
//         //         line = line + s"ref stat: \(ToString(substat.RefStat().StatType()))\n";
//         //         line = line + s"ref object: \(NameToString(substat.RefObject()))\n";
//         //     }
//         //     if modifier.IsExactlyA(n"gamedataRandomStatModifier_Record") {
//         //         random = modifier as RandomStatModifier_Record;
//         //         line = line + s"min: \(ToString(random.Min()))\n";
//         //         line = line + s"max: \(ToString(random.Max()))\n";
//         //         line = line + s"use controlled random: \(ToString(random.UseControlledRandom()))\n";
//         //     }
//         //     if modifier.IsExactlyA(n"gamedataCurveStatModifier_Record") {
//         //         curve = modifier as CurveStatModifier_Record;
//         //         line = line + s"id: \(curve.Id())\n";
//         //         line = line + s"column: \(curve.Column())\n";
//         //         line = line + s"ref stat: \(ToString(curve.RefStat().StatType()))\n";
//         //         line = line + s"ref object: \(NameToString(curve.RefObject()))\n";
//         //     }
//         //     ArrayPush(lines, line);
//         // }
//     }
//     WriteToFile(lines, "StatModifier");
// }
