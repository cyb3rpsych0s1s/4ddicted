module Addicted

@addField(buffListItemLogicController)
public let system: wref<System>;

@addField(SingleCooldownManager)
public let system: wref<System>;

// icons shown on top of the screen
@wrapMethod(buffListGameController)
protected cb func OnBuffSpawned(newItem: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    LogChannel(n"DEBUG", "buff list");
    let controller = newItem.GetController() as buffListItemLogicController;
    let owner = this.GetOwnerEntity() as PlayerPuppet;
    controller.system = System.GetInstance(owner.GetGame());
    return wrappedMethod(newItem, userData);
}

// icons shown in radial wheel
@wrapMethod(inkCooldownGameController)
protected cb func OnInitialize() -> Bool {
    LogChannel(n"DEBUG", "cooldown");
    let out = wrappedMethod();
    let system = System.GetInstance(this.GetInstance());
    for scm in this.m_cooldownPool {
        scm.system = system;
    }
    return out;
}

@replaceMethod(SingleCooldownManager)
public final func ActivateCooldown(buffData: UIBuffInfo) -> Void {
    let threshold: Threshold;
    let effectUIData: wref<StatusEffectUIData_Record>;
    let i: Int32;
    let textParams: ref<inkTextParams>;
    this.excludedStatusEffect = TDBID.Create(this.C_EXCLUDED_STATUS_EFFECT_NAME);
    let effect: wref<StatusEffect_Record> = TweakDBInterface.GetStatusEffectRecord(buffData.buffID);
    if !IsDefined(effect) || effect.GetID() == this.excludedStatusEffect {
      return;
    };
    effectUIData = effect.UiData();
    if !IsDefined(effectUIData) {
      return;
    };
    this.m_buffData = buffData;
    this.GetRootWidget().SetVisible(true);
    if this.m_buffData.isBuff {
      this.GetRootWidget().SetState(n"Buff");
    } else {
      this.GetRootWidget().SetState(n"Debuff");
    };
    inkTextRef.SetText(this.m_name, effectUIData.DisplayName());
    inkTextRef.SetText(this.m_desc, effectUIData.Description());
    inkWidgetRef.SetVisible(this.m_desc, IsStringValid(effectUIData.Description()));
    if effectUIData.GetFloatValuesCount() > 0 || effectUIData.GetIntValuesCount() > 0 || effectUIData.GetNameValuesCount() > 0 {
      textParams = new inkTextParams();
      i = 0;
      while i < effectUIData.GetFloatValuesCount() {
        textParams.AddNumber("float_" + IntToString(i), effectUIData.GetFloatValuesItem(i));
        i += 1;
      };
      i = 0;
      while i < effectUIData.GetIntValuesCount() {
        textParams.AddNumber("int_" + IntToString(i), effectUIData.GetIntValuesItem(i));
        i += 1;
      };
      i = 0;
      while i < effectUIData.GetNameValuesCount() {
        textParams.AddString("name_" + IntToString(i), GetLocalizedText(NameToString(effectUIData.GetNameValuesItem(i))));
        i += 1;
      };
      inkTextRef.SetTextParameters(this.m_desc, textParams);
    };
    this.SetTimeRemaining(this.m_buffData.timeRemaining);
    this.SetStackCount(Cast<Int32>(this.m_buffData.stackCount));
    let addictive = this.system.GetRelatedAddictiveEffect(effect);
    threshold = this.system.GetThresholdFromAppliedEffects(addictive);
    if Equals(this.m_type, ECooldownGameControllerMode.COOLDOWNS) {
      InkImageUtils.RequestSetImage(this, this.m_spriteBg, GetUIIcon(threshold, effectUIData.IconPath()));
      InkImageUtils.RequestSetImage(this, this.m_sprite, GetUIIcon(threshold, effectUIData.IconPath()));
    } else {
      InkImageUtils.RequestSetImage(this, this.m_icon, GetUIIcon(threshold, effectUIData.IconPath()));
    };
    this.m_state = ECooldownIndicatorState.Intro;
    this.m_initialDuration = this.m_buffData.timeRemaining;
    if this.m_initialDuration > this.m_outroDuration {
      this.FillIntroAnimationStart();
    } else {
      this.FillOutroAnimationStart();
    };
    this.GetRootWidget().Reparent(inkWidgetRef.Get(this.m_grid) as inkCompoundWidget);
}

@replaceMethod(buffListItemLogicController)
public final func SetData(icon: CName, time: Float, totalTime: Float, opt stackCount: Int32) -> Void {
    let threshold: Threshold;
    if stackCount > 1 {
        inkWidgetRef.SetVisible(this.m_stackCounterContainer, true);
        inkTextRef.SetText(this.m_stackCounter, "x" + IntToString(stackCount));
    } else {
        inkWidgetRef.SetVisible(this.m_stackCounterContainer, false);
    };
    this.SetTimeFill(time, totalTime);
    this.SetTimeText(time);
    let addictive = this.system.GetRelatedAddictiveEffect(this.GetStatusEffectRecord());
    threshold = this.system.GetThresholdFromAppliedEffects(addictive);
    InkImageUtils.RequestSetImage(this, this.m_icon, GetUIIcon(threshold, NameToString(icon)));
    InkImageUtils.RequestSetImage(this, this.m_iconBg, GetUIIcon(threshold, NameToString(icon)));
}

@replaceMethod(buffListItemLogicController)
public final func SetData(icon: TweakDBID, time: Float, totalTime: Float) -> Void {
    let threshold: Threshold;
    this.SetTimeText(time);
    this.SetTimeFill(time, totalTime);
    let addictive = this.system.GetRelatedAddictiveEffect(this.GetStatusEffectRecord());
    threshold = this.system.GetThresholdFromAppliedEffects(addictive);
    InkImageUtils.RequestSetImage(this, this.m_icon, GetUIIcon(threshold, TDBID.ToStringDEBUG(icon)));
    InkImageUtils.RequestSetImage(this, this.m_iconBg, GetUIIcon(threshold, TDBID.ToStringDEBUG(icon)));
}

@replaceMethod(buffListItemLogicController)
public final func SetData(icon: CName, stackCount: Int32) -> Void {
    let threshold: Threshold;
    if stackCount > 1 {
        inkWidgetRef.SetVisible(this.m_stackCounterContainer, true);
        inkTextRef.SetText(this.m_stackCounter, "x" + ToString(stackCount));
    } else {
        inkWidgetRef.SetVisible(this.m_stackCounterContainer, false);
    };
    let addictive = this.system.GetRelatedAddictiveEffect(this.GetStatusEffectRecord());
    threshold = this.system.GetThresholdFromAppliedEffects(addictive);
    InkImageUtils.RequestSetImage(this, this.m_icon, GetUIIcon(threshold, NameToString(icon)));
    InkImageUtils.RequestSetImage(this, this.m_iconBg, GetUIIcon(threshold, NameToString(icon)));
}