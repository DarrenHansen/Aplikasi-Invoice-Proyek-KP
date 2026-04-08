class Item {
  int? id;
  String name;
  double price;
  String category;
  String? description;

  Item({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'description': description,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      category: map['category'],
      description: map['description'],
    );
  }
}
