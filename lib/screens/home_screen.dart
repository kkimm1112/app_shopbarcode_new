import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'inventory_screen.dart';
import 'scan_screen.dart';
import 'salesHistoryScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS - ระบบคิดเงิน')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // ให้สูงเท่าที่จำเป็น
          children: [
            buildMenuButton(
              context,
              title: '➕ เพิ่มสินค้า',
              color: const Color.fromARGB(255, 140, 115, 243),
              page: AddProductScreen(),
            ),
            const SizedBox(height: 20),
            buildMenuButton(
              context,
              title: '📦 สินค้าคงเหลือ',
              color: const Color.fromARGB(255, 217, 105, 245),
              page: InventoryScreen(),
            ),
            const SizedBox(height: 20),
            buildMenuButton(
              context,
              title: '💳 ขายสินค้า / สแกน',
              color: const Color.fromARGB(255, 255, 108, 233),
              page: ScanScreen(),
            ),
            const SizedBox(height: 20),
            buildMenuButton(
              context,
              title: '🧾 ประวัติการขาย',
              color: const Color.fromARGB(255, 245, 159, 196),
              page: SalesHistoryScreen(),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildMenuButton(BuildContext context,
      {required String title, required Color color, required Widget page}) {
    return SizedBox(
      width: 260,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
