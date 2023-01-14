abstract class HintRequest extends ScriptableSystemRequest {
  // game timestamp where to stop at
  protected let until: Float;
  protected let times: Int32 = 0;
  protected let threshold: Threshold;
  public func Sound() -> CName;
}

// hint for inhalers
public class CoughingRequest extends HintRequest {
  public func Sound() -> CName {
    if EnumInt(this.threshold) == EnumInt(Threshold.Severely) {
      return n"g_sc_v_sickness_cough_hard";
    }
    return n"g_sc_v_sickness_cough_light";
  }
}
// hint for pills
public class VomitingRequest extends HintRequest {
  public func Sound() -> CName {
    if EnumInt(this.threshold) == EnumInt(Threshold.Severely) {
      return n"g_sc_v_sickness_cough_blood";
    }
    return n"sq032_sc_04_v_pukes";
  }
}
// hint for injectors
public class AchingRequest extends HintRequest {
  public func Sound() -> CName {
    if EnumInt(this.threshold) == EnumInt(Threshold.Severely) {
      return n"ono_v_pain_long";
    }
    return n"ono_v_pain_short";
  }
}

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

enum Kind {
  Inhaler = 0,
  Injector = 1,
  Pill = 2,
}

enum Addiction {
  Invalid = -1,
  Healers = 0,
}
