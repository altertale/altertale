import 'package:cloud_firestore/cloud_firestore.dart';

/// Okuma ilerlemesi modeli
class ReadingProgressModel {
  final String id;
  final String userId;
  final String bookId;
  final int? currentPage;
  final int? totalPages;
  final double? percentRead;
  final DateTime? lastOpenedAt;
  final DateTime? sessionStartTime;
  final DateTime? sessionEndTime;
  final int? sessionDuration; // saniye cinsinden
  final DateTime? updatedAt;

  ReadingProgressModel({
    required this.id,
    required this.userId,
    required this.bookId,
    this.currentPage,
    this.totalPages,
    this.percentRead,
    this.lastOpenedAt,
    this.sessionStartTime,
    this.sessionEndTime,
    this.sessionDuration,
    this.updatedAt,
  });

  /// Firestore'dan model oluştur
  factory ReadingProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ReadingProgressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      currentPage: data['currentPage'],
      totalPages: data['totalPages'],
      percentRead: data['percentRead']?.toDouble(),
      lastOpenedAt: data['lastOpenedAt'] != null 
          ? (data['lastOpenedAt'] as Timestamp).toDate() 
          : null,
      sessionStartTime: data['sessionStartTime'] != null 
          ? (data['sessionStartTime'] as Timestamp).toDate() 
          : null,
      sessionEndTime: data['sessionEndTime'] != null 
          ? (data['sessionEndTime'] as Timestamp).toDate() 
          : null,
      sessionDuration: data['sessionDuration'],
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Firestore'a kaydetmek için map oluştur
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookId': bookId,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'percentRead': percentRead,
      'lastOpenedAt': lastOpenedAt != null ? Timestamp.fromDate(lastOpenedAt!) : null,
      'sessionStartTime': sessionStartTime != null ? Timestamp.fromDate(sessionStartTime!) : null,
      'sessionEndTime': sessionEndTime != null ? Timestamp.fromDate(sessionEndTime!) : null,
      'sessionDuration': sessionDuration,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Modeli kopyala ve güncelle
  ReadingProgressModel copyWith({
    String? id,
    String? userId,
    String? bookId,
    int? currentPage,
    int? totalPages,
    double? percentRead,
    DateTime? lastOpenedAt,
    DateTime? sessionStartTime,
    DateTime? sessionEndTime,
    int? sessionDuration,
    DateTime? updatedAt,
  }) {
    return ReadingProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      percentRead: percentRead ?? this.percentRead,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      sessionEndTime: sessionEndTime ?? this.sessionEndTime,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Okuma yüzdesini hesapla
  double get calculatedPercentRead {
    if (currentPage == null || totalPages == null || totalPages == 0) {
      return 0.0;
    }
    return (currentPage! / totalPages!) * 100;
  }

  /// Okuma yüzdesini formatla
  String get formattedPercentRead {
    final percent = percentRead ?? calculatedPercentRead;
    return '${percent.toStringAsFixed(1)}%';
  }

  /// Son açılma zamanını formatla
  String get formattedLastOpened {
    if (lastOpenedAt == null) return 'Hiç açılmadı';
    
    final now = DateTime.now();
    final difference = now.difference(lastOpenedAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  /// Oturum süresini formatla
  String get formattedSessionDuration {
    if (sessionDuration == null) return 'Bilinmiyor';
    
    final hours = sessionDuration! ~/ 3600;
    final minutes = (sessionDuration! % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    } else {
      return '${minutes}dk';
    }
  }

  /// Okuma durumunu kontrol et
  bool get isCompleted {
    return percentRead != null && percentRead! >= 100;
  }

  /// Okuma durumunu kontrol et
  bool get isInProgress {
    return currentPage != null && currentPage! > 0 && !isCompleted;
  }

  /// Okuma durumunu kontrol et
  bool get isNotStarted {
    return currentPage == null || currentPage == 0;
  }

  /// Okuma durumu metni
  String get statusText {
    if (isCompleted) return 'Tamamlandı';
    if (isInProgress) return 'Devam ediyor';
    return 'Başlanmadı';
  }

  /// Okuma durumu rengi
  String get statusColor {
    if (isCompleted) return '#4CAF50'; // Yeşil
    if (isInProgress) return '#2196F3'; // Mavi
    return '#9E9E9E'; // Gri
  }

  @override
  String toString() {
    return 'ReadingProgressModel(id: $id, bookId: $bookId, currentPage: $currentPage, percentRead: $percentRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingProgressModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 