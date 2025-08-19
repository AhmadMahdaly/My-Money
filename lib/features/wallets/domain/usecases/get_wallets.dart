import 'package:opration/features/wallets/domain/entities/wallet.dart';
import 'package:opration/features/wallets/domain/repositories/wallet_repository.dart';

class GetWalletsUseCase {
  GetWalletsUseCase({required this.repository});
  final WalletRepository repository;
  Future<List<Wallet>> call() => repository.getWallets();
}
