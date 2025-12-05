import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stone_lotus/checkout_page.dart';
import 'package:stone_lotus/controllers/root.controller.dart';
import 'package:stone_lotus/product_page.dart';
import 'package:stone_lotus/size_page.dart';
import 'package:stone_lotus/user_homepage.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  dynamic image="";
  @override
  void initState() {
   image= base64Decode(widget.product.imageUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F2),
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Image.memory(
                   image,
                    height: 400,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.broken_image, size: 80),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1F2B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // PRICE + RATING
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${product.price ?? "0"}đ",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Color(0xFF6E8A3C),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Row(
                                //   children: const [
                                //     Icon(Icons.star, color: Colors.amber, size: 20),
                                //     SizedBox(width: 5),
                                //     Text(
                                //       "4.9",
                                //       style: TextStyle(
                                //           fontSize: 16, color: Colors.black87),
                                //     ),
                                //   ],
                                // )
                              ],
                            ),

                            // QUANTITY SELECTOR
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9F3DE),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (quantity > 1) {
                                        setState(() => quantity--);
                                      }
                                    },
                                    child: const CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Color(0xFFB7C9A8),
                                      child: Icon(
                                        Icons.remove,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: () {
                                      setState(() => quantity++);
                                    },
                                    child: const CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Color(0xFFB7C9A8),
                                      child: Icon(
                                        Icons.add,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // DESCRIPTION
                        const Text(
                          "Mô tả",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // // SIZE
                        // const Text(
                        //   "Size",
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        // const SizedBox(height: 5),
                        // Text(
                        //   product.size ?? "N/A",
                        //   style: const TextStyle(
                        //     fontSize: 14,
                        //     color: Colors.black54,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Positioned(
              top: 80,
              left: 20,
              child: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFFB7C9A8),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: // BUY NOW
      Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorApp,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 0),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                product.image=base64Decode(product.imageUrl);
                Get.to(()=>CheckoutPage(products: [ product],));
              },
              child: const Text(
                "Mua ngay",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0E8D0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 0),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                final db = FirebaseDatabase.instance.ref();
                final userId=RootController.to.user.id;
                DatabaseReference ref = db.child("cart/$userId/${product.idProduct}");

                final snapshot = await ref.get();

                if (snapshot.exists) {
                  // Sản phẩm đã tồn tại → tăng số lượng
                  int currentQty = snapshot.child("quantity").value as int? ?? 1;

                  await ref.update({"quantity": currentQty + 1});
                } else {
                  // Sản phẩm chưa có → thêm full product data
                  await ref.set(product.toMap());
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã thêm sản phẩm vào giỏ hàng")),
                );
              },
              child: const Text(
                "Thêm vào giỏ hàng",
                style: TextStyle(fontSize: 20, color: Color(0xFF4D6538)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
