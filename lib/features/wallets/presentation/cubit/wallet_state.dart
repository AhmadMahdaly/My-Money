part of 'wallet_cubit.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  const WalletLoaded(this.wallets, {this.showMainWallet = true});
  final List<Wallet> wallets;
  final bool showMainWallet;

  @override
  List<Object> get props => [wallets, showMainWallet];
}

class WalletError extends WalletState {
  const WalletError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
