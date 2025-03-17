class BookPage {
  final int id;
  final int bookId;
  final int pageNumber;
  final String text;
  final String? imageUrl;

  BookPage({
    required this.id,
    required this.bookId,
    required this.pageNumber,
    required this.text,
    this.imageUrl,
  });

  factory BookPage.fromJson(Map<String, dynamic> json) {
    return BookPage(
      id: json['id'],
      bookId: json['bookId'],
      pageNumber: json['pageNumber'],
      text: json['text'],
      imageUrl: json['imageUrl'],
    );
  }
}

