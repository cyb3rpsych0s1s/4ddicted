module Addicted.Localization
import Codeware.Localization.*

public class LocalizationProvider extends ModLocalizationProvider {
  public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
    switch language {
      case n"en-us": return new English();
      case n"fr-fr": return new French();
      default: return null;
    }
  }

  public func GetFallback() -> CName {
    return n""; // no fallback on voices
  }
}