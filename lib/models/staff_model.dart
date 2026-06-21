class StaffMember {
  final String id;
  final String businessId;
  final String name;
  final String email;
  final String role;
  final DateTime addedAt;

  StaffMember({
    required this.id,
    required this.businessId,
    required this.name,
    required this.email,
    required this.role,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'email': email,
      'role': role,
      'addedAt': addedAt,
    };
  }

  factory StaffMember.fromMap(Map<String, dynamic> map) {
    return StaffMember(
      id: map['id'] ?? '',
      businessId: map['businessId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'viewer',
      addedAt: (map['addedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
