import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateProductPage extends StatefulWidget {
  final String productId;
  final String currentName;
  final String currentCategory;
  final double currentPrice;
  final int currentStock;

  UpdateProductPage({
    required this.productId,
    required this.currentName,
    required this.currentCategory,
    required this.currentPrice,
    required this.currentStock,
  });

  @override
  _UpdateProductPageState createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
    _categoryController.text = widget.currentCategory;
    _priceController.text = widget.currentPrice.toString();
    _stockController.text = widget.currentStock.toString();
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final category = _categoryController.text;
      final price = double.parse(_priceController.text);
      final stockQuantity = int.parse(_stockController.text);

      final response = await http.put(
        Uri.parse(
            'http://10.0.2.2:7070/api/products/update/${widget.productId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'category': category,
          'price': price,
          'stockQuantity': stockQuantity,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Formu kapat ve geri dön
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürün başarıyla güncellendi!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürün güncellenirken hata oluştu!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Güncelle'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Ürün Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ürün adı gereklidir';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori gereklidir';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Fiyat',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Fiyat gereklidir';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir fiyat giriniz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: 'Stok Miktarı',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok miktarı gereklidir';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Geçerli bir stok miktarı giriniz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _updateProduct,
                  icon: Icon(Icons.update),
                  label: Text('Ürünü Güncelle'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    backgroundColor: const Color.fromARGB(255, 189, 192,
                        209), // 'primary' yerine 'backgroundColor'
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
