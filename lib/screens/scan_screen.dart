import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/product.dart';
import '../helpers/database_helper.dart';
import '../models/sales_history.dart'; // ต้องสร้างไฟล์นี้ด้วย

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  Map<Product, int> cart = {};
  double total = 0.0;
  bool scanning = true;

  double get tax => total * 0.07;
  double get grandTotal => total + tax;

  void onBarcodeDetected(BarcodeCapture capture) async {
    if (!scanning) return;

    final Barcode? barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final String? code = barcode?.rawValue;
    if (code == null) return;

    scanning = false;

    final allProducts = await DatabaseHelper().getAllProducts();
    final match = allProducts.firstWhere(
      (p) => p.barcode == code,
      orElse: () => Product(name: '', price: 0, barcode: '', quantity: 0, imagePath: ''),
    );

    if (match.name.isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ ไม่พบสินค้านี้')));
    } else if (match.quantity <= 0) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ สินค้าหมดสต็อก')));
    } else {
      setState(() {
        cart.update(match, (value) => value + 1, ifAbsent: () => 1);
        total += match.price;
      });
    }

    await Future.delayed(Duration(seconds: 1));
    scanning = true;
  }

  void removeItem(Product product) {
    setState(() {
      if (cart.containsKey(product)) {
        total -= product.price * cart[product]!;
        cart.remove(product);
      }
    });
  }

  Future<void> confirmSale() async {
    for (var entry in cart.entries) {
      final product = entry.key;
      final count = entry.value;

      final newQty = product.quantity - count;
      await DatabaseHelper().updateProductQuantity(product.id!, newQty);

      if (newQty < 3) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ สินค้า "${product.name}" ใกล้หมด เหลือ $newQty ชิ้น')),
        );
      }
    }

    // 📝 บันทึกประวัติการขาย
    final sale = SalesHistory(
      dateTime: DateTime.now(),
      total: grandTotal,
      items: cart.entries.map((e) => {
        'name': e.key.name,
        'price': e.key.price,
        'qty': e.value,
      }).toList(),
    );
    await DatabaseHelper().insertSalesHistory(sale);

    setState(() {
      cart.clear();
      total = 0;
    });

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ ขายสินค้าสำเร็จ')));
  }

  Widget summaryLine(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text('฿${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ขายสินค้า / สแกน')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: MobileScanner(onDetect: onBarcodeDetected),
          ),
          Divider(),

          // 🛒 แสดงสินค้าในตะกร้า
          Expanded(
            child: cart.isEmpty
                ? Center(child: Text('ยังไม่มีสินค้าในตะกร้า'))
                : ListView(
                    children: cart.entries.map((entry) {
                      final product = entry.key;
                      final qty = entry.value;
                      return ListTile(
                        leading: product.imagePath.isNotEmpty
                            ? Image.file(File(product.imagePath), width: 50, height: 50)
                            : Icon(Icons.inventory),
                        title: Text(product.name),
                        subtitle: Text('จำนวน: $qty x ฿${product.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('฿${(product.price * qty).toStringAsFixed(2)}'),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeItem(product),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),

          // 💰 สรุปราคา + ปุ่ม
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                summaryLine('รวม', total),
                summaryLine('ภาษี 7%', tax),
                summaryLine('รวมสุทธิ', grandTotal, bold: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            cart.clear();
                            total = 0;
                          });
                        },
                        icon: Icon(Icons.cancel),
                        label: Text('ล้างตะกร้า'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: cart.isNotEmpty ? confirmSale : null,
                        icon: Icon(Icons.check),
                        label: Text('ยืนยันการขาย'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
