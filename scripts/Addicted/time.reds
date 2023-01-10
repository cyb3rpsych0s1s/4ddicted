module Addicted

/// track time whenever player rests for hour(s)
@wrapMethod(TimeskipGameController)
private final func Apply() -> Void {
  if this.m_hoursToSkip > 0 {
    let container = GameInstance.GetScriptableSystemsContainer(this.m_gameInstance);
    let system = container.Get(n"Addicted.PlayerAddictionSystem") as PlayerAddictionSystem;
    system.m_startRestingAtTimestamp = this.m_timeSystem.GetGameTimeStamp();
  }
  wrappedMethod();
}

public class Doses {
  private let doses: array<Float>;

  /// record timestamp on each consumption
  public func Consume() -> Void {
      let game = Game.GetPlayer().GetGame();
      let system = GameInstance.GetTimeSystem(game);
      ArrayPush(this.doses, system.GetGameTimeStamp());
  }

  /// get rid of everything older than 1 week
  public func WeanOff() -> Void {
      let game = Game.GetPlayer().GetGame();
      let system = GameInstance.GetTimeSystem(game);
      let now = system.GetGameTime();
      let one_week_ago = GameTime.MakeGameTime(Min(now.Days() - 7, 0), 0);
      let count = ArrayCount(this.doses);
      if count == 0 {
        return;
      }
      let i = 0;
      let current: GameTime;
      while i < count {
          current = system.RealTimeSecondsToGameTime(this.doses[i])
          if current.isAfter(one_week_ago) {
              break;
          }
          i++;
      }
      if i == 0 {
          ArrayClear(this.doses);
      }
      if i < (count - 1) {
          ArrayResize(this.doses, i);
      }
  }

  /// if hasn't consumed for a day or more
  public func IsWithdrawing() -> Bool {
      let game = Game.GetPlayer().GetGame();
      let system = GameInstance.GetTimeSystem(game);
      let count = ArrayCount(this.doses);
      if count == 0 {
          return false;
      }
      let now = system.GetGameTime();
      let today = now.Days();
      let first = this.doses[0];
      let last = system.RealTimeSecondsToGameTime(first);
      if today > last {
          return true;
      }
      return false;
  }

  /// if consumed for at least 3 days in a row lately
  public func ConsumeFrequently() -> Bool {
      let game = Game.GetPlayer().GetGame();
      let system = GameInstance.GetTimeSystem(game);
      let consecutive = 0;
      let last: GameTime;
      let current: GameTime;
      let days = [];
      for dose in this.doses {
          current = system.RealTimeSecondsToGameTime(dose);
          if !IsDefined(last) {
              last = current;
              continue;
          }
          if current.Days() == (last.Days() + 1) {
              consecutive += 1;
          } else if current.Days() > (last.Days() + 1) {
              consecutive = 0;
          }
          if consecutive >= 3 {
            return true;
          }
          last = current;
      }
      return false;
  }
}
