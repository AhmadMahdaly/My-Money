import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:opration/core/services/cache_helper/cache_values.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract class TransactionLocalDataSource {
  Future<List<Transaction>> getTransactions();
  Future<void> saveTransaction(Transaction transaction);
  Future<List<TransactionCategory>> getCategories();
  Future<void> saveCategory(TransactionCategory category);
  Future<void> saveDateFilter(DateTime startDate, DateTime endDate);
  Future<Map<String, DateTime?>> getDateFilter();
}

const CACHED_FILTER_START_DATE = 'CACHED_FILTER_START_DATE';
const CACHED_FILTER_END_DATE = 'CACHED_FILTER_END_DATE';

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  TransactionLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.uuid,
  });
  final SharedPreferences sharedPreferences;
  final Uuid uuid;

  @override
  Future<List<TransactionCategory>> getCategories() async {
    final jsonString = sharedPreferences.getString(CacheKeys.cachedCategories);
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map(
            (json) =>
                TransactionCategory.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } else {
      final defaultCategories = [
        TransactionCategory(
          id: uuid.v4(),
          name: 'Salary',
          colorValue: Colors.green.value,
          type: TransactionType.income,
        ),
        TransactionCategory(
          id: uuid.v4(),
          name: 'Gift',
          colorValue: Colors.pinkAccent.value,
          type: TransactionType.income,
        ),
        TransactionCategory(
          id: uuid.v4(),
          name: 'Transportation',
          colorValue: Colors.orange.value,
          type: TransactionType.expense,
        ),
        TransactionCategory(
          id: uuid.v4(),
          name: 'Food',
          colorValue: Colors.red.value,
          type: TransactionType.expense,
        ),
        TransactionCategory(
          id: uuid.v4(),
          name: 'Supermarket',
          colorValue: Colors.blue.value,
          type: TransactionType.expense,
        ),
      ];
      final jsonList = defaultCategories.map((c) => c.toJson()).toList();
      await sharedPreferences.setString(
        CacheKeys.cachedCategories,
        json.encode(jsonList),
      );
      return defaultCategories;
    }
  }

  @override
  Future<void> saveCategory(TransactionCategory category) async {
    final categories = await getCategories();
    categories.add(category);
    final jsonList = categories.map((c) => c.toJson()).toList();
    await sharedPreferences.setString(
      CacheKeys.cachedCategories,
      json.encode(jsonList),
    );
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    final jsonString = sharedPreferences.getString(
      CacheKeys.cachedTransactions,
    );
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> saveTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await sharedPreferences.setString(
      CacheKeys.cachedTransactions,
      json.encode(jsonList),
    );
  }

  @override
  Future<void> saveDateFilter(DateTime startDate, DateTime endDate) async {
    await sharedPreferences.setString(
      CACHED_FILTER_START_DATE,
      startDate.toIso8601String(),
    );
    await sharedPreferences.setString(
      CACHED_FILTER_END_DATE,
      endDate.toIso8601String(),
    );
  }

  @override
  Future<Map<String, DateTime?>> getDateFilter() async {
    final startDateString = sharedPreferences.getString(
      CACHED_FILTER_START_DATE,
    );
    final endDateString = sharedPreferences.getString(CACHED_FILTER_END_DATE);
    return {
      'startDate': startDateString != null
          ? DateTime.parse(startDateString)
          : null,
      'endDate': endDateString != null ? DateTime.parse(endDateString) : null,
    };
  }
}
