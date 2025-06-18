import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'budget_manager.dart'; // Pakai BudgetSummary dari file lama

class BudgetHistoryManager {
  static Future<File> _getHistoryFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/budget_history.json');
  }

  /// Tambahkan 1 data budget baru ke history
  static Future<void> addSummary(BudgetSummary newSummary) async {
    final file = await _getHistoryFile();
    List<BudgetSummary> existing = await loadAllSummaries();

    // Cek duplikat berdasarkan bulan
    existing.removeWhere((item) => item.month == newSummary.month);

    existing.add(newSummary);

    final jsonList = existing.map((item) => item.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  /// Ambil semua summary
  static Future<List<BudgetSummary>> loadAllSummaries() async {
    try {
      final file = await _getHistoryFile();
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final jsonData = jsonDecode(content);

      if (jsonData is List) {
        return jsonData.map((item) => BudgetSummary.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Gagal load budget history: $e");
      return [];
    }
  }

  /// Hapus semua data history
  static Future<void> clearHistory() async {
    final file = await _getHistoryFile();
    if (await file.exists()) {
      await file.writeAsString(jsonEncode([]));
    }
  }

  /// Cari summary by bulan (optional helper)
  static Future<BudgetSummary?> getSummaryByMonth(String month) async {
    List<BudgetSummary> all = await loadAllSummaries();
    try {
      return all.firstWhere((item) => item.month == month);
    } catch (_) {
      return null;
    }
  }
}
