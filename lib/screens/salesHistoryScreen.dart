// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../models/sales_history.dart';
import '../helpers/database_helper.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  List<SalesHistory> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final data = await DatabaseHelper().getAllSalesHistory();
    setState(() {
      history = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ประวัติการขาย')),
      body: history.isEmpty
          ? Center(child: Text('ยังไม่มีประวัติการขาย'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final sale = history[index];
                return ExpansionTile(
                  title: Text(
                    '🧾 ${sale.dateTime.toLocal().toString().substring(0, 16)} - ฿${sale.total.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: sale.items.map((item) {
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text('จำนวน ${item['qty']} x ฿${item['price']}'),
                      trailing: Text('฿${(item['qty'] * item['price']).toStringAsFixed(2)}'),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
