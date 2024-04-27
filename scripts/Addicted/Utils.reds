module Addicted.Utils

// auto-disabled when LogChannel not in scope
public static func E(msg: String) -> Void {
  if ShowDebugLogsAddicted() {
    ModLog(n"Addicted", AsRef(msg));
  }
}

// available at all time
public static func F(str: String) -> Void {
  let msg = s"ERROR: \(str)";
  ModLog(n"Addicted", AsRef(msg));
}

public static func EI(id: TweakDBID, str: String) -> Void {
  E(s"[\(TDBID.ToStringDEBUG(id))] \(str)");
}

public static func EI(id: ItemID, str: String) -> Void {
  EI(ItemID.GetTDBID(id), str);
}

public static func FI(id: TweakDBID, str: String) -> Void {
  F(s"[\(TDBID.ToStringDEBUG(id))] \(str)");
}

public static func FI(id: ItemID, str: String) -> Void {
  FI(ItemID.GetTDBID(id), str);
}
