public class Consumption {
  public persistent let current: Int32;
  public persistent let doses: array<Float>;
}

enum Category {
  Mild = 0,
  Hard = 1,
}
