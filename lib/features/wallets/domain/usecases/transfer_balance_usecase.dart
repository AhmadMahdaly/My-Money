import 'package:opration/features/wallets/domain/repositories/wallet_repository.dart';

class TransferBalanceUseCase {
  TransferBalanceUseCase({required this.repository});
  final WalletRepository repository;

  Future<void> call(String fromId, String toId, double amount) {
    return repository.transferBalance(fromId, toId, amount);
  }
}
