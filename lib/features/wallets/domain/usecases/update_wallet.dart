import 'package:opration/features/wallets/domain/entities/wallet.dart';
import 'package:opration/features/wallets/domain/repositories/wallet_repository.dart';

class UpdateWalletUseCase {
  UpdateWalletUseCase({required this.repository});
  final WalletRepository repository;
  Future<void> call(Wallet wallet) => repository.updateWallet(wallet);
}
