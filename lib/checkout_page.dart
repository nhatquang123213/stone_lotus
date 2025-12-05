import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:stone_lotus/controllers/root.controller.dart';
import 'package:stone_lotus/product_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<ProductModel> products;

  const CheckoutPage({super.key, required this.products});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {

  @override
  void initState() {
    super.initState();
  }

  int selectedPayment = 0;

  int getTotalPrice() {
    int total = 0;
    for (var p in widget.products) {
      final price = int.tryParse(p.price ?? "0") ?? 0;
      total += price * p.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = getTotalPrice();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Thanh toán",
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------------- ĐỊA CHỈ GIAO HÀNG ----------------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Địa chỉ giao hàng",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "k14/34 Phan Tứ, Mỹ an, Ngũ Hành Sơn, TP Đà Nẵng",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.edit, size: 18, color: Colors.white),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- MẶT HÀNG ----------------
            Row(
              children: [
                const Text(
                  "Mặt hàng",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    widget.products.length.toString(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // danh sách sản phẩm
            Column(
              children: widget.products
                  .map((p) => _buildCartItem(p))
                  .toList(),
            ),

            const SizedBox(height: 35),

            // ---------------- PHƯƠNG THỨC THANH TOÁN ----------------
            const Text(
              "Phương thức thanh toán",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            _paymentOption(0, "Thanh toán khi nhận hàng", Icons.check_circle),
            const SizedBox(height: 12),
            _paymentOption(1, "Thanh toán ngay bằng chuyển khoản", Icons.account_balance),

            const SizedBox(height: 35),

            // ---------------- THỜI GIAN GIAO HÀNG ----------------
            const Text(
              "Thời gian giao hàng",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "5-7 ngày",
                style: TextStyle(color: Color(0xFF407BFF), fontSize: 15),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Giao hàng vào hoặc trước Thứ Năm, ngày 3 tháng 12 năm 2025",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 35),
          ],
        ),
      ),

      // ---------------- FOOTER ----------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "Tổng cộng:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Text(
                  "$totalPriceđ",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),

            GestureDetector(
              onTap: () async {
                await placeOrder(
                userId: RootController.to.user.id,
                cartProducts: widget.products,
                address: "k14/34 Phan Tứ, Mỹ An, Đà Nẵng",
                paymentMethod: selectedPayment == 0
                    ? "COD"
                    : "BANKING",
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đặt hàng thành công!")),
                );

                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Đặt hàng",
                  style: TextStyle(
                      fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- WIDGET ITEM GIỎ HÀNG ----------------
  Widget _buildCartItem(ProductModel p) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            p.image,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(width: 60, height: 60, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 12),

        // name + quantity buttons
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${p.name}",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                p.sizeName??"",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),

        // Quantity selector
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                if (p.quantity > 1) {
                  setState(() => p.quantity--);
                }
              },
            ),
            Text(
              p.quantity.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                setState(() => p.quantity++);
              },
            ),
          ],
        ),

        const SizedBox(width: 12),

        Text(
          "${p.price}đ",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ---------------- WIDGET PHƯƠNG THỨC THANH TOÁN ----------------
  Widget _paymentOption(int index, String text, IconData icon) {
    bool selected = selectedPayment == index;

    return InkWell(
      onTap: () => setState(() => selectedPayment = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE9EEFF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: selected ? Colors.blue : Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.blue : Colors.black54),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: selected ? Colors.blue : Colors.black87,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> placeOrder({
    required String userId,
    required List<ProductModel> cartProducts,
    required String address,
    required String paymentMethod,
  }) async {
    final DatabaseReference dbOrder = FirebaseDatabase.instance.ref("order");
    // Tính tổng tiền
    int totalPrice = cartProducts.fold(
      0,
          (sum, item) => sum + (int.tryParse(item.price ?? "0") ?? 0) * item.quantity,
    );
    // Tạo ID đơn hàng Firebase
    final orderRef = dbOrder.push();
    final orderId = orderRef.key ?? "";
    final user=RootController.to.user;
    // Tạo OrderModel
    final order = OrderModel(
      orderId: orderId,
      userId: userId,
      products: cartProducts,
      totalPrice: totalPrice,
      paymentMethod: paymentMethod,
      address: address,
      createdAt: DateTime.now().toIso8601String(),
      customerName: user.username,
      email: user.email,
      phoneNumber: user.email,
    );
    // Đẩy lên Firebase
    await orderRef.set(order.toJson());
  }

}


class OrderModel {
  final String orderId;
   String? orderIdCustom;
   String status;
  final String userId;
  final List<ProductModel> products;
  final int totalPrice;
  final String paymentMethod;
  final String customerName;
  final String phoneNumber;
  final String email;
  final String address;
  final String createdAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.products,
    required this.totalPrice,
     this.status="1",
    required this.customerName,
    required this.email,
    required this.paymentMethod,
    required this.phoneNumber,
    required this.address,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "userId": userId,
      "products": products.map((p) => p.toMap()).toList(),
      "totalPrice": totalPrice,
      "paymentMethod": paymentMethod,
      "email": email,
      "customerName": customerName,
      "status": status,
      "phoneNumber": phoneNumber,
      "address": address,
      "createdAt": createdAt,
    };
  }

  factory OrderModel.fromJson(Map<dynamic, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      totalPrice: json['totalPrice'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? '1',
      customerName: json['customerName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      createdAt: json['createdAt'] ?? '',
      products: (json['products'] as List<dynamic>)
          .map((item) => ProductModel.fromMap(Map<dynamic, dynamic>.from(item)))
          .toList(),
    );
  }

}
