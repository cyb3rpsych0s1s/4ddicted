module Addicted

import Martindale.MartindaleSystem
import Martindale.RegisteredConsumable
import Martindale.Consumable

@addMethod(StatusEffectHelper)
public final static func GetAppliedEffectsForConsumable(target: wref<GameObject>, consumable: Consumable) -> array<ref<StatusEffect>> {
    let applied: array<ref<StatusEffect>> = StatusEffectHelper.GetAppliedEffects(target);
    let main: ref<System> = System.GetInstance(target.GetGame());
    let knowns = main.GetRegisteredConsumables(consumable);
    let related: array<ref<StatusEffect>>;
    let record: ref<StatusEffect_Record>;
    for effect in applied {
        record = effect.GetRecord();
        for known in knowns {
            if known.ContainsStatus(record) { ArrayPush(related, effect); break; }
        }
    }
    return related;
}

// @wrapMethod(EquipmentSystemPlayerData)
// private final func GetItemGLPs(itemID: TweakDBID) -> array<wref<GameplayLogicPackage_Record>> {
//     let packages = wrappedMethod(itemID);
//     LogPackages("GetItemGLPs", packages);
//     return packages;
// }

// private func LogPackages(at: String, packages: array<wref<GameplayLogicPackage_Record>>) -> Void {
//     let stats: array<wref<StatModifier_Record>>;
//     LogChannel(n"DEBUG", s"--- \(at) ---");
//     for package in packages {
//         LogChannel(n"DEBUG", s"package: \(TDBID.ToStringDEBUG(package.GetID()))");
//         package.Stats(stats);
//         for stat in stats {
//             LogChannel(n"DEBUG", s"stat: \(TDBID.ToStringDEBUG(stat.StatType().GetID()))");
//         }
//     }
// }
