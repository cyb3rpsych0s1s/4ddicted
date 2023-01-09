module Addicted

/// addictions threshold
enum Threshold {
    Clean = 0,
    Barely = 10,
    Mildly = 20,
    Notably = 40,
    Severely = 60,
}

/// consumable addictive potency
enum Potency {
  Mild = 1,
  Hard = 2,
}

/// audios onomatopea
enum Onomatopea {
    Cough = 0,
    Pain = 1,
    Fear = 2,
}

/// keep track of consumption for a given consumable
public class Addiction {
    public persistent let id: TweakDBID;
    public persistent let consumption: Int32;
    
    /// get threshold from consumption
    public func GetThreshold() -> Threshold {
        if this.consumption > EnumInt(Threshold.Severely) {
            return Threshold.Severely;
        }
        if this.consumption > EnumInt(Threshold.Notably) {
            return Threshold.Notably;
        }
        if this.consumption > EnumInt(Threshold.Mildly) {
            return Threshold.Mildly;
        }
        if this.consumption == EnumInt(Threshold.Clean) {
            return Threshold.Clean;
        }
        return Threshold.Barely;
    }

    /// addiction potency
    public func Potency() -> Int32 {
        return EnumInt(GetPotency(this.id));
    }

    /// addiction multiplier:
    /// becomes stronger when reaching higher threshold
    public func Multiplier() -> Int32 {
        let threshold = this.GetThreshold();
        switch (threshold) {
            case Threshold.Severely:
            case Threshold.Notably:
                return 2;
            default:
                break;
        }
        return 1;
    }
}

/// keep track of respective consumptions for all consumables
public class Addictions {
  public persistent let addictions: array<ref<Addiction>>;

  /// get given substance consumption
  public func GetConsumption(id: TweakDBID) -> Int32 {
      for addiction in this.addictions {
          if addiction.id == id {
              return addiction.consumption;
          }
      }
      return -1;
  }

  /// get given substance addiction threshold reached
  public func GetThreshold(id: TweakDBID) -> Threshold {
      for addiction in this.addictions {
          if addiction.id == id {
              return addiction.GetThreshold();
          }
      }
      return Threshold.Clean;
  }

  /// get highest substance addiction threshold reached, no matter the substance
  public func GetHighestThreshold() -> Threshold {
      let highest = Threshold.Clean;
      let current: Threshold;
      for addiction in this.addictions {
          current = addiction.GetThreshold();
          if EnumInt(highest) > EnumInt(current) {
              highest = current;
          }
      }
      return highest;
  }

  /// keep track whenever an addictive substance is consumed
  public func Consume(id: TweakDBID) -> Void {
      for addiction in this.addictions {
          if addiction.id == id {
              addiction.consumption = Min(addiction.consumption + (addiction.Potency() * addiction.Multiplier()), 2 * EnumInt(Threshold.Severely));
              return; // if found
          }
      }
      // if not found
      let addiction = new Addiction();
      addiction.id = id;
      addiction.consumption = EnumInt(GetPotency(id));
      ArrayPush(this.addictions, addiction);
  }

  /// keep track whenever addictive substance(s) addiction weans off
  public func WeanOff() -> Void {
      for addiction in this.addictions {
          if addiction.consumption > 0 {
              addiction.consumption -= 1;
          } else {
              ArrayRemove(this.addictions, addiction);
          }
      }
  }
}
