import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:opration/core/models/app_currency.dart';
import 'package:opration/core/services/app_settings_service.dart';
import 'package:opration/features/auth/data/datasources/login_local_data_source.dart';

part 'login_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.localDataSource}) : super(AuthInitial());
  final AuthLocalDataSource localDataSource;

  Future<void> checkAuthStatus() async {
    try {
      final username = await localDataSource.getUsername();
      if (username != null && username.isNotEmpty) {
        emit(Authenticated(username: username));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> login(
    String username, {
    String currencyCode = kDefaultCurrencyCode,
  }) async {
    if (username.isEmpty) {
      emit(const AuthFailure(message: 'متنساش تسجل اسمك'));
      emit(Unauthenticated());
      return;
    }

    emit(AuthLoading());
    try {
      await AppSettingsService.saveCurrencyCode(currencyCode);
      await localDataSource.saveUsername(username);
      emit(Authenticated(username: username));
    } catch (e) {
      emit(AuthFailure(message: 'فيه غلطة: $e'));
    }
  }

  Future<void> updateUsername(String username) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      emit(const AuthFailure(message: 'متنساش تسجل اسمك'));
      return;
    }

    try {
      await localDataSource.saveUsername(trimmed);
      // await CloudSyncService.touchLocalUpdate();
      emit(Authenticated(username: trimmed));
    } catch (e) {
      emit(AuthFailure(message: 'فيه غلطة: $e'));
    }
  }

  // Future<void> loginWithGoogle({
  //   String currencyCode = kDefaultCurrencyCode,
  // }) async {
  //   emit(AuthLoading());
  //   try {
  //     final userCredential = await CloudAuthService.signInWithGoogle();
  //     final user = userCredential.user;
  //     if (user == null) {
  //       emit(const AuthFailure(message: 'تعذر تسجيل الدخول بجوجل'));
  //       return;
  //     }
  //     await AppSettingsService.saveCurrencyCode(currencyCode);
  //     final hasDisplayName = user.displayName?.trim().isNotEmpty ?? false;
  //     final username = hasDisplayName
  //         ? user.displayName!.trim()
  //         : user.email?.split('@').first ?? 'مستخدم';
  //     await localDataSource.saveUsername(username);
  //     await CloudSyncService.bootstrapSync(uid: user.uid);
  //     emit(Authenticated(username: username));
  //   } catch (e) {
  //     emit(AuthFailure(message: 'فشل تسجيل الدخول بجوجل: $e'));
  //   }
  // }
  // Future<bool> syncToCloud() async {
  //   final user = CloudAuthService.currentUser;
  //   if (user == null) {
  //     emit(const AuthFailure(message: 'سجل دخول بجوجل أولاً للمزامنة'));
  //     return false;
  //   }
  //   try {
  //     await CloudSyncService.pushAllData(uid: user.uid);
  //     return true;
  //   } catch (e) {
  //     emit(AuthFailure(message: 'فشل رفع البيانات: $e'));
  //     return false;
  //   }
  // }
  // Future<bool> restoreFromCloud() async {
  //   final user = CloudAuthService.currentUser;
  //   if (user == null) {
  //     emit(const AuthFailure(message: 'سجل دخول بجوجل أولاً للاسترجاع'));
  //     return false;
  //   }
  //   try {
  //     await CloudSyncService.pullAllData(uid: user.uid);
  //     final username = await localDataSource.getUsername();
  //     emit(Authenticated(username: username ?? user.displayName ?? 'مستخدم'));
  //     return true;
  //   } catch (e) {
  //     emit(AuthFailure(message: 'فشل استرجاع البيانات: $e'));
  //     return false;
  //   }
  // }
  // Future<bool> deleteDataFromCloud() async {
  //   final user = CloudAuthService.currentUser;
  //   if (user == null) {
  //     emit(const AuthFailure(message: 'سجل دخول بجوجل أولاً لحذف البيانات'));
  //     return false;
  //   }
  //   emit(AuthLoading());
  //   try {
  //     await CloudSyncService.deleteCloudData(uid: user.uid);
  //     final username = await localDataSource.getUsername();
  //     emit(Authenticated(username: username ?? user.displayName ?? 'مستخدم'));
  //     return true;
  //   } catch (e) {
  //     emit(AuthFailure(message: 'فشل حذف البيانات من السحابة: $e'));
  //     return false;
  //   }
  // }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      // await CloudAuthService.signOut();
      await localDataSource.clearUsername();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(message: 'فيه غلطة حصلت وأنت بتخرج: $e'));
    }
  }
}
