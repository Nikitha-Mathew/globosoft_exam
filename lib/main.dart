import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manshar Cart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Product> products = [];

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(
          'https://mansharcart.com/api/products/category/373/limit/4/key/123456789'));

      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('JSON data: $jsonData');

        setState(() {
          products = (jsonData['products'] as List)
              .map<Product>((json) => Product.fromJson(json))
              .toList();
          print('Products list: $products');
        });
      } else {
        print('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manshar Cart',
          style: TextStyle(color: Colors.blue, fontSize: 25),
        ),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      'https://mansharcart.com/image/${product.thumb}',
                    ),
                    title: Text(product.name),
                    subtitle: Text('Price: ${product.price}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailsPage(product: product),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network('https://mansharcart.com/image/${product.thumb}'),
            SizedBox(height: 16),
            Text(
              product.name,
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 8),
            Text('Price: ${product.price}'),
            SizedBox(height: 8),
            Text('Stock Status: ${product.stockStatus}'),
            SizedBox(height: 8),
            Text('Quantity: ${product.quantity}'),
            SizedBox(height: 8),
            if (product.description != null)
              Text('Description: ${product.description}'),
            if (product.manufacturer != null)
              Text('Manufacturer: ${product.manufacturer}'),
            if (product.reviews != null) Text('Reviews: ${product.reviews}'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              child: Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final String? description;
  @JsonKey(name: 'stock_status')
  final String stockStatus;
  final String? manufacturer;
  final String quantity;
  final String? reviews;
  final String price;
  final String href;
  final String thumb;
  final bool special;
  final int rating;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.stockStatus,
    this.manufacturer,
    required this.quantity,
    this.reviews,
    required this.price,
    required this.href,
    required this.thumb,
    required this.special,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        stockStatus: json['stock_status'],
        manufacturer: json['manufacturer'],
        quantity: json['quantity'],
        reviews: json['reviews'],
        price: json['price'],
        href: json['href'],
        thumb: json['thumb'],
        special: json['special'],
        rating: json['rating'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'stock_status': stockStatus,
        'manufacturer': manufacturer,
        'quantity': quantity,
        'reviews': reviews,
        'price': price,
        'href': href,
        'thumb': thumb,
        'special': special,
        'rating': rating,
      };
}
