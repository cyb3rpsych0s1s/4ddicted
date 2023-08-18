import Codeware.Localization.*

native func RetrieveSubtitles(mod: String, locale: Locale) -> array<Translation>;

enum Locale {
    English = 0,
    French = 1,
}

public struct Translation {
    let locale: Locale;
    let female: String;
    let male: String;
}

public class AudiowareLocalizationProvider extends ModLocalizationProvider {
    public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
        switch language {
            case n"en-us":
                let package = new AudiowareLocalizationPackage();
                package.locale = Locale.English;
                return package;
            case n"fr-fr":
                let package = new AudiowareLocalizationPackage();
                package.locale = Locale.French;
                return package;
            default: return null;
        }
    }
}

public class AudiowareLocalizationPackage extends ModLocalizationPackage {
    public let locale: Locale;
    protected func DefineSubtitles() -> Void {
        // retrieve from natives ...
        let subtitles = RetrieveSubtitles("Addicted", this.locale);
        LogChannel(n"DEBUG", s"[!!AUDIOWARE!!] retrieved subtitles from audioware");
        for subtitle in subtitles {
            LogChannel(n"DEBUG", s"[!!AUDIOWARE!!] subtitle: \(subtitle.locale), \(subtitle.female), \(subtitle.male)");
        }
    }
}