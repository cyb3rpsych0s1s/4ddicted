@wrapMethod(TimeskipGameController)
private final func Apply() -> Void {
  if this.m_hoursToSkip > 0 {
    let container = GameInstance.GetScriptableSystemsContainer(this.GetGame());
    let system = container.Get(n"Addicted.PlayerAddictionSystem") as PlayerAddictionSystem;
    let timeSystem = GameInstance.GetTimeSystem(this.GetGame());
    system.m_startRestingAtTimestamp = timeSystem.GetGameTimeStamp();
  }
  wrappedMethod();
}