import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stone_lotus/checkout_page.dart';
import 'package:stone_lotus/main.dart';
import 'package:stone_lotus/my_order.dart';

import 'order_detail.page.dart';


class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {

  final DatabaseReference dbOrder = FirebaseDatabase.instance.ref("order");
  final DatabaseReference dbOrder2 = FirebaseDatabase.instance.ref("order");
  final DatabaseReference dbOrder3 = FirebaseDatabase.instance.ref("order");
  final DatabaseReference dbOrder4 = FirebaseDatabase.instance.ref("order");
  final DatabaseReference dbOrder5 = FirebaseDatabase.instance.ref("order");

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Đơn hàng"),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Tất cả"),
              Tab(text: "Mới"),
              Tab(text: "Đang xử lý "),
              Tab(text: "Đã giao"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrderListTab( dbRef: dbOrder, statuses: ["1", "2","3","4"]), // Tab Đang xử lý
            OrderListTab( dbRef: dbOrder2, statuses: ["1"]), // Tab Đang xử lý
            OrderListTab( dbRef: dbOrder2, statuses: ["2"]), // Tab Đang xử lý
            OrderListTab( dbRef: dbOrder2, statuses: ["3"]), // Tab Đang xử lý
            // OrderListTab( dbRef: dbOrder2, statuses: [ "4"]), // Tab Đang xử lý
          ],
        ),
      ),
    );
  }

  // --------------------------------------
  // STREAM LẤY ĐƠN THEO TRẠNG THÁI
  // --------------------------------------
  // --------------------------------------
  // UI CARD LIST ĐƠN HÀNG (Giống UI bạn gửi)
  // --------------------------------------
  Widget orderCard(OrderModel order) {

    return GestureDetector(
      onTap: () {
        // chuyển sang trang chi tiết nếu cần
        // Navigator.push(...)
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.05),
            )
          ],
        ),
        child: Row(
          children: [
            // ảnh sản phẩm đầu tiên
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                order.products.first.image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mã đơn hàng: ${order.orderIdCustom}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo(DateTime.parse(order.createdAt)),
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),

            statusBadge(order.status),
          ],
        ),
      ),
    );
  }

  // --------------------------------------
  // STATUS BADGE
  // --------------------------------------
  Widget statusBadge(String status) {
    String text = "";
    Color color = Colors.grey;

    switch (status) {
      case "1":
        text = "Mới";
        color = const Color(0xFF34C759);
        break;
      case "2":
        text = "Đang xử lý";
        color = const Color(0xFFFFCC00);
        break;
      case "3":
        text = "Đã giao";
        color = const Color(0xFF5856D6);
        break;
      case "4":
        text = "Đã huỷ";
        color = const Color(0xFF8E8E93);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --------------------------------------
  // FORMAT THỜI GIAN
  // --------------------------------------
  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return "Vừa xong";
    if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
    if (diff.inHours < 24) return "${diff.inHours} giờ trước";
    if (diff.inDays == 1) return "Hôm qua";
    if (diff.inDays < 7) return "${diff.inDays} ngày trước";

    return "${date.day}/${date.month}/${date.year}";
  }
}
