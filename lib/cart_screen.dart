import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stone_lotus/controllers/root.controller.dart';
import 'package:stone_lotus/product_page.dart';
import 'package:stone_lotus/profile_page.dart';

import 'checkout_page.dart';

// ===================================================================
//                          CART SERVICE
// ===================================================================
class CartService {
  final db = FirebaseDatabase.instance.ref();

  // Stream giỏ hàng
  Stream<DatabaseEvent> getCartStream(String userId) {
    return db.child("cart/$userId").onValue;
  }

  // ------------------ Tăng số lượng ------------------
  Future<void> increaseQty(String userId, String idProduct) async {
    final ref = db.child("cart/$userId/$idProduct");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      int currentQty = snapshot.child("quantity").value as int? ?? 1;
      await ref.update({"quantity": currentQty + 1});
    } else {
      debugPrint("❗ Không thể tăng số lượng vì sản phẩm chưa có trong giỏ");
    }
  }

  // ------------------ Giảm số lượng ------------------
  Future<void> decreaseQty(String userId, String idProduct) async {
    final ref = db.child("cart/$userId/$idProduct");
    final snapshot = await ref.get();

    if (!snapshot.exists) return;

    int qty = snapshot.child("quantity").value as int? ?? 1;

    if (qty > 1) {
      await ref.update({"quantity": qty - 1});
    } else {
      await ref.remove(); // qty = 1 → xóa luôn
    }
  }

  // ------------------ Xóa sản phẩm ------------------
  Future<void> removeItem(String userId, String idProduct) async {
    await db.child("cart/$userId/$idProduct").remove();
  }
}

// ===================================================================
//                          CART SCREEN
// ===================================================================
class CartScreen extends StatefulWidget {
  CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final String userId = RootController.to.user.id;
  final CartService cartService = CartService();
  List<ProductModel> cartList =[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ==================== APP BAR ====================
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.black)),
        title: const Text("Giỏ hàng",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      // ==================== BODY ====================
      body: StreamBuilder(
        stream: cartService.getCartStream(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Giỏ hàng trống"));
          }

          Map cartMap = snapshot.data!.snapshot.value as Map;

         cartList = cartMap.entries.map((e) {
            return ProductModel.fromMap(Map<String, dynamic>.from(e.value));
          }).toList();

          // Convert base64 thành Uint8List
          for (var item in cartList) {
            item.image = base64Decode(item.imageUrl);
          }

          double total = cartList.fold(
            0,
                (sum, item) =>
            sum + ((int.tryParse(item.price ?? "0") ?? 0) * item.quantity),
          );

          return Column(
            children: [
              _addressCard(),

              Expanded(
                child: ListView.builder(
                  itemCount: cartList.length,
                  itemBuilder: (context, index) {
                    final item = cartList[index];

                    return _cartItem(
                      item,
                      onIncrease: () =>
                          cartService.increaseQty(userId, item.idProduct),
                      onDecrease: () =>
                          cartService.decreaseQty(userId, item.idProduct),
                      onDelete: () =>
                          cartService.removeItem(userId, item.idProduct),
                    );
                  },
                ),
              ),

              _bottomBar(total),
            ],
          );
        },
      ),
    );
  }

  // ===================================================================
  //                        ĐỊA CHỈ GIAO HÀNG
  // ===================================================================
  Widget _addressCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Địa chỉ giao hàng",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(RootController.to.user.address ?? ""),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Get.to(() => PersonalInfoScreen())?.whenComplete(() {
                Future.delayed(const Duration(milliseconds: 100)).then((_) {
                  setState(() {});
                });
              });
            },
            child: const Icon(Icons.edit, color: Colors.cyan),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  //                        ITEM GIỎ HÀNG
  // ===================================================================
  Widget _cartItem(
      ProductModel item, {
        required VoidCallback onIncrease,
        required VoidCallback onDecrease,
        required VoidCallback onDelete,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ==================== Ảnh sản phẩm ====================
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  item.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),

              // Nút xóa
              Positioned(
                top: 6,
                left: 6,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete, color: Colors.red, size: 20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // ==================== Thông tin sản phẩm ====================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("${item.price}đ",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // ==================== Tăng giảm số lượng ====================
          Row(
            children: [
              _qtyBtn(Icons.remove, onDecrease),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                margin:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(8)),
                child: Text("${item.quantity}",
                    style: const TextStyle(color: Colors.white)),
              ),
              _qtyBtn(Icons.add, onIncrease),
            ],
          )
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.cyan),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: Colors.cyan),
      ),
    );
  }

  // ===================================================================
  //                        BOTTOM CHECKOUT BAR
  // ===================================================================
  Widget _bottomBar(double total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tổng cộng:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("$totalđ",
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // product.image=base64Decode(product.imageUrl);
              Get.to(()=>CheckoutPage(products:cartList,));
            },
            child: const Text("Thanh toán",
                style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
