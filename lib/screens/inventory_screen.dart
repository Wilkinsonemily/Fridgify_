import 'dart:io';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'scanner_screen.dart';
import 'package:image_picker/image_picker.dart';

class InventoryScreen extends StatefulWidget {
  final List<Product> inventoryList;
  final Function(String, String, String, File?, String, String) onProductAdded;

  const InventoryScreen({
    super.key,
    required this.inventoryList,
    required this.onProductAdded,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Product> get _filteredInventory {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return widget.inventoryList.where((product) => product.isInInventory).toList();
    }
    return widget.inventoryList
        .where((product) => product.isInInventory && product.name.toLowerCase().contains(query))
        .toList();
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
    );
  }

  void _showAddManualDialog() {
    String name = '';
    String expirationDate = DateTime.now().toString().split(' ')[0];
    String price = '';
    File? image;
    String currency = 'Rp';

    final nameController = TextEditingController(text: name);
    final priceController = TextEditingController(text: price);

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
                      decoration: const InputDecoration(labelText: "Name"),
                      controller: nameController,
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
                                expirationDate =
                                    picked.toString().split(' ')[0];
                              });
                            }
                          },
                          child: Text(
                            expirationDate.isEmpty
                                ? "Select Date"
                                : expirationDate,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: "Price"),
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => price = value,
                    ),
                    Row(
                      children: [
                        const Text("Image: "),
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () async {
                            final picked = await ImagePicker().pickImage(
                              source: ImageSource.camera,
                            );
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
                            final picked = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );
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
                          items:
                              ['Rp', 'USD'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setStateDialog(() {
                              currency = newValue!;
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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (name.isNotEmpty &&
                        expirationDate.isNotEmpty &&
                        price.isNotEmpty) {
                      final String addedOn = DateTime.now()
                          .toString()
                          .split(' ')[0];
                      widget.onProductAdded(
                        name,
                        expirationDate,
                        price,
                        image,
                        currency,
                        addedOn,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.green),
                  ),
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
                onChanged: (value) {
                  setState(() {});
                },
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
                            leading: item.image != null
                                ? Image.file(
                                    item.image!,
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
                                Text(
                                  'Price: ${item.currency}${item.price}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Exp: ${item.expirationDate}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Added on: ${item.addedOn}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
        label: const Text(
          "Add Inventory",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}

