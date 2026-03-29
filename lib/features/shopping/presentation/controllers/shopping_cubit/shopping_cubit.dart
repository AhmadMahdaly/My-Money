import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opration/features/shopping/domain/entities/shopping_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shopping_state.dart';

class ShoppingCubit extends Cubit<ShoppingState> {
  ShoppingCubit({required this.sharedPreferences})
    : super(const ShoppingState()) {
    loadItems();
  }

  final SharedPreferences sharedPreferences;
  final String _cacheKey = 'cached_shopping_list';

  void loadItems() {
    final jsonString = sharedPreferences.getString(_cacheKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final list = (json.decode(jsonString) as List)
          .cast<Map<String, dynamic>>()
          .map(ShoppingItem.fromJson)
          .toList();
      emit(state.copyWith(items: list));
    }
  }

  Future<void> _saveItems(List<ShoppingItem> items) async {
    final jsonList = items.map((i) => i.toJson()).toList();
    await sharedPreferences.setString(_cacheKey, json.encode(jsonList));
    emit(state.copyWith(items: items));
  }

  Future<void> addItem(ShoppingItem item) async {
    final updatedList = List<ShoppingItem>.from(state.items)..add(item);
    await _saveItems(updatedList);
  }

  Future<void> markAsBought(String id) async {
    final updatedList = state.items.map((item) {
      if (item.id == id) {
        return item.copyWith(isBought: true);
      }
      return item;
    }).toList();
    await _saveItems(updatedList);
  }

  Future<void> deleteItem(String id) async {
    final updatedList = state.items.where((i) => i.id != id).toList();
    await _saveItems(updatedList);
  }
}

// --- ملف State ---
