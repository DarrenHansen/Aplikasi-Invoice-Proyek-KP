class Invoice {
  int? id;
  String customerName;
  String date;
  double total;

  Invoice({
    this.id,
    required this.customerName,
    required this.date,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'date': date,
      'total': total,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      customerName: map['customer_name'],
      date: map['date'],
      total: map['total'],
    );
  }
}