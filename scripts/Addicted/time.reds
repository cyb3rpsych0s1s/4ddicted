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
  public persistent let doses: array<Float>;

  /// record timestamp on each consumption
  public func Consume() -> Void {
      let system = GameInstance.GetTimeSystem(GetGameInstance());
      ArrayPush(this.doses, system.GetGameTimeStamp());
  }

  /// get rid of everything older than 1 week
  public func WeanOff() -> Void {
    let system = GameInstance.GetTimeSystem(GetGameInstance());
    let now = system.GetGameTime();
    let one_week_ago = GameTime.MakeGameTime(Min(GameTime.Days(now) - 7, 0), 0);
    let count = ArraySize(this.doses);
    if count == 0 {
        return;
    }
    let i = 0;
    let current: GameTime;
    while i < count {
        current = system.RealTimeSecondsToGameTime(this.doses[i]);
        if GameTime.IsAfter(current, one_week_ago) {
            break;
        }
        i += 1;
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
    let system = GameInstance.GetTimeSystem(GetGameInstance());
    let count = ArraySize(this.doses);
    if count == 0 {
        return false;
    }
    let now = system.GetGameTime();
    let today = GameTime.Days(now);
    let first = this.doses[0];
    let last = GameTime.Days(system.RealTimeSecondsToGameTime(first));
    if today > last {
        return true;
    }
    return false;
  }

  /// if consumed for at least 3 days in a row lately
  public func ConsumeFrequently() -> Bool {
    let size = ArraySize(this.doses);
    if size <= 3 {
        return false;
    }
    let system = GameInstance.GetTimeSystem(GetGameInstance());
    let consecutive = 0;
    let last: GameTime;
    let current: GameTime;
    let i = 0;
    for dose in this.doses {
    if i > 0 {
        last = current;
    }
    current = system.RealTimeSecondsToGameTime(dose);
    if i > 0 {
        if GameTime.Days(current) == (GameTime.Days(last) + 1) {
            consecutive += 1;
        } else {
            if GameTime.Days(current) > (GameTime.Days(last) + 1) {
                consecutive = 0;
            }
        }
        if consecutive >= 3 {
            return true;
        }
    }
    }
    return false;
  }
}
