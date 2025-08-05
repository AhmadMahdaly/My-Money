part of 'login_cubit.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  LoginSuccess({required this.username});
  final String username;
}

class LoginFailure extends LoginState {
  LoginFailure({required this.message});
  final String message;
}
