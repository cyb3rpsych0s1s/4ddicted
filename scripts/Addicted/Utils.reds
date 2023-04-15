// inspired from DJ_Kovrik

module Addicted.Utils

@if(!ModuleExists("Addicted.Debug"))
public static func E(str: String) -> Void;
@if(ModuleExists("Addicted.Debug"))
public static func E(str: String) -> Void {
  if ShowDebugLogsAddicted() {
    LogChannel(n"DEBUG", s"[Addicted] \(str)");
  };
}

public static func F(str: String) -> Void {
  LogError(s"[ERROR] [Addicted] \(str)");
}

@if(!ModuleExists("Addicted.Debug"))
public static func EI(id: TweakDBID, str: String) -> Void;
@if(ModuleExists("Addicted.Debug"))
public static func EI(id: TweakDBID, str: String) -> Void {
  E(s"[\(TDBID.ToStringDEBUG(id))] \(str)");
}

public static func FI(id: TweakDBID, str: String) -> Void {
  F(s"[\(TDBID.ToStringDEBUG(id))] \(str)");
}
