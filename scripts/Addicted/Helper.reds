module Addicted

import Addicted.Category

public final class Helper {
  static public final func Category(id: TweakDBID) -> Category {
    switch(id) {
      case t"BaseStatusEffect.BlackLaceV0":
        return Category.Hard;
      default:
        return Category.Mild;
    }
  }
}
