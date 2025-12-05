import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stone_lotus/controllers/root.controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final DatabaseReference dbUser = FirebaseDatabase.instance.ref("user");

  final TextEditingController oldPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  Future<void> changePassword() async {
    final root = Get.find<RootController>();
    final user = root.user;

    if (user == null) {
      Get.snackbar("Lỗi", "Không tìm thấy người dùng!");
      return;
    }

    final oldPass = oldPassController.text.trim();
    final newPass = newPassController.text.trim();
    final confirmPass = confirmPassController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text( "Vui lòng nhập đầy đủ thông tin")),
      );

      // Get.snackbar("Lỗi", "Vui lòng nhập đầy đủ thông tin");
      return;
    }

    if (oldPass != user.password) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text( "Mật khẩu cũ không đúng")),
      );
      // Get.snackbar("Sai mật khẩu", );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text( "Mật khẩu mới không trùng khớp")),
      );
      return;
    }

    try {
      await dbUser.child(user.id).update({"password": newPass});

      // Cập nhật vào RootController
      user.password = newPass;
      root.saveCurrentUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text( "Đổi mật khẩu thành công!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text( "Không thể đổi mật khẩu")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            buildPasswordField(
              controller: oldPassController,
              label: "Mật khẩu cũ",
              isVisible: showOld,
              onToggle: () => setState(() => showOld = !showOld),
            ),
            const SizedBox(height: 16),
            buildPasswordField(
              controller: newPassController,
              label: "Mật khẩu mới",
              isVisible: showNew,
              onToggle: () => setState(() => showNew = !showNew),
            ),
            const SizedBox(height: 16),
            buildPasswordField(
              controller: confirmPassController,
              label: "Xác nhận mật khẩu mới",
              isVisible: showConfirm,
              onToggle: () => setState(() => showConfirm = !showConfirm),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C8B3),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: changePassword,
              child: const Text("Đổi mật khẩu", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}
