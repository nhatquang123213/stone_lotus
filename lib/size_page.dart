import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stone_lotus/input.dart';
import 'package:stone_lotus/product_page.dart';

class SizeModel {
  final String id;
  final String name;
  final String description;

  SizeModel({
    required this.id,
    required this.name,
    required this.description,
  });
}

final colorApp= Color(0xFF02897B);

class SizeManagerPage extends StatefulWidget {
  const SizeManagerPage({super.key});

  @override
  State<SizeManagerPage> createState() => _SizeManagerPageState();
}

class _SizeManagerPageState extends State<SizeManagerPage> {
  final DatabaseReference dbCategory = FirebaseDatabase.instance.ref(
    "size",
  );

  String searchText="";
  bool isLoading=false;
  List<SizeModel> list=[];
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading=true;
    });
    getCategoryList().then((_){
      setState(() {
        isLoading=false;
      });
    });
    dbCategory.onValue.listen((event) {
      getCategoryList().then((_){
        Future.delayed(Duration(milliseconds: 1000)).then((_){
          setState(() {
            isLoading=false;
          });
        });

      });
    });
  }

  Future<List<SizeModel>> getCategoryList() async {

    final snapshot = await dbCategory.get();
    final data = snapshot.value;

    if (data == null) {
      setState(() {
        isLoading=false;
      });
      return [];
    }

    final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;

    final a= map.entries.map((e) {
      return SizeModel(
        id: e.key,
        name: e.value["name"] ?? "",
        description: e.value["description"] ?? "",
      );
    }).toList();
    list=a;
    return a;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSizePage()),
          );
        },
        backgroundColor:colorApp,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white,size: 32,),
      ),
      appBar: AppBar(
        title: Align(
          alignment: AlignmentGeometry.centerLeft,
          child: Text(
            "Quản lý size",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInput(subtitle: "Tìm kiếm",isSearch:true,onChange:( __){
                setState(() {
                  searchText=__;
                });
              }),
              const SizedBox(height: 20),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }


                    if (list.isEmpty) {
                      return const Center(child: Text("Không có Size"));
                    }

                    return ListView.builder(
                      itemCount: list.where((e)=>e.name.contains(searchText)).length,
                      itemBuilder: (context, index) {
                        final item =  list.where((e)=>e.name.contains(searchText)).toList()[index];
                        return _categoryItem(item, context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryItem(SizeModel item, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddSizePage(item: item)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              dbCategory.child(item.id).remove();
            },
          ),
        ],
      ),
    );
  }

  Future<void> deleteCategory(String id) async {
    await dbCategory.child(id).remove();
  }
}

class AddSizePage extends StatefulWidget {
  final SizeModel? item; // null = thêm mới, có data = sửa

  const AddSizePage({super.key, this.item});

  @override
  State<AddSizePage> createState() => _AddSizePageState();
}

class _AddSizePageState extends State<AddSizePage> {
  final DatabaseReference dbSize = FirebaseDatabase.instance.ref(
    "size",
  );
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      nameCtrl.text = widget.item!.name;
      descCtrl.text = widget.item!.description;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: AlignmentGeometry.centerLeft,
          child: Text(
            widget.item == null ? "Thêm size" : "Chỉnh sửa size",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppInput(
                title: "Tên size *",
                controller: nameCtrl,
                subtitle: "Nhập tên size",
              ),
              const SizedBox(height: 15),
              AppInput(
                title: "Mô tả size",
                controller: descCtrl,
                subtitle: "Nhập mô tả",
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child:   OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        side:  BorderSide(color: colorApp, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child:  Text("Hủy",style: TextStyle(color: colorApp),),

                    ),
                  ),
                  const SizedBox(width: 20),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        String name = nameCtrl.text.trim();
                        String desc = descCtrl.text.trim();
                        if (widget.item == null) {
                          await addSize(name, desc);
                        } else {
                          await updateSize(widget.item!.id, name, desc);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: colorApp, padding: const EdgeInsets.symmetric(vertical: 8),),
                      child:  Text(widget.item!=null?"Sửa size":"Thêm size",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateSize(
      String id,
      String name,
      String description,
      ) async {
    await dbSize.child(id).update({
      "name": name,
      "description": description,
    });
  }

  Future<void> addSize(String name, String description) async {
    String id = dbSize.push().key!;

    await dbSize.child(id).set({"name": name, "description": description});
  }
}
