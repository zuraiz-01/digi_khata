class LedgerEntry {
  final String id;
  final String businessId;
  final String type;
  final String? partyId;
  final String? partyName;
  final String partyType;
  final double amount;
  final String description;
  final DateTime createdAt;

  LedgerEntry({
    required this.id,
    required this.businessId,
    required this.type,
    this.partyId,
    this.partyName,
    this.partyType = '',
    required this.amount,
    this.description = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'type': type,
      'partyId': partyId ?? '',
      'partyName': partyName ?? '',
      'partyType': partyType,
      'amount': amount,
      'description': description,
      'createdAt': createdAt,
    };
  }

  factory LedgerEntry.fromMap(Map<String, dynamic> map) {
    return LedgerEntry(
      id: map['id'] ?? '',
      businessId: map['businessId'] ?? '',
      type: map['type'] ?? '',
      partyId: map['partyId'] ?? '',
      partyName: map['partyName'] ?? '',
      partyType: map['partyType'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
