class InvoiceItem {
  String description;
  double quantity;
  double rate;
  double get amount => quantity * rate;

  InvoiceItem({
    this.description = '',
    this.quantity = 1,
    this.rate = 0,
  });

  Map<String, dynamic> toMap() => {
        'description': description,
        'quantity': quantity,
        'rate': rate,
        'amount': amount,
      };

  factory InvoiceItem.fromMap(Map<String, dynamic> map) => InvoiceItem(
        description: map['description'] ?? '',
        quantity: (map['quantity'] ?? 0).toDouble(),
        rate: (map['rate'] ?? 0).toDouble(),
      );
}

class Invoice {
  final String id;
  final String businessId;
  final String? customerId;
  final String? customerName;
  final String invoiceNumber;
  final List<InvoiceItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  Invoice({
    required this.id,
    required this.businessId,
    this.customerId,
    this.customerName,
    required this.invoiceNumber,
    this.items = const [],
    this.totalAmount = 0,
    this.status = 'unpaid',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'customerId': customerId ?? '',
      'customerName': customerName ?? '',
      'invoiceNumber': invoiceNumber,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] ?? '',
      businessId: map['businessId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      items: (map['items'] as List<dynamic>?)?.map((e) => InvoiceItem.fromMap(e as Map<String, dynamic>)).toList() ?? [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'unpaid',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
