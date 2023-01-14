// inspired from DJ_Kovrik

module Addicted.Utils

public static func E(str: String) -> Void {
  if ShowDebugLogsAddicted() {
    LogChannel(n"DEBUG", s"Addicted: \(str)");
  };
}

public static func F(str: String) -> Void {
  LogError(s"Addicted: \(str)");
}
