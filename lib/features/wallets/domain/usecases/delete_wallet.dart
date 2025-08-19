import 'package:opration/features/wallets/domain/repositories/wallet_repository.dart';

class DeleteWalletUseCase {
  DeleteWalletUseCase({required this.repository});
  final WalletRepository repository;
  Future<void> call(String walletId) => repository.deleteWallet(walletId);
}
