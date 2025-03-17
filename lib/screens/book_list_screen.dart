import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../widgets/book_card.dart';
import '../widgets/loading_indicator.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  void _openBookDetails(BuildContext context, Book book) {
    Navigator.of(context).pushNamed(
      '/book-detail',
      arguments: book,
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as Category;
    final appState = Provider.of<AppState>(context);
    final books = appState.getBooksByCategory(category.name);
    final isLoading = appState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: Color(category.color),
      ),
      body: isLoading
          ? const LoadingIndicator()
          : books.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.book_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No books in this category yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: books.length,
                  itemBuilder: (ctx, index) {
                    return BookCard(
                      book: books[index],
                      onTap: () => _openBookDetails(context, books[index]),
                    );
                  },
                ),
    );
  }
}

