module Addicted.Helpers

public class Bits {

  public static func Invert(num: Uint32) -> Uint32 {
    let after = num;
    let i: Int32 = 0;
    while i < 32 {
      after = after ^ BitShiftL32(1u, i);
      i += 1;
    }
    return after;
  }

  public static func Has(num: Uint32, n: Int32) -> Bool {
    return BitTest32(num, n);
  }
  
  public static func Set(num: Uint32, n: Int32, value: Bool) -> Uint32 {
    let after = num;
    if value {
      // set bit to 1
      after |= BitShiftL32(1u, n);
    } else {
      // set bit to 0
      let shifted = BitShiftL32(1u, n);
      let inversed = Bits.Invert(shifted);
      after &= inversed;
    }
    return after;
  }
}