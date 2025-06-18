import 'dart:io';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ListScreen extends StatefulWidget {
  final List<Product> productList;
  final Function(String, String, String, File?, String, String) addProductToInventory;

  const ListScreen({
    super.key,
    required this.productList,
    required this.addProductToInventory,
  });

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String totalAmount = 'Rp 0,00';
  String uncheckedItems = 'Rp 0,00';
  String checkedItems = 'Rp 0,00';

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  void _calculateTotal() {
    double totalChecked = 0;
    double totalUnchecked = 0;
    double totalAll = 0;

    for (var product in widget.productList) {
      double price = double.tryParse(product.price.replaceAll('Rp ', '').replaceAll(',', '').replaceAll('.', '')) ?? 0;
      
      if (product.checked) {
        totalChecked += price;
      } else {
        totalUnchecked += price;
      }

      totalAll += price;
    }

    setState(() {
      totalAmount = 'Rp ${totalAll.toStringAsFixed(2).replaceAll('.', ',')}';
      checkedItems = 'Rp ${totalChecked.toStringAsFixed(2).replaceAll('.', ',')}';
      uncheckedItems = 'Rp ${totalUnchecked.toStringAsFixed(2).replaceAll('.', ',')}';
    });
  }

  void toggleCheck(int index) {
    setState(() {
      widget.productList[index].checked = !widget.productList[index].checked;
    });
    _calculateTotal();
  }

  void addNewList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String expirationDate = DateTime.now().toString().split(' ')[0];
        String price = '';
        File? image;
        String currency = 'Rp';

        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text("Add Product"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: "Name"),
                    controller: TextEditingController(text: name),
                    onChanged: (value) => name = value,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Expiration Date: "),
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
                          expirationDate.isEmpty
                              ? "Select Date"
                              : expirationDate,
                          style: TextStyle(color: Colors.green),
                        ),
                      )
                    ],
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Price"),
                    controller: TextEditingController(text: price),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => price = value,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Image: "),
                      IconButton(
                        icon: Icon(Icons.camera_alt),
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
                        icon: Icon(Icons.photo),
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
                      Text("Currency: "),
                      DropdownButton<String>(
                        value: currency,
                        items: ['Rp', 'USD'].map((String value) {
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
                      )
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: TextStyle(color: Colors.green),),
              ),
              TextButton(
                onPressed: () {
                  if (name.isNotEmpty && expirationDate.isNotEmpty && price.isNotEmpty) {
                    final String addedOn = DateTime.now()
                        .toString()
                        .split(' ')[0];
                    widget.productList.add(Product(
                      name: name,
                      expirationDate: expirationDate,
                      price: price,
                      image: image,
                      currency: currency,
                      checked: false,
                      isInInventory: false,
                      addedOn: addedOn,
                    ));
                    _calculateTotal();
                    Navigator.pop(context);
                  }
                },
                child: Text('Save', style: TextStyle(color: Colors.green),),
              ),
            ],
          );
        });
      },
    );
  }

  List<Product> getFilteredList() {
    String query = _searchController.text.toLowerCase();
    return widget.productList.where((product) {
      return product.name.toLowerCase().contains(query);
    }).toList();
  }

  String formatPrice(String price, String currency) {
    double priceValue = double.tryParse(price.replaceAll('Rp ', '').replaceAll(',', '').replaceAll('.', '')) ?? 0;
    var formatter = NumberFormat.simpleCurrency(locale: 'id_ID', name: currency);
    if (currency == 'USD') {
      formatter = NumberFormat.simpleCurrency(locale: 'en_US', name: 'USD');
    }
    return formatter.format(priceValue);
  }

  void editProduct(int index) {
    Product product = widget.productList[index];
    String name = product.name;
    String expirationDate = product.expirationDate;
    String price = product.price;
    File? image = product.image;
    String currency = product.currency;
    String addedOn = product.addedOn;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Edit Product'),
              content: Column(
                children: [
                  TextField(
                    controller: TextEditingController(text: name),
                    decoration: InputDecoration(labelText: 'Product Name'),
                    onChanged: (value) {
                      name = value;
                    },
                  ),
                  Row(
                    children: [
                      Text('Expiration Date: '),
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
                        child: Text(expirationDate.isEmpty ? 'Select Date' : expirationDate, style: TextStyle(color: Colors.green),),
                      ),
                    ],
                  ),
                  TextField(
                    controller: TextEditingController(text: price),
                    decoration: InputDecoration(labelText: 'Price'),
                    onChanged: (value) {
                      price = value;
                    },
                  ),
                  Row(
                    children: [
                      Text("Image: "),
                      IconButton(
                        icon: Icon(Icons.camera),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.camera);
                          if (pickedFile != null) {
                            setStateDialog(() {
                              image = File(pickedFile.path);
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.photo_library),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setStateDialog(() {
                              image = File(pickedFile.path);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Currency: '),
                      DropdownButton<String>(
                        value: currency,
                        items: ['Rp', 'USD'].map((String value) {
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
                  Row(
                    children: [
                      Text('Added On: '),
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
                              addedOn = picked.toString().split(' ')[0];
                            });
                          }
                        },
                        child: Text(addedOn, style: TextStyle(color: Colors.green),),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.green),),
                ),
                TextButton(
                  onPressed: () {
                    if (name.isNotEmpty && expirationDate.isNotEmpty && price.isNotEmpty) {
                      setState(() {
                        widget.productList[index] = Product(
                          name: name,
                          expirationDate: expirationDate,
                          price: price,
                          image: image,
                          currency: currency,
                          checked: widget.productList[index].checked,
                          isInInventory: widget.productList[index].isInInventory,
                          addedOn: addedOn,
                        );
                      });
                      _calculateTotal();
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save', style: TextStyle(color: Colors.green),),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Lists',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.green),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search in the list',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.green),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: getFilteredList().length,
                itemBuilder: (context, index) {
                  var product = getFilteredList()[index]; // Simpan dulu di awal

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Dismissible(
                      key: Key(product.name + product.addedOn),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          // Pake product yang sudah disimpan
                          int originalIndex = widget.productList.indexWhere((p) =>
                              p.name == product.name &&
                              p.addedOn == product.addedOn);

                          if (originalIndex != -1) {
                            widget.productList.removeAt(originalIndex);
                          }
                        });

                        _calculateTotal();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} deleted')),
                        );
                      },
                      child: ListTile(
                        leading: product.image != null
                            ? Image.file(product.image!, width: 50, height: 50, fit: BoxFit.cover)
                            : Icon(Icons.image, size: 50),
                        title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: ${formatPrice(product.price, product.currency)}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Text('Exp: ${product.expirationDate}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Text('Added on: ${product.addedOn}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: () {
                                editProduct(index);
                              },
                            ),
                            Checkbox(
                              value: product.checked,
                              onChanged: (value) {
                                toggleCheck(index);
                              },
                              activeColor: Colors.green,
                            ),
                            IconButton(
                              icon: Icon(Icons.inventory),
                              onPressed: () {
                                if (product.checked) {
                                  widget.addProductToInventory(
                                    product.name,
                                    product.expirationDate,
                                    product.price,
                                    product.image,
                                    product.currency,
                                    product.addedOn,
                                  );
                                  setState(() {
                                    product.isInInventory = true;
                                  });
                                  _showSuccessMessage('${product.name} has been added to inventory');
                                } else {
                                  _showSuccessMessage('Please check the item before adding to inventory');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Text('Unchecked        ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          Text('$uncheckedItems', style: TextStyle(fontSize: 14, color: Colors.black)),
                        ],
                      ),
                      SizedBox(width: 20), 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Text('Checked           ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          Text('$checkedItems', style: TextStyle(fontSize: 14, color: Colors.black)),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Text('Total             ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          Text('$totalAmount', style: TextStyle(fontSize: 14, color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addNewList,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('ADD LIST', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
