import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SampleItemUpdate extends StatefulWidget {
  final String? initialName;
  const SampleItemUpdate({Key? key, this.initialName}) : super(key: key);

  @override
  State<SampleItemUpdate> createState() => _SampleItemUpdateState();
}

class _SampleItemUpdateState extends State<SampleItemUpdate> {
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.initialName != null ? 'Chỉnh sửa' : 'Thêm mới',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 127, 84, 84),
        actions: [
          IconButton(
            onPressed: () {
              final enteredText = textEditingController.text.trim();
              if (enteredText.isNotEmpty) {
                Navigator.of(context).pop(enteredText);
              } else {
                // Hiển thị cảnh báo nếu không nhập tên
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Cảnh báo'),
                      content: const Text('Tên không được để trống.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Đóng'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: textEditingController,
          decoration: const InputDecoration(
            hintText: 'Nhập tên mục...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

class SampleItemWidget extends StatelessWidget {
  final SampleItem item;
  final VoidCallback? onTap;

  const SampleItemWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: item.name,
      builder: (context, name, child) {
        debugPrint(item.id);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              border: Border.all(
                color: const Color.fromARGB(
                    255, 144, 106, 106), // Màu viền của item
                width: 2.0, // Độ dày của viền
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // Màu đổ bóng
                  spreadRadius: 3, // Bán kính đổ bóng
                  blurRadius: 20, // Độ mờ đổ bóng
                ),
              ],
              borderRadius: BorderRadius.circular(40.0), // Độ cong viền
            ),
            child: ListTile(
              title: Text(name!),
              subtitle: Text(item.id),
              leading: const CircleAvatar(
                foregroundImage: AssetImage('assets/images/logo.jpg'),
              ),
              onTap: onTap,
              trailing: const Icon(Icons.keyboard_arrow_right),
            ),
          ),
        );
      },
    );
  }
}

class SampleItemDetailsView extends StatefulWidget {
  final SampleItem item;

  const SampleItemDetailsView({
    super.key,
    required this.item,
  });

  @override
  State<SampleItemDetailsView> createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  final viewModel = SampleItemViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 232, 232),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 144, 106, 106),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet<String?>(
                context: context,
                builder: (context) =>
                    SampleItemUpdate(initialName: widget.item.name.value),
              ).then((value) {
                if (value != null) {
                  viewModel.updateItem(widget.item.id, value);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Xác nhận xóa"),
                    content: const Text("Bạn có chắc muốn xóa mục này?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Bỏ qua"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Xóa"),
                      ),
                    ],
                  );
                },
              ).then((confirmed) {
                if (confirmed) {
                  Navigator.of(context).pop(true);
                }
              });
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: widget.item.name,
        builder: (_, name, __) {
          return Center(
              child: Text(
            name,
            style: const TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w700,
            ),
          ));
        },
      ),
    );
  }
}

class SampleItemListView extends StatefulWidget {
  const SampleItemListView({super.key});

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  final viewModel = SampleItemViewModel();
  final TextEditingController _searchController = TextEditingController();
  late List<SampleItem> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = viewModel.items; // Bắt đầu với danh sách ban đầu
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = viewModel.items.where((item) {
        final name = item.name.value.toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 232, 232),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 144, 106, 106),
        title: const Text(
          'Manager Document',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white70, // Màu nền
                borderRadius: BorderRadius.circular(20.0), // Bo tròn viền
                border: Border.all(
                  color: const Color.fromARGB(255, 144, 106, 106),
                  width: 2.0, // Độ dày viền
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm...',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 126, 126, 126), // Màu chữ
                  ),
                  border:
                      InputBorder.none, // Loại bỏ viền nội dung của TextField
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0), // Khoảng cách giữa nội dung và viền
                ),
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                return ListView.builder(
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return SampleItemWidget(
                      key: ValueKey(item.id),
                      item: item,
                      onTap: () {
                        Navigator.of(context)
                            .push<bool>(
                          MaterialPageRoute(
                            builder: (context) =>
                                SampleItemDetailsView(item: item),
                          ),
                        )
                            .then((deleted) {
                          if (deleted == true) {
                            viewModel.removeItem(item.id);
                            _onSearchChanged(); // Cập nhật lại danh sách sau khi xóa
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<String?>(
            context: context,
            builder: (context) => const SampleItemUpdate(),
          ).then((value) {
            if (value != null) {
              viewModel.addItem(value);
              _onSearchChanged(); // Cập nhật lại danh sách sau khi th
            }
          });
        },
        backgroundColor: const Color.fromARGB(255, 160, 110, 110),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), // Bo tròn nút
        ), // Màu nền của nút
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Đặt vị trí ở góc phải dưới
    );
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
