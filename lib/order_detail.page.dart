import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stone_lotus/checkout_page.dart';

final DatabaseReference dbOrder = FirebaseDatabase.instance.ref("order");

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Chi tiết đơn hàng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NGÀY ĐẶT HÀNG
            Text(
              "Ngày đặt hàng:   ${formatDate(widget.order.createdAt)}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // THÔNG TIN KHÁCH HÀNG
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thông tin khách hàng",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  rowText("Tên khách hàng:", widget.order.customerName),
                  rowText("Địa chỉ:", widget.order.address),
                  rowText("Số điện thoại:", widget.order.phoneNumber),
                  rowText("Email:", widget.order.email ?? ""),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // THÔNG TIN ĐƠN HÀNG + BADGE MỚI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Thông tin đơn hàng",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                statusBadge(widget.order.status),
              ],
            ),

            const SizedBox(height: 16),

            // MÃ ĐƠN
            Row(
              children: [
                const Text(
                  "Mã đơn hàng:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.order.orderIdCustom ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // DANH SÁCH SẢN PHẨM
            Column(
              children: widget.order.products.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          item.image,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontSize: 15),
                            ),
                            Text(
                              "x${item.quantity}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "${item.price}đ",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Tổng thanh toán
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tổng thanh toán:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                Text(
                  "${widget.order.totalPrice} đ",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Phương thức thanh toán
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Phương thức thanh toán:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                Text(widget.order.paymentMethod),
              ],
            ),

            const SizedBox(height: 30),

            // NÚT DUYỆT
            Center(
              child: SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00C2A0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: () {
                    widget.order.status == "1"
                        ? updateOrderStatus(widget.order.orderId, "2")
                        : widget.order.status == "2"
                        ? updateOrderStatus(widget.order.orderId, "3")
                        : Get.back();
                  },
                  child: Text(
                    widget.order.status == "1"
                        ? "Duyệt"
                        : widget.order.status == "2"
                        ? "Giao thành công"
                        : "Đóng",

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await dbOrder.child(orderId).update({
        "status": newStatus,
        "updatedAt": ServerValue.timestamp,
      });
      setState(() {
        widget.order.status = newStatus;
      });
    } catch (e) {
      print("Lỗi cập nhật trạng thái đơn hàng: $e");
      rethrow;
    }
  }

  Widget rowText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(title)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------
  String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return "${date.day}/${date.month}/${date.year}";
  }
}

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
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}
