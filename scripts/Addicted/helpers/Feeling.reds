module Addicted.Helpers
import Addicted.Mood
import Addicted.Threshold
import Addicted.Utils.E

public class Feeling {
  public static func OnceWarned(threshold: Threshold, warnings: Uint32) -> Mood {
    let random = RandF();
    let likeliness = 1.0 - MinF(Cast<Float>(warnings) / 10.0, 0.9);
    if random < likeliness {
      return Mood.Surprised;
    }
    random = RandF();
    if Equals(EnumInt(threshold), EnumInt(Threshold.Severely)) && random >= likeliness {
      return Mood.Disheartened;
    }
    return Mood.Offhanded;
  }
  public static func OnBoot(warnings: Uint32) -> Mood {
    if warnings >= 3u { return Mood.Surprised; }
    return Mood.Any;
  }
  public static func OnDismissInCombat() -> Mood {
    return Mood.Pestered;
  }

  public static func Disheartened() -> array<String> {
   return [
      "as_if_I_didnt_know_already",
      "come_on_biomon_cant_you_give_me_a_break",
      "damn_cant_you_just_leave_me_alone",
      "fuck",
      "yeah_I_know"
   ];
  }
  public static func Offhanded() -> array<String> {
   return [
     "yeah_yeah_yeah_alright",
     "yeah_yeah_yeah_who_cares",
     "you_tell_me_biomon",
     "nah_everything_is_all_good",
     "nah_Im_cool",
     "noo"
   ];
  }
  public static func Pestered() -> array<String> {
   return [
     "dont_you_see_Im_in_trouble",
     "fuck_this_biomon_just_not_right_now",
     "get_this_damn_UI_out_of_my_face",
     "so_frustrating",
     "shit"
   ];
  }
  public static func Surprised() -> array<String> {
   return [
     "biomon",
     "come_on_again",
     "damn_thats_fucked_up",
     "oh_shit",
     "what"
   ];
  }

  public static func Reaction(mood: Mood, gender: gamedataGender, language: CName) -> CName {
    let language = NameToString(language);
    if Equals(mood, Mood.Any) { return n""; }
    if StrLen(language) == 0 { language = "en-us"; }
    if NotEquals(language, "en-us")
      && NotEquals(language, "fr-fr")
      && NotEquals(language, "es-es") { return n""; }

    let output: CName;
    let choices: array<String>;
    let size: Int32;
    let which: Int32;

    switch(mood) {
      case Mood.Disheartened:
        choices = Feeling.Disheartened();
        break;
      case Mood.Offhanded:
        choices = Feeling.Offhanded();
        break;
      case Mood.Pestered:
        choices = Feeling.Pestered();
        break;
      case Mood.Surprised:
        choices = Feeling.Surprised();
        break;
      default:
        choices = [];
        break;
    }

    size = ArraySize(choices);
    if size > 0 {
      which = size > 1 ? RandRange(0, size -1) : 0;
      output = StringToName(choices[which]);
      E(s"picked \(NameToString(output)) (\(which))");
      return IsNameValid(output) ? output : n"";
    }

    return n"";
  }
}