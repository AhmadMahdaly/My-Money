// ignore_for_file: avoid_positional_boolean_parameters

import 'package:opration/features/wallets/domain/repositories/wallet_repository.dart';

class SaveShowMainWalletPrefUseCase {
  SaveShowMainWalletPrefUseCase({required this.repository});
  final WalletRepository repository;
  Future<void> call(bool show) => repository.setShowMainWalletPref(show);
}
