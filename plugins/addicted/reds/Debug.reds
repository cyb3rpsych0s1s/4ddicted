import Addicted.System
import Addicted.Consumable
import Addicted.Threshold
import Addicted.Consumption

native func WriteToFile(lines: array<String>, filename: String) -> Void;

public func DebugHealthBoosterAddiction(gi: GameInstance) -> Void {
    let system = System.GetInstance(gi);
    let effect = TDBID.ToStringDEBUG(system.GetAddictStatusEffectID(Consumable.HealthBooster));
    ApplyEffectOnPlayer(gi, effect);
    PrintEffectsOnPlayer(gi);
    AddToInventory(gi, "Items.HealthBooster");
    ItemActionsHelper_ConsumeItem(GetPlayer(gi), ItemID.FromTDBID(t"Items.HealthBooster"), true);
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

public static exec func ApplyVFXOn(gi: GameInstance, name: String) -> Void {
    let player: ref<PlayerPuppet>;
    player = GetPlayer(gi);
    GameObjectEffectHelper.StartEffectEvent(player, StringToName(name));
}

public static exec func RemoveVFXOn(gi: GameInstance, name: String) -> Void {
    let player: ref<PlayerPuppet>;
    player = GetPlayer(gi);
    GameObjectEffectHelper.StopEffectEvent(player, StringToName(name));
}

public static exec func PlaySFXOn(gi: GameInstance, name: String) -> Void {
    let player: ref<PlayerPuppet>;
    player = GetPlayer(gi);
    GameObject.PlaySound(player, StringToName(name));
}

public static exec func StopSFXOn(gi: GameInstance, name: String) -> Void {
    let player: ref<PlayerPuppet>;
    player = GetPlayer(gi);
    GameObject.StopSound(player, StringToName(name));
}

public static exec func SearchItem(gi: GameInstance, id: String) -> Void {
  let i: Int32;
  let itemID: ItemID;
  let itemList: array<wref<gameItemData>>;
  let quantity: Int32;
  let str: String;
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let trans: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gi);
  let found: Bool = false;
  trans.GetItemList(player, itemList);
  i = 0;
  LogItems(s"searching for \(id) in inventory...");
  while i < ArraySize(itemList) {
    itemID = itemList[i].GetID();
    if Equals(ItemID.FromTDBID(TDBID.Create(id)), itemID) {
        quantity = trans.GetItemQuantity(player, itemID);
        str = SpaceFill(IntToString(quantity), 6, ESpaceFillMode.JustifyRight) + "x " + TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID));
        LogItems(str);
        found = true;
        break;
    }
    i += 1;
  };
  if !found { LogItems(s"couldn't find \(id) in inventory"); }
}

// Game.SetConsumptions("Items.BonesMcCoy70V0", 40, {});
public static exec func SetConsumptions(gi: GameInstance, id: String, score: Int32, doses: array<Float>) -> Void {
    let system = System.GetInstance(gi);
    let key = TDBID.Create(id);
    let position = system.Position(key);
    let s: Int32 = score;
    if s > 100 { s = 100; }
    if s < 0   { s = 0;   }
    if position != -1 {
        let printDoses = "[";
        let idx = 0;
        for dose in system.values[position].doses {
            if idx > 0 { printDoses = printDoses + ToString(dose); }
            else       { printDoses = printDoses + ToString(dose) + ","; }
            idx += 1;
        }
        printDoses = printDoses + "]";
        let printCurrent = ToString(system.values[position].current);
        LogChannel(n"DEBUG", s"\(id) = { current: \(printCurrent), doses: \(printDoses) }");
        system.values[position].current = s;
        system.values[position].doses = doses;
    } else {
        LogChannel(n"DEBUG", s"\(id) = { current: 0, doses: [] }");
        let value = new Consumption();
        value.current = s;
        value.doses = doses;
        ArrayPush(system.keys, key);
        ArrayPush(system.values, value);
    }
}

// Game.ResetConsumptions();
public static exec func ResetConsumptions(gi: GameInstance) -> Void {
    let system = System.GetInstance(gi);
    system.keys = [];
    system.values = [];
}

// Game.Checkup();
public static exec func Checkup(gi: GameInstance) -> Void {
    let system = System.GetInstance(gi);
    let idx = 0;
    let line: String;
    let msg: String = "";
    for key in system.keys {
        line = TDBID.ToStringDEBUG(key);
        line = line + "\n" + "   current: " + ToString(system.values[idx].current);
        line = line + "\n" + "   doses:";
        for dose in system.values[idx].doses {
            line = line + "\n" + "       " + ToString(dose);
        }
        msg = msg + "\n" + line;
    }
    LogChannel(n"DEBUG", msg);
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
