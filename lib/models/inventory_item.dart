class InventoryItem {
  final String name;
  final String expirationDate;
  final String price;
  final String? imagePath;
  final String currency;
  final String addedOn;

  InventoryItem({
    required this.name,
    required this.expirationDate,
    required this.price,
    required this.imagePath,
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

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      name: json['name'],
      expirationDate: json['expirationDate'],
      price: json['price'],
      imagePath: json['imagePath'],
      currency: json['currency'],
      addedOn: json['addedOn'],
    );
  }
}
