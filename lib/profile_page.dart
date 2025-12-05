import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stone_lotus/controllers/root.controller.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:stone_lotus/login.dart';
import 'package:stone_lotus/user/change_password_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool faceIDEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              "Hồ sơ cá nhân",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====== CARD PROFILE ======
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.shade700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        image: DecorationImage(
                          image: getAvatarImage(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Name + username
                     Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            RootController.to.user.username,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            RootController.to.user.email,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ====== MENU LIST ======
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _menuItem(
                      icon: Icons.person_outline,
                      title: "Thông tin cá nhân",
                      subtitle: "Thực hiện thay đổi cho tài khoản của bạn",
                      onTap: () {
                        Get.to(()=>PersonalInfoScreen())?.whenComplete((){
                          Future.delayed(Duration(milliseconds: 1000)).then((_){
                            setState(() {

                            });
                          });

                        });
                      },
                    ),
                    const Divider(),

                    _menuItem(
                      icon: Icons.lock_outline,
                      title: "Đổi mật khẩu",
                      subtitle: "Bảo mật tài khoản của bạn để đảm bảo an toàn",
                      onTap: () {
                        Get.to(()=>ChangePasswordScreen());
                      },
                    ),
                    const Divider(),

                    _menuItem(
                      icon: Icons.logout,
                      title: "Đăng xuất",
                      subtitle: "Đăng xuất khỏi tài khoản",
                      onTap: () {
                        Get.offAll(()=>LoginScreen());
                      },
                      iconColor: Colors.red,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget item chung
  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}


class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  File? avatarFile;
  final picker = ImagePicker();

  final DatabaseReference db = FirebaseDatabase.instance.ref("user");

  // controllers
  final usernameC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();

  UserModel? user;

  @override
  void initState() {
    super.initState();
    user = RootController.to.user;

    /// fill data vào form
    if (user != null) {
      usernameC.text = user!.username;
      phoneC.text = user!.phone ?? "";
      addressC.text = user!.address ?? "";
    }
  }

  // Pick avatar
  Future<void> pickAvatar() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => avatarFile = File(picked.path));
    }
  }

  // Save user update
  Future<void> updateUser() async {
    if (user == null) return;

    final updatedData = {
      "username": usernameC.text.trim(),
      "phone": phoneC.text.trim(),
      "address": addressC.text.trim(),
      "avatar": user!.avatar ?? "",
    };

    // **Upload avatar nếu user chọn ảnh mới**
    if (avatarFile != null) {
      final bytes = await avatarFile!.readAsBytes();         // Đọc file thành bytes
      final base64String = base64Encode(bytes);              // Convert sang base64
      updatedData["avatar"] = base64String;                  // Lưu vào Firebase
    }


    try {
      await db.child(user!.id).update(updatedData);

      /// Update local user
      user = user!.copyWith(
        username: updatedData["username"],
        phone: updatedData["phone"],
        address: updatedData["address"],
        avatar: updatedData["avatar"],
      );

      RootController.to.saveCurrentUser(user!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thành công")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi cập nhật: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xfff8f8f8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Thông tin cá nhân",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      image: DecorationImage(
                        image: getAvatarImage(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: pickAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            _label("Tên tài khoản"),
            _customTextField(usernameC),

            const SizedBox(height: 20),
            _label("Số điện thoại"),
            _customTextField(phoneC),

            const SizedBox(height: 20),
            _label("Địa chỉ"),
            _customTextField(addressC),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff00bfa5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Lưu thay đổi",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
  );

  ImageProvider getAvatarImage() {
    if (avatarFile != null) {
      return FileImage(avatarFile!);
    }

    if (user?.avatar != null && user!.avatar!.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(user!.avatar!));
      } catch (e) {
        print("Avatar base64 decode error: $e");
      }
    }

    // Avatar mặc định
    return const NetworkImage("https://i.imgur.com/BoN9kdC.png");
  }


  Widget _customTextField(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}


ImageProvider getAvatarImage() {
final  user = RootController.to.user;
  if (user?.avatar != null && user!.avatar!.isNotEmpty) {
    try {
      return MemoryImage(base64Decode(user!.avatar!));
    } catch (e) {
      print("Avatar base64 decode error: $e");
    }
  }

  // Avatar mặc định
  return const NetworkImage("https://i.imgur.com/BoN9kdC.png");
}