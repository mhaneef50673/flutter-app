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
  static const String baseUrl = 'https://api.example.com'; // Mock base URL
  static const String tokenKey = 'auth_token';
  
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
  
  // Clear token from shared preferences
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey) != null;
  }
  
  // Register user
  Future<User> register(String username, String email, String password) async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
      // Mock successful registration
      final user = User(
        id: 1,
        username: username,
        email: email,
        token: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      await _saveToken(user.token);
      return user;
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data);
      await _saveToken(user.token);
      return user;
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }
  
  // Login user
  Future<User> login(String email, String password) async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
      // Mock login validation
      if (email == 'test@example.com' && password == 'password') {
        final user = User(
          id: 1,
          username: 'testuser',
          email: email,
          token: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        await _saveToken(user.token);
        return user;
      } else {
        throw Exception('Invalid credentials');
      }
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data);
      await _saveToken(user.token);
      return user;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }
  
  // Get all books
  Future<List<Book>> getBooks() async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
      // Mock books data
      return [
        Book(
          id: 1,
          title: 'The Magic Forest',
          author: 'Jane Smith',
          category: 'Adventure',
          coverImageUrl: 'https://via.placeholder.com/150/FF9800/FFFFFF?text=Magic+Forest',
          description: 'Join Lucy on her adventure through the magical forest where she meets talking animals and discovers hidden treasures.',
          isFeatured: true,
        ),
        Book(
          id: 2,
          title: 'Dragon\'s Tale',
          author: 'Michael Johnson',
          category: 'Fantasy',
          coverImageUrl: 'https://via.placeholder.com/150/4CAF50/FFFFFF?text=Dragon+Tale',
          description: 'A young dragon learns to breathe fire and finds his place in the dragon community.',
          isFeatured: true,
        ),
        Book(
          id: 3,
          title: 'Fluffy\'s Adventure',
          author: 'Sarah Williams',
          category: 'Animals',
          coverImageUrl: 'https://via.placeholder.com/150/2196F3/FFFFFF?text=Fluffy',
          description: 'Fluffy the cat gets lost in the big city and must find his way back home.',
          isFeatured: false,
        ),
        Book(
          id: 4,
          title: 'Bedtime for Teddy',
          author: 'Emma Thompson',
          category: 'Bedtime',
          coverImageUrl: 'https://via.placeholder.com/150/9C27B0/FFFFFF?text=Teddy',
          description: 'Teddy the bear doesn\'t want to go to sleep and comes up with many excuses to stay awake.',
          isFeatured: false,
        ),
        Book(
          id: 5,
          title: 'Counting with Monkeys',
          author: 'David Brown',
          category: 'Educational',
          coverImageUrl: 'https://via.placeholder.com/150/E91E63/FFFFFF?text=Counting',
          description: 'Learn to count from 1 to 10 with the help of playful monkeys.',
          isFeatured: true,
        ),
      ];
    }
    
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/books'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books: ${response.body}');
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
      Uri.parse('$baseUrl/api/books/$bookId'),
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
  Future<List<BookPage>> getBookContent(int bookId) async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Mock book pages based on book ID
      if (bookId == 1) {
        return [
          BookPage(
            id: 1,
            bookId: 1,
            pageNumber: 1,
            text: 'Once upon a time, there was a little girl named Lucy who lived at the edge of a magical forest.',
            imageUrl: 'https://via.placeholder.com/400/FF9800/FFFFFF?text=Page+1',
          ),
          BookPage(
            id: 2,
            bookId: 1,
            pageNumber: 2,
            text: 'One day, Lucy decided to explore the forest despite her parents\' warnings.',
            imageUrl: 'https://via.placeholder.com/400/FF9800/FFFFFF?text=Page+2',
          ),
          BookPage(
            id: 3,
            bookId: 1,
            pageNumber: 3,
            text: 'As she walked deeper into the forest, the trees seemed to whisper her name.',
            imageUrl: 'https://via.placeholder.com/400/FF9800/FFFFFF?text=Page+3',
          ),
          BookPage(
            id: 4,
            bookId: 1,
            pageNumber: 4,
            text: 'Suddenly, she came across a talking rabbit who introduced himself as Mr. Whiskers.',
            imageUrl: 'https://via.placeholder.com/400/FF9800/FFFFFF?text=Page+4',
          ),
          BookPage(
            id: 5,
            bookId: 1,
            pageNumber: 5,
            text: 'Mr. Whiskers offered to guide Lucy through the magical forest.',
            imageUrl: 'https://via.placeholder.com/400/FF9800/FFFFFF?text=Page+5',
          ),
          BookPage(
            id: 6,
            bookId: 1,
            pageNumber: 6,
            text: 'They encountered many magical creatures and had wonderful adventures.',
            imageUrl: 'https://via.placeholder.com/400/FF9800/FFFFFF?text=Page+6',
          ),
          BookPage(
            id: 7,
            bookId: 1,
            pageNumber: 7,
            text: 'When it was time to go home, Lucy promised to visit her new friends again.',
            imageUrl: 'https://via.placeholder.com/400/FF9800/FFFFFF?text=Page+7',
          ),
          BookPage(
            id: 8,
            bookId: 1,
            pageNumber: 8,
            text: 'The End.',
            imageUrl: 'https://via.placeholder.com/400/FF9800/FFFFFF?text=The+End',
          ),
        ];
      } else if (bookId == 2) {
        return [
          BookPage(
            id: 9,
            bookId: 2,
            pageNumber: 1,
            text: 'In a land of dragons, a young dragon named Spark couldn\'t breathe fire.',
            imageUrl: 'https://via.placeholder.com/400/4CAF50/FFFFFF?text=Page+1',
          ),
          BookPage(
            id: 10,
            bookId: 2,
            pageNumber: 2,
            text: 'All the other dragons could breathe magnificent flames, but not Spark.',
            imageUrl: 'https://via.placeholder.com/400/4CAF50/FFFFFF?text=Page+2',
          ),
          // Add more pages for book 2
        ];
      } else {
        // Generate generic pages for other books
        return List.generate(
          8,
          (index) => BookPage(
            id: 100 + (bookId * 10) + index,
            bookId: bookId,
            pageNumber: index + 1,
            text: 'This is page ${index + 1} of book $bookId.',
            imageUrl: 'https://via.placeholder.com/400/2196F3/FFFFFF?text=Book+$bookId+Page+${index + 1}',
          ),
        );
      }
    }
    
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/books/$bookId/content'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BookPage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load book content: ${response.body}');
    }
  }
  
  // Get categories
  Future<List<Category>> getCategories() async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Mock categories data
      return [
        Category(name: 'Adventure', color: 0xFFFF9800),
        Category(name: 'Fantasy', color: 0xFF4CAF50),
        Category(name: 'Animals', color: 0xFF2196F3),
        Category(name: 'Bedtime', color: 0xFF9C27B0),
        Category(name: 'Educational', color: 0xFFE91E63),
      ];
    }
    
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/books/categories'),
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
      
      // Mock bookmarks data
      final List<Bookmark> bookmarks = [
        Bookmark(
          id: 1,
          userId: 1,
          bookId: 1,
          pageNumber: 3,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Bookmark(
          id: 2,
          userId: 1,
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
    
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/bookmarks'),
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
      
      // Mock adding a bookmark
      final bookmark = Bookmark(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: 1,
        bookId: bookId,
        pageNumber: pageNumber,
        createdAt: DateTime.now(),
      );
      
      // Get book details
      final books = await getBooks();
      bookmark.book = books.firstWhere((book) => book.id == bookId);
      
      return bookmark;
    }
    
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/bookmarks'),
      headers: headers,
      body: jsonEncode({
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
  Future<void> removeBookmark(int bookmarkId) async {
    if (_isMockEnabled) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      return; // Mock successful deletion
    }
    
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/bookmarks/$bookmarkId'),
      headers: headers,
    );
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove bookmark: ${response.body}');
    }
  }
}

