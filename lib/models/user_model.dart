class UserProfile {
  final String uid;
  final String fullName;
  final String businessName;
  final String phoneNumber;
  final String email;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.businessName,
    required this.phoneNumber,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'businessName': businessName,
      'phoneNumber': phoneNumber,
      'email': email,
      'createdAt': createdAt,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      businessName: map['businessName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
