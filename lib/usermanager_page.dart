import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

final DatabaseReference dbUser = FirebaseDatabase.instance.ref("user");

// ===================== MODEL =====================
enum CustomerStatus { active, inactive }

class Customer {
  final String id;
  final String username;
  final String email;
  final String password;
  final CustomerStatus status;

  Customer({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.status = CustomerStatus.active,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json["id"] ?? "",
      username: json["username"] ?? "",
      email: json["email"] ?? "",
      password: json["password"] ?? "",
      status: CustomerStatus.active,
    );
  }
}

// ===================== MAIN PAGE =====================
class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  List<Customer> _allCustomers = [];
  List<Customer> _filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCustomers();
    _searchController.addListener(_searchCustomer);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============ LẤY DATA Firebase =============
  Future<void> loadCustomers() async {
    final snapshot = await dbUser.get();

    if (!snapshot.exists) return;

    final data = snapshot.value as Map<dynamic, dynamic>;

    final customers = data.entries.map((entry) {
      return Customer.fromJson(
        Map<String, dynamic>.from(entry.value),
      );
    }).toList();

    setState(() {
      _allCustomers = customers.where((e)=>e.username!="admin").toList();
      _filteredCustomers = customers.where((e)=>e.username!="admin").toList();
    });
  }

  // ============ TÌM KIẾM =============
  void _searchCustomer() {
    String keyword = _searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) {
      setState(() => _filteredCustomers = _allCustomers);
      return;
    }

    setState(() {
      _filteredCustomers = _allCustomers.where((customer) {
        return customer.username.toLowerCase().contains(keyword) ||
            customer.email.toLowerCase().contains(keyword);
      }).toList();
    });
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý tài khoản khách hàng"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildHeader(),

          Expanded(
            child: _filteredCustomers.isEmpty
                ? const Center(child: Text("Không tìm thấy khách hàng"))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredCustomers.length,
              itemBuilder: (context, index) {
                return CustomerItem(customer: _filteredCustomers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Nhập tên hoặc email khách hàng...",
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: const [
          Text(
            "Danh sách khách hàng",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ===================== CUSTOMER ITEM =====================
class CustomerItem extends StatelessWidget {
  final Customer customer;

  const CustomerItem({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.blue, size: 28),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.username,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(customer.email,
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),

          CustomerStatusBadge(status: customer.status),
        ],
      ),
    );
  }
}

// ===================== STATUS BADGE =====================
class CustomerStatusBadge extends StatelessWidget {
  final CustomerStatus status;

  const CustomerStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == CustomerStatus.active;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? "Đang hoạt động" : "Đã vô hiệu hoá",
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
