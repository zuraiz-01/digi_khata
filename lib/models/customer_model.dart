class Customer {
  final String id;
  final String businessId;
  final String name;
  final String phone;
  final String address;
  final double openingBalance;
  final double totalUdhaar;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.businessId,
    required this.name,
    this.phone = '',
    this.address = '',
    this.openingBalance = 0,
    this.totalUdhaar = 0,
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
      'totalUdhaar': totalUdhaar,
      'createdAt': createdAt,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      businessId: map['businessId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      openingBalance: (map['openingBalance'] ?? 0).toDouble(),
      totalUdhaar: (map['totalUdhaar'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
