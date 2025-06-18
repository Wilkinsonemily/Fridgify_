import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'budget_screen.dart';
import 'inventory_screen.dart';
import 'list_screen.dart';
import 'scanner_screen.dart';
import 'user_screen.dart';
import '../data/inventory_manager.dart';
import '../data/budget_manager.dart';
import 'package:intl/intl.dart' show NumberFormat;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double remainingBudget = 1000000.00;
  double usedBudget = 200000.00;
  int _currentIndex = 0;
  final List<Product> _products = [];
  
  void updateBudget(double newRemainingBudget, double newUsedBudget) {
    if (!mounted) return;
    setState(() {
      remainingBudget = newRemainingBudget;
      usedBudget = newUsedBudget;
    });
  }

  String formatCurrency(double value) {
    final formatter = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ');
    return formatter.format(value).replaceAll(",00", "");
  }

  // void _addProductToInventory(
  //   String name,
  //   String expirationDate,
  //   String price,
  //   File? image,
  //   String currency,
  //   String addedOn,
  // ) {
  //   if (!mounted) return;
  //   setState(() {
  //     // Check if product already exists
  //     Product? existingProduct = _products.firstWhereOrNull(
  //       (product) => product.name == name && product.addedOn == addedOn,
  //     );
  //     if (existingProduct != null) {
  //       // Update existing product
  //       existingProduct.isInInventory = true;
  //     } else {
  //       // Add new product
  //       _products.add(
  //         Product(
  //           name: name,
  //           expirationDate: expirationDate,
  //           price: price,
  //           image: image,
  //           currency: currency,
  //           checked: false,
  //           isInInventory: true,
  //           addedOn: addedOn,
  //         ),
  //       );
  //     }
  //   });
  // }

  void _addProductToInventory(
  String name,
  String expirationDate,
  String price,
  File? image,
  String currency,
  String addedOn,
  ) async {
    if (!mounted) return;

    setState(() {
      Product? existingProduct = _products.firstWhereOrNull(
        (product) => product.name == name && product.addedOn == addedOn,
      );
      if (existingProduct != null) {
        existingProduct.isInInventory = true;
      } else {
        _products.add(
          Product(
            name: name,
            expirationDate: expirationDate,
            price: price,
            image: image,
            currency: currency,
            checked: false,
            isInInventory: true,
            addedOn: addedOn,
          ),
        );
      }
    });

    // Tambahan penyimpanan ke JSON
    final item = InventoryItem(
      name: name,
      expirationDate: expirationDate,
      price: price,
      imagePath: image?.path,
      currency: currency,
      addedOn: addedOn,
    );
    await InventoryManager.addItem(item);

    final allItems = await InventoryManager.loadInventory();
    double total = 0;
    for (var i in allItems) {
      total += double.tryParse(i.price) ?? 0;
    }

    final summary = BudgetSummary(
      totalSpent: total,
      numItems: allItems.length,
      avgItemPrice: allItems.isEmpty ? 0 : total / allItems.length,
      month: DateTime.now().month.toString(),
      currency: currency,
    );

    await BudgetManager.saveSummary(summary);
  }

  void _onItemTapped(int index) {
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        remainingBudget: remainingBudget,
        usedBudget: usedBudget,
        updateBudget: updateBudget,
      ),
      InventoryScreen(
        inventoryList: _products,
        onProductAdded: _addProductToInventory,
      ),
      ScannerScreen(onProductAdded: _addProductToInventory),
      ListScreen(
        productList: _products,
        addProductToInventory: _addProductToInventory,
      ),
      UserScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Home'
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory), 
            label: 'Inventory'
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add, size: 40, color: Colors.green), 
            label: ''
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list), 
            label: 'List'
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), 
            label: 'User'
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final double remainingBudget;
  final double usedBudget;
  final Function(double, double) updateBudget;

  const HomePage({
    super.key,
    required this.remainingBudget,
    required this.usedBudget,
    required this.updateBudget,
  });

  String formatCurrency(double value) {
    final formatter = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ');
    return formatter.format(value).replaceAll(",00", "");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hello, Olivia',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Remaining Budget',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BudgetScreen(
                    remainingBudget: remainingBudget,
                    usedBudget: usedBudget,
                    onBudgetChanged: updateBudget,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formatCurrency(remainingBudget),
                style: const TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.green),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.green),
                hintStyle: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension ListExtensions<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class Product {
  String name;
  String expirationDate;
  String price;
  File? image;
  String currency;
  bool checked;
  bool isInInventory;
  String addedOn;

  Product({
    required this.name,
    required this.expirationDate,
    required this.price,
    required this.currency,
    required this.checked,
    required this.isInInventory,
    required this.addedOn,
    required this.image,
  });
}
