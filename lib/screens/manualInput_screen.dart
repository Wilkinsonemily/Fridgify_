import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ManualInputScreen extends StatefulWidget {
  final String productName;
  final String expireDate;
  final String purchaseDate;
  final String price;
  final String currency;
  final File image;
  final Function(String name, String expiry, String purchase, String price, String currency, File? image) onSave;

  ManualInputScreen({
    required this.productName,
    required this.expireDate,
    required this.purchaseDate,
    required this.price,
    required this.currency,
    required this.image,
    required this.onSave,
  });

  @override
  _ManualInputScreenState createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  late TextEditingController _productNameController;
  late TextEditingController _expireDateController;
  late TextEditingController _purchaseDateController;
  late TextEditingController _priceController;

  String selectedCurrency = 'Rp';
  String? selectedCategory;
  Color productNameBorderColor = Colors.grey;
  Color expireDateBorderColor = Colors.grey;
  Color purchaseDateBorderColor = Colors.grey;
  Color priceBorderColor = Colors.grey;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(text: widget.productName);
    _expireDateController = TextEditingController(text: widget.expireDate);
    _purchaseDateController = TextEditingController(text: widget.purchaseDate);
    _priceController = TextEditingController(text: widget.price);
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _expireDateController.dispose();
    _purchaseDateController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = '${pickedDate.toLocal()}'.split(' ')[0];
      });
    }
  }

  void _selectCategory() async {
    String? newCategory = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Category'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: Text('Milk'), onTap: () => Navigator.pop(context, 'Milk')),
                ListTile(title: Text('Eggs'), onTap: () => Navigator.pop(context, 'Eggs')),
                ListTile(title: Text('Bread'), onTap: () => Navigator.pop(context, 'Bread')),
                ListTile(title: Text('Fruits'), onTap: () => Navigator.pop(context, 'Fruits')),
                ListTile(title: Text('Vegetables'), onTap: () => Navigator.pop(context, 'Vegetables')),
                ListTile(title: Text('Snacks'), onTap: () => Navigator.pop(context, 'Snacks')),
                ListTile(title: Text('Others'), onTap: () => Navigator.pop(context, 'Others')),
              ],
            ),
          ),
        );
      },
    );

    if (newCategory != null) {
      setState(() {
        selectedCategory = newCategory;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final action = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          actions: [
            TextButton(
              child: Text('Camera'),
              onPressed: () => Navigator.pop(context, ImageSource.camera),
            ),
            TextButton(
              child: Text('Gallery'),
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        );
      },
    );

    if (action != null) {
      final XFile? image = await _picker.pickImage(source: action);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Item'),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.all(100),
                margin: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(10),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Add a photo', style: TextStyle(color: Colors.green)),
                        ],
                      )
                    : null,
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              _productNameController,
              'Item Name',
              borderColor: productNameBorderColor,
              onTap: () {
                if (_productNameController.text == 'Product Not Found') {
                  _productNameController.clear();
                }
                setState(() {
                  productNameBorderColor = Colors.green;
                });
              },
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _selectCategory,
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        selectedCategory ?? 'Item Category',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              _priceController,
              'Price',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              borderColor: priceBorderColor,
              onTap: () {
                setState(() {
                  priceBorderColor = Colors.green;
                });
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              _expireDateController,
              'Expiration Date',
              readOnly: true,
              borderColor: expireDateBorderColor,
              onTap: () {
                _selectDate(context, _expireDateController);
                setState(() {
                  expireDateBorderColor = Colors.green;
                });
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              _purchaseDateController,
              'Purchase Date',
              readOnly: true,
              borderColor: purchaseDateBorderColor,
              onTap: () {
                _selectDate(context, _purchaseDateController);
                setState(() {
                  purchaseDateBorderColor = Colors.green;
                });
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(
                    _productNameController.text,
                    _expireDateController.text,
                    _purchaseDateController.text,
                    _priceController.text,
                    selectedCurrency,
                    _selectedImage,
                  );
                  Navigator.pop(context);
                },
                child: Text('Save Edit', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.all(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, void Function()? onTap, bool readOnly = false, Color borderColor = Colors.grey}) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          borderColor = hasFocus ? Colors.green : Colors.grey; // Change border color on focus
        });
      },
      child: Container(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
            hintText: label,
          ),
          keyboardType: keyboardType,
          onTap: onTap,
          readOnly: readOnly,
          onChanged: (value) {
            setState(() {
              borderColor = Colors.grey; // Reset border color on text input
            });
          },
        ),
      ),
    );
  }
}