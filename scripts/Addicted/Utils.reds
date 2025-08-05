module Addicted.Utils

public func E(msg: String) -> Void {
  if ShowDebugLogsAddicted() {
    ModLog(n"Addicted", AsRef(msg));
  }
}

// available at all time
public func F(str: String) -> Void {
  let msg = s"ERROR: \(str)";
  ModLog(n"Addicted", AsRef(msg));
}

public func EI(id: TweakDBID, str: String) -> Void {
  E(s"[\(TDBID.ToStringDEBUG(id))] \(str)");
}

public func EI(id: ItemID, str: String) -> Void {
  EI(ItemID.GetTDBID(id), str);
}

public func FI(id: TweakDBID, str: String) -> Void {
  F(s"[\(TDBID.ToStringDEBUG(id))] \(str)");
}

public func FI(id: ItemID, str: String) -> Void {
  FI(ItemID.GetTDBID(id), str);
}
