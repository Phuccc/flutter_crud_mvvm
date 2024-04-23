import 'crud.dart';
import 'home_screen.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class SampleItem {
  String id;
  ValueNotifier<String> name;

  SampleItem({String? id, required String name})
      : id = id ?? generateUuid(),
        name = ValueNotifier(name);

  static String generateUuid() {
    return int.parse(
            '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(100000)}')
        .toRadixString(35)
        .substring(0, 9);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.value,
    };
  }

  factory SampleItem.fromJson(Map<String, dynamic> json) {
    return SampleItem(id: json['id'], name: json['name']);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final viewModel = SampleItemViewModel();
  await viewModel
      .loadItemsFromPrefs(); // Khôi phục danh sách từ shared preferences
  runApp(const MaterialApp(
    home: SampleItemListView(),
  ));
}
