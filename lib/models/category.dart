class Category {
  final String name;
  final int color;

  Category({
    required this.name,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      color: json['color'] ?? 0xFF2196F3, // Default blue color
    );
  }
}

