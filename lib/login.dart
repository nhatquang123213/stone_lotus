import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stone_lotus/controllers/root.controller.dart';
import 'package:stone_lotus/main.dart';
import 'package:stone_lotus/register_page.dart';
import 'package:stone_lotus/user_homepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final DatabaseReference dbUser = FirebaseDatabase.instance.ref("user");
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  Future<Map?> loginUser(String email, String password) async {
    try {
      final snapshot = await dbUser.get();
      if (!snapshot.exists) return null;

      for (var child in snapshot.children) {
        final data = child.value as Map;
        final dbEmail = data['username']?.toString() ?? '';
        final dbPassword = data['password']?.toString() ?? '';

        if (dbEmail == email && dbPassword == password) {
          final user = UserModel.fromJson(data);
          Get.find<RootController>().isAdmin = dbEmail == "admin";
          Get.find<RootController>().saveCurrentUser(user);
          return {"userId": child.key, "email": dbEmail};
        }
      }
      print("Sai email hoặc mật khẩu");
      return null;
    } catch (e) {
      print("Lỗi đăng nhập: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Chào mừng trở lại!\nRất vui được gặp bạn!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            // Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Nhập tên đăng nhập",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Password
            TextField(
              obscureText: !isPasswordVisible,
              controller: passwordController,
              decoration: InputDecoration(
                hintText: "Nhập mật khẩu",
                filled: true,

                fillColor: Colors.grey.shade100,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text("Quên mật khẩu?"),
              ),
            ),

            const SizedBox(height: 10),

            // Button Login
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C8B3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();

                  var result = await loginUser(email, password);

                  if (result != null) {
                    RootController.to.isAdmin
                        ? Get.offAll(() => MyHomePage())
                        : Get.offAll(() => HomePageUser());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Email hoặc mật khẩu không đúng"),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Đăng nhập",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),


            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Chưa có tài khoản? "),
                TextButton(
                  onPressed: () {
                    Get.to(() => RegisterScreen());
                  },
                  child: const Text(
                    "Đăng ký ngay",
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class UserModel {
  final String id;
  final String email;
  final String username;
   String password;
  final String? phone;
  final String? address;
  final String? avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
    this.phone,
    this.address,
    this.avatar,
  });

  factory UserModel.fromJson(Map json) {
    return UserModel(
      id: json["id"],
      email: json["email"],
      username: json["username"],
      password: json["password"],
      phone: json["phone"],
      address: json["address"],
      avatar: json["avatar"],
    );
  }

  UserModel copyWith({
    String? username,
    String? phone,
    String? address,
    String? avatar,
  }) {
    return UserModel(
      id: id,
      email: email,
      username: username ?? this.username,
      password: password,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
    );
  }
}
