module Addicted

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
