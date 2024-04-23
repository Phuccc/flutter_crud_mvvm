import 'package:flutter/material.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SampleItemViewModel extends ChangeNotifier {
  static final _instance = SampleItemViewModel._();
  factory SampleItemViewModel() => _instance;
  SampleItemViewModel._();
  final List<SampleItem> items = [];
  final String _prefsKey = 'sample_items';

  Future<void> loadItemsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_prefsKey);
    if (itemsJson != null) {
      final List<dynamic> jsonList = jsonDecode(itemsJson);
      items.clear();
      items.addAll(jsonList.map((itemJson) => SampleItem.fromJson(itemJson)));
      notifyListeners();
    }
  }

  Future<void> saveItemsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<dynamic> jsonList = items.map((item) => item.toJson()).toList();
    final itemsJson = jsonEncode(jsonList);
    await prefs.setString(_prefsKey, itemsJson);
  }

  void addItem(String name) {
    final newItem = SampleItem(name: name);
    items.add(newItem);
    saveItemsToPrefs(); // Lưu danh sách vào shared preferences sau khi thêm mục mới
    notifyListeners();
  }

  void removeItem(String id) {
    items.removeWhere((item) => item.id == id);
    saveItemsToPrefs(); // Lưu danh sách vào shared preferences sau khi xóa mục
    notifyListeners();
  }

  void updateItem(String id, String newName) {
    try {
      final item = items.firstWhere((item) => item.id == id);
      item.name.value = newName;
      saveItemsToPrefs(); // Lưu danh sách vào shared preferences sau khi cập nhật mục
      notifyListeners();
    } catch (e) {
      debugPrint("Không tìm thấy mục với ID $id");
    }
  }
}
