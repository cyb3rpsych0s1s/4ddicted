// inspired from DJ_Kovrik

public class AddictedConfig {
  @runtimeProperty("ModSettings.mod", "Addicted")
  @runtimeProperty("ModSettings.category", "Mod-Addicted-Addiction")
  @runtimeProperty("ModSettings.displayName", "Mod-Addicted-Addiction-Healer")
  @runtimeProperty("ModSettings.description", "Mod-Addicted-Addiction-Healer-Desc")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "200")
  let baseAddictionHealer: Int32 = 0;
}

// Replace false with true to show full debug logs in CET console
public static func ShowDebugLogsAddicted() -> Bool = false
