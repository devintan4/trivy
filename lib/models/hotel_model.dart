class Hotel {
  final String id;
  final String imagePath;
  final String name;
  final String location;
  final double rating;

  Hotel({
    required this.name,
    required this.imagePath,
    required this.location,
    required this.rating,
  }) : id = name.replaceAll(' ', '').toLowerCase();
}
