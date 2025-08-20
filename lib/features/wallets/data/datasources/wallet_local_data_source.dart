import 'dart:convert';

import 'package:opration/core/services/cache_helper/cache_values.dart';
import 'package:opration/features/wallets/data/models/wallet_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract class WalletLocalDataSource {
  Future<List<WalletModel>> getWallets();
  Future<void> saveWallets(List<WalletModel> wallets);
  Future<bool> getShowMainWalletPref();
  Future<void> setShowMainWalletPref(bool show);
}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  WalletLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.uuid,
  });
  final SharedPreferences sharedPreferences;
  final Uuid uuid;

  @override
  Future<List<WalletModel>> getWallets() async {
    final jsonString = sharedPreferences.getString(CacheKeys.cachedWallets);
    if (jsonString != null && jsonString.isNotEmpty) {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      final wallets = jsonList
          .map((json) => WalletModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return wallets;
    } else {
      final defaultWallet = WalletModel(
        id: uuid.v4(),
        name: 'الكاش',
        balance: 0,
        isMain: true,
      );

      await saveWallets([defaultWallet]);

      return [defaultWallet];
    }
  }

  @override
  Future<void> saveWallets(List<WalletModel> wallets) {
    final jsonList = wallets.map((wallet) => wallet.toJson()).toList();
    return sharedPreferences.setString(
      CacheKeys.cachedWallets,
      json.encode(jsonList),
    );
  }

  @override
  Future<bool> getShowMainWalletPref() {
    return Future.value(
      sharedPreferences.getBool(CacheKeys.showMainWalletPref) ?? true,
    );
  }

  @override
  Future<void> setShowMainWalletPref(bool show) {
    return sharedPreferences.setBool(CacheKeys.showMainWalletPref, show);
  }
}
