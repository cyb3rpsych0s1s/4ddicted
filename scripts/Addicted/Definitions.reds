public class Consumption {
  public persistent let current: Int32;
  public persistent let doses: array<Float>;
}

enum Category {
  Mild = 0,
  Hard = 1,
}

enum Threshold {
  Clean = 0,
  Barely = 10,
  Mildly = 20,
  Notably = 40,
  Severely = 60,
}
