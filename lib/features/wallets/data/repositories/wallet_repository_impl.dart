import 'package:opration/features/wallets/data/datasources/wallet_local_data_source.dart';
import 'package:opration/features/wallets/data/models/wallet_model.dart';
import 'package:opration/features/wallets/domain/entities/wallet.dart';
import 'package:opration/features/wallets/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl({required this.localDataSource});
  final WalletLocalDataSource localDataSource;

  @override
  Future<List<Wallet>> getWallets() async {
    final walletModels = await localDataSource.getWallets();

    return List<Wallet>.from(walletModels);
  }

  @override
  Future<void> addWallet(Wallet wallet) async {
    final currentWallets = await localDataSource.getWallets();

    final updatedWallets = List<WalletModel>.from(currentWallets)
      ..add(WalletModel.fromEntity(wallet));

    await localDataSource.saveWallets(updatedWallets);
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    final currentWallets = await localDataSource.getWallets();

    final index = currentWallets.indexWhere((w) => w.id == wallet.id);

    if (index != -1) {
      final updatedWallets = List<WalletModel>.from(currentWallets);

      updatedWallets[index] = WalletModel.fromEntity(wallet);

      await localDataSource.saveWallets(updatedWallets);
    }
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    final currentWallets = await localDataSource.getWallets();

    final walletIndex = currentWallets.indexWhere((w) => w.id == walletId);

    if (walletIndex == -1) return;

    final walletToRemove = currentWallets[walletIndex];

    final updatedWallets = currentWallets
        .where((w) => w.id != walletId)
        .toList();

    if (walletToRemove.isMain && updatedWallets.isNotEmpty) {
      final newMainWalletEntity = updatedWallets.first.copyWith(isMain: true);
      updatedWallets[0] = WalletModel.fromEntity(newMainWalletEntity);
    }

    await localDataSource.saveWallets(updatedWallets);
  }

  @override
  Future<void> setMainWallet(String walletId) async {
    final wallets = await localDataSource.getWallets();

    final updatedWallets = wallets.map((wallet) {
      return WalletModel(
        id: wallet.id,
        name: wallet.name,
        balance: wallet.balance,
        isMain: wallet.id == walletId,
      );
    }).toList();

    await localDataSource.saveWallets(updatedWallets);
  }

  @override
  Future<bool> getShowMainWalletPref() {
    return localDataSource.getShowMainWalletPref();
  }

  @override
  Future<void> setShowMainWalletPref(bool show) {
    return localDataSource.setShowMainWalletPref(show);
  }
}
