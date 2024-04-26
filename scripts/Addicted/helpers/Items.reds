module Addicted.Helpers

import Addicted.*
import Addicted.Utils.{E,EI,F}

// items helper
public class Items {

  private static func Suffix(id: TweakDBID) -> String {
    let raw: String = TDBID.ToStringDEBUG(id);
    let prefix: String;
    let suffix: String;
    StrSplitFirst(raw, ".", prefix, suffix);
    return suffix;
  }
  private static func SuffixContains(id: TweakDBID, keyword: String) -> Bool {
    let suffix: String = Items.Suffix(id);
    return StrContains(suffix, keyword);
  }
  public static func IsDetoxifier(id: TweakDBID) -> Bool { return Equals(id, t"Items.ToxinCleanser"); }
  public static func IsMetabolicEditor(id: TweakDBID) -> Bool { return Equals(id, t"Items.ReverseMetabolicEnhancer"); }
  public static func IsBioconductor(id: TweakDBID) -> Bool { return StrBeginsWith(Items.Suffix(id), "AdvancedBioConductors"); }
  public static func IsCOX2(id: TweakDBID) -> Bool { return StrBeginsWith(Items.Suffix(id), "IconicBioConductors"); }
  public static func IsExDisk(id: TweakDBID) -> Bool { return StrBeginsWith(Items.Suffix(id), "AdvancedExDisk"); }
  public static func IsCamillo(id: TweakDBID) -> Bool { return StrBeginsWith(Items.Suffix(id), "AdvancedCamilloRamManager"); }
  
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