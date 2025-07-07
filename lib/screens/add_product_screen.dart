import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../helpers/database_helper.dart';
import 'barcode_scan_page.dart'; // 👈 หน้าสแกนที่เราจะสร้าง

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  double? _price;
  int _stock = 1;
  String _barcode = '';
  File? _image;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BarcodeScanPage()),
    );

    if (result != null && result is String) {
      setState(() {
        _barcode = result;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_barcode.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('กรุณาสแกนบาร์โค้ด')));
        return;
      }

      _formKey.currentState!.save();

      final product = Product(
        name: _name!,
        price: _price!,
        barcode: _barcode,
        quantity: _stock,
        imagePath: _image?.path ?? '',
      );

      await DatabaseHelper().insertProduct(product);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เพิ่มสินค้าเรียบร้อย')));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('เพิ่มสินค้าใหม่')),
    body: Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500), // กำหนดความกว้างให้พอดี
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'กรอกข้อมูลสินค้า',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 24),

                    // ช่องกรอกชื่อ
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ชื่อสินค้า',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'กรุณากรอกชื่อสินค้า' : null,
                      onSaved: (value) => _name = value!,
                    ),
                    SizedBox(height: 16),

                    // ช่องกรอกราคา
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ราคา',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'กรุณากรอกราคา' : null,
                      onSaved: (value) => _price = double.tryParse(value!) ?? 0,
                    ),
                    SizedBox(height: 16),

                    // จำนวนสินค้า
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'จำนวนสินค้าในคลัง',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: null,
                      onSaved: (value) => _stock = int.tryParse(value!) ?? 1,
                    ),
                    SizedBox(height: 24),

                    // ปุ่มเลือกรูป + แสดงรูป
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: Icon(Icons.image),
                          label: Text('เลือกรูปภาพ'),
                        ),
                        SizedBox(width: 16),
                        _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_image!, width: 80, height: 80, fit: BoxFit.cover),
                              )
                            : Text('ยังไม่ได้เลือกรูป'),
                      ],
                    ),
                    SizedBox(height: 24),

                    // ปุ่มสแกนบาร์โค้ด
                    ElevatedButton.icon(
                      onPressed: _scanBarcode,
                      icon: Icon(Icons.qr_code),
                      label: Text('สแกนบาร์โค้ด'),
                    ),
                    if (_barcode.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text('บาร์โค้ด: $_barcode'),
                      ),
                    SizedBox(height: 32),

                    // ปุ่มส่ง
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('เพิ่มสินค้า'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}


  
}
