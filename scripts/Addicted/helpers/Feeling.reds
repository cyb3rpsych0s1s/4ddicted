module Addicted.Helpers
import Addicted.Mood
import Addicted.Threshold

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
  public static func Disheartened() -> array<String> {
   return [
     "as_if_I_didnt_know_already",
     "come_on_biomon_cant_you_give_me_a_break",
     "damn_cant_you_just_leave_me_alone",
     "yeah_I_know"
   ];
  }
  public static func Offhanded() -> array<String> {
   return [
     "yeah_yeah_yeah_alright",
     "yeah_yeah_yeah_who_cares",
     "you_tell_me_biomon"
   ];
  }
  public static func Pestered() -> array<String> {
   return [
     "dont_you_see_im_in_trouble",
     "fuck_this_biomon_just_not_right_now",
     "get_this_damn_ui_out_of_my_face",
     "so_frustrating"
   ];
  }
  public static func Surprised() -> array<String> {
   return [
     "come_on_again",
     "damn_thats_fucked_up"
   ];
  }
}