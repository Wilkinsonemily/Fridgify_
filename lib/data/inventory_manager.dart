import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class InventoryItem {
  String name;
  String expirationDate;
  String price;
  String? imagePath;
  String currency;
  String addedOn;

  InventoryItem({
    required this.name,
    required this.expirationDate,
    required this.price,
    this.imagePath,
    required this.currency,
    required this.addedOn,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'expirationDate': expirationDate,
        'price': price,
        'imagePath': imagePath,
        'currency': currency,
        'addedOn': addedOn,
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        name: json['name'],
        expirationDate: json['expirationDate'],
        price: json['price'],
        imagePath: json['imagePath'],
        currency: json['currency'],
        addedOn: json['addedOn'],
      );
}

class InventoryManager {
  static Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<File> get _inventoryFile async {
    final path = await _localPath;
    return File('$path/inventory_data.json');
  }

  static Future<List<InventoryItem>> loadInventory() async {
    final file = await _inventoryFile;

    if (!await file.exists()) {
      return [];
    }

    final contents = await file.readAsString();
    final List<dynamic> jsonData = jsonDecode(contents);
    return jsonData.map((e) => InventoryItem.fromJson(e)).toList();
  }

  static Future<void> saveInventory(List<InventoryItem> items) async {
    final file = await _inventoryFile;
    final data = jsonEncode(items.map((e) => e.toJson()).toList());
    await file.writeAsString(data);
  }

  static Future<void> addItem(InventoryItem item) async {
    final current = await loadInventory();
    current.add(item);
    await saveInventory(current);
  }

  static Future<void> clearAll() async {
    final file = await _inventoryFile;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
