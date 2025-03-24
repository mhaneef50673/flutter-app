import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/book.dart';
import '../models/book_page.dart';
import '../models/bookmark.dart';
import '../models/category.dart';

class ApiService {
  // API base URL - would be the real URL in production
  static const String baseUrl = 'https://localhost:7147/api';
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  
  // For mock implementation
  bool _isMockEnabled = true;
  
  // Headers with authentication
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }
  
  // Save token to shared preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Save userId to shared preferences
  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userIdKey, userId);
  }
  
  // Get userId from shared preferences
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }
  
  // Clear token from shared preferences
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey) != null;
  }
  
  // Register user
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
      // Mock successful registration
      return {
        'message': 'User registered successfully'
      };
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }
  
  // Login user
  Future<User> login(String username, String password) async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
      // Mock login validation
      if (username == 'test' && password == 'password') {
        final userId = '1';
        final token = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
        
        await _saveToken(token);
        await _saveUserId(userId);
        
        return User(
          id: int.parse(userId),
          username: username,
          email: 'test@example.com',
          token: token,
        );
      } else {
        throw Exception('Invalid credentials');
      }
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userId = data['userId'];
      final token = data['token'];
      
      await _saveToken(token);
      await _saveUserId(userId);
      
      return User(
        id: int.parse(userId),
        username: username,
        email: '', // Email not returned from API
        token: token,
      );
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }
  
  // Get all books
  Future<List<Book>> getBooks() async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
      // Mock books data matching API response format
      return [
        Book(
          id: 1,
          title: 'The Magic Forest',
          author: 'Jane Smith',
          category: 'Fiction',
          coverImageUrl: 'https://picsum.photos/seed/book1/300/450',
          description: 'Join Lucy on her adventure through the magical forest where she meets talking animals and discovers hidden treasures.',
        ),
        Book(
          id: 2,
          title: 'Dragon\'s Tale',
          author: 'Michael Johnson',
          category: 'Fiction',
          coverImageUrl: 'https://picsum.photos/seed/book2/300/450',
          description: 'A young dragon learns to breathe fire and finds his place in the dragon community.',
        ),
        Book(
          id: 3,
          title: 'Fluffy\'s Adventure',
          author: 'Sarah Williams',
          category: 'Animals',
          coverImageUrl: 'https://picsum.photos/seed/book3/300/450',
          description: 'Fluffy the cat gets lost in the big city and must find his way back home.',
        ),
        Book(
          id: 4,
          title: 'Bedtime for Teddy',
          author: 'Emma Thompson',
          category: 'Bedtime',
          coverImageUrl: 'https://picsum.photos/seed/book4/300/450',
          description: 'Teddy the bear doesn\'t want to go to sleep and comes up with many excuses to stay awake.',
        ),
        Book(
          id: 5,
          title: 'Counting with Monkeys',
          author: 'David Brown',
          category: 'Educational',
          coverImageUrl: 'https://picsum.photos/seed/book5/300/450',
          description: 'Learn to count from 1 to 10 with the help of playful monkeys.',
        ),
      ];
    }
    
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/books'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books: ${response.body}');
    }
  }
  
  // Get books by category
  Future<List<Book>> getBooksByCategory(String category) async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Filter mock books by category
      final allBooks = await getBooks();
      return allBooks.where((book) => book.category == category).toList();
    }
    
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/books/category?category=$category'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books by category: ${response.body}');
    }
  }
  
  // Get book details
  Future<Book> getBookDetails(int bookId) async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Find book in mock data
      final books = await getBooks();
      final book = books.firstWhere(
        (book) => book.id == bookId,
        orElse: () => throw Exception('Book not found'),
      );
      
      return book;
    }
    
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/books/$bookId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Book.fromJson(data);
    } else {
      throw Exception('Failed to load book details: ${response.body}');
    }
  }
  
  // Get book content (pages)
  Future<BookPage> getBookContent(int bookId, int pageNumber) async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Mock book pages based on book ID and page number
      String content = '';
      
      if (bookId == 1) {
        switch (pageNumber) {
          case 1:
            content = 'Once upon a time, there was a little girl named Lucy who lived at the edge of a magical forest.';
            break;
          case 2:
            content = 'One day, Lucy decided to explore the forest despite her parents\' warnings.';
            break;
          case 3:
            content = 'As she walked deeper into the forest, the trees seemed to whisper her name.';
            break;
          case 4:
            content = 'Suddenly, she came across a talking rabbit who introduced himself as Mr. Whiskers.';
            break;
          case 5:
            content = 'Mr. Whiskers offered to guide Lucy through the magical forest.';
            break;
          case 6:
            content = 'They encountered many magical creatures and had wonderful adventures.';
            break;
          case 7:
            content = 'When it was time to go home, Lucy promised to visit her new friends again.';
            break;
          case 8:
            content = 'The End.';
            break;
          default:
            content = 'Page not found.';
        }
      } else if (bookId == 2) {
        switch (pageNumber) {
          case 1:
            content = 'In a land of dragons, a young dragon named Spark couldn\'t breathe fire.';
            break;
          case 2:
            content = 'All the other dragons could breathe magnificent flames, but not Spark.';
            break;
          default:
            content = 'This is page $pageNumber of book $bookId.';
        }
      } else {
        // Generate generic content for other books
        content = 'This is page $pageNumber of book $bookId.';
      }
      
      return BookPage(
        pageNumber: pageNumber,
        text: content,
      );
    }
    
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/books/$bookId/content?page=$pageNumber'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return BookPage.fromJson(data, pageNumber);
    } else {
      throw Exception('Failed to load book content: ${response.body}');
    }
  }
  
  // Get total pages for a book
  Future<int> getBookTotalPages(int bookId) async {
    if (_isMockEnabled) {
      // Mock total pages based on book ID
      switch (bookId) {
        case 1:
          return 8;
        case 2:
          return 6;
        default:
          return 5;
      }
    }
    
    // In a real implementation, we would fetch this from the API
    // For now, we'll use the mock implementation
    throw Exception('API endpoint not implemented');
  }
  
  // Get categories
  Future<List<Category>> getCategories() async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Mock categories data matching API response format
      return [
        Category(id: 1, name: 'Fiction', color: 0xFFFF9800),
        Category(id: 2, name: 'Science', color: 0xFF4CAF50),
        Category(id: 3, name: 'Animals', color: 0xFF2196F3),
        Category(id: 4, name: 'Bedtime', color: 0xFF9C27B0),
        Category(id: 5, name: 'Educational', color: 0xFFE91E63),
      ];
    }
    
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/books/categories'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.body}');
    }
  }
  
  // Get user's bookmarks
  Future<List<Bookmark>> getBookmarks() async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Get userId
      final userId = await getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      // Mock bookmarks data matching API response format
      final List<Bookmark> bookmarks = [
        Bookmark(
          id: 1,
          userId: int.parse(userId),
          bookId: 1,
          pageNumber: 3,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Bookmark(
          id: 2,
          userId: int.parse(userId),
          bookId: 3,
          pageNumber: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      
      // Fetch book details for each bookmark
      final books = await getBooks();
      for (var bookmark in bookmarks) {
        bookmark.book = books.firstWhere((book) => book.id == bookmark.bookId);
      }
      
      return bookmarks;
    }
    
    final userId = await getUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }
    
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/bookmarks/user/$userId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Bookmark.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookmarks: ${response.body}');
    }
  }
  
  // Add bookmark
  Future<Bookmark> addBookmark(int bookId, int pageNumber) async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Get userId
      final userId = await getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      // Mock adding a bookmark
      final bookmark = Bookmark(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: int.parse(userId),
        bookId: bookId,
        pageNumber: pageNumber,
        createdAt: DateTime.now(),
      );
      
      // Get book details
      final books = await getBooks();
      bookmark.book = books.firstWhere((book) => book.id == bookId);
      
      return bookmark;
    }
    
    final userId = await getUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }
    
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/bookmarks'),
      headers: headers,
      body: jsonEncode({
        'userId': userId,
        'bookId': bookId,
        'pageNumber': pageNumber,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Bookmark.fromJson(data);
    } else {
      throw Exception('Failed to add bookmark: ${response.body}');
    }
  }
  
  // Remove bookmark
  Future<Map<String, dynamic>> removeBookmark(int bookmarkId) async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      // Mock successful deletion
      return {
        'message': 'Bookmark deleted successfully'
      };
    }
    
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/bookmarks/user/$bookmarkId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to remove bookmark: ${response.body}');
    }
  }
}

