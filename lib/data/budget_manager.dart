import 'dart:convert';
import 'dart:io';

class BudgetSummary {
  final double totalSpent;
  final int numItems;
  final double avgItemPrice;
  final String month;
  final String currency;

  BudgetSummary({
    required this.totalSpent,
    required this.numItems,
    required this.avgItemPrice,
    required this.month,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
        'totalSpent': totalSpent,
        'numItems': numItems,
        'avgItemPrice': avgItemPrice,
        'month': month,
        'currency': currency,
      };
}

class BudgetManager {
  static const String _filePath = 'assets/data/budget_summary.json';

  static Future<void> saveSummary(BudgetSummary summary) async {
    final file = File(_filePath);
    final jsonData = jsonEncode(summary.toJson());
    await file.writeAsString(jsonData);
  }
}
