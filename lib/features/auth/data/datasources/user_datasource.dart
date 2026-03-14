abstract class UserDataSource {
  Future<void> createUserProfile(Map<String, dynamic> userData);
  Future<Map<String, dynamic>> getUserProfile(String uid);
}
