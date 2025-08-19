import 'package:opration/features/wallets/domain/repositories/wallet_repository.dart';

class SetMainWalletUseCase {
  SetMainWalletUseCase({required this.repository});
  final WalletRepository repository;
  Future<void> call(String walletId) => repository.setMainWallet(walletId);
}
