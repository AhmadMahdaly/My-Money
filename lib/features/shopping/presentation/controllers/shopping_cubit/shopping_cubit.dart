import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/features/shopping/domain/entities/shopping_item.dart';

part 'shopping_state.dart';

class ShoppingCubit extends Cubit<ShoppingState> {
  ShoppingCubit() : super(const ShoppingState()) {
    loadItems();
  }

  final String _cacheKey = 'cached_shopping_list';
  final String _orderCacheKey = 'cached_category_order';

  void loadItems() {
    final jsonString = CacheHelper.getData(_cacheKey) as String?;
    var loadedItems = <ShoppingItem>[];
    if (jsonString != null && jsonString.isNotEmpty) {
      loadedItems = (json.decode(jsonString) as List)
          .cast<Map<String, dynamic>>()
          .map(ShoppingItem.fromJson)
          .toList();
    }

    final orderString = CacheHelper.getData(_orderCacheKey) as String?;
    var loadedOrder = <String>[];
    if (orderString != null && orderString.isNotEmpty) {
      loadedOrder = List<String>.from(
        json.decode(orderString) as Iterable<dynamic>,
      );
    }

    emit(state.copyWith(items: loadedItems, categoryOrder: loadedOrder));
  }

  Future<void> _saveItems(List<ShoppingItem> items) async {
    final jsonList = items.map((i) => i.toJson()).toList();
    await CacheHelper.saveData(key: _cacheKey, value: json.encode(jsonList));
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

  // دالة إعادة ترتيب كروت المشتريات
  Future<void> reorderShoppingItems(
    int oldIndex,
    int newIndex,
    List<ShoppingItem> activeItems,
  ) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // تعديل الترتيب في القائمة النشطة
    final item = activeItems.removeAt(oldIndex);
    activeItems.insert(newIndex, item);

    // جلب العناصر التي تم شراؤها (لتبقى كما هي في نهاية القائمة)
    final boughtItems = state.items.where((i) => i.isBought).toList();

    // دمج القائمتين وحفظهم
    final updatedList = [...activeItems, ...boughtItems];
    await _saveItems(updatedList);
  }
}
