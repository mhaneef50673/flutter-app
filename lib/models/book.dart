class Book {
  final int id;
  final String title;
  final String author;
  final String category;
  final String coverImageUrl;
  final String description;
  final bool isFeatured; // Additional field for UI purposes

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.coverImageUrl,
    required this.description,
    this.isFeatured = false,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      category: json['category'],
      coverImageUrl: json['coverImageUrl'],
      description: json['description'],
      isFeatured: json['isFeatured'] ?? false,
    );
  }
}

