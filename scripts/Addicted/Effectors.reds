module Addicted

import Addicted.System.AddictedSystem
import Addicted.Utils.{F,E}

// prevents deadlock on System.CalculateConsumptionModifier (GLPS.GetAppliedPackages)
public class ContraindicationCallback extends DelayCallback {
    public let system: wref<AddictedSystem>;
    public func Call() -> Void {
        this.system.OnContraindication(ItemID.FromTDBID(t"Items.ripperdoc_med_contraindication"));
    }
}

public class IncreaseNeuroBlockerEffector extends Effector {
    protected func ActionOn(owner: ref<GameObject>) -> Void {
        let system = AddictedSystem.GetInstance(owner.GetGame());
        let scheduler = GameInstance.GetDelaySystem(owner.GetGame());
        // use a fake ID to differentiate, see:
        // - Generic.IsNeuroBlocker
        // - Generic.IsContraindicated
        // - Consumptions.Items
        // - NeuroBlockerTweaks
        let callback: ref<ContraindicationCallback> = new ContraindicationCallback();
        callback.system = system;
        scheduler.DelayCallbackNextFrame(callback);
    }
}

public class CruciateEffector extends TriggerContinuousAttackEffector {
    public let isForceOpening: Bool;
    public let wasForceOpening: Bool;
    public let applied: Bool;
    private let callback: ref<CallbackHandle>;
    protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
        super.Initialize(record, game, parentRecord);
        let v = this.GetOwner() as PlayerPuppet;
        if !IsDefined(v) { F("player is undefined"); }
        let board = GameInstance.GetBlackboardSystem(v.GetGame()).GetLocalInstanced(v.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
        this.callback = board.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsForceOpeningDoor, this, n"OnForceOpeningChange", true);
    }
    protected func Uninitialize(game: GameInstance) -> Void {
        if IsDefined(this.callback) {
            let v = this.GetOwner() as PlayerPuppet;
            let board = GameInstance.GetBlackboardSystem(v.GetGame()).GetLocalInstanced(v.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
            board.UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsForceOpeningDoor, this.callback);
            this.callback = null;
        }
    }
    protected func ContinuousAction(owner: ref<GameObject>, instigator: ref<GameObject>) -> Void {
        if this.isForceOpening {
            super.ContinuousAction(owner, instigator);
        } else if this.wasForceOpening {
            this.m_attack.StopAttack();
            this.m_attack = null;
            this.wasForceOpening = false;
        }
    }
    protected cb func OnForceOpeningChange(value: Bool) -> Bool {
        if NotEquals(this.isForceOpening, value) {
            if !value {
                this.wasForceOpening = true;
            }
            this.isForceOpening = value;
        }
    }
}
