module Addicted

/// addictions threshold
enum Threshold {
    Clean = 0,
    Barely = 10,
    Mildly = 20,
    Notably = 40,
    Severely = 60,
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
}
