import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

final DatabaseReference dbOrder =
FirebaseDatabase.instance.ref("order");

class OrderStatisticsWidget extends StatefulWidget {
  const OrderStatisticsWidget({super.key});

  @override
  State<OrderStatisticsWidget> createState() => _OrderStatisticsWidgetState();
}

class _OrderStatisticsWidgetState extends State<OrderStatisticsWidget> {
  Map<String, double> dailyTotals = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadOrderStats();
  }

  Future<void> loadOrderStats() async {
    final snapshot = await dbOrder.get();

    if (!snapshot.exists) {
      setState(() => loading = false);
      return;
    }

    final data = snapshot.value as Map<dynamic, dynamic>;

    Map<String, double> tempTotals = {};

    data.forEach((key, value) {
      final order = Map<String, dynamic>.from(value);

      String createdAt = order["createdAt"];
      double totalPrice =
          double.tryParse(order["totalPrice"].toString()) ?? 0;

      DateTime dt = DateTime.parse(createdAt);
      String formatted = DateFormat("dd/MM").format(dt);

      tempTotals.update(formatted, (v) => v + totalPrice,
          ifAbsent: () => totalPrice);
    });

    setState(() {
      dailyTotals = tempTotals;
      loading = false;
    });
  }

  List<BarChartGroupData> _buildBarGroups() {
    List<double> values =
    dailyTotals.values.map((e) => e / 1000).toList(); // chia 1000 cho đẹp

    return List.generate(values.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i],
            color: Colors.teal,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> labels = dailyTotals.keys.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, spreadRadius: 1),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thống kê doanh thu",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          loading
              ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()))
              : dailyTotals.isEmpty
              ? const SizedBox(
            height: 120,
            child: Center(child: Text("Không có dữ liệu")),
          )
              : SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(
                  topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 100000,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) =>
                          Text("${value.toInt()}k",
                              style: const TextStyle(fontSize: 10)),
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int i = value.toInt();
                        if (i < labels.length) {
                          return Text(labels[i],
                              style: const TextStyle(fontSize: 10));
                        }
                        return const Text("");
                      },
                    ),
                  ),
                ),

                barGroups: _buildBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
