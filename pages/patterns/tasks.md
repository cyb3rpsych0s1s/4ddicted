# Tasks

Tasks can be used in conjunction with `DelaySystem` and allows for more granular control on when it gets processed (see [gameScriptTaskExecutionStage](https://jac3km4.github.io/cyberdoc/#2360)).

```swift
public class EnableTaskData extends ScriptTaskData {
  public let enabled: Bool;
}

public class System extends ScriptableSystem {
  protected final func Enable(enabled: Bool) -> Void {
    let data: ref<EnableTaskData> = new EnableTaskData();
    data.enabled = enabled;
    GameInstance.GetDelaySystem(this.GetGameInstance()).QueueTask(this, data, n"OnEnable", gameScriptTaskExecutionStage.Any);
  }
  // function signature matters!
  protected final func OnEnable(data: ref<ScriptTaskData>) -> Void {
    let task: ref<EnableTaskData> = data as EnableTaskData;
    if !IsDefined(task) {
      return;
    };
    // do something ..
  }
}
```
