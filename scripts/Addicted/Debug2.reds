// use like: Game.PrintRecordsType("ApplyStatusEffectByChanceEffector");
public static exec func PrintRecordsType(kind: String) -> Void {
    let records = TweakDBInterface.GetRecords(StringToName(kind));
    for record in records {
        LogChannel(n"DEBUG", s">>>>> \(TDBID.ToStringDEBUG(record.GetID()))");
    }
}