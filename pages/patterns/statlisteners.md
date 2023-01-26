# Stats listeners

Detoxifier (a.k.a `ToxinCleanser`) grants:

`gamedataStatType.PoisonImmunity`
`gamedataStatType.HasPoisonImmunity`

example from the sources for `gamedataStatType.AutoReveal`:

```swift
public class AutoRevealStatListener extends ScriptStatsListener {
  public let m_owner: wref<GameObject>;
  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    let updateRequest: ref<UpdateAutoRevealStatEvent>;
    if Equals(statType, gamedataStatType.AutoReveal) && IsDefined(this.m_owner as PlayerPuppet) {
      updateRequest = new UpdateAutoRevealStatEvent();
      updateRequest.hasAutoReveal = total > 0.00;
      this.m_owner.QueueEvent(updateRequest);
    };
  }
}

public class UpdateAutoRevealStatEvent extends Event {
  public let hasAutoReveal: Bool;
}

public class PlayerPuppet extends ScriptedPuppet {
  protected cb func OnUpdateAutoRevealStatEvent(evt: ref<UpdateAutoRevealStatEvent>) -> Bool {
    // do something ...
  }
  protected final func RegisterStatListeners(self: ref<PlayerPuppet>) -> Void {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    let entityID: EntityID = this.GetEntityID();
    this.m_autoRevealListener = new AutoRevealStatListener();
    this.m_autoRevealListener.SetStatType(gamedataStatType.AutoReveal);
    this.m_autoRevealListener.m_owner = self;
    statsSystem.RegisterListener(Cast<StatsObjectID>(entityID), this.m_autoRevealListener);
  }
  protected final func UnregisterStatListeners(self: ref<PlayerPuppet>) -> Void {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    let entityID: EntityID = this.GetEntityID();
    statsSystem.UnregisterListener(Cast<StatsObjectID>(entityID), this.m_autoRevealListener);
    this.m_autoRevealListener = null;
  }
}
```

- `ScriptStatsListener`     ➡️ `BaseStats`
- `ScriptStatPoolsListener` ➡️ `BaseStatPools`
- ...
