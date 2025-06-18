import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

  factory BudgetSummary.fromJson(Map<String, dynamic> json) => BudgetSummary(
        totalSpent: json['totalSpent'],
        numItems: json['numItems'],
        avgItemPrice: json['avgItemPrice'],
        month: json['month'],
        currency: json['currency'],
      );
}

class BudgetManager {
  static Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<File> get _budgetFile async {
    final path = await _localPath;
    return File('$path/budget_summary.json');
  }

  static Future<void> saveSummary(BudgetSummary summary) async {
    final file = await _budgetFile;
    final data = jsonEncode(summary.toJson());
    await file.writeAsString(data);
  }

  static Future<BudgetSummary?> loadSummary() async {
    final file = await _budgetFile;
    if (!await file.exists()) return null;
    final data = await file.readAsString();
    return BudgetSummary.fromJson(jsonDecode(data));
  }
}
