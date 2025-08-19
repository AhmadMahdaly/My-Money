import 'dart:convert';

import 'package:opration/core/services/cache_helper/cache_values.dart';
import 'package:opration/features/financial_goals/data/models/financial_goal_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FinancialGoalLocalDataSource {
  Future<List<FinancialGoalModel>> getGoals();
  Future<void> saveGoals(List<FinancialGoalModel> goals);
}

class FinancialGoalLocalDataSourceImpl implements FinancialGoalLocalDataSource {
  FinancialGoalLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  @override
  Future<List<FinancialGoalModel>> getGoals() {
    final jsonString = sharedPreferences.getString(
      CacheKeys.cachedFinancialGoals,
    );
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return Future.value(
        jsonList
            .map(
              (json) =>
                  FinancialGoalModel.fromJson(json as Map<String, dynamic>),
            )
            .toList(),
      );
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<void> saveGoals(List<FinancialGoalModel> goals) {
    final jsonList = goals.map((goal) => goal.toJson()).toList();
    return sharedPreferences.setString(
      CacheKeys.cachedFinancialGoals,
      json.encode(jsonList),
    );
  }
}
