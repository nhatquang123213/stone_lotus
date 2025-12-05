import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stone_lotus/login.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final DatabaseReference dbUser = FirebaseDatabase.instance.ref("user");
  bool isPasswordVisible = false;
  bool isRePasswordVisible = false;
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.pop(context),
                ),

                const SizedBox(height: 10),

                // Title
                const Text(
                  "Xin chào! Đăng ký để bắt đầu",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 30),

                // Username
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: "Tên người dùng",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Mật khẩu",
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Confirm Password
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Xác nhận mật khẩu",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isRePasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isRePasswordVisible = !isRePasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // REGISTER button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00C8B3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      String username = usernameController.text.trim();
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();
                      String confirmPassword = confirmPasswordController.text
                          .trim();

                      String? result = await registerUser(
                        username: username,
                        email: email,
                        password: password,
                        confirmPassword: confirmPassword,
                      );

                      if (result == null) {
                        // Thành công
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Đăng ký thành công!")),
                        );

                        Get.to(() => LoginScreen());
                      } else {
                        // Thất bại
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(result)));
                      }
                    },
                    child: const Text(
                      "Đăng ký",
                      style: TextStyle(fontSize: 16,color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 25),



                const SizedBox(height: 25),

                // Google button
                // Center(
                //   child: Container(
                //     padding: const EdgeInsets.all(10),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(12),
                //       border: Border.all(color: Colors.grey.shade300),
                //     ),
                //     child: Image.asset(
                //       'assets/images/google.png',
                //       height: 30,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 40),

                // Already have an account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Đã có tài khoản? "),
                    GestureDetector(
                      onTap: () {
                        Get.offAll(()=>LoginScreen());
                      },
                      child: const Text(
                        "Đăng nhập ngay",
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (username.isEmpty || email.isEmpty || password.isEmpty) {
        return "Vui lòng nhập đầy đủ thông tin";
      }
      if (password != confirmPassword) return "Mật khẩu không khớp";
      // Lấy toàn bộ users để kiểm tra email trùng
      final snapshot = await dbUser.get();
      if (snapshot.exists) {
        for (var child in snapshot.children) {
          final data = child.value as Map;
          if (data["email"] == email) {
            return "Email đã tồn tại";
          }
        }
      }
      // Tạo ID tự động
      String userId = dbUser.push().key!;
      await dbUser.child(userId).set({
        "id": userId,
        "username": username,
        "email": email,
        "password": password,
      });
      return null; // null nghĩa là OK
    } catch (e) {
      return "Lỗi đăng ký: $e";
    }
  }
}
