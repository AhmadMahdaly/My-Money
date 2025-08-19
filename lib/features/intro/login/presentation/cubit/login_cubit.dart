import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:opration/features/intro/login/data/datasources/login_local_data_source.dart';

part 'login_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.localDataSource}) : super(AuthInitial());
  final AuthLocalDataSource localDataSource;

  Future<void> checkAuthStatus() async {
    try {
      final username = await localDataSource.getUsername();
      if (username != null && username.isNotEmpty) {
        emit(Authenticated(username: username));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> login(String username) async {
    if (username.isEmpty) {
      emit(const AuthFailure(message: 'Please enter your name.'));
      emit(Unauthenticated());
      return;
    }

    emit(AuthLoading());
    try {
      await localDataSource.saveUsername(username);
      emit(Authenticated(username: username));
    } catch (e) {
      emit(AuthFailure(message: 'An error occurred: $e'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await localDataSource.clearUsername();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(message: 'An error occurred during logout: $e'));
    }
  }
}
