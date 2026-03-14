class User {
  String? uid;
  String username;
  String email;
  String branchCode;
  String accountNumber;

  User({
    this.uid,
    required this.username,
    required this.email,
    required this.branchCode,
    required this.accountNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'branchCode': branchCode,
      'accountNumber': accountNumber,
    };
  }

  factory User.fromFirestore(String uid, Map<String, dynamic> data) {
    return User(
      uid: uid,
      username:
          data['username'] ?? data['fullName'] ?? '', // Fallback para fullName
      email: data['email'] ?? '',
      branchCode: data['branchCode'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
    );
  }
}
