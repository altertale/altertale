import 'package:cloud_firestore/cloud_firestore.dart';

/// Beğeni işlemleri servisi
class LikesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'likes';

  /// Kitap için beğeni sayısını getir
  Future<int> getLikeCountForBook(String bookId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('bookId', isEqualTo: bookId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Beğeni sayısı alınırken hata oluştu: $e');
    }
  }

  /// Kullanıcının kitabı beğenip beğenmediğini kontrol et
  Future<bool> isBookLikedByUser({
    required String userId,
    required String bookId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Beğeni durumu kontrol edilirken hata oluştu: $e');
    }
  }

  /// Kitabı beğen/beğenmekten vazgeç
  Future<bool> toggleLike({
    required String userId,
    required String bookId,
  }) async {
    try {
      // Önce mevcut beğeniyi kontrol et
      final existingLike = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .limit(1)
          .get();

      if (existingLike.docs.isNotEmpty) {
        // Beğeniyi kaldır
        await existingLike.docs.first.reference.delete();
        return false; // Artık beğenilmiyor
      } else {
        // Yeni beğeni ekle
        await _firestore.collection(_collection).add({
          'userId': userId,
          'bookId': bookId,
          'timestamp': Timestamp.now(),
        });
        return true; // Şimdi beğeniliyor
      }
    } catch (e) {
      throw Exception('Beğeni işlemi yapılırken hata oluştu: $e');
    }
  }

  /// Kitabı beğenen kullanıcıları getir
  Future<List<String>> getUsersWhoLikedBook({
    required String bookId,
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('bookId', isEqualTo: bookId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['userId'] as String)
          .toList();
    } catch (e) {
      throw Exception('Beğenen kullanıcılar alınırken hata oluştu: $e');
    }
  }

  /// Kullanıcının beğendiği kitapları getir
  Future<List<String>> getBooksLikedByUser({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['bookId'] as String)
          .toList();
    } catch (e) {
      throw Exception('Kullanıcının beğendiği kitaplar alınırken hata oluştu: $e');
    }
  }

  /// En çok beğenilen kitapları getir (admin için)
  Future<Map<String, int>> getMostLikedBooks({
    int limit = 20,
  }) async {
    try {
      // Firestore'da aggregation query yok, bu yüzden client-side hesaplama yapıyoruz
      final allLikes = await _firestore
          .collection(_collection)
          .get();

      final bookLikeCounts = <String, int>{};
      
      for (final doc in allLikes.docs) {
        final bookId = doc.data()['bookId'] as String;
        bookLikeCounts[bookId] = (bookLikeCounts[bookId] ?? 0) + 1;
      }

      // Beğeni sayısına göre sırala
      final sortedBooks = bookLikeCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return Map.fromEntries(sortedBooks.take(limit));
    } catch (e) {
      throw Exception('En çok beğenilen kitaplar alınırken hata oluştu: $e');
    }
  }

  /// Belirli bir tarih aralığındaki beğenileri getir (admin için)
  Future<List<Map<String, dynamic>>> getLikesInDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 100,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      throw Exception('Tarih aralığındaki beğeniler alınırken hata oluştu: $e');
    }
  }

  /// Beğeni istatistiklerini getir (admin için)
  Future<Map<String, dynamic>> getLikeStatistics() async {
    try {
      final totalLikes = await _firestore
          .collection(_collection)
          .count()
          .get();

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final todayLikes = await _firestore
          .collection(_collection)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .count()
          .get();

      return {
        'totalLikes': totalLikes.count,
        'todayLikes': todayLikes.count,
      };
    } catch (e) {
      throw Exception('Beğeni istatistikleri alınırken hata oluştu: $e');
    }
  }
}
