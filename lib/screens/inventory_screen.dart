import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fridgify/screens/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../data/inventory_manager.dart';
import '../models/inventory_item.dart';
import 'scanner_screen.dart';

class InventoryScreen extends StatefulWidget {
  final Function(String, String, String, File?, String, String) onProductAdded;
  final void Function(double) onUsedBudgetChanged;


  const InventoryScreen({
    super.key,
    required this.onProductAdded,
    required List<Product> inventoryList,
    required Future<void> Function() onInventoryChanged,
    required this.onUsedBudgetChanged, // ✅ Tambahan
  });


  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<InventoryItem> _allItems = [];

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    final items = await InventoryManager.loadInventory();
    if (mounted) {
      setState(() {
        _allItems = items;
      });
    }
  }

  List<InventoryItem> get _filteredInventory {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _allItems;
    return _allItems.where((item) => item.name.toLowerCase().contains(query)).toList();
  }

  void _addInventoryDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Add Manually'),
            onTap: () {
              Navigator.pop(context);
              _showAddManualDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Add from Scanner'),
            onTap: () {
              Navigator.pop(context);
              _navigateToScanner();
            },
          ),
        ],
      ),
    );
  }

  void _navigateToScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(onProductAdded: widget.onProductAdded),
      ),
    ).then((_) => _loadInventory());
  }

  void _showAddManualDialog() {
    String name = '';
    String expirationDate = DateTime.now().toString().split(' ')[0];
    String price = '';
    File? image;
    String currency = 'Rp';

    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Inventory Item'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                      onChanged: (value) => name = value,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text("Expiration Date: "),
                        TextButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                expirationDate = picked.toString().split(' ')[0];
                              });
                            }
                          },
                          child: Text(
                            expirationDate.isEmpty ? "Select Date" : expirationDate,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: "Price"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => price = value,
                    ),
                    Row(
                      children: [
                        const Text("Image: "),
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () async {
                            final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                            if (picked != null) {
                              setStateDialog(() {
                                image = File(picked.path);
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo),
                          onPressed: () async {
                            final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              setStateDialog(() {
                                image = File(picked.path);
                              });
                            }
                          },
                        ),
                        if (image != null)
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.file(image!, fit: BoxFit.cover),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Currency: "),
                        DropdownButton<String>(
                          value: currency,
                          items: ['Rp', 'USD'].map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setStateDialog(() {
                              currency = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () {
                    if (name.isNotEmpty && expirationDate.isNotEmpty && price.isNotEmpty) {
                      final addedOn = DateTime.now().toString().split(' ')[0];
                      widget.onProductAdded(name, expirationDate, price, image, currency, addedOn);
                      double parsedPrice = double.tryParse(price) ?? 0;
                      widget.onUsedBudgetChanged(parsedPrice);
                      Navigator.pop(context);
                      _loadInventory(); // Refresh list
                    }
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.green)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Inventory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.green),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search in the inventory',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.green),
                  hintStyle: TextStyle(color: Colors.black),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredInventory.isEmpty
                  ? const Center(child: Text('No inventory items found.'))
                  : ListView.builder(
                      itemCount: _filteredInventory.length,
                      itemBuilder: (context, index) {
                        var item = _filteredInventory[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: item.imagePath != null
                                ? Image.file(
                                    File(item.imagePath!),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image, size: 50),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Price: ${item.currency}${item.price}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Text('Exp: ${item.expirationDate}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Text('Added on: ${item.addedOn}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Konfirmasi hapus
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Item'),
                                    content: const Text('Are you sure you want to delete this item?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Cancel', style: TextStyle(color: Colors.green)),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  setState(() {
                                    _allItems.removeWhere((element) =>
                                        element.name == item.name &&
                                        element.addedOn == item.addedOn);
                                  });

                                  // Simpan database setelah hapus
                                  await InventoryManager.saveInventory(_allItems);

                                  // ✅ Recalculate total spent
                                  double newTotalSpent = _allItems.fold(0, (sum, item) {
                                    double price = double.tryParse(item.price) ?? 0;
                                    return sum + price;
                                  });

                                  widget.onUsedBudgetChanged(0); // Reset dulu
                                  widget.onUsedBudgetChanged(newTotalSpent); // Kirim total baru

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${item.name} deleted')),
                                    );
                                  }
                                }
                              },
                            ),
                          )

                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addInventoryDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Inventory", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }
}
