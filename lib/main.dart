import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/book_list_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/reader_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/profile_screen.dart'; // New profile screen
import 'models/app_state.dart';
import 'widgets/main_navigation.dart'; // New navigation widget

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Children\'s Book App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.orange,
          tertiary: Colors.green,
        ),
        fontFamily: 'Quicksand',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainNavigation(), // Use the new navigation widget
        '/book-list': (context) => const BookListScreen(),
        '/book-detail': (context) => const BookDetailScreen(),
        '/reader': (context) => const ReaderScreen(),
        '/bookmarks': (context) => const BookmarksScreen(),
        '/profile': (context) => const ProfileScreen(), // Add profile screen route
      },
    );
  }
}

