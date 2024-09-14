import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SalesStatsPage extends StatefulWidget {
  @override
  _SalesStatsPageState createState() => _SalesStatsPageState();
}

class _SalesStatsPageState extends State<SalesStatsPage> {
  int totalSalesCount = 0;
  double totalSalesAmount = 0.0;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
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
      _fetchSalesSummaryByDate(); // Tarih seçildikten sonra istatistikleri güncelle
    }
  }

  Future<void> _fetchSalesSummaryByDate() async {
    if (_selectedDate == null) return;

    final formattedDate =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    final response = await http.get(Uri.parse(
        'http://10.0.2.2:7070/api/sales/sales-summary-by-date?date=$formattedDate'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        totalSalesCount = data['totalSalesCount'] ?? 0;
        totalSalesAmount = (data['totalSalesAmount'] ?? 0.0).toDouble();
      });
    } else {
      print("Satış istatistikleri yüklenirken hata oluştu: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satış İstatistikleri'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: IconButton(
                onPressed: _selectDate,
                icon: Icon(
                  Icons.calendar_today_rounded,
                  size: 48,
                  color: Colors.blueAccent,
                ),
                splashRadius: 24,
                padding: EdgeInsets.all(12),
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Toplam Satış Sayısı',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '$totalSalesCount',
                          style: TextStyle(
                              fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Toplam Satış Tutarı',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${totalSalesAmount.toStringAsFixed(2)} TL',
                          style: TextStyle(
                              fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
