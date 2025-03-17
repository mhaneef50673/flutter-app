import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user.dart';
import 'book.dart';
import 'book_page.dart';
import 'bookmark.dart';
import 'category.dart';
import '../services/api_service.dart';

class AppState with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  List<Book> _books = [];
  List<Category> _categories = [];
  List<Bookmark> _bookmarks = [];
  Map<int, List<BookPage>> _bookPages = {}; // Cache for book pages
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  List<Book> get books => _books;
  List<Category> get categories => _categories;
  List<Bookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;

  // Get books by category
  List<Book> getBooksByCategory(String category) {
    return _books.where((book) => book.category == category).toList();
  }

  // Get featured books
  List<Book> get featuredBooks {
    return _books.where((book) => book.isFeatured).toList();
  }

  // Check if user is logged in
  Future<bool> checkLoginStatus() async {
    return await _apiService.isLoggedIn();
  }

  // Login user
  Future<bool> login(String email, String password) async {
    setLoading(true);
    
    try {
      _currentUser = await _apiService.login(email, password);
      await fetchInitialData();
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Register user
  Future<bool> register(String username, String email, String password) async {
    setLoading(true);
    
    try {
      _currentUser = await _apiService.register(username, email, password);
      await fetchInitialData();
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    await _apiService.clearToken();
    _currentUser = null;
    _books = [];
    _categories = [];
    _bookmarks = [];
    _bookPages = {};
    notifyListeners();
  }

  // Fetch initial data
  Future<void> fetchInitialData() async {
    await Future.wait([
      fetchCategories(),
      fetchBooks(),
      fetchBookmarks(),
    ]);
  }

  // Fetch categories
  Future<void> fetchCategories() async {
    setLoading(true);
    
    try {
      _categories = await _apiService.getCategories();
      setLoading(false);
      notifyListeners();
    } catch (e) {
      setLoading(false);
      notifyListeners();
    }
  }

  // Fetch books
  Future<void> fetchBooks() async {
    setLoading(true);
    
    try {
      _books = await _apiService.getBooks();
      setLoading(false);
      notifyListeners();
    } catch (e) {
      setLoading(false);
      notifyListeners();
    }
  }

  // Fetch book details
  Future<Book?> fetchBookDetails(int bookId) async {
    setLoading(true);
    
    try {
      final book = await _apiService.getBookDetails(bookId);
      setLoading(false);
      notifyListeners();
      return book;
    } catch (e) {
      setLoading(false);
      notifyListeners();
      return null;
    }
  }

  // Fetch book content (pages)
  Future<List<BookPage>> fetchBookContent(int bookId) async {
    setLoading(true);
    
    try {
      // Check if we already have the pages cached
      if (_bookPages.containsKey(bookId)) {
        setLoading(false);
        return _bookPages[bookId]!;
      }
      
      // Fetch pages from API
      final pages = await _apiService.getBookContent(bookId);
      
      // Cache the pages
      _bookPages[bookId] = pages;
      
      setLoading(false);
      notifyListeners();
      return pages;
    } catch (e) {
      setLoading(false);
      notifyListeners();
      return [];
    }
  }

  // Fetch bookmarks
  Future<void> fetchBookmarks() async {
    setLoading(true);
    
    try {
      _bookmarks = await _apiService.getBookmarks();
      setLoading(false);
      notifyListeners();
    } catch (e) {
      setLoading(false);
      notifyListeners();
    }
  }

  // Add bookmark
  Future<bool> addBookmark(int bookId, int pageNumber) async {
    setLoading(true);
    
    try {
      final bookmark = await _apiService.addBookmark(bookId, pageNumber);
      _bookmarks.add(bookmark);
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Remove bookmark
  Future<bool> removeBookmark(int bookmarkId) async {
    setLoading(true);
    
    try {
      await _apiService.removeBookmark(bookmarkId);
      _bookmarks.removeWhere((bookmark) => bookmark.id == bookmarkId);
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Check if a book page is bookmarked
  bool isPageBookmarked(int bookId, int pageNumber) {
    return _bookmarks.any(
      (bookmark) => bookmark.bookId == bookId && bookmark.pageNumber == pageNumber
    );
  }

  // Get bookmark for a specific book page
  Bookmark? getBookmarkForPage(int bookId, int pageNumber) {
    try {
      return _bookmarks.firstWhere(
        (bookmark) => bookmark.bookId == bookId && bookmark.pageNumber == pageNumber
      );
    } catch (e) {
      return null;
    }
  }

  // Toggle bookmark for a book page
  Future<bool> toggleBookmarkForPage(int bookId, int pageNumber) async {
    final existingBookmark = getBookmarkForPage(bookId, pageNumber);
    
    if (existingBookmark != null) {
      return await removeBookmark(existingBookmark.id);
    } else {
      return await addBookmark(bookId, pageNumber);
    }
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

