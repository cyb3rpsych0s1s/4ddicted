// use like: Game.PrintRecordsType("ApplyStatusEffectByChanceEffector");
public static exec func PrintRecordsType(kind: String) -> Void {
    let records = TweakDBInterface.GetRecords(StringToName(kind));
    for record in records {
        LogChannel(n"DEBUG", s">>>>> \(TDBID.ToStringDEBUG(record.GetID()))");
    }
}

// use like: Game.DebugStatusEffectVFX("status_blinded")
public static exec func DebugStatusEffectVFX(game: GameInstance, name: String) -> Void {
    let player = GetPlayer(game);
    let i: Int32;
    let vfxList = TweakDBInterface.GetRecords(n"StatusEffectFX");
    let vfx: wref<StatusEffectFX_Record>;
    i = 0;
    while i < ArraySize(vfxList) {
        vfx = vfxList[i] as StatusEffectFX_Record;
        GameObjectEffectHelper.BreakEffectLoopEvent(player, vfx.Name());
        i += 1;
    };
    GameObjectEffectHelper.StartEffectEvent(player, StringToName(name));
}