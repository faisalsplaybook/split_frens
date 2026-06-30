/// Defines the different ways an expense can be split among friends.
enum SplitType {
  /// Split the cost equally among everyone (e.g., $30 divided by 3 people = $10 each).
  equal,

  /// Each person pays an exact amount (e.g., Person A pays $15, Person B pays $5).
  exact,

  /// Each person pays a specific percentage of the total (e.g., Person A pays 60%, Person B pays 40%).
  percentage,

  /// Split based on shares or ratios (e.g., Person A gets 2 shares, Person B gets 1 share).
  shares,
}
