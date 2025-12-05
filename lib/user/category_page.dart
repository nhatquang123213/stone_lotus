import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stone_lotus/input.dart';
import 'package:stone_lotus/product_page.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String url;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
  });
}

final colorApp = Color(0xFF02897B);

class CategoryManagerPage extends StatefulWidget {
  const CategoryManagerPage({super.key});

  @override
  State<CategoryManagerPage> createState() => _CategoryManagerPageState();
}

class _CategoryManagerPageState extends State<CategoryManagerPage> {
  final DatabaseReference dbCategory = FirebaseDatabase.instance.ref(
    "category",
  );

  String searchText = "";
  bool isLoading = true;
  List<CategoryModel> list = [];
  @override
  void initState() {
    super.initState();
    getCategoryList().then((_) {
      setState(() {
        isLoading = false;
      });
    });
    dbCategory.onValue.listen((event) {
      getCategoryList();
    });
  }

  Future<List<CategoryModel>> getCategoryList() async {
    final snapshot = await dbCategory.get();
    final data = snapshot.value;

    if (data == null) return [];

    final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;

    final a = map.entries.map((e) {
      return CategoryModel(
        id: e.key,
        name: e.value["name"] ?? "",
        description: e.value["description"] ?? "",
        url: e.value["url"] ?? "",
      );
    }).toList();
    list = a;
    setState(() {
      isLoading = false;
    });
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoryPage()),
          );
        },
        backgroundColor: colorApp,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      appBar: AppBar(
        title: Align(
          alignment: AlignmentGeometry.centerLeft,
          child: Text(
            "Quản lý danh mục",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInput(
                subtitle: "Tìm kiếm",
                isSearch: true,
                onChange: (__) {
                  setState(() {
                    searchText = __;
                  });
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (list.isEmpty) {
                      return const Center(child: Text("Không có danh mục"));
                    }

                    return ListView.builder(
                      itemCount: list
                          .where((e) => e.name.contains(searchText))
                          .length,
                      itemBuilder: (context, index) {
                        final item = list
                            .where((e) => e.name.contains(searchText))
                            .toList()[index];
                        return _categoryItem(item, context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryItem(CategoryModel item, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              base64Decode(item.url),
              width: 48,
              gaplessPlayback: true,
              fit: BoxFit.cover,
              height: 48,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddCategoryPage(item: item)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              dbCategory.child(item.id).remove();
            },
          ),
        ],
      ),
    );
  }

  Future<void> deleteCategory(String id) async {
    await dbCategory.child(id).remove();
  }
}

class AddCategoryPage extends StatefulWidget {
  final CategoryModel? item; // null = thêm mới, có data = sửa

  const AddCategoryPage({super.key, this.item});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final DatabaseReference dbCategory = FirebaseDatabase.instance.ref(
    "category",
  );
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      nameCtrl.text = widget.item!.name;
      descCtrl.text = widget.item!.description;
      imageUrl = widget.item!.url;
    }
  }

  String imageUrl = "";
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();

    // Chọn ảnh
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;
    imageUrl = await imageFileToBase64(file.path);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: AlignmentGeometry.centerLeft,
          child: Text(
            widget.item == null ? "Thêm danh mục" : "Chỉnh sửa danh mục",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Stack(
                  children: [
                    Container(
                      height: 170,
                      width: 170,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.add_a_photo, size: 40)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Image.memory(
                                base64Decode(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 16,
                      child: imageUrl.isEmpty
                          ? SizedBox()
                          : Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade900,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppInput(
                title: "Tên danh mục *",
                controller: nameCtrl,
                subtitle: "Nhập tên danh mục",
              ),
              const SizedBox(height: 15),
              AppInput(
                title: "Mô tả danh mục",
                controller: descCtrl,
                subtitle: "Nhập mô tả",
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorApp, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text("Hủy", style: TextStyle(color: colorApp)),
                    ),
                  ),
                  const SizedBox(width: 20),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        String name = nameCtrl.text.trim();
                        String desc = descCtrl.text.trim();
                        if (widget.item == null) {
                          await addCategory(name, desc, imageUrl);
                        } else {
                          await updateCategory(
                            widget.item!.id,
                            name,
                            desc,
                            imageUrl,
                          );
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorApp,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        widget.item != null ? "Sửa danh mục" : "Thêm danh mục",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateCategory(
    String id,
    String name,
    String description,
    String imageUrl,
  ) async {
    await dbCategory.child(id).update({
      "name": name,
      "description": description,
      "url": imageUrl,
    });
  }

  Future<void> addCategory(
    String name,
    String description,
    String imageUrl,
  ) async {
    String id = dbCategory.push().key!;

    await dbCategory.child(id).set({
      "name": name,
      "description": description,
      "url": imageUrl,
    });
  }

  Widget _inputField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
