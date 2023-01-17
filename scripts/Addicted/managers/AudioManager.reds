module Addicted.Manager

import Addicted.System.AddictedSystem

@addField(PlayerPuppet)
public let onomatopeaEventID: DelayID;

public class PlayOnomotopeaEvent extends Event {
  public let player: wref<PlayerPuppet>;
  public let sound: CName;
  public let duration: Float;
}

public class AudioManager extends IScriptable {

  private let system: wref<AddictedSystem>;
  private let playing: Bool = false;

  public final func Initialize(system: ref<AddictedSystem>) -> Void {
    this.system = system;
  }

  public func IsPlaying() -> Bool { return this.playing; }
}