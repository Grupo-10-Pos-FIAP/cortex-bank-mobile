class User {
  String? uid; // ID do Firebase Auth
  String username;
  String email;

  User({this.uid, required this.username, required this.email});

  Map<String, dynamic> toMap() {
    return {'username': username, 'email': email};
  }

  factory User.fromFirestore(String uid, Map<String, dynamic> data) {
    return User(
      uid: uid,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
    );
  }
}
