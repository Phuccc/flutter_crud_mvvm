import 'package:flutter/material.dart';
import 'main.dart';
import 'home_screen.dart';
import 'crud.dart';

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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 220, 151, 124),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Bo tròn nút
            ),
            child: const Icon(Icons.edit),
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
        ],
      ),
    );
  }
}
