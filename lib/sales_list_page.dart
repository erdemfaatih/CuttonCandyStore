import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // intl paketini ekledik

class SalesListPage extends StatefulWidget {
  @override
  _SalesListPageState createState() => _SalesListPageState();
}

class _SalesListPageState extends State<SalesListPage> {
  List<dynamic> sales = [];
  Map<String, String> productNames = {};
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchSales();
  }

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:7070/api/products/list'));
    if (response.statusCode == 200) {
      final products = json.decode(response.body) as List;
      setState(() {
        productNames = {for (var p in products) p['id']: p['name']};
      });
    } else {
      print("Ürünler yüklenirken hata oluştu: ${response.body}");
    }
  }

  Future<void> fetchSales() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:7070/api/sales/list'));
    if (response.statusCode == 200) {
      setState(() {
        sales = json.decode(response.body);
      });
    } else {
      print("Satışlar yüklenirken hata oluştu: ${response.body}");
    }
  }

  String formatDate(String date) {
    // Tarihi 'yyyy-MM-dd' formatından DateTime'e dönüştürüyoruz
    DateTime parsedDate = DateTime.parse(date);
    // Tarihi 'dd/MM/yyyy' formatında gösteriyoruz
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, now.month, 1);
    DateTime lastDate = DateTime(now.year, now.month + 1, 0);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _fetchSalesByDate();
    }
  }

  Future<void> _fetchSalesByDate() async {
    if (_selectedDate == null) return;

    final formattedDate =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    final response = await http.get(Uri.parse(
        'http://10.0.2.2:7070/api/sales/sales-by-date?date=$formattedDate'));

    if (response.statusCode == 200) {
      setState(() {
        sales = json.decode(response.body);
      });
    } else {
      print("Satışlar yüklenirken hata oluştu: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Satışlar',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Tooltip(
              message: 'Tarih Seç',
              child: IconButton(
                onPressed: _selectDate,
                icon: Icon(
                  Icons.calendar_today_rounded,
                  size: 36,
                  color: Colors.blueAccent,
                ),
                splashRadius: 28,
                padding: EdgeInsets.all(12),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: sales.isEmpty
                  ? Center(
                      child: Text(
                        'Gösterilecek satış yok',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sales.length,
                      itemBuilder: (context, index) {
                        final sale = sales[index];
                        final productName =
                            productNames[sale['productId']] ?? 'Bilinmiyor';
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          color: Colors.blue[50],
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              productName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.blueAccent),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  'Miktar: ${sale['quantitySold']}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.blueGrey[800]),
                                ),
                                Text(
                                  'Fiyat: ${sale['totalPrice']}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.blueGrey[800]),
                                ),
                                Text(
                                  'Tarih: ${formatDate(sale['saleDate'])}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.blueGrey[800]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
