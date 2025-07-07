class Product {
  final int? id;
  final String name;
  final double price;
  final String barcode;
  final int quantity;
  final String imagePath;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.barcode,
    required this.quantity,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'barcode': barcode,
      'quantity': quantity,
      'imagePath': imagePath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      barcode: map['barcode'],
      quantity: map['quantity'],
      imagePath: map['imagePath'],
    );
  }
}
