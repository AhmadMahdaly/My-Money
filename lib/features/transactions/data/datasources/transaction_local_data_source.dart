import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:opration/core/services/cache_helper/cache_values.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract class TransactionLocalDataSource {
  Future<List<Transaction>> getTransactions();
  Future<void> saveTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String transactionId);

  Future<List<TransactionCategory>> getCategories();
  Future<void> saveCategory(TransactionCategory category);
  Future<void> updateCategory(TransactionCategory category);
  Future<void> deleteCategory(String categoryId);

  Future<void> saveDateFilter(
    DateTime startDate,
    DateTime endDate,
    PredefinedFilter activeFilter,
  );
  Future<Map<String, dynamic>> getDateFilter();
}

const CACHED_FILTER_START_DATE = 'CACHED_FILTER_START_DATE';
const CACHED_FILTER_END_DATE = 'CACHED_FILTER_END_DATE';
const CACHED_ACTIVE_FILTER = 'CACHED_ACTIVE_FILTER';

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  TransactionLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.uuid,
  });
  final SharedPreferences sharedPreferences;
  final Uuid uuid;

  // Helper to get and decode a list from JSON
  Future<List<Map<String, dynamic>>> _getDecodedList(String key) async {
    final jsonString = sharedPreferences.getString(key);
    if (jsonString != null) {
      return (json.decode(jsonString) as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Helper to encode and save a list to JSON
  Future<void> _saveEncodedList(
    String key,
    List<Map<String, dynamic>> list,
  ) async {
    await sharedPreferences.setString(key, json.encode(list));
  }

  @override
  Future<List<TransactionCategory>> getCategories() async {
    final list = await _getDecodedList(CacheKeys.cachedCategories);
    if (list.isNotEmpty) {
      return list.map(TransactionCategory.fromJson).toList();
    } else {
      // Add default categories on first run
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
          name: 'مواصلات',
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
        TransactionCategory(
          id: uuid.v4(),
          name: 'خروج',
          colorValue: Colors.purple.value,
          type: TransactionType.expense,
        ),
        TransactionCategory(
          id: uuid.v4(),
          name: 'رصيد',
          colorValue: Colors.teal.value,
          type: TransactionType.expense,
        ),
        TransactionCategory(
          id: uuid.v4(),
          name: 'استثمار',
          colorValue: Colors.lime.value,
          type: TransactionType.expense,
        ),
        TransactionCategory(
          id: uuid.v4(),
          name: 'هدايا',
          colorValue: Colors.cyan.value,
          type: TransactionType.expense,
        ),
      ];
      await _saveEncodedList(
        CacheKeys.cachedCategories,
        defaultCategories.map((c) => c.toJson()).toList(),
      );
      return defaultCategories;
    }
  }

  @override
  Future<void> saveCategory(TransactionCategory category) async {
    final list = await _getDecodedList(CacheKeys.cachedCategories);
    list.add(category.toJson());
    await _saveEncodedList(CacheKeys.cachedCategories, list);
  }

  @override
  Future<void> updateCategory(TransactionCategory category) async {
    final list = await _getDecodedList(CacheKeys.cachedCategories);
    final index = list.indexWhere((c) => c['id'] == category.id);
    if (index != -1) {
      list[index] = category.toJson();
      await _saveEncodedList(CacheKeys.cachedCategories, list);
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final list = await _getDecodedList(CacheKeys.cachedCategories);
    list.removeWhere((c) => c['id'] == categoryId);
    await _saveEncodedList(CacheKeys.cachedCategories, list);

    // Also delete transactions associated with this category
    final transactions = await _getDecodedList(CacheKeys.cachedTransactions);
    transactions.removeWhere((t) => t['categoryId'] == categoryId);
    await _saveEncodedList(CacheKeys.cachedTransactions, transactions);
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    final list = await _getDecodedList(CacheKeys.cachedTransactions);
    return list.map(Transaction.fromJson).toList();
  }

  @override
  Future<void> saveTransaction(Transaction transaction) async {
    final list = await _getDecodedList(CacheKeys.cachedTransactions);
    list.add(transaction.toJson());
    await _saveEncodedList(CacheKeys.cachedTransactions, list);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final list = await _getDecodedList(CacheKeys.cachedTransactions);
    final index = list.indexWhere((t) => t['id'] == transaction.id);
    if (index != -1) {
      list[index] = transaction.toJson();
      await _saveEncodedList(CacheKeys.cachedTransactions, list);
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    final list = await _getDecodedList(CacheKeys.cachedTransactions);
    list.removeWhere((t) => t['id'] == transactionId);
    await _saveEncodedList(CacheKeys.cachedTransactions, list);
  }

  @override
  Future<void> saveDateFilter(
    DateTime startDate,
    DateTime endDate,
    PredefinedFilter activeFilter,
  ) async {
    await sharedPreferences.setString(
      CACHED_FILTER_START_DATE,
      startDate.toIso8601String(),
    );
    await sharedPreferences.setString(
      CACHED_FILTER_END_DATE,
      endDate.toIso8601String(),
    );
    await sharedPreferences.setString(CACHED_ACTIVE_FILTER, activeFilter.name);
  }

  @override
  Future<Map<String, dynamic>> getDateFilter() async {
    final startDateString = sharedPreferences.getString(
      CACHED_FILTER_START_DATE,
    );
    final endDateString = sharedPreferences.getString(CACHED_FILTER_END_DATE);
    final activeFilterString = sharedPreferences.getString(
      CACHED_ACTIVE_FILTER,
    );

    final activeFilter = PredefinedFilter.values.firstWhere(
      (e) => e.name == activeFilterString,
      orElse: () => PredefinedFilter.month,
    );

    return {
      'startDate': startDateString != null
          ? DateTime.parse(startDateString)
          : null,
      'endDate': endDateString != null ? DateTime.parse(endDateString) : null,
      'activeFilter': activeFilter,
    };
  }
}
