import 'package:flutter/material.dart';
import 'add_sale_page.dart';
import 'sales_list_page.dart';
import 'product_list_page.dart';
import 'add_product_page.dart';
import 'product_info_page.dart';
import 'sales_stats_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pişmaniye Dükkanı',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 sütunlu grid
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: <Widget>[
            _buildGridItem(
              context,
              icon: Icons.list,
              label: 'Ürünleri Listele',
              page: ProductListPage(onProductSelected: (id, name) {}),
            ),
            _buildGridItem(
              context,
              icon: Icons.add_circle,
              label: 'Ürün Ekle',
              page: AddProductPage(),
            ),
            _buildGridItem(
              context,
              icon: Icons.shopping_cart,
              label: 'Satış Ekle',
              page: AddSalePage(),
            ),
            _buildGridItem(
              context,
              icon: Icons.history,
              label: 'Satışları Görüntüle',
              page: SalesListPage(),
            ),
            _buildGridItem(
              context,
              icon: Icons.info_outline,
              label: 'Ürün Bilgileri',
              page: ProductInfoPage(),
            ),
            _buildGridItem(
              context,
              icon: Icons.bar_chart,
              label: 'Satış İstatistikleri',
              page: SalesStatsPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context,
      {required IconData icon, required String label, required Widget page}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.indigo),
              SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
