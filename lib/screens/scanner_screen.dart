import 'dart:io';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'global_product.dart';
import 'manualInput_screen.dart'; 

class ScannerScreen extends StatefulWidget {
  final Function(String, String, String, File?, String, String) onProductAdded;

  ScannerScreen({required this.onProductAdded});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String barcode = '';
  String productName = '';
  String expireDate = '';
  String purchaseDate = '';
  String price = '';
  String currency = 'Rp';
  File image = File('');

  // Fetch product details from the Open Food Facts API
  Future<void> fetchProductInfo(String barcode) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          productName = data['product'] != null && data['product']['product_name'] != null
              ? data['product']['product_name']
              : 'Product Not Found';
          expireDate = data['product'] != null && data['product']['expiration_date'] != null
              ? data['product']['expiration_date']
              : 'Select Date';
          purchaseDate = DateTime.now().toString().split(' ')[0]; 
          price = data['product'] != null && data['product']['price'] != null
              ? data['product']['price'].toString()
              : '';

          GlobalProduct.productName = productName;
          GlobalProduct.expireDate = expireDate;
          GlobalProduct.purchaseDate = purchaseDate;
          GlobalProduct.price = price;
          GlobalProduct.currency = currency;
        });

        // After fetching the product info, navigate directly to the manual input screen.
        navigateToManualInput();
      } else {
        setState(() {
          productName = 'Product not found';
        });
      }
    } catch (e) {
      setState(() {
        productName = 'Error fetching data';
      });
      print('Error: $e');
    }
  }

  // Scan barcode function
  Future<void> scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan(); 
      setState(() {
        barcode = result.rawContent;  
      });

      if (barcode != '-1') {
        fetchProductInfo(barcode); // After scanning, fetch the product info and go to manual input screen
      }
    } catch (e) {
      setState(() {
        barcode = 'Error: $e';  
      });
    }
  }

  // Navigate to manual input screen
  void navigateToManualInput() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualInputScreen(
          productName: productName,
          expireDate: expireDate,
          purchaseDate: purchaseDate,
          price: price,
          currency: currency,
          image: image,
          onSave: (name, expiry, purchase, price, currency,image) {
            // Call onProductAdded callback from parent to save the product in list
            widget.onProductAdded(name, expiry, price, image, currency, purchase);
          },
        ),
      ),
    );
  }

  String formatPrice(String price) {
    double priceValue = double.tryParse(price) ?? 0.0;
    var formatter = NumberFormat.simpleCurrency(locale: 'id_ID', name: currency);

    if (currency == 'USD') {
      formatter = NumberFormat.simpleCurrency(locale: 'en_US', name: 'USD');
    }

    return formatter.format(priceValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Your Product'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (barcode.isNotEmpty) ...[
              Text(
                'Scanned Barcode: $barcode',  
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
            ],
            if (productName.isNotEmpty) ...[
              Text('Product Name: $productName'),
              Text('Expiration Date: $expireDate'),
              Text('Purchase Date: $purchaseDate'),
              Text('Price: ${formatPrice(price)}'),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: scanBarcode,  
              child: Text(
                'Scan Barcode',
                style: TextStyle(color: Colors.green),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: navigateToManualInput, 
              child: Text(
                'Enter Manually',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
