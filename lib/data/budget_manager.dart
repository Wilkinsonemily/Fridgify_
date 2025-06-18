import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class BudgetSummary {
  final double totalSpent;
  final int numItems;
  final double avgItemPrice;
  final String month;
  final String currency;
  final double initialBudget; // ✅ Tambahan ini

  BudgetSummary({
    required this.totalSpent,
    required this.numItems,
    required this.avgItemPrice,
    required this.month,
    required this.currency,
    required this.initialBudget, // ✅ Tambahkan ke konstruktor
  });

  Map<String, dynamic> toJson() => {
    'totalSpent': totalSpent,
    'numItems': numItems,
    'avgItemPrice': avgItemPrice,
    'month': month,
    'currency': currency,
    'initialBudget': initialBudget, // ✅ Tambahkan ke JSON
  };

  factory BudgetSummary.fromJson(Map<String, dynamic> json) => BudgetSummary(
    totalSpent: json['totalSpent'] ?? 0.0,
    numItems: json['numItems'] ?? 0,
    avgItemPrice: json['avgItemPrice'] ?? 0.0,
    month: json['month'] ?? '',
    currency: json['currency'] ?? 'Rp ',
    initialBudget: json['initialBudget'] ?? 1000000.0, // ✅ Default fallback
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

  static Future<void> initializeBudgetIfNeeded() async {
    final file = await _getLocalFile();
    if (!(await file.exists())) {
      // Buat default summary awal dengan budget 50.000
      final summary = BudgetSummary(
        totalSpent: 0.0,
        numItems: 0,
        avgItemPrice: 0.0,
        month: DateFormat('yyyy-MM').format(DateTime.now()),
        currency: 'Rp',
        initialBudget: 50000.0,
      );
      await saveSummary(summary);
      print('Budget initialized with Rp 50.000');
    }
  }

  static Future<void> updateBudgetAfterAdding(double price) async {
    final summary = await loadSummary();
    if (summary != null) {
      final updated = BudgetSummary(
        totalSpent: summary.totalSpent + price,
        numItems: summary.numItems + 1,
        avgItemPrice: (summary.totalSpent + price) / (summary.numItems + 1),
        month: summary.month,
        currency: summary.currency,
        initialBudget: summary.initialBudget,
      );
      await saveSummary(updated);
    }
  }
}
