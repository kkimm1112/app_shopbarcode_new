import 'package:flutter/material.dart';
import 'dart:io';
import '../helpers/database_helper.dart';
import '../models/product.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseHelper().getAllProducts();
    setState(() {
      _products = products;
    });
  }

  Future<void> _deleteProduct(int id) async {
    await DatabaseHelper().deleteProduct(id);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('สินค้าคงเหลือ')),
      body: _products.isEmpty
          ? Center(child: Text('ยังไม่มีสินค้า'))
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (_, index) {
                final p = _products[index];
                return Card(
                  child: ListTile(
                    leading: p.imagePath.isNotEmpty
                        ? Image.file(File(p.imagePath), width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.inventory),
                    title: Text(p.name),
                    subtitle: Text('ราคา: ฿${p.price} | จำนวน: ${p.quantity}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(p.id!),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
