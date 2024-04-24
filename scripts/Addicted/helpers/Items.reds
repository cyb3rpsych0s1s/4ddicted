module Addicted.Helpers

import Addicted.*
import Addicted.Utils.{E,EI,F}

// items helper
public class Items {

  public static func IsDetoxifier(id: TweakDBID) -> Bool { return Equals(id, t"Items.ToxinCleanser"); }
  public static func IsMetabolicEditor(id: TweakDBID) -> Bool { return Equals(id, t"Items.ReverseMetabolicEnhancer"); }
  public static func IsInstant(record: ref<TweakDBRecord>) -> Bool {
    // TODO: refactor based on duration < 1
    if record.IsA(n"gamedataConsumableItem_Record") {
      let item = record as Item_Record;
      let id = item.GetID();
      let str = TDBID.ToStringDEBUG(id);
      let suffix = StrAfterFirst(str, ".");
      return StrContains(suffix, "FirstAidWhiff");
    }
    return false;
  }
}