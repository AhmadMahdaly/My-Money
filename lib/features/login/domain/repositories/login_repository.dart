abstract class LoginRepository {
  Future<void> saveUsername(String username);
  Future<String?> getUsername();
}
