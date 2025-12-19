class Post {
  final int id;
  final String title;
  final String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      // Kita mapping 'description' dari API ke field 'body' agar tidak banyak ubah UI
      body: json['description'] ?? '',
    );
  }
}
