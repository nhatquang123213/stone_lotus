import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import 'package:stone_lotus/controllers/root.controller.dart';
import 'package:stone_lotus/my_order.dart';
import 'package:stone_lotus/product_detail_page.dart';
import 'package:stone_lotus/cart_screen.dart';
import 'package:stone_lotus/product_page.dart';
import 'package:stone_lotus/user/category_page.dart';
import 'package:stone_lotus/profile_page.dart';

class HomePageUser extends StatefulWidget {
  const HomePageUser({super.key});

  @override
  State<HomePageUser> createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  late Future<List<ProductModel>> _futureProducts;
  late Future<List<CategoryModel>> _futureCategories;

  final dbProduct = FirebaseDatabase.instance.ref('products');
  final dbCategory = FirebaseDatabase.instance.ref('category');

  int selectedCategoryIndex = 0;
  List<CategoryModel> categoryList = [];

  String searchKeyword = "";

  @override
  void initState() {
    super.initState();
    _futureProducts = getProductList();
    _futureCategories = getCategoryList();
  }

  // ------------------- Lấy sản phẩm -------------------
  Future<List<ProductModel>> getProductList() async {
    final snapshot = await dbProduct.get();
    if (snapshot.value == null) return [];
    final map = snapshot.value as Map<dynamic, dynamic>;

    return map.entries.map((e) {
      return ProductModel.fromMap(e.value, id: e.key.toString());
    }).toList();
  }

  // ------------------- Lấy danh mục -------------------
  Future<List<CategoryModel>> getCategoryList() async {
    final snapshot = await dbCategory.get();
    if (snapshot.value == null) return [];

    final Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
    List<CategoryModel> result = map.entries.map((e) {
      return CategoryModel(
        id: e.key,
        name: e.value["name"] ?? "",
        description: e.value["description"] ?? "",
        url: e.value["url"] ?? "",
      );
    }).toList();

    // ========== ADD TAB "TẤT CẢ" ==========
    result.insert(
      0,
      CategoryModel(id: "all", name: "Tất cả", description: "", url: ""),
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 20),

              // ------------------- FutureBuilder danh mục -------------------
              FutureBuilder<List<CategoryModel>>(
                future: _futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 38,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return SizedBox(height: 38, child: Text('Lỗi: ${snapshot.error}'));
                  }

                  final categories = snapshot.data ?? [];
                  categoryList = categories.map((e)=>e).toList();
                  if(!categoryList.any((e)=>e.id=="all")) {
                    categoryList.insert(0, CategoryModel(id: "all", name: "Tất cả", description: "", url: ""));
                  }

                  //, element)

                  return SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final selected = selectedCategoryIndex == index;
                        final cat = categories[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedCategoryIndex = index);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF445B39) : Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                  color: selected ? Colors.transparent : Colors.grey.shade300),
                            ),
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ------------------- FutureBuilder sản phẩm -------------------
              Expanded(
                child: FutureBuilder<List<ProductModel>>(
                  future: _futureProducts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không có sản phẩm'));
                    }

                    List<ProductModel> products = snapshot.data!;

                    // --------- FILTER CATEGORY ---------
                    if (categoryList.isNotEmpty &&
                        selectedCategoryIndex < categoryList.length) {
                      final selectedCategoryId = categoryList[selectedCategoryIndex].id;

                      if (selectedCategoryId != "all") {
                        products = products
                            .where((p) => p.categoryId == selectedCategoryId)
                            .toList();
                      }
                    }

                    // --------- FILTER SEARCH ---------
                    if (searchKeyword.isNotEmpty) {
                      products = products
                          .where((p) =>
                          p.name.toLowerCase().contains(searchKeyword.toLowerCase()))
                          .toList();
                    }

                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        mainAxisExtent: 220,
                      ),
                      itemBuilder: (context, index) {
                        final p = products[index];
                        return _buildProductItem(p);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ------------------- Header -------------------
  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Xin chào', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(
              RootController.to.user.username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------- SearchBar -------------------
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() => searchKeyword = value.trim());
              },
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- Product Item -------------------
  Widget _buildProductItem(ProductModel p) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4EF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                child: Image.memory(
                  base64Decode(p.imageUrl),
                  width: Get.width,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(p.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5C9AD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          formatPrice(p.price ?? ''),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5C9AD),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child:
                        const Icon(Icons.add, size: 26, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ------------------- Bottom Navigation -------------------
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 12,
            offset: const Offset(0, -1),
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomNavItem(Icons.home, true, () => Get.offAll(() => const HomePageUser())),
          _bottomNavItem(Icons.production_quantity_limits, false,
                  () => Get.to(() => MyOrdersPage(userId: RootController.to.user.id))),
          _bottomNavItem(Icons.shopping_cart_outlined, false,
                  () => Get.to(() =>  CartScreen())),
          _bottomNavItem(Icons.person_outline, false,
                  () => Get.to(() => const ProfileScreen())),
        ],
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, bool selected, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF445B39) : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child:
        Icon(icon, color: selected ? Colors.white : Colors.grey, size: 28),
      ),
    );
  }
}

// ------------------- Format Price -------------------
String formatPrice(String? price) {
  if (price == null || price.isEmpty) return '';
  int value;
  try {
    value = int.parse(price);
  } catch (_) {
    return price;
  }

  if (value >= 1000000) {
    double m = value / 1000000;
    return m % 1 == 0 ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
  } else if (value >= 1000) {
    double k = value / 1000;
    return k % 1 == 0 ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
  } else {
    return value.toString();
  }
}
