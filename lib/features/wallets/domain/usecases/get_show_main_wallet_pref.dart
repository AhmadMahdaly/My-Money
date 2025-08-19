import 'package:opration/features/wallets/domain/repositories/wallet_repository.dart';

class GetShowMainWalletPrefUseCase {
  GetShowMainWalletPrefUseCase({required this.repository});
  final WalletRepository repository;
  Future<bool> call() => repository.getShowMainWalletPref();
}
