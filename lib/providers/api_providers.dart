import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

final postsProvider = FutureProvider<List<Post>>((ref) async {
  // Ganti ke DummyJSON Products
  const String url = 'https://dummyjson.com/products';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    // DummyJSON membungkus datanya di dalam key 'products'
    final List<dynamic> productsJson = data['products'];

    return productsJson.map((json) => Post.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load products from DummyJSON');
  }
});
