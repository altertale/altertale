import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_transaction_model.dart';

/// İşlem loglama servisi - Ödeme ve kullanıcı aktivitelerini kaydeder
class TransactionLogger {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const String _transactionsCollection = 'transactions';
  static const String _userActivitiesCollection = 'user_activities';
  static const String _paymentLogsCollection = 'payment_logs';

  /// Ödeme işlemini logla
  Future<void> logPaymentTransaction({
    required String userId,
    required String bookId,
    required String paymentType,
    required String status,
    double? amount,
    String? currency,
    String? gateway,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final transactionRef = _firestore.collection(_transactionsCollection).doc();
      
      final transaction = PaymentTransactionModel(
        id: transactionRef.id,
        userId: userId,
        bookId: bookId,
        paymentType: paymentType,
        amount: amount,
        currency: currency ?? 'TL',
        status: status,
        gateway: gateway ?? 'unknown',
        platform: 'flutter',
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
        completedAt: status == 'completed' ? DateTime.now() : null,
      );

      await transactionRef.set(transaction.toFirestore());
      
      print('Ödeme işlemi loglandı: ${transaction.id}');
    } catch (e) {
      print('Ödeme işlemi loglanırken hata: $e');
    }
  }

  /// Kullanıcı aktivitesini logla
  Future<void> logUserActivity({
    required String userId,
    required String activity,
    String? bookId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection(_userActivitiesCollection).add({
        'userId': userId,
        'activity': activity,
        'bookId': bookId,
        'metadata': metadata ?? {},
        'timestamp': Timestamp.now(),
        'platform': 'flutter',
      });
      
      print('Kullanıcı aktivitesi loglandı: $activity');
    } catch (e) {
      print('Kullanıcı aktivitesi loglanırken hata: $e');
    }
  }

  /// Ödeme logunu kaydet
  Future<void> logPaymentAttempt({
    required String userId,
    required String bookId,
    required String paymentType,
    required String status,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection(_paymentLogsCollection).add({
        'userId': userId,
        'bookId': bookId,
        'paymentType': paymentType,
        'status': status,
        'errorMessage': errorMessage,
        'metadata': metadata ?? {},
        'timestamp': Timestamp.now(),
        'platform': 'flutter',
        'userAgent': 'Flutter App',
      });
      
      print('Ödeme logu kaydedildi: $status');
    } catch (e) {
      print('Ödeme logu kaydedilirken hata: $e');
    }
  }

  /// Satın alma işlemini logla
  Future<void> logPurchase({
    required String userId,
    required String bookId,
    required String paymentType,
    double? amount,
    String? currency,
    bool isFakePayment = true,
  }) async {
    try {
      // Ödeme işlemi logu
      await logPaymentTransaction(
        userId: userId,
        bookId: bookId,
        paymentType: paymentType,
        status: 'completed',
        amount: amount,
        currency: currency,
        gateway: isFakePayment ? 'fake_payment' : 'real_payment',
        metadata: {
          'isFakePayment': isFakePayment,
          'logSource': 'transaction_logger',
        },
      );

      // Kullanıcı aktivitesi logu
      await logUserActivity(
        userId: userId,
        activity: 'purchase_book',
        bookId: bookId,
        metadata: {
          'paymentType': paymentType,
          'amount': amount,
          'currency': currency,
          'isFakePayment': isFakePayment,
        },
      );

      print('Satın alma işlemi loglandı: $bookId');
    } catch (e) {
      print('Satın alma işlemi loglanırken hata: $e');
    }
  }

  /// Ödeme başarısızlığını logla
  Future<void> logPaymentFailure({
    required String userId,
    required String bookId,
    required String paymentType,
    required String errorMessage,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Ödeme işlemi logu
      await logPaymentTransaction(
        userId: userId,
        bookId: bookId,
        paymentType: paymentType,
        status: 'failed',
        gateway: 'unknown',
        metadata: {
          'errorMessage': errorMessage,
          'logSource': 'transaction_logger',
          ...?metadata,
        },
      );

      // Ödeme logu
      await logPaymentAttempt(
        userId: userId,
        bookId: bookId,
        paymentType: paymentType,
        status: 'failed',
        errorMessage: errorMessage,
        metadata: metadata,
      );

      print('Ödeme başarısızlığı loglandı: $errorMessage');
    } catch (e) {
      print('Ödeme başarısızlığı loglanırken hata: $e');
    }
  }

  /// Puan işlemini logla
  Future<void> logPointsTransaction({
    required String userId,
    required int pointsChange,
    required String reason,
    String? bookId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('points_transactions').add({
        'userId': userId,
        'pointsChange': pointsChange,
        'reason': reason,
        'bookId': bookId,
        'metadata': metadata ?? {},
        'timestamp': Timestamp.now(),
        'platform': 'flutter',
      });

      // Kullanıcı aktivitesi logu
      await logUserActivity(
        userId: userId,
        activity: 'points_transaction',
        bookId: bookId,
        metadata: {
          'pointsChange': pointsChange,
          'reason': reason,
          ...?metadata,
        },
      );

      print('Puan işlemi loglandı: $pointsChange puan ($reason)');
    } catch (e) {
      print('Puan işlemi loglanırken hata: $e');
    }
  }

  /// Kitap görüntüleme işlemini logla
  Future<void> logBookView({
    required String userId,
    required String bookId,
    String? source, // 'explore', 'search', 'category', etc.
  }) async {
    try {
      await logUserActivity(
        userId: userId,
        activity: 'view_book',
        bookId: bookId,
        metadata: {
          'source': source ?? 'unknown',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Kitap görüntüleme loglanırken hata: $e');
    }
  }

  /// Satın alma butonuna tıklama işlemini logla
  Future<void> logPurchaseButtonClick({
    required String userId,
    required String bookId,
    String? paymentType,
  }) async {
    try {
      await logUserActivity(
        userId: userId,
        activity: 'click_purchase_button',
        bookId: bookId,
        metadata: {
          'paymentType': paymentType,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Satın alma butonu tıklama loglanırken hata: $e');
    }
  }

  /// Ödeme dialog açılma işlemini logla
  Future<void> logPaymentDialogOpen({
    required String userId,
    required String bookId,
    String? paymentType,
  }) async {
    try {
      await logUserActivity(
        userId: userId,
        activity: 'open_payment_dialog',
        bookId: bookId,
        metadata: {
          'paymentType': paymentType,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Ödeme dialog açılma loglanırken hata: $e');
    }
  }

  /// Kullanıcının işlem geçmişini getir
  Future<List<PaymentTransactionModel>> getUserTransactionHistory({
    required String userId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => PaymentTransactionModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Kullanıcı işlem geçmişi getirilirken hata: $e');
      return [];
    }
  }

  /// Kullanıcının aktivite geçmişini getir
  Future<List<Map<String, dynamic>>> getUserActivityHistory({
    required String userId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_userActivitiesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          'id': doc.id,
          ...data,
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      print('Kullanıcı aktivite geçmişi getirilirken hata: $e');
      return <Map<String, dynamic>>[];
    }
  }

  /// Belirli bir tarih aralığındaki işlemleri getir
  Future<List<PaymentTransactionModel>> getTransactionsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startTimestamp = Timestamp.fromDate(startDate);
      final endTimestamp = Timestamp.fromDate(endDate);

      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
          .where('createdAt', isLessThanOrEqualTo: endTimestamp)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => PaymentTransactionModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Tarih aralığı işlemleri getirilirken hata: $e');
      return [];
    }
  }

  /// İstatistik verilerini getir
  Future<Map<String, dynamic>> getTransactionStats({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId);

      if (startDate != null && endDate != null) {
        final startTimestamp = Timestamp.fromDate(startDate);
        final endTimestamp = Timestamp.fromDate(endDate);
        query = query
            .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
            .where('createdAt', isLessThanOrEqualTo: endTimestamp);
      }

      final snapshot = await query.get();

      int totalTransactions = 0;
      int completedTransactions = 0;
      int failedTransactions = 0;
      double totalAmount = 0;
      Map<String, int> paymentTypeCount = {};
      Map<String, double> paymentTypeAmount = {};

      for (var doc in snapshot.docs) {
        final transaction = PaymentTransactionModel.fromFirestore(doc);
        totalTransactions++;

        if (transaction.isCompleted) {
          completedTransactions++;
          if (transaction.amount != null) {
            totalAmount += transaction.amount!;
          }
        } else if (transaction.isFailed) {
          failedTransactions++;
        }

        // Ödeme tipi istatistikleri
        paymentTypeCount[transaction.paymentType] = 
            (paymentTypeCount[transaction.paymentType] ?? 0) + 1;
        
        if (transaction.amount != null) {
          paymentTypeAmount[transaction.paymentType] = 
              (paymentTypeAmount[transaction.paymentType] ?? 0) + transaction.amount!;
        }
      }

      return {
        'totalTransactions': totalTransactions,
        'completedTransactions': completedTransactions,
        'failedTransactions': failedTransactions,
        'successRate': totalTransactions > 0 ? (completedTransactions / totalTransactions) * 100 : 0,
        'totalAmount': totalAmount,
        'paymentTypeCount': paymentTypeCount,
        'paymentTypeAmount': paymentTypeAmount,
      };
    } catch (e) {
      print('İşlem istatistikleri getirilirken hata: $e');
      return {};
    }
  }
} 