module Addicted.Helpers
import Addicted.Mood
import Addicted.Threshold
import Addicted.Utils.E

public class Feeling {
  public static func OnceWarned(threshold: Threshold, warnings: Uint32) -> Mood {
    let random = RandF();
    let likeliness = MaxF(Cast<Float>(warnings / 10u), 0.9);
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
  public static func OnDismissInCombat(threshold: Threshold, warnings: Uint32) -> Mood {
    if warnings > 1u && Equals(EnumInt(threshold), EnumInt(Threshold.Severely)) { return Mood.Pestered; }
    return Mood.Any;
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
     "noo"
   ];
  }
  public static func Pestered() -> array<String> {
   return [
     "dont_you_see_im_in_trouble",
     "fuck_this_biomon_just_not_right_now",
     "get_this_damn_ui_out_of_my_face",
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

  public static func Reaction(mood: Mood, gender: gamedataGender, opt language: String) -> CName {
    if Equals(mood, Mood.Any) { return n""; }

    let output: CName;
    let choices: array<String>;
    let size: Int32;
    let which: Int32;
    let prefix: String = Equals(gender, gamedataGender.Female) ? "fem_v" : "male_v";
    if StrLen(language) == 0 { language = "en-us"; }

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
      output = StringToName("addicted" + "." + language + "." + prefix + "_" + choices[which]);
      E(s"picked \(NameToString(output)) (\(which))");
      return IsNameValid(output) ? output : n"";
    }

    return n"";
  }
}