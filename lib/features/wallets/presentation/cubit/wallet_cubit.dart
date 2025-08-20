import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opration/features/wallets/domain/entities/wallet.dart';
import 'package:opration/features/wallets/domain/usecases/add_wallet.dart';
import 'package:opration/features/wallets/domain/usecases/delete_wallet.dart';
import 'package:opration/features/wallets/domain/usecases/get_show_main_wallet_pref.dart';
import 'package:opration/features/wallets/domain/usecases/get_wallets.dart';
import 'package:opration/features/wallets/domain/usecases/set_main_wallet.dart';
import 'package:opration/features/wallets/domain/usecases/set_show_main_wallet_pref.dart';
import 'package:opration/features/wallets/domain/usecases/update_wallet.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit({
    required this.getWalletsUseCase,
    required this.addWalletUseCase,
    required this.updateWalletUseCase,
    required this.deleteWalletUseCase,
    required this.setMainWalletUseCase,
    required this.getShowMainWalletPrefUseCase,
    required this.saveShowMainWalletPrefUseCase,
  }) : super(WalletInitial());
  final GetWalletsUseCase getWalletsUseCase;
  final AddWalletUseCase addWalletUseCase;
  final UpdateWalletUseCase updateWalletUseCase;
  final DeleteWalletUseCase deleteWalletUseCase;
  final SetMainWalletUseCase setMainWalletUseCase;
  final GetShowMainWalletPrefUseCase getShowMainWalletPrefUseCase;
  final SaveShowMainWalletPrefUseCase saveShowMainWalletPrefUseCase;

  Future<void> loadWallets() async {
    try {
      emit(WalletLoading());
      final wallets = await getWalletsUseCase();
      final showMain = await getShowMainWalletPrefUseCase();
      emit(WalletLoaded(wallets, showMainWallet: showMain));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _performOperation(Future<void> Function() operation) async {
    if (state is! WalletLoaded) return;
    final originalWallets = (state as WalletLoaded).wallets;
    try {
      await operation();
      await loadWallets();
    } catch (e) {
      emit(WalletError(e.toString()));
      emit(WalletLoaded(originalWallets));
    }
  }

  Future<void> addWallet(Wallet wallet) async {
    await _performOperation(() => addWalletUseCase(wallet));
  }

  Future<void> updateWallet(Wallet wallet) async {
    await _performOperation(() => updateWalletUseCase(wallet));
  }

  Future<void> deleteWallet(String walletId) async {
    await _performOperation(() => deleteWalletUseCase(walletId));
  }

  Future<void> setMainWallet(String walletId) async {
    await _performOperation(() => setMainWalletUseCase(walletId));
  }

  Future<void> updateWalletBalance(String walletId, double amountChange) async {
    if (state is! WalletLoaded) return;
    final currentState = state as WalletLoaded;
    final wallets = List<Wallet>.from(currentState.wallets);
    final walletIndex = wallets.indexWhere((w) => w.id == walletId);
    if (walletIndex != -1) {
      final oldWallet = wallets[walletIndex];
      final newWallet = oldWallet.copyWith(
        balance: oldWallet.balance + amountChange,
      );
      await updateWallet(newWallet);
    }
  }

  Future<void> toggleShowMainWalletPref() async {
    if (state is! WalletLoaded) return;
    final currentState = state as WalletLoaded;
    final newPref = !currentState.showMainWallet;
    await saveShowMainWalletPrefUseCase(newPref);
    emit(WalletLoaded(currentState.wallets, showMainWallet: newPref));
  }
}
