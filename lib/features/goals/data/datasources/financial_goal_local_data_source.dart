import 'dart:convert';

import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/core/services/cache_helper/cache_values.dart';
import 'package:opration/features/goals/data/models/financial_goal_model.dart';

abstract class FinancialGoalLocalDataSource {
  Future<List<FinancialGoalModel>> getGoals();
  Future<void> saveGoals(List<FinancialGoalModel> goals);
}

class FinancialGoalLocalDataSourceImpl implements FinancialGoalLocalDataSource {
  FinancialGoalLocalDataSourceImpl();

  @override
  Future<List<FinancialGoalModel>> getGoals() async {
    final jsonString = await CacheHelper.getData(
      CacheKeys.cachedFinancialGoals,
    );
    if (jsonString != null) {
      final jsonList = json.decode(jsonString.toString()) as List<dynamic>;
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
  Future<bool> saveGoals(List<FinancialGoalModel> goals) async {
    final jsonList = goals.map((goal) => goal.toJson()).toList();
    return CacheHelper.saveData(
      key: CacheKeys.cachedFinancialGoals,
      value: json.encode(jsonList),
    );
  }
}
