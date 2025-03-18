import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/book.dart';
import '../models/book_page.dart';
import '../widgets/page_turn_button.dart';
import '../widgets/loading_indicator.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int _currentPageIndex = 0;
  bool _showControls = true;
  List<BookPage> _pages = [];
  bool _isLoading = true;
  double _fontSize = 18.0; // Default font size

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use Future.delayed to avoid calling setState during build
    Future.delayed(Duration.zero, () {
      _loadBookContent();
    });
  }

  Future<void> _loadBookContent() async {
    final book = ModalRoute.of(context)!.settings.arguments as Book;
    final appState = Provider.of<AppState>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    final pages = await appState.fetchBookContent(book.id);
    
    if (mounted) {
      setState(() {
        _pages = pages;
        _isLoading = false;
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _goToNextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      setState(() {
        _currentPageIndex++;
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
    }
  }

  void _toggleBookmark() async {
    if (_pages.isEmpty) return;
    
    final book = ModalRoute.of(context)!.settings.arguments as Book;
    final appState = Provider.of<AppState>(context, listen: false);
    final currentPage = _pages[_currentPageIndex];
    
    await appState.toggleBookmarkForPage(book.id, currentPage.pageNumber);
  }

  void _changeFontSize(double newSize) {
    setState(() {
      _fontSize = newSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as Book;
    final appState = Provider.of<AppState>(context);
    
    final hasNextPage = _currentPageIndex < _pages.length - 1;
    final hasPreviousPage = _currentPageIndex > 0;
    
    final isCurrentPageBookmarked = _pages.isNotEmpty 
        ? appState.isPageBookmarked(book.id, _pages[_currentPageIndex].pageNumber)
        : false;

    return Scaffold(
      appBar: _showControls
          ? AppBar(
              title: Text(book.title),
              actions: [
                IconButton(
                  icon: Icon(
                    isCurrentPageBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isCurrentPageBookmarked ? Colors.yellow : null,
                  ),
                  onPressed: _toggleBookmark,
                ),
                IconButton(
                  icon: const Icon(Icons.text_fields),
                  onPressed: () {
                    // Font size adjustment dialog
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Adjust Font Size'),
                        content: StatefulBuilder(
                          builder: (context, setDialogState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Sample Text',
                                  style: TextStyle(fontSize: _fontSize),
                                ),
                                const SizedBox(height: 20),
                                Slider(
                                  value: _fontSize,
                                  min: 12.0,
                                  max: 32.0,
                                  divisions: 10,
                                  label: _fontSize.round().toString(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      _fontSize = value;
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _changeFontSize(_fontSize);
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading book...')
          : _pages.isEmpty
              ? const Center(
                  child: Text('No pages found for this book.'),
                )
              : GestureDetector(
                  onTap: _toggleControls,
                  child: Container(
                    color: Colors.white,
                    child: SafeArea(
                      child: Stack(
                        children: [
                          // Page content
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _pages[_currentPageIndex].text,
                                style: TextStyle(
                                  fontSize: _fontSize,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Page number
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Page ${_currentPageIndex + 1} of ${_pages.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Navigation controls
                          if (_showControls)
                            Positioned(
                              bottom: 24,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  PageTurnButton(
                                    direction: PageTurnDirection.previous,
                                    onTap: _goToPreviousPage,
                                    enabled: hasPreviousPage,
                                  ),
                                  PageTurnButton(
                                    direction: PageTurnDirection.next,
                                    onTap: _goToNextPage,
                                    enabled: hasNextPage,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

