import 'package:flutter/material.dart';
import 'main.dart';
import 'crud.dart';
import 'details_screen.dart';

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
        backgroundColor: const Color.fromARGB(255, 220, 151, 124),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), // Bo tròn nút
        ), // Màu nền của nút
        child: const Icon(Icons.add),
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

class SampleItemUpdate extends StatefulWidget {
  final String? initialName;
  const SampleItemUpdate({super.key, this.initialName});

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
      body: Container(
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
