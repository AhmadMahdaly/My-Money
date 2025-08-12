import 'package:app_usage/app_usage.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:installed_apps/app_info.dart';
import 'package:opration/features/app_blocker/data/models/app_rule.dart';
import 'package:opration/features/app_blocker/data/repositories/app_repository.dart';
import 'package:opration/features/app_blocker/data/repositories/rules_repository.dart';

part 'blocker_event.dart';
part 'blocker_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required AppRepository appRepository,
    required RulesRepository rulesRepository,
  }) : _appRepository = appRepository,
       _rulesRepository = rulesRepository,
       super(HomeLoading()) {
    on<LoadInstalledApps>(_onLoadInstalledApps);
  }
  final AppRepository _appRepository;
  final RulesRepository _rulesRepository;

  Future<void> _onLoadInstalledApps(
    LoadInstalledApps event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final apps = await _appRepository.getInstalledApps();
      final usageStats = await _appRepository.getUsageStats();
      final rules = _rulesRepository.getAllRules();
      emit(HomeLoaded(apps, usageStats, rules));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
