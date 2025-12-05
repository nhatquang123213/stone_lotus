import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:stone_lotus/profile_page.dart';
import 'package:stone_lotus/user/category_page.dart';
import 'package:stone_lotus/controllers/root.controller.dart';
import 'package:stone_lotus/order_detail.page.dart';
import 'package:stone_lotus/order_page.dart';
import 'package:stone_lotus/product_page.dart';
import 'package:stone_lotus/size_page.dart';
import 'package:stone_lotus/user/chart.dart';
import 'package:stone_lotus/usermanager_page.dart';
import 'package:stone_lotus/welcome.dart';
// import 'firebase login.dart';
import 'checkout_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp( const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            Get.focusScope?.unfocus();
          },
          child: child,
        );
      },
      title: 'Flutter Demo',
      initialBinding: RootBinding(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class RootBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(RootController());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseReference dbCategory = FirebaseDatabase.instance.ref("category");
  final DatabaseReference dbSize = FirebaseDatabase.instance.ref("size");
  final DatabaseReference dbProduct = FirebaseDatabase.instance.ref("products");

  int totalCategory=0;
  int totalSize=0;
  int totalProduct=0;
  int totalOrder=0;
  int totalUser=0;
  List<OrderModel> orders=[];

  @override
  void initState() {
    super.initState();

    dbCategory.onValue.listen((event) {
      final snapshot = event.snapshot;
      totalCategory= snapshot.children.length;
      setState(() {

      });
    });
    dbSize.onValue.listen((event) {
      final snapshot = event.snapshot;
      totalSize= snapshot.children.length;
      setState(() {

      });
    });
    dbProduct.onValue.listen((event) {
      final snapshot = event.snapshot;
      totalProduct= snapshot.children.length;
      setState(() {

      });
    });

    dbOrder.onValue.listen((event) {
      final snapshot = event.snapshot;
      getOrders().then((__){
        orders=__;
      });
      totalOrder= snapshot.children.length;
      setState(() {

      });
    });

    dbUser.onValue.listen((event) {
      final snapshot = event.snapshot;
      totalUser= snapshot.children.length-1;
      setState(() {

      });
    });
  }

  final DatabaseReference dbOrder = FirebaseDatabase.instance.ref("order");
  final DatabaseReference dbUser = FirebaseDatabase.instance.ref("user");

  Future<List<OrderModel>> getOrders() async {
    final snapshot = await dbOrder.get();

    final data = snapshot.value as Map<dynamic, dynamic>?;

    if (data == null) return [];

    final orders = data.entries.map((entry) {
      return OrderModel.fromJson(
        Map<String, dynamic>.from(entry.value),
      );
    }).toList();

    // Decode Base64 image
    for (var order in orders) {
      for (var p in order.products) {
        p.image = base64Decode(p.imageUrl);
      }
    }

    return orders;
  }


  Stream<List<OrderModel>> getOrdersStream() {
    return dbOrder.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return [];

      final data2= data.entries.map((entry) {
        return OrderModel.fromJson(
          Map<String, dynamic>.from(entry.value),
        );
      }).toList();
      data2.forEach((e){
        e.products.forEach((__){
         __.image=base64Decode(__.imageUrl);
        });
      });
      return data2;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // const Icon(Icons.menu, size: 30),
                  const Text(
                    "Admin",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Get.to(()=>ProfileScreen());
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage("https://cdn2.fptshop.com.vn/unsafe/1920x0/filters:format(webp):quality(75)/small/avatar_hoat_hinh_db4e0e9cf4.jpg"), // đổi ảnh tùy bạn
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// SEARCH BAR

              /// BALANCE CARDS
              Row(
                spacing: 12,
                children: [

                  _infoCard(
                    title: "Sản phẩm",
                    value: totalProduct.toString(),
                    onTap:()=>Get.to(()=>ProductListPage()),
                    icon: Icons.storefront_outlined,
                    color: Colors.teal.shade200,
                  ),
                  _infoCard(
                    title: "Đơn hàng",
                    value: totalOrder.toString(),
                    onTap:()=>Get.to(()=>OrdersPage()),

                    icon: Icons.list_alt,
                    color: Colors.blue.shade200,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard(
                    title: "Danh mục",
                    value: totalCategory.toString(),
                    onTap:()=>Get.to(()=>CategoryManagerPage()),
                    icon: Icons.receipt_long,
                    color: Colors.pink.shade200,
                  ),

                  _infoCard(
                    title: "Khách hàng",
                    value: totalUser.toString(),
                    onTap:()=>Get.to(()=>CustomerListPage()),

                    icon: Icons.person,
                    color: Colors.blue.shade200,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _infoCard(
                title: "Size",
                value: totalSize.toString(),
                onTap:()=>Get.to(()=>SizeManagerPage()),
                icon: Icons.photo_size_select_large,
                color: Colors.pink.shade200,
              ),
              const SizedBox(height: 30),
              OrderStatisticsWidget(),
              /// NEW ORDERS TITLE
              const Text(
                "Đơn hàng mới",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              StreamBuilder<List<OrderModel>>(
                stream: getOrdersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Chưa có đơn hàng nào"));
                  }

                  final orders = snapshot.data!.reversed.toList();

                  Future.delayed(Duration(milliseconds: 1000)).then((_){
                      totalOrder=orders.length;
                  });


                  return Column(children: [...List.generate(
                    orders.length,
                        (index) {
                      final order = orders[index];
                       order.orderIdCustom = "DH${(orders.length)-index}";

                      return GestureDetector(
                        onTap: (){
                          Get.to(()=>OrderDetailPage(order: order,));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric( vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // ẢNH SẢN PHẨM
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  order.products.first.image, // đảm bảo OrderModel có field imageUrl
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(width: 12),

                              // TEXT BÊN TRÁI
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Mã đơn hàng: ${order.orderIdCustom}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text( timeAgo(DateTime.parse(order.createdAt)),   style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),

                              // BADGE "Mới"
                              statusBadge(order.status),
                              const SizedBox(width: 8),
                              // DẤU 3 CHẤM
                              const Icon(Icons.more_horiz, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  )],);
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }


  /// INFO CARD WIDGET
  Widget _infoCard({required String title, required String value, required IconData icon, required Color color,  Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (Get.width-32-20)/2,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  /// TRANSACTION ITEM WIDGET
  Widget _transactionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String date,
    required String amount,
    required Color amountColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor,
            radius: 22,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              color: amountColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


String timeAgo(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inSeconds < 60) return "Vừa xong";
  if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
  if (diff.inHours < 24) return "${diff.inHours} giờ trước";
  if (diff.inDays == 1) return "Hôm qua";
  if (diff.inDays < 7) return "${diff.inDays} ngày trước";
  if (diff.inDays < 30) return "${(diff.inDays / 7).floor()} tuần trước";
  if (diff.inDays < 365) return "${(diff.inDays / 30).floor()} tháng trước";
  return "${(diff.inDays / 365).floor()} năm trước";
}