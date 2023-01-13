// inspired from DJ_Kovrik

public class AddictedConfig {
  @runtimeProperty("ModSettings.mod", "Addicted")
  @runtimeProperty("ModSettings.category", "Mod-Addicted-Thresholds")
  @runtimeProperty("ModSettings.displayName", "Mod-Addicted-Threshold-Barely")
  @runtimeProperty("ModSettings.description", "Mod-Addicted-Threshold-Barely-Desc")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "40")
  let baseThresholdBarely: Int32 = 10;

  @runtimeProperty("ModSettings.mod", "Addicted")
  @runtimeProperty("ModSettings.category", "Mod-Addicted-Thresholds")
  @runtimeProperty("ModSettings.displayName", "Mod-Addicted-Threshold-Mildly")
  @runtimeProperty("ModSettings.description", "Mod-Addicted-Threshold-Mildly-Desc")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "20")
  @runtimeProperty("ModSettings.max", "60")
  let baseThresholdMildly: Int32 = 20;
}

// Replace false with true to show full debug logs in CET console
public static func ShowDebugLogsAddicted() -> Bool = true
