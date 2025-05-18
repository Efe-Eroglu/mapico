class BadgeModel {
  final int? id;
  final String name;
  final String description;
  final String imageUrl;
  final String? category;
  final int? pointValue;

  BadgeModel({
    this.id,
    required this.name,
    this.description = '',
    required this.imageUrl,
    this.category,
    this.pointValue,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    // Null-safe erişim için safe get fonksiyonu
    T _safeGet<T>(Map<String, dynamic>? json, String key, T defaultValue) {
      if (json == null) return defaultValue;
      
      try {
        final value = json[key];
        if (value == null) return defaultValue;
        if (value is T) return value;
        
        // Tip dönüşümü denemeleri
        if (T == int && value is String) {
          return int.tryParse(value) as T? ?? defaultValue;
        }
        
        return defaultValue;
      } catch (e) {
        print('_safeGet error for key $key: $e');
        return defaultValue;
      }
    }

    // URL çıkarma fonksiyonu - farklı alan adlarını denesin
    String extractImageUrl(Map<String, dynamic>? json) {
      if (json == null) return '';
      
      for (final key in ['icon_url', 'image_url', 'icon', 'url', 'img']) {
        final value = json[key];
        if (value != null && value is String && value.isNotEmpty) {
          return value;
        }
      }
      
      return '';
    }
    
    return BadgeModel(
      id: _safeGet<int?>(json, 'id', null),
      name: _safeGet<String>(json, 'name', 'İsimsiz Rozet'),
      description: _safeGet<String>(json, 'description', ''),
      imageUrl: extractImageUrl(json),
      category: _safeGet<String?>(json, 'category', null),
      pointValue: _safeGet<int?>(json, 'point_value', null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'point_value': pointValue,
    };
  }
} 