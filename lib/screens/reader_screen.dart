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
  int _currentPageNumber = 1;
  bool _showControls = true;
  BookPage? _currentPage;
  int _totalPages = 0;
  bool _isLoading = true;
  double _fontSize = 18.0; // Default font size

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use Future.delayed to avoid calling setState during build
    Future.delayed(Duration.zero, () {
      _initReader();
    });
  }

  Future<void> _initReader() async {
    final book = ModalRoute.of(context)!.settings.arguments as Book;
    final appState = Provider.of<AppState>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get total pages
      final totalPages = await appState.fetchBookTotalPages(book.id);
      
      // Get first page
      final page = await appState.fetchBookPage(book.id, _currentPageNumber);
      
      if (mounted) {
        setState(() {
          _totalPages = totalPages;
          _currentPage = page;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading book: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > _totalPages) return;
    
    final book = ModalRoute.of(context)!.settings.arguments as Book;
    final appState = Provider.of<AppState>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final page = await appState.fetchBookPage(book.id, pageNumber);
      
      if (mounted) {
        setState(() {
          _currentPageNumber = pageNumber;
          _currentPage = page;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading page: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _goToNextPage() {
    if (_currentPageNumber < _totalPages) {
      _loadPage(_currentPageNumber + 1);
    }
  }

  void _goToPreviousPage() {
    if (_currentPageNumber > 1) {
      _loadPage(_currentPageNumber - 1);
    }
  }

  void _toggleBookmark() async {
    if (_currentPage == null) return;
    
    final book = ModalRoute.of(context)!.settings.arguments as Book;
    final appState = Provider.of<AppState>(context, listen: false);
    
    final success = await appState.toggleBookmarkForPage(book.id, _currentPageNumber);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.isPageBookmarked(book.id, _currentPageNumber)
                ? 'Bookmark added'
                : 'Bookmark removed'
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
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
    
    final hasNextPage = _currentPageNumber < _totalPages;
    final hasPreviousPage = _currentPageNumber > 1;
    
    final isCurrentPageBookmarked = _currentPage != null 
        ? appState.isPageBookmarked(book.id, _currentPageNumber)
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
          : _currentPage == null
              ? const Center(
                  child: Text('No content found for this book.'),
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
                                _currentPage!.text,
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
                                  'Page $_currentPageNumber of $_totalPages',
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

