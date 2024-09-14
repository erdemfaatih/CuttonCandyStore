import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'update_product_page.dart'; // Import UpdateProductPage

class ProductListPage extends StatefulWidget {
  final Function(String id, String name) onProductSelected;

  ProductListPage({required this.onProductSelected});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:7070/api/products/list'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    } else {
      print("Ürünler yüklenirken hata oluştu: ${response.body}");
    }
  }

  Future<void> _deleteProduct(String productId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:7070/api/products/delete/$productId'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün başarıyla silindi!')),
      );
      // Silme işlemi başarılı, ürünü listeden kaldır
      setState(() {
        products.removeWhere((product) => product['id'] == productId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün silinirken hata oluştu!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürünler Listesi'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: products.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      widget.onProductSelected(product['id'], product['name']);
                      Navigator.pop(context); // Seçim yapıldığında geri dön
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          product['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.indigo,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              'Stok: ${product['stockQuantity']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Fiyat: ${product['price']} ₺',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateProductPage(
                                      productId: product['id'],
                                      currentName: product['name'],
                                      currentCategory: product['category'],
                                      currentPrice: product['price'],
                                      currentStock: product['stockQuantity'],
                                    ),
                                  ),
                                ).then((_) {
                                  // Güncelleme sonrası ürünleri yeniden yükle
                                  fetchProducts();
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Sil'),
                                      content: Text(
                                          '${product['name']} ürününü silmek istediğinize emin misiniz?'),
                                      actions: [
                                        TextButton(
                                          child: Text('İptal'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Sil'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _deleteProduct(product['id']);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
