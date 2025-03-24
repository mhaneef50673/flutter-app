import 'dart:math';

class Category {
  final int id;
  final String name;
  final int color;

  Category({
    required this.id,
    required this.name,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // Get the category name from either 'category' or 'name' field
    final categoryName = json['category'] ?? json['name'] ?? 'Unknown';
    
    // Use the provided color or generate one based on the category name
    final color = json['color'] ?? _generateColorFromName(categoryName);
    
    return Category(
      id: json['id'],
      name: categoryName,
      color: color,
    );
  }
  
  // Generate a consistent color based on the category name
  static int _generateColorFromName(String name) {
    // Create a deterministic seed from the name
    int seed = 0;
    for (int i = 0; i < name.length; i++) {
      seed += name.codeUnitAt(i);
    }
    
    // Use the seed to create a random generator
    final random = Random(seed);
    
    // List of bright, child-friendly colors (without alpha)
    final List<int> colorOptions = [
      0xFF4CAF50, // Green
      0xFF2196F3, // Blue
      0xFFFF9800, // Orange
      0xFF9C27B0, // Purple
      0xFFE91E63, // Pink
      0xFF00BCD4, // Cyan
      0xFFFFEB3B, // Yellow
      0xFF673AB7, // Deep Purple
      0xFF3F51B5, // Indigo
      0xFF009688, // Teal
    ];
    
    // Pick a color from the list based on the seed
    return colorOptions[random.nextInt(colorOptions.length)];
  }
}

