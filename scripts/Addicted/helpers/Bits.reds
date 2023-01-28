public class Bits {
  public static func ShiftRight(num: Int32, n: Int32) -> Int32 {
    return num / Bits.PowI(2, n);
  }

  public static func ShiftLeft(num: Int32, n: Int32) -> Int32 {
    return num * Bits.PowI(2, n);
  }

  public static func PowI(num: Int32, times: Int32) -> Int32 {
    return RoundMath(PowF(Cast<Float>(num), Cast<Float>(times)));
  }

  public static func Invert(num: Int32) -> Int32 {
    let i = 0;
    while i < 32 {
      num = Bits.PowI(num, Bits.ShiftLeft(1, i));
      i += 1;
    }
    return num;
  }

  public static func Has(num: Int32, n: Int32) -> Bool {
    return Cast<Bool>(Bits.ShiftRight(num, n) & 1);
  }
  
  public static func Set(num: Int32, n: Int32, value: Bool) -> Int32 {
    let after = num;
    if value {
      // set bit to 1
      after |= Bits.ShiftLeft(1, n);
    } else {
      // set bit to 0
      after &= Bits.Invert(Bits.ShiftLeft(1, n));
    }
    return after;
  }
}