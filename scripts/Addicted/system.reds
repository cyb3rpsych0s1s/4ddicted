module Addicted

/// addictions threshold
enum Threshold {
    Clean = 0,
    Barely = 10,
    Mildly = 20,
    Notably = 40,
    Severely = 60,
}

/// keep track of consumption for a given consumable
public class Addiction {
    public persistent let id: TweakDBID;
    public persistent let consumption: Int32;
}

/// periodically check for addiction state
public class CheckAddictionStateRequest extends ScriptableSystemRequest {}
/// play multiple successive status effects
public class PlayMultipleAddictionEffectsRequest extends ScriptableSystemRequest {
    public let effects: array<TweakDBID>;
}

public class PlayerAddictionSystem extends ScriptableSystem {
    private persistent let m_addictions: array<ref<Addiction>>;
    private persistent let m_lastRestTimestamp: Float;
    public persistent let m_startRestingAtTimestamp: Float;
    public let m_checkDelayID: DelayID;
    public let m_playDelayID: DelayID;

    private func OnAttach() -> Void {
        super.OnAttach();
        this.Reschedule();
    }

    // cancel previous scheduled check if exist, then reschedule check request
    private func Reschedule() -> Void {
        let system = GameInstance.GetDelaySystem(this.GetGameInstance());
        if this.m_checkDelayID != GetInvalidDelayID() {
            system.CancelDelay(this.m_checkDelayID);
            this.m_checkDelayID = GetInvalidDelayID();
        }
        let request = new CheckAddictionStateRequest();
        this.m_checkDelayID = system.DelayScriptableSystemRequest(this.GetClassName(), request, 10, false);
    }

    // skip if already planned, otherwise plan to play multiple status effects consecutively
    public func Plan(effects: array<TweakDBID>) -> Void {
        if this.m_playDelayID != GetInvalidDelayID() {
            return;
        }
        let system = GameInstance.GetDelaySystem(this.GetGameInstance());
        let request = new PlayMultipleAddictionEffectsRequest();
        request.effects = effects;
        this.m_playDelayID = system.DelayScriptableSystemRequest(this.GetClassName(), request, 0.5, true);
    }

    protected final func OnPlayMultipleAddictionEffectsRequest(request: ref<PlayMultipleAddictionEffectsRequest>) -> Void {
        let system = GameInstance.GetDelaySystem(this.GetGameInstance());
        system.CancelDelay(this.m_playDelayID);
        if ArraySize(request.effects) > 0 {
            let next = ArrayPop(request.effects);
            StatusEffectHelper.ApplyStatusEffect(GetPlayer(this.GetGameInstance()), next);
            this.m_playDelayID = system.DelayScriptableSystemRequest(this.GetClassName(), request, 3, true);
        }
    }

    protected final func OnCheckAdditionStateRequest(request: ref<CheckAddictionStateRequest>) -> Void {
        if this.ShouldApplyAddictionStatusEffect() {
            // ok, this works
            GetPlayer(this.GetGameInstance()).SlowStun();
        }
        this.Reschedule();
    }

    /// when substance consumed, add or increase substance consumption
    public func OnAddictiveSubstanceConsumed(substanceID: TweakDBID) -> Void {
        for addiction in this.m_addictions {
            if addiction.id == substanceID {
                addiction.consumption = Min(addiction.consumption + (this.AddictionPotency(substanceID) * this.AddictionMultiplier(substanceID)), 2 * EnumInt(Threshold.Severely));
                return; // if found
            }
        }
        // if not found
        let addiction = new Addiction();
        addiction.id = substanceID;
        addiction.consumption = this.AddictionPotency(substanceID);
        ArrayPush(this.m_addictions, addiction);
    }

    /// when substance wean off, remove or decrease substance consumption
    public func OnAddictiveSubstanceWeanOff() -> Void {
        for addiction in this.m_addictions {
            if addiction.consumption > 0 {
                addiction.consumption -= 1;
            } else {
                ArrayRemove(this.m_addictions, addiction);
            }
        }
    }

    /// if rests long enough, addictions slightly wean off
    public func OnRested(timestamp: Float) -> Void {
        let day = (24.0 * 3600.0);
        let cycle = (8.0 * 3600.0);
        let initial = (timestamp == 0.0);
        let scarce = (timestamp >= (this.m_lastRestTimestamp + day + cycle));
        if initial || scarce {
            this.OnAddictiveSubstanceWeanOff();
            this.m_lastRestTimestamp = timestamp;
        }
    }

    /// get current substance consumption
    private func GetConsumption(substanceID: TweakDBID) -> Int32 {
        for addiction in this.m_addictions {
            if addiction.id == substanceID {
                return addiction.consumption;
            }
        }
        return -1;
    }

    /// get current substance addiction threshold reached
    private func GetThreshold(substanceID: TweakDBID) -> Threshold {
        for addiction in this.m_addictions {
            if addiction.id == substanceID {
                if addiction.consumption > EnumInt(Threshold.Severely) {
                    return Threshold.Severely;
                }
                if addiction.consumption > EnumInt(Threshold.Notably) && addiction.consumption <= EnumInt(Threshold.Severely) {
                    return Threshold.Notably;
                }
                if addiction.consumption > EnumInt(Threshold.Mildly) && addiction.consumption <= EnumInt(Threshold.Notably) {
                    return Threshold.Notably;
                }
                if addiction.consumption > EnumInt(Threshold.Barely) && addiction.consumption <= EnumInt(Threshold.Mildly) {
                    return Threshold.Mildly;
                }
                if addiction.consumption > EnumInt(Threshold.Clean) {
                    return Threshold.Barely;
                }
                return Threshold.Clean;
            }
        }
        return Threshold.Clean;
    }

    /// addiction becomes stronger when reaching higher threshold
    public func AddictionMultiplier(substanceID: TweakDBID) -> Int32 {
        let threshold = this.GetThreshold(substanceID);
        switch (threshold) {
            case Threshold.Severely:
            case Threshold.Notably:
                return 2;
            default:
                return 1;
        }
        return 1;
    }

    private func AddictionPotency(substanceID: TweakDBID) -> Int32 {
        switch(substanceID) {
            case t"BaseStatusEffect.FirstAidWhiffV0":
                return 1;
            case t"BaseStatusEffect.BonesMcCoy70V0":
                return 2;
            case t"BaseStatusEffect.FR3SH":
                return 2;
            // TODO: add missing
            default:
                return 1;
        }
    }

    private func ShouldApplyAddictionStatusEffect() -> Bool {
        let player = GetPlayer(this.GetGameInstance());
        let tier = PlayerPuppet.GetSceneTier(player); // FullGameplay only
        let addicted = player.HasAnyAddiction();
        return addicted && tier == 1;
    }
}