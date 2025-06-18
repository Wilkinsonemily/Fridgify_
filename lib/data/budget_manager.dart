import 'dart:io';
import 'dart:convert';
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
  static Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/budget_summary.json');
  }

  static Future<void> saveSummary(BudgetSummary summary) async {
    final file = await _getLocalFile();
    final jsonData = jsonEncode(summary.toJson());
    await file.writeAsString(jsonData);
  }

  static Future<BudgetSummary?> loadSummary() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonData = jsonDecode(contents);
        return BudgetSummary.fromJson(jsonData);
      } else {
        return null; // BELUM ADA FILE, return null
      }
    } catch (e) {
      print('Error loading budget summary: $e');
      return null; // ERROR PARSING JUGA return null
    }
  }
}
