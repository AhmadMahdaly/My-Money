// ignore_for_file: avoid_positional_boolean_parameters

import 'package:opration/features/wallets/domain/entities/wallet.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getWallets();
  Future<void> addWallet(Wallet wallet);
  Future<void> updateWallet(Wallet wallet);
  Future<void> deleteWallet(String walletId);
  Future<void> setMainWallet(String walletId);
  Future<bool> getShowMainWalletPref();
  Future<void> setShowMainWalletPref(bool show);
}
