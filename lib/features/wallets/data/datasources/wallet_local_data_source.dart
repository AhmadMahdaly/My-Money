import 'dart:convert';

import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/core/services/cache_helper/cache_values.dart';
import 'package:opration/features/wallets/data/models/transfer_record_model.dart';
import 'package:opration/features/wallets/data/models/wallet_model.dart';
import 'package:uuid/uuid.dart';

abstract class WalletLocalDataSource {
  Future<List<WalletModel>> getWallets();
  Future<void> saveWallets(List<WalletModel> wallets);
  Future<bool> getShowMainWalletPref();
  Future<void> setShowMainWalletPref(bool show);
  Future<void> saveTransferRecord(TransferRecordModel record);
  Future<List<TransferRecordModel>> getTransferHistory();
}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  WalletLocalDataSourceImpl({
    required this.uuid,
  });
  final Uuid uuid;

  @override
  Future<List<WalletModel>> getWallets() async {
    final jsonString = CacheHelper.getData(CacheKeys.cachedWallets) as String?;
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
    return CacheHelper.saveData(
      key: CacheKeys.cachedWallets,
      value: json.encode(jsonList),
    );
  }

  @override
  Future<bool> getShowMainWalletPref() {
    return Future.value(
      CacheHelper.getData(CacheKeys.showMainWalletPref) as bool? ?? true,
    );
  }

  @override
  Future<void> setShowMainWalletPref(bool show) {
    return CacheHelper.saveData(key: CacheKeys.showMainWalletPref, value: show);
  }

  @override
  Future<void> saveTransferRecord(TransferRecordModel record) async {
    final records = await getTransferHistory();
    records.insert(0, record);
    final jsonList = records.map((r) => r.toJson()).toList();
    await CacheHelper.saveData(
      key: 'transfer_history',
      value: json.encode(jsonList),
    );
  }

  @override
  Future<List<TransferRecordModel>> getTransferHistory() async {
    final jsonString = CacheHelper.getData('transfer_history') as String?;
    if (jsonString == null) return [];
    final jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((j) => TransferRecordModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
