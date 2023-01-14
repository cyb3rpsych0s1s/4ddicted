// inspired from DJ_Kovrik

enum AddictedMode {
  Normal = 0,
  Hard = 1,
}

public class AddictedConfig {
  @runtimeProperty("ModSettings.mod", "Addicted")
  @runtimeProperty("ModSettings.displayName", "Mod-Addicted-Mode")
  @runtimeProperty("ModSettings.displayValues.Normal", "Mod-Addicted-Mode-Normal")
  @runtimeProperty("ModSettings.displayValues.Hard", "Mod-Addicted-Mode-Hard")
  public let mode: AddictedMode = AddictedMode.Normal;
}

// Replace false with true to show full debug logs in CET console
public static func ShowDebugLogsAddicted() -> Bool = false
