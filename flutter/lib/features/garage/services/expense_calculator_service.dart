/// RiderMate 2.0 — Expense & Cost-Per-KM Calculator
class ExpenseCalculatorService {
  static double calculateCostPerKm(double totalExpensesRupees, double totalDistanceKm) {
    if (totalDistanceKm <= 0) return 0.0;
    return double.parse((totalExpensesRupees / totalDistanceKm).toStringAsFixed(2));
  }
}
