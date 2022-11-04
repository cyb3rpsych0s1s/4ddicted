module Addicted

public class Consumption {
    let name: CName;
    let id: TweakDBID;

    public static func New() -> ref<Consumption> {
        let consumption = new Consumption();
        return consumption;
    }
}

public class Consumptions {
  let elements: array<Consumption>;
  
  public static func New() -> ref<Consumptions> {
    let consumptions = new Consumptions();
    return consumptions;
  }
}

@addField(PlayerPuppet)
let consumptions: ref<Consumptions>;

@addMethod(StatusEffectEvent)
public func IsAddictive() -> Bool {
    return ArrayContains(
        [
            t"BaseStatusEffect.FirstAidWhiffV0",
            t"BaseStatusEffect.BonesMcCoy70V0"
            // TODO: add missing
        ],
        this.staticData.GetID());
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    // LogChannel(n"DEBUG", s"RED:Addicted:OnStatusEffectApplied \(TDBID.ToStringDEBUG(evt.staticData.GetID()))");
    if evt.isNewApplication && evt.IsAddictive() {
        // this.consumed += 1;
        // LogChannel(n"DEBUG","RED:Addicted once again: " + this.consumed);
    }
    return wrappedMethod(evt);
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    // LogChannel(n"DEBUG", s"RED:Addicted:OnStatusEffectRemoved \(TDBID.ToStringDEBUG(evt.staticData.GetID()))");
    if evt.IsAddictive() {
        LogChannel(n"DEBUG","RED:Addicted:OnStatusEffectRemoved (IsAddictive)");
    }
  return wrappedMethod(evt);
}