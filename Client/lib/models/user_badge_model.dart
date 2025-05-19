import 'package:mapico/models/badge_model.dart';

class UserBadgeModel {
  final int id;
  final int userId;
  final int badgeId;
  final String earnedDate;
  final BadgeModel? badge;

  UserBadgeModel({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.earnedDate,
    this.badge,
  });

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    // Null-safe erişim için yardımcı fonksiyon
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
    
    // Badge ID için olası alan adlarını deneyelim
    int getBadgeId(Map<String, dynamic> json) {
      for (final field in ['badge_id', 'badgeId', 'id_badge', 'badge']) {
        if (json.containsKey(field)) {
          final value = json[field];
          if (value is int) return value;
          if (value is String) {
            final parsed = int.tryParse(value);
            if (parsed != null) return parsed;
          }
          // Eğer badge bir nesne ise ve içinde id varsa
          if (value is Map<String, dynamic> && value.containsKey('id')) {
            final id = value['id'];
            if (id is int) return id;
            if (id is String) {
              final parsed = int.tryParse(id);
              if (parsed != null) return parsed;
            }
          }
        }
      }
      return 0; // Varsayılan değer
    }
    
    // Badge verisini deneyelim
    BadgeModel? badgeData;
    if (json.containsKey('badge') && json['badge'] != null) {
      try {
        if (json['badge'] is Map<String, dynamic>) {
          badgeData = BadgeModel.fromJson(json['badge'] as Map<String, dynamic>);
          print('Badge data successfully parsed from json');
        }
      } catch (e) {
        print('Badge parsing error: $e');
      }
    }
    
    // Tarih alanı için olası alan adlarını deneyelim (earned_date veya awarded_at)
    String getDateField(Map<String, dynamic> json) {
      for (final field in ['earned_date', 'awarded_at', 'date', 'created_at']) {
        if (json.containsKey(field) && json[field] != null) {
          return json[field].toString();
        }
      }
      return '';
    }
    
    // Badge ID'yi al
    final badgeId = getBadgeId(json);
    
    print('Parsed user badge: id=${_safeGet<int>(json, 'id', 0)}, '
          'userId=${_safeGet<int>(json, 'user_id', 0)}, '
          'badgeId=$badgeId, '
          'hasBadgeObject=${badgeData != null}');
    
    return UserBadgeModel(
      id: _safeGet<int>(json, 'id', 0),
      userId: _safeGet<int>(json, 'user_id', 0),
      badgeId: badgeId,
      earnedDate: getDateField(json),
      badge: badgeData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'badge_id': badgeId,
      'earned_date': earnedDate,
    };
  }
} 