module Addicted

enum IconKind {
    None = 0,
    Notably = 1,
    Severely = 2,
}

@addField(SingleCooldownManager)
public let system: wref<System>;

@addField(buffListItemLogicController)
public let system: wref<System>;

@wrapMethod(inkCooldownGameController)
protected cb func OnInitialize() -> Bool {
    let out = wrappedMethod();
    let system = System.GetInstance(this.GetInstance());
    for scm in this.m_cooldownPool {
        scm.system = system;
    }
    return out;
}

@wrapMethod(buffListGameController)
protected cb func OnBuffSpawned(newItem: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let controller = newItem.GetController() as buffListItemLogicController;
    let owner = this.GetOwnerEntity() as PlayerPuppet;
    controller.system = System.GetInstance(owner.GetGame());
    return wrappedMethod(newItem, userData);
}

@wrapMethod(InkImageUtils)
public final static func RequestSetImage(controller: ref<inkLogicController>, target: wref<inkImage>, iconID: TweakDBID, opt callbackFunction: CName) -> Void {
    let icon = iconID;
    if Equals(iconID, t"UIIcon.regeneration_icon")
       && (controller.IsExactlyA(n"SingleCooldownManager") || controller.IsExactlyA(n"buffListItemLogicController"))
    {
        LogChannel(n"DEBUG", "hook onto RequestSetImage:inkLogicController");
        let system: ref<System>;
        if controller.IsExactlyA(n"SingleCooldownManager") { system = (controller as SingleCooldownManager).system; }
        else { system = (controller as buffListItemLogicController).system; } 
        let kind = system.IconMaxDOC();
        switch (kind) {
            case IconKind.None:
                break;
            case IconKind.Notably:
                LogChannel(n"DEBUG", "replacing icon as expected");
                icon = t"UIIcon.notably_weakened_regeneration_icon";
                break;
            case IconKind.Severely:
                icon = t"UIIcon.severely_weakened_regeneration_icon";
                break;
        }
    }
    wrappedMethod(controller, target, icon, callbackFunction);
}
