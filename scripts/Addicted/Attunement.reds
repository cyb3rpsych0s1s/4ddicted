module Addicted

import Addicted.System.AddictedSystem
import Addicted.Helpers.Generic

@wrapMethod(ConsumableTransitions)
protected final func ChangeConsumableAnimFeature(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, newState: Bool) -> Void {
    let item: ItemID;
    let id: TweakDBID;
    let addictive: Bool;
    let consumable: Consumable;
    let threshold: Threshold;
    let player: ref<PlayerPuppet>;
    let system: ref<AddictedSystem>;
    wrappedMethod(stateContext, scriptInterface, newState);
    item = this.GetItemIDFromWrapperPermanentParameter(stateContext, n"consumable");
    id = ItemID.GetTDBID(item);
    addictive = Generic.IsAddictive(id);
    if addictive {
        player = scriptInterface.GetPlayerSystem().GetLocalPlayerMainGameObject() as PlayerPuppet;
        system = AddictedSystem.GetInstance(player.GetGame());
        consumable = Generic.Consumable(id);
        threshold = system.Threshold(consumable);
        if EnumInt(threshold) >= EnumInt(Threshold.Severely) {
            let itemType: gamedataItemType = TweakDBInterface.GetItemRecord(id).ItemType().Type();
            let inCombat: Bool = (scriptInterface.GetPlayerSystem().GetLocalPlayerMainGameObject() as PlayerPuppet).IsInCombat();
            let isPerkFasterHealingUnlocked: Bool = PlayerDevelopmentSystem.GetData(scriptInterface.executionOwner).IsNewPerkBought(gamedataNewPerkType.Tech_Left_Perk_2_3) > 0;
            let consumableAnimFeature: ref<AnimFeature_ConsumableAnimation> = new AnimFeature_ConsumableAnimation();
            consumableAnimFeature.useConsumable = false;
            switch itemType {
                case gamedataItemType.Con_Injector:
                    consumableAnimFeature.consumableType = 0;
                    if inCombat && isPerkFasterHealingUnlocked {
                        consumableAnimFeature.animationScale = 1.65 + 0.15;
                    } else {
                        consumableAnimFeature.animationScale = 1.15 + 0.3;
                    };
                    break;
                case gamedataItemType.Con_Inhaler:
                    consumableAnimFeature.consumableType = 1;
                    if inCombat && isPerkFasterHealingUnlocked {
                        consumableAnimFeature.animationScale = 1.50 + 0.1;
                    } else {
                        consumableAnimFeature.animationScale = 1.15 + 0.2;
                    };
            };
            scriptInterface.SetAnimationParameterFeature(n"ConsumableFeature", consumableAnimFeature, scriptInterface.executionOwner);
        }
    }
}