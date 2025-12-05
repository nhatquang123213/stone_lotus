import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stone_lotus/input.dart';
import 'package:stone_lotus/size_page.dart' hide colorApp;

import 'user/category_page.dart';

/// ===============================
/// FIREBASE REFERENCES
/// ===============================
final DatabaseReference dbCategory = FirebaseDatabase.instance.ref("category");
final DatabaseReference dbSize = FirebaseDatabase.instance.ref("size");
final DatabaseReference dbProduct = FirebaseDatabase.instance.ref("products");

/// ===============================
/// MODELS
/// ===============================

class ProductModel {
  final String? id;
  final String name;
   int quantity;
  final String idProduct;
  final String description;
  final String imageUrl;
   dynamic image;
  final String? size;
  final String? sizeName;
  final String? amount;
  final String? price;
  final String categoryId;

  ProductModel({
    this.id,
    required this.name,
    required this.idProduct,
     this.quantity=1,
    required this.description,
    required this.imageUrl,
     this.image,
     this.sizeName,
    required this.amount,
    required this.price,
    required this.categoryId,  this.size,
  });
  factory ProductModel.fromMap( Map<dynamic, dynamic> data, {String? id,}) {
      return ProductModel(
        id: id ?? data["id"],
        name: data["name"] ?? "",
        idProduct: data["idProduct"] ?? "",
        description: data["description"] ?? "",
        imageUrl: data["imageUrl"] ?? "",
        quantity: data["quantity"] ?? 1,
        size: data["size"]?.toString(),
        sizeName: data["sizeName"]?.toString(),
        amount: data["amount"]?.toString(),
        price: data["price"]?.toString(),
        categoryId: data["categoryId"] ?? "",
      );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'idProduct': idProduct,
      'description': description,
      'sizeName': sizeName,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'size': size,
      'amount': amount,
      'price': price,
      'categoryId': categoryId,
    };
  }
}

/// ===============================
/// STREAM GET CATEGORY LIST
/// ===============================
Stream<List<CategoryModel>> getCategoryList() {
  return dbCategory.onValue.map((event) {
    if (event.snapshot.value == null) return [];

    final map = event.snapshot.value as Map<dynamic, dynamic>;

    return map.entries
        .map(
          (e) => CategoryModel(
            id: e.key,
            name: e.value["name"] ?? "",
            description: e.value["description"] ?? "",
            url: e.value["url"] ?? "",
          ),
        )
        .toList();
  });
}

Future<List<SizeModel>> getSizeList() async {
  final snapshot = await dbSize.get();
  final data = snapshot.value;

  if (data == null) {
    return [];
  }

  final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;

  final a = map.entries.map((e) {
    return SizeModel(
      id: e.key,
      name: e.value["name"] ?? "",
      description: e.value["description"] ?? "",
    );
  }).toList();
  return a;
}

/// ===============================
/// STREAM GET PRODUCT LIST
/// ===============================
  Future<List<ProductModel>> getProductList() async {
    final snapshot = await dbProduct.get();
    if (snapshot.value == null) return [];

    final map = snapshot.value as Map<dynamic, dynamic>;

    final a= map.entries
        .map((e) {
      final b= ProductModel.fromMap( e.value,id: e.key,);
      return b;
    })
        .toList();
    return a;

  }

/// ===============================
/// PRODUCT LIST PAGE
/// ===============================
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = []; // danh sách hiển thị sau khi tìm kiếm
  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Lắng nghe danh sách sản phẩm từ Firebase
    dbProduct.onValue.listen((event) {
      getProductList().then((__) {
        products = __;
        filteredProducts = products;
        setState(() {});
      });
    });

    getProductList().then((__) {
      products = __;
      filteredProducts = products;
      setState(() {});
    });

    // Lắng nghe thay đổi của ô tìm kiếm
    searchCtrl.addListener(() {
      final query = searchCtrl.text.toLowerCase();
      setState(() {
        if (query.isEmpty) {
          filteredProducts = products;
        } else {
          filteredProducts = products
              .where((p) => p.name.toLowerCase().contains(query))
              .toList();
        }
      });
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
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
            "Quản lý sản phẩm",
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
              // TextField tìm kiếm
              TextField(
                controller: searchCtrl,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm sản phẩm...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Danh sách sản phẩm
              Expanded(
                child: filteredProducts.isEmpty
                    ? const Center(child: Text("Chưa có sản phẩm."))
                    : ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (_, i) =>
                      _productItem(context, filteredProducts[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productItem(BuildContext context, ProductModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              base64Decode(p.imageUrl),
              width: 70,
              height: 70,
            ),
          ),
          const SizedBox(width: 15),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  p.idProduct,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddProductPage(item: p)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => dbProduct.child(p.id ?? "").remove(),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// ADD OR EDIT PRODUCT
/// ===============================
class AddProductPage extends StatefulWidget {
  final ProductModel? item;
  const AddProductPage({super.key, this.item});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameCtrl = TextEditingController();
  final idCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  String? categoryId;
  String? sizeId;
  String imageUrl = "";
  List<SizeModel> sizes = [];
  @override
  void initState() {
    getSizeList().then((__) {
      sizes = __;
      setState(() {});
    });
    super.initState();
    if (widget.item != null) {
      final p = widget.item!;
      nameCtrl.text = p.name;
      idCtrl.text = p.idProduct;
      descCtrl.text = p.description;
      categoryId = p.categoryId;
      sizeId = p.size;
      priceCtrl.text = p.price??"";
      amountCtrl.text = p.amount??"";
      imageUrl = p.imageUrl;
    }
  }

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
            "Thêm / Sửa sản phẩm",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        titleSpacing: 0,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
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
                      _submit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorApp,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      widget.item != null ? "Sửa danh mục" : "Thêm sản phẩm",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.add_a_photo, size: 40)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              AppInput(
                title: "Tên sản phẩm *",
                controller: nameCtrl,
                subtitle: "Nhập tên sản phẩm",
              ),
              const SizedBox(height: 15),
              AppInput(
                title: "Mã sản phẩm *",
                controller: idCtrl,
                subtitle: "Nhập mã sản phẩm",
              ),
              const SizedBox(height: 15),
              StreamBuilder<List<CategoryModel>>(
                stream: getCategoryList(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final list = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "Danh mục sản phẩm *",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,

                          hint: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Danh mục sản phẩm',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: list
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item.id,
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          value: categoryId,
                          onChanged: (String? value) {
                            setState(() {
                              categoryId = value;
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: Get.width,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black38),
                            ),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(Icons.keyboard_arrow_down),
                            iconSize: 14,
                            iconEnabledColor: Colors.black,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 200,
                            width: Get.width - 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            offset: const Offset(0, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: MaterialStateProperty.all<double>(6),
                              thumbVisibility: MaterialStateProperty.all<bool>(
                                true,
                              ),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.only(left: 14, right: 14),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Size *",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,

                      hint: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Size sản phẩm',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      items: sizes
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      value: sizeId,
                      onChanged: (String? value) {
                        setState(() {
                          sizeId = value;
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        height: 50,
                        width: Get.width,
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black38),
                        ),
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(Icons.keyboard_arrow_down),
                        iconSize: 14,
                        iconEnabledColor: Colors.black,
                        iconDisabledColor: Colors.grey,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        width: Get.width - 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                        ),
                        offset: const Offset(0, 0),
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(40),
                          thickness: MaterialStateProperty.all<double>(6),
                          thumbVisibility: MaterialStateProperty.all<bool>(
                            true,
                          ),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                        padding: EdgeInsets.only(left: 14, right: 14),
                      ),
                    ),
                  ),
                ],
              ),

              AppInput(
                title: "Giá *",
                controller: priceCtrl,
                subtitle: "Nhập giá",

                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              AppInput(
                title: "Số lượng *",
                controller: amountCtrl,
                subtitle: "Nhập số lượng",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              AppInput(
                title: "Mô tả sản phẩm",
                controller: descCtrl,
                subtitle: "Mô tả sản phẩm",
                minLines: 5,
              ),
              // CATEGORY DROPDOWN
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    final desc = descCtrl.text.trim();
    final idProduct = idCtrl.text.trim();
    final product = ProductModel(
      name: name,
      idProduct: idProduct,
      description: desc,
      imageUrl: imageUrl,
      size: sizeId??"",
      sizeName: sizes.firstWhere((e)=>(e.id==sizeId)).name,
      amount: amountCtrl.text.trim(),
      price:priceCtrl.text.trim(),
      categoryId: categoryId??"",
    );

    if (categoryId == null) return;

    if (widget.item == null) {
      // ADD
      String id = dbProduct.push().key!;
      await dbProduct.child(id).set(product.toMap());
    } else {
      // UPDATE
      await dbProduct.child(widget.item!.id ?? "").update(product.toMap());
    }

    Navigator.pop(context);
  }
}

Future<String> imageFileToBase64(String path) async {
  File file = File(path); // dùng file bạn đã upload
  List<int> bytes = await file.readAsBytes();
  String base64String = base64Encode(bytes);
  return base64String;
}
