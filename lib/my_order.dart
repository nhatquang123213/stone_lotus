import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:stone_lotus/user/category_page.dart';
import 'package:stone_lotus/checkout_page.dart';
import 'package:stone_lotus/controllers/root.controller.dart';
import 'package:stone_lotus/main.dart';

import 'order_detail.page.dart';

class MyOrdersPage extends StatefulWidget {
  final String userId; // ID user hiện tại
  const MyOrdersPage({super.key, required this.userId});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  final DatabaseReference dbOrder = FirebaseDatabase.instance.ref("order");
  final DatabaseReference dbOrder2 = FirebaseDatabase.instance.ref("order");

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Đơn hàng của tôi"),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Đang vận chuyển"),
              Tab(text: "Đơn đã mua"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrderListTab(
              dbRef: dbOrder,
              statuses: ["1", "2"],
              userId: widget.userId,
            ), // Tab Đang xử lý
            OrderListTab(
              dbRef: dbOrder2,
              statuses: ["3", "4"],
              userId: widget.userId,
            ), // Tab Đang xử lý
          ],
        ),
      ),
    );
  }

  // --------------------------------------
  // STREAM LẤY ĐƠN THEO TRẠNG THÁI
  // --------------------------------------
  Widget buildOrderList(DatabaseReference db, List<String> statuses) {
    return StreamBuilder(
      stream: db.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text("Không có đơn hàng"));
        }
        Map raw = snapshot.data!.snapshot.value as Map;
        final orders = raw.values.where((order) {
          return order["userId"] == widget.userId &&
              statuses.contains(order["status"]);
        }).toList();
        if (orders.isEmpty) {
          return const Center(child: Text("Không có đơn hàng"));
        }
        final data = orders.map((e) => OrderModel.fromJson(e)).toList();
        data.forEach((e) {
          e.products.forEach((__) {
            __.image = base64Decode(__.imageUrl);
          });
        });
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final order = data[index];
            order.orderIdCustom = "DH${index + 1}";
            return orderCard(order);
          },
        );
      },
    );
  }

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
            BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.05)),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo(DateTime.parse(order.createdAt)),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
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

class OrderListTab extends StatefulWidget {
  final DatabaseReference dbRef;
  final List<String> statuses;
  final String? userId;

  const OrderListTab({
    super.key,
    required this.dbRef,
    this.userId,
    required this.statuses,
  });

  @override
  State<OrderListTab> createState() => _OrderListTabState();
}

class _OrderListTabState extends State<OrderListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // GIỮ TAB KHÔNG RELOAD

  @override
  Widget build(BuildContext context) {
    super.build(context); // bắt buộc khi dùng keepalive

    return StreamBuilder(
      stream: widget.dbRef.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text("Không có đơn hàng"));
        }

        Map raw = snapshot.data!.snapshot.value as Map;

        // Filter theo userId và trạng thái
        final orders = raw.values.where((order) {
          return (widget.userId == null
                  ? true
                  : order["userId"] == widget.userId) &&
              widget.statuses.contains(order["status"]);
        }).toList();

        if (orders.isEmpty) {
          return const Center(child: Text("Không có đơn hàng"));
        }

        final data = orders.map((e) => OrderModel.fromJson(e)).toList();
        data.forEach((e) {
          e.products.forEach((__) {
            __.image = base64Decode(__.imageUrl);
          });
        });
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final order = data[index];
            order.orderIdCustom = "DH${index + 1}";
            return orderCard(order);
          },
        );
      },
    );
  }

  Widget orderCard(OrderModel order) {
    if (widget.userId != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...order.products
              .map(
                (e) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ảnh sản phẩm đầu tiên
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          e.image,
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
                              e.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${e.price.toString()} x ${e.quantity.toString()}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tổng ${(int.parse(e.price??"")*e.quantity).toString()} VND",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (["1", "2"].contains(order.status) == false)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorApp,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Viết đánh giá",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      );
    }
    return GestureDetector(
      onTap: () {
        if (RootController.to.isAdmin)
          Get.to(() => OrderDetailPage(order: order));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.05)),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo(DateTime.parse(order.createdAt)),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
}
