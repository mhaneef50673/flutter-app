import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/book.dart';
import '../widgets/loading_indicator.dart';
// No Category import needed here

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh bookmarks when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).fetchBookmarks();
    });
  }

  void _openBookDetails(Book book) {
    Navigator.of(context).pushNamed(
      '/book-detail',
      arguments: book,
    );
  }

  void _openBookReader(Book book, int pageNumber) {
    Navigator.of(context).pushNamed(
      '/reader',
      arguments: book,
    );
  }

  void _removeBookmark(int bookmarkId) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.removeBookmark(bookmarkId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookmark deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final bookmarks = appState.bookmarks;
    final isLoading = appState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks'),
      ),
      body: isLoading
          ? const LoadingIndicator(message: 'Loading bookmarks...')
          : bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bookmarks yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the bookmark icon while reading to add bookmarks',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: appState.fetchBookmarks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookmarks.length,
                    itemBuilder: (ctx, index) {
                      final bookmark = bookmarks[index];
                      final book = bookmark.book;
                      
                      if (book == null) {
                        return const SizedBox.shrink();
                      }
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _openBookReader(book, bookmark.pageNumber),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 150,
                                child: Image.network(
                                  book.coverImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(Icons.broken_image, size: 40),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'By ${book.author}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Page ${bookmark.pageNumber}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'Bookmarked on ${bookmark.createdAt.day}/${bookmark.createdAt.month}/${bookmark.createdAt.year}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(Icons.book),
                                            label: const Text('Continue Reading'),
                                            onPressed: () => _openBookReader(book, bookmark.pageNumber),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            onPressed: () => _removeBookmark(bookmark.id),
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

