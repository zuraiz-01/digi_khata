class Supplier {
  final String id;
  final String businessId;
  final String name;
  final String phone;
  final String address;
  final double openingBalance;
  final double totalPayable;
  final DateTime createdAt;

  Supplier({
    required this.id,
    required this.businessId,
    required this.name,
    this.phone = '',
    this.address = '',
    this.openingBalance = 0,
    this.totalPayable = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'phone': phone,
      'address': address,
      'openingBalance': openingBalance,
      'totalPayable': totalPayable,
      'createdAt': createdAt,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] ?? '',
      businessId: map['businessId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      openingBalance: (map['openingBalance'] ?? 0).toDouble(),
      totalPayable: (map['totalPayable'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
