public class WithdrawalSymptomController extends IScriptable {
    private let m_owner: wref<GameObject>;

    public final func RegisterOwner(owner: ref<GameObject>) -> Void {
    if this.m_owner != null {
      LogError("WithdrawalSymptomController.RegisterOwner is stomping on a previously registered owner.");
      // unregister stuff
    };
    this.m_owner = owner;
    if owner != null {
      // initialize/register stuff
    };
  }

  public final func UnregisterOwner() -> Void {
    if this.m_owner == null {
      LogError("WithdrawalSymptomController.UnregisterOwner has nothing to unregister.");
    } else {
      // unregister stuff
    };
    this.m_owner = null;
  }

  public func OnWithdrawalSymptomExperienced() -> Void {}
}