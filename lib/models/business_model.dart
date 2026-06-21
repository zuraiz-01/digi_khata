class Business {
  final String id;
  final String name;
  final String ownerId;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  Business({
    required this.id,
    required this.name,
    required this.ownerId,
    this.phone,
    this.address,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'phone': phone ?? '',
      'address': address ?? '',
      'createdAt': createdAt,
    };
  }

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
