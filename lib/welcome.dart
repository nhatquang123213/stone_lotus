import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stone_lotus/login.dart';
import 'package:stone_lotus/register_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Ảnh
          Image.asset("assets/images/img.png",
            // height: 500,
            width: Get.width,
            fit: BoxFit.contain,
          ),

          Positioned(
            top: Get.height/2,
            child: SizedBox(
              width: Get.width,
              child: Column(

                children: [
                  // Logo
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.tealAccent.shade100,
                    child: Icon(Icons.eco, color: Colors.teal, size: 40),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    "Stone Lotus",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Serif',
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Nút Đăng nhập
                  SizedBox(
                    width: 260,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00C8B3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Get.to(()=>LoginScreen());
                      },
                      child: const Text("Đăng nhập",style: TextStyle(color: Colors.white),),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Nút Register
                  SizedBox(
                    width: 260,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black87),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Get.to(()=>RegisterScreen());
                      },
                      child: const Text("Đăng ký"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // // Continue as guest
                  // TextButton(
                  //   onPressed: () {},
                  //   child: const Text(
                  //     "Continue as a guest",
                  //     style: TextStyle(color: Colors.teal),
                  //   ),
                  // )
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }


}
