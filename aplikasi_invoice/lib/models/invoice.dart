import 'item.dart';

enum PaymentStatus { paid, unpaid }

class InvoiceItem {
  Item item;
  int quantity;

  InvoiceItem({required this.item, required this.quantity});

  double get subtotal => item.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'itemId': item.id,
      'itemName': item.name,
      'price': item.price,
      'quantity': quantity,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map, Item item) {
    return InvoiceItem(item: item, quantity: map['quantity']);
  }
}

class Invoice {
  int? id;
  String invoiceNumber;
  DateTime date;
  int businessId;
  int clientId;
  List<InvoiceItem> items;
  double tax;
  double? discount;
  double total;
  PaymentStatus paymentStatus;
  String? signaturePath;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.date,
    required this.businessId,
    required this.clientId,
    required this.items,
    required this.tax,
    this.discount,
    required this.total,
    required this.paymentStatus,
    this.signaturePath,
  });

  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  double get taxAmount {
    return subtotal * (tax / 100);
  }

  double get discountAmount {
    return discount ?? 0;
  }

  double calculateTotal() {
    return subtotal + taxAmount - discountAmount;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'date': date.toIso8601String(),
      'businessId': businessId,
      'clientId': clientId,
      'items': items.map((e) => e.toMap()).toList(),
      'tax': tax,
      'discount': discount,
      'total': total,
      'paymentStatus': paymentStatus.index,
      'signaturePath': signaturePath,
    };
  }
}
