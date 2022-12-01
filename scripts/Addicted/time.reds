module Addicted

@wrapMethod(TimeskipGameController)
private final func Apply() -> Void {
  if this.m_hoursToSkip > 0 {
    LogChannel(n"DEBUG", s"RED:TimeskipGameController:Apply: \(this.m_hoursToSkip) hour(s) to skip");
    let container = GameInstance.GetScriptableSystemsContainer(this.m_gameInstance);
    let system = container.Get(n"Addicted.PlayerAddictionSystem") as PlayerAddictionSystem;
    system.m_startRestingAtTimestamp = this.m_timeSystem.GetGameTimeStamp();
  } else {
    LogChannel(n"DEBUG", s"RED:TimeskipGameController:Apply: less than one hour to skip");
  }
  wrappedMethod();
}