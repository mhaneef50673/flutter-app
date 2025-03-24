class Book {
  final int id;
  final String title;
  final String author;
  final String category;
  final String coverImageUrl;
  final String description;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.coverImageUrl,
    required this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      category: json['category'],
      coverImageUrl: json['coverImageUrl'],
      description: json['description'],
    );
  }
}

