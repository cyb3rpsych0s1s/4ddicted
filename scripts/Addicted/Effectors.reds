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
    public let bloodied: Bool;
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
            GameInstance.GetEffectorSystem(owner.GetGame()).ApplyEffector(owner.GetEntityID(), GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerControlledGameObject(), t"Effectors.BloodyRightHandVFX");
            GameInstance.GetEffectorSystem(owner.GetGame()).ApplyEffector(owner.GetEntityID(), GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerControlledGameObject(), t"Effectors.BloodyLeftHandVFX");
            if !this.bloodied {
                GameInstance.GetEffectorSystem(owner.GetGame()).ApplyEffector(owner.GetEntityID(), GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerControlledGameObject(), t"Effectors.BloodOnScreenVFX");
                this.bloodied = true;
            }
        } else if this.wasForceOpening {
            this.m_attack.StopAttack();
            this.m_attack = null;
            this.wasForceOpening = false;
            if this.bloodied {
                GameInstance.GetEffectorSystem(owner.GetGame()).RemoveEffector(owner.GetEntityID(), t"Effectors.BloodOnScreenVFX");
                this.bloodied = false;
            }
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

public class PainfulLandingEffector extends TriggerAttackOnOwnerEffect {
    private let callback: ref<CallbackHandle>;
    protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
        super.Initialize(record, game, parentRecord);
        let v = this.GetOwner() as PlayerPuppet;
        if !IsDefined(v) { F("player is undefined"); }
        let board = GameInstance.GetBlackboardSystem(v.GetGame()).GetLocalInstanced(v.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
        this.callback = board.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Landing, this, n"OnLandingChange", true);
    }
    protected func Uninitialize(game: GameInstance) -> Void {
        if IsDefined(this.callback) {
            let v = this.GetOwner() as PlayerPuppet;
            let board = GameInstance.GetBlackboardSystem(v.GetGame()).GetLocalInstanced(v.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
            board.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Landing, this.callback);
            this.callback = null;
        }
    }
    protected func ActionOn(owner: ref<GameObject>) -> Void {
        this.m_owner = owner;
        let board = GameInstance.GetBlackboardSystem(owner.GetGame()).GetLocalInstanced(owner.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
        let value = board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Landing);
        this.OnLandingChange(value);
    }
    protected cb func OnLandingChange(value: Int32) -> Bool {
        if Equals(value, EnumInt(LandingType.Hard)) || Equals(value, EnumInt(LandingType.VeryHard)) || Equals(value, EnumInt(LandingType.Superhero)) {
            this.RepeatedAction(this.m_owner);
        }
    }
}
