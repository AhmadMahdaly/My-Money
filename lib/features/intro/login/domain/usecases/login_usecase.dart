import 'package:opration/features/intro/login/domain/repositories/login_repository.dart';

class LoginUseCase {
  LoginUseCase({required this.repository});
  final LoginRepository repository;

  Future<void> call(String username) async {
    return repository.saveUsername(username);
  }
}
