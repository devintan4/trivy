import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

final postsProvider = FutureProvider<List<Post>>((ref) async {
  const String url = 'https://dummyjson.com/posts';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> postsJson = data['posts'];

      return postsJson.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to connect: $e');
  }
});
