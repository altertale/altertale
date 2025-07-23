import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import 'points_service.dart';

/// Satın alma işlemleri ve transaction yönetimi
class PurchaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String usersCollection = 'users';
  final PointsService _pointsService = PointsService();
  final String booksCollection = 'books';
  final String transactionsCollection = 'transactions';

  /// TL ile satın alma (sahte ödeme, gerçek entegrasyon için altyapı hazır)
  Future<bool> purchaseWithTL({
    required String userId,
    required BookModel book,
    required double amount,
    String? paymentProvider, // 'stripe', 'iyzico', 'google', 'apple' vs.
  }) async {
    // Gerçek ödeme entegrasyonu burada olacak
    // Şimdilik sahte ödeme ile test
    await Future.delayed(const Duration(seconds: 1));
    return await _finalizePurchase(
      userId: userId,
      book: book,
      paymentType: 'tl',
      amount: amount,
      paymentProvider: paymentProvider,
    );
  }

  /// Puan ile satın alma
  Future<bool> purchaseWithPoints({
    required String userId,
    required BookModel book,
    required int userPoints,
  }) async {
    if (userPoints < book.pointPrice) {
      throw Exception('Yeterli puanınız yok.');
    }

    return await _finalizePurchase(
      userId: userId,
      book: book,
      paymentType: 'points',
      amount: book.pointPrice.toDouble(),
    );
  }

  /// Satın alma işlemini tamamlar: Firestore günceller, transaction kaydeder
  Future<bool> _finalizePurchase({
    required String userId,
    required BookModel book,
    required String paymentType, // 'tl' veya 'points'
    required double amount,
    String? paymentProvider,
  }) async {
    final userRef = _firestore.collection(usersCollection).doc(userId);
    final transactionRef = _firestore.collection(transactionsCollection).doc();
    final now = DateTime.now();

    return _firestore
        .runTransaction((transaction) async {
          final userSnap = await transaction.get(userRef);
          if (!userSnap.exists) throw Exception('Kullanıcı bulunamadı');
          final userData = userSnap.data() as Map<String, dynamic>;
          final purchasedBooks = List<String>.from(
            userData['purchasedBooks'] ?? [],
          );
          final totalPoints = userData['totalPoints'] ?? 0;

          // Zaten satın alınmışsa hata verme
          if (purchasedBooks.contains(book.id)) {
            throw Exception('Bu kitabı zaten satın aldınız.');
          }

          // Puanla satın alma ise puan düş
          int newPoints = totalPoints;
          if (paymentType == 'points') {
            if (totalPoints < book.pointPrice)
              throw Exception('Yeterli puan yok.');
            newPoints -= book.pointPrice;
          }

          // Kitabı purchasedBooks listesine ekle
          purchasedBooks.add(book.id);

          // Kullanıcıyı güncelle
          transaction.update(userRef, {
            'purchasedBooks': purchasedBooks,
            'totalPoints': newPoints,
            'updatedAt': now,
          });

          // Transaction kaydı oluştur
          transaction.set(transactionRef, {
            'userId': userId,
            'bookId': book.id,
            'bookTitle': book.title,
            'paymentType': paymentType,
            'amount': amount,
            'paymentProvider': paymentProvider,
            'createdAt': now,
          });
        })
        .then((_) => true)
        .catchError((e) {
          throw Exception('Satın alma başarısız: $e');
        });
  }

  /// Kullanıcının kitabı satın alıp almadığını kontrol et
  Future<bool> hasUserPurchasedBook({
    required String userId,
    required String bookId,
  }) async {
    try {
      final userDoc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return false;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final purchasedBooks = List<String>.from(
        userData['purchasedBooks'] ?? [],
      );

      return purchasedBooks.contains(bookId);
    } catch (e) {
      throw Exception('Satın alma durumu kontrol edilirken hata: $e');
    }
  }
}
