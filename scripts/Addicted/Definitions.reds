abstract class PlayUntilRequest extends ScriptableSystemRequest {
  // game timestamp where to stop at
  protected let until: Float;
  protected let times: Int32 = 0;
  protected let threshold: Threshold;
}

// hint for inhalers
public class CoughingRequest extends PlayUntilRequest {}
// hint for pills
public class VomitingRequest extends PlayUntilRequest {}
// hint for injectors
public class AchingRequest extends PlayUntilRequest {}

public class Consumption {
  public persistent let current: Int32;
  public persistent let doses: array<Float>;
}

enum Category {
  Mild = 0,
  Hard = 1,
}

enum Threshold {
  Clean = 0,
  Barely = 10,
  Mildly = 20,
  Notably = 40,
  Severely = 60,
}

enum Consumable {
  Invalid = -1,
  Alcohol = 0,
  MaxDOC = 1, // BonesMcCoy
  BounceBack = 2, // FirstAidWhiff
  HealthBooster = 3,
  MemoryBooster = 4,
  OxyBooster = 5,
  StaminaBooster = 6,
  BlackLace = 7,
}

enum Addiction {
  Invalid = -1,
  Healers = 0,
}
