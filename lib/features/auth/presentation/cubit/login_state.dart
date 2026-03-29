part of 'login_cubit.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  const Authenticated({required this.username});
  final String username;

  @override
  List<Object?> get props => [username];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  const AuthFailure({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
