module Addicted

import Codeware.Localization.*

public class LocalizationProvider extends ModLocalizationProvider {
    public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
        switch language {
            case n"en-us":  return new English();
            case n"fr-fr":  return new French();
            case n"es-mx":  return new Spanish();
            case n"es-es":  return new Spanish();
            case n"it-it":  return new Italian();
            default:        return null;
        }
    }

    public func GetFallback() -> CName {
        return n"en-us";
    }
}

private abstract class LocalizationPackage extends ModLocalizationPackage {
    protected func DefineTexts() -> Void {
        this.Text("Mod-Addicted-Consumable-HealthBooster",        GetLocalizedTextByKey(n"Gameplay-Consumables-LongLasting-DisplayName-HealthBooster"));
        this.Text("Mod-Addicted-Consumable-StaminaBooster",       GetLocalizedTextByKey(n"Gameplay-Consumables-LongLasting-DisplayName-StaminaBooster"));
        this.Text("Mod-Addicted-Consumable-MemoryBooster",        GetLocalizedTextByKey(n"Gameplay-Consumables-LongLasting-DisplayName-MemoryBooster"));
        this.Text("Mod-Addicted-Consumable-CarryCapacityBooster", GetLocalizedTextByKey(n"Gameplay-Consumables-LongLasting-DisplayName-CarryCapacityBooster"));
    }
}