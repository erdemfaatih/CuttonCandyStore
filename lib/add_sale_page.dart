import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_list_page.dart';

class AddSalePage extends StatefulWidget {
  @override
  _AddSalePageState createState() => _AddSalePageState();
}

class _AddSalePageState extends State<AddSalePage> {
  final TextEditingController _quantitySoldController = TextEditingController();
  final TextEditingController _priceController =
      TextEditingController(); // Yeni eklendi
  String _selectedProductId = "";
  String _selectedProductName = "";

  void _showProductSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListPage(
          onProductSelected: (id, name) {
            setState(() {
              _selectedProductId = id;
              _selectedProductName = name;
            });
          },
        ),
      ),
    );
  }

  Future<void> addSale() async {
    if (_selectedProductId.isEmpty ||
        _quantitySoldController.text.isEmpty ||
        _priceController.text.isEmpty) {
      // Fiyat kontrolü eklendi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:7070/api/sales/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'productId': _selectedProductId,
        'quantitySold': int.parse(_quantitySoldController.text),
        'totalPrice': double.parse(_priceController.text), // Fiyat ekleniyor
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Satış başarıyla eklendi!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Satış eklenirken hata: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satış Ekle'),
        backgroundColor:
            Colors.indigo, // Başlık rengini modern bir tonla değiştir
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Ürün',
                  hintText: 'Bir ürün seçin',
                  labelStyle: TextStyle(color: Colors.indigo),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.indigo),
                    onPressed: _showProductSelection,
                  ),
                ),
                controller: TextEditingController(text: _selectedProductName),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _quantitySoldController,
                decoration: InputDecoration(
                  labelText: 'Satılan Miktar',
                  labelStyle: TextStyle(color: Colors.indigo),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _priceController, // Yeni eklendi
                decoration: InputDecoration(
                  labelText: 'Toplam Fiyat', // Fiyat alanı
                  labelStyle: TextStyle(color: Colors.indigo),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true), // Ondalık sayı desteği
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: addSale,
                  icon: Icon(Icons.add_shopping_cart),
                  label: Text('Satış Ekle'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    backgroundColor: const Color.fromARGB(
                        255, 205, 206, 216), // Buton rengini belirle
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
