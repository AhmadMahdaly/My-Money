import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:opration/features/login/domain/usecases/login_usecase.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this.loginUseCase}) : super(LoginInitial());
  final LoginUseCase loginUseCase;

  Future<void> login(String username) async {
    if (username.isEmpty) {
      emit(LoginFailure(message: 'Please enter the username.'));
      return;
    }

    emit(LoginLoading());
    try {
      await loginUseCase.call(username);
      emit(LoginSuccess(username: username));
    } catch (e) {
      emit(LoginFailure(message: 'An error occurred during login.: $e'));
    }
  }
}
