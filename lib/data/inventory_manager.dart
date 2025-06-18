import 'dart:convert';
import 'dart:io';
import '../models/inventory_item.dart';

class InventoryManager {
  static const String _filePath = 'assets/data/inventory_data.json';

  static Future<List<InventoryItem>> loadInventory() async {
    try {
      final file = File(_filePath);
      if (!file.existsSync()) {
        return [];
      }
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => InventoryItem.fromJson(json)).toList();
    } catch (e) {
      print('Error loading inventory: $e');
      return [];
    }
  }

  static Future<void> addItem(InventoryItem item) async {
    final items = await loadInventory();
    items.add(item);
    await _saveInventory(items);
  }

  static Future<void> _saveInventory(List<InventoryItem> items) async {
    final file = File(_filePath);
    final jsonList = items.map((item) => item.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
}
