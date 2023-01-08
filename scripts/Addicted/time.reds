module Addicted

@wrapMethod(TimeskipGameController)
private final func Apply() -> Void {
  if this.m_hoursToSkip > 0 {
    let container = GameInstance.GetScriptableSystemsContainer(this.m_gameInstance);
    let system = container.Get(n"Addicted.PlayerAddictionSystem") as PlayerAddictionSystem;
    system.m_startRestingAtTimestamp = this.m_timeSystem.GetGameTimeStamp();
  }
  wrappedMethod();
}
