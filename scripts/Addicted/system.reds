module Addicted

/// periodically check for addiction state
public class CheckAddictionStateRequest extends ScriptableSystemRequest {}
/// play multiple successive status effects
public class PlayMultipleAddictionEffectsRequest extends ScriptableSystemRequest {
    public let effects: array<TweakDBID>;
}
/// play onomatopea audios for some duration
public class PlayAudioForDurationRequest extends ScriptableSystemRequest {
    /// game timestamp
    public let until: Float;
}

public class PlayerAddictionSystem extends ScriptableSystem {
    private persistent let m_addictions: ref<Addictions>;
    private persistent let m_lastRestTimestamp: Float;
    public persistent let m_startRestingAtTimestamp: Float;
    public let m_checkDelayID: DelayID;
    public let m_playDelayID: DelayID;
    public let m_audioDelayID: DelayID;

    private func OnAttach() -> Void {
        // super.OnAttach();
        if !IsDefined(this.m_addictions) {
            LogChannel(n"DEBUG", "RED:OnAttach" + " creating addictions for the first time");
            this.m_addictions = new Addictions();
        }
        this.Reschedule(6);
    }

    // cancel previous scheduled check if exist, then reschedule check request
    // delay in seconds
    private func Reschedule(delay: Float) -> Void {
        let system = GameInstance.GetDelaySystem(this.GetGameInstance());
        if this.m_checkDelayID != GetInvalidDelayID() {
            system.CancelDelay(this.m_checkDelayID);
            this.m_checkDelayID = GetInvalidDelayID();
        }
        let request = new CheckAddictionStateRequest();
        this.m_checkDelayID = system.DelayScriptableSystemRequest(this.GetClassName(), request, delay, false);
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
            let player = GetPlayer(this.GetGameInstance());
            player.SlowStun();

            let delay = GameInstance.GetDelaySystem(this.GetGameInstance());
            let time = GameInstance.GetTimeSystem(this.GetGameInstance());
            let request = new PlayAudioForDurationRequest();
            request.until = time.GetGameTimeStamp() + this.GetRandomOnoDuration();
            this.m_audioDelayID = delay.DelayScriptableSystemRequest(this.GetClassName(), request, this.GetRandomOnoDelay(), true);
        }
        this.Reschedule(this.GetRandomSymptomDelay());
    }

    protected final func OnPlayAudioForDurationRequest(request: ref<PlayAudioForDurationRequest>) -> Void {
        let player = GetPlayer(this.GetGameInstance());
        player.Cough();
        
        let delay = GameInstance.GetDelaySystem(this.GetGameInstance());
        let time = GameInstance.GetTimeSystem(this.GetGameInstance());
        delay.CancelDelay(this.m_audioDelayID);
        let wait = this.GetRandomOnoDelay();
        let now = time.GetGameTimeStamp();
        LogChannel(n"DEBUG", "RED:OnPlayAudioForDurationRequest" + " until: " + request.until + " now: " + now + " next: " + ToString(now + wait));
        if request.until > (now + wait) {
            this.m_audioDelayID = delay.DelayScriptableSystemRequest(this.GetClassName(), request, wait, true);
        } else {
            this.m_audioDelayID = GetInvalidDelayID();
        }
    }

    /// when substance consumed, add or increase substance consumption
    public func OnAddictiveSubstanceConsumed(substanceID: TweakDBID) -> Void {
        LogChannel(n"DEBUG", "RED:OnAddictiveSubstanceConsumed");
        let system = GameInstance.GetTimeSystem(this.GetGameInstance());
        let now = system.GetGameTimeStamp();
        this.m_addictions.Consume(substanceID, now);
    }

    /// if rests long enough, addictions slightly wean off
    public func OnRested(timestamp: Float) -> Void {
        let day = (24.0 * 3600.0);
        let cycle = (8.0 * 3600.0);
        let initial = (timestamp == 0.0);
        let scarce = (timestamp >= (this.m_lastRestTimestamp + day + cycle));
        if initial || scarce {
            this.m_addictions.WeanOff();
            this.ReevaluateAllDoses();
            this.m_lastRestTimestamp = timestamp;
        }
    }

    private func GetConsumption(substanceID: TweakDBID) -> Int32 {
        return this.m_addictions.GetConsumption(substanceID);
    }

    private func GetThreshold(substanceID: TweakDBID) -> Threshold {
        return this.m_addictions.GetThreshold(substanceID);
    }

    public func GetHighestThreshold() -> Threshold {
        return this.m_addictions.GetHighestThreshold();
    }

    private func GetDoses(id: TweakDBID) -> array<Float> {
        return this.m_addictions.GetDoses(id);
    }

    private func ShouldApplyAddictionStatusEffect() -> Bool {
        let player = GetPlayer(this.GetGameInstance());
        let tier = PlayerPuppet.GetSceneTier(player); // FullGameplay / StagedGameplay only
        LogChannel(n"DEBUG","RED:ShouldApplyAddictionStatusEffect" + " " + ToString(tier));
        let addicted = true; // player.HasAnyAddiction();
        return addicted && (tier == 1 || tier == 2);
    }

    private func GetRandomSymptomDelay() -> Float {
        return RandRangeF(500, 900);
    }

    private func GetRandomOnoDelay() -> Float {
        return RandRangeF(4, 9);
    }

    private func GetRandomOnoDuration() -> Float {
        return RandRangeF(120, 400);
    }

    private func ReevaluateAllDoses() -> Void {
        for addiction in this.m_addictions.addictions {
            this.ReevaluateDoses(addiction.id);
        }
    }

    /// get rid of everything older than 1 week
    private func ReevaluateDoses(id: TweakDBID) -> Void {
        LogChannel(n"DEBUG", "RED:ReevaluateDoses");
        let doses = this.GetDoses(id);
        let count = ArraySize(doses);
        if count == 0 {
            return;
        }
        let system = GameInstance.GetTimeSystem(this.GetGameInstance());
        let now = system.GetGameTime();
        let one_week_ago = GameTime.MakeGameTime(Max(GameTime.Days(now) - 7, 0), 0);
        let current: GameTime;
        let i = 0;
        while i < count {
            current = system.RealTimeSecondsToGameTime(doses[i]);
            if GameTime.IsAfter(current, one_week_ago) {
                break;
            }
            i += 1;
        }
        if i == 0 {
            this.m_addictions.ClearDoses(id);
        }
        if i < (count - 1) {
            this.m_addictions.ResizeDoses(id, i);
        }
    }

    /// if hasn't consumed for a day or more
    public func IsWithdrawing(id: TweakDBID) -> Bool {
        let doses = this.GetDoses(id);
        let size = ArraySize(doses);
        if size == 0 {
            return false;
        }
        let system = GameInstance.GetTimeSystem(this.GetGameInstance());
        let now = system.GetGameTime();
        let today = GameTime.Days(now);
        let first = doses[0];
        let last = system.RealTimeSecondsToGameTime(first);
        let before = GameTime.Days(last);
        let yesterday = today - 1;
        let moreThan24Hours = (before == yesterday) && ((GameTime.Hours(now) + (24 - GameTime.Hours(last))) >= 24);
        let moreThan1Day = today >= (before + 2);
        if moreThan1Day || moreThan24Hours {
            return true;
        }
        return false;
    }

    /// if consumed for at least 3 days in a row lately
    public func ConsumeFrequently(id: TweakDBID) -> Bool {
        let doses = this.GetDoses(id);
        let size = ArraySize(doses);
        if size <= 3 {
            return false;
        }
        let system = GameInstance.GetTimeSystem(GetGameInstance());
        let consecutive = 0;
        let last: GameTime;
        let current: GameTime;
        let i = 0;
        for dose in doses {
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