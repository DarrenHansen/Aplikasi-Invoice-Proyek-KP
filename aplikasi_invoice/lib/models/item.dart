class Item {
  int? id;
  int invoiceId;
  String productName;
  double price;
  int qty;

  Item({
    this.id,
    required this.invoiceId,
    required this.productName,
    required this.price,
    required this.qty,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'product_name': productName,
      'price': price,
      'qty': qty,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      invoiceId: map['invoice_id'],
      productName: map['product_name'],
      price: map['price'],
      qty: map['qty'],
    );
  }

  // 🔥 TOTAL PER ITEM
  double get total => price * qty;
}