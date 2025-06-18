import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

import '../models/inventory_item.dart';

class InventoryManager {
  static Future<File> _getInventoryFile() async {
    final dir = await getApplicationDocumentsDirectory();  // ✅ direktori bisa ditulis
    return File('${dir.path}/inventory.json');
  }

  static Future<List<InventoryItem>> loadInventory() async {
    try {
      final file = await _getInventoryFile();

      if (!await file.exists()) {
        await file.writeAsString(jsonEncode([]));  // bikin file kosong dulu
      }

      final content = await file.readAsString();
      final List<dynamic> jsonData = json.decode(content);
      return jsonData.map((e) => InventoryItem.fromJson(e)).toList();
    } catch (e) {
      print("Error reading inventory: $e");
      return [];
    }
  }

  static Future<void> addItem(InventoryItem item) async {
    final file = await _getInventoryFile();
    final items = await loadInventory();
    items.add(item);
    final jsonData = items.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonData));
  }

  static Future<void> saveInventory(List<InventoryItem> items) async {
    final file = await _getInventoryFile();
    final jsonData = items.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonData));
  }

}
