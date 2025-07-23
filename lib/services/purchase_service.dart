import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';
import 'auth_service.dart';
import 'package:flutter/foundation.dart';

/// Purchase Service
/// Handles book purchasing, validation, and payment processing
class PurchaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Cache for purchased books
  final Set<String> _purchasedBooks = {};
  bool _purchasesLoaded = false;

  /// Initialize purchased books cache
  Future<void> initializePurchases() async {
    if (_purchasesLoaded) return;

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _purchasesLoaded = true;
      return;
    }

    try {
      // Load from SharedPreferences first (always works offline)
      final prefs = await SharedPreferences.getInstance();
      final purchasedIds = prefs.getStringList('purchased_books_$userId') ?? [];
      _purchasedBooks.addAll(purchasedIds);

      if (kDebugMode) {
        print(
          '💰 PurchaseService: Loaded ${purchasedIds.length} purchased books from local storage',
        );
      }

      // Try to load from Firestore with shorter timeout
      try {
        final userPurchasesDoc = await _firestore
            .collection('userPurchases')
            .doc(userId)
            .get()
            .timeout(const Duration(seconds: 2)); // Much shorter timeout

        if (userPurchasesDoc.exists) {
          final data = userPurchasesDoc.data() as Map<String, dynamic>;
          final remotePurchases = List<String>.from(
            data['purchasedBooks'] ?? [],
          );
          _purchasedBooks.addAll(remotePurchases);

          // Save merged data to local storage
          await _savePurchasesToLocal(userId);

          if (kDebugMode) {
            print(
              '💰 PurchaseService: Merged with ${remotePurchases.length} remote purchases',
            );
          }
        }
      } catch (e) {
        // Firestore timeout/offline - continue with local data only
        if (kDebugMode) {
          print(
            '💰 PurchaseService: Firestore unavailable, using local cache only: $e',
          );
        }
      }

      _purchasesLoaded = true;
      if (kDebugMode) {
        print(
          '💰 PurchaseService: Initialization complete - ${_purchasedBooks.length} total purchased books',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ PurchaseService: Error initializing purchases: $e');
      }
      _purchasedBooks.clear(); // Start with empty cache on error
      _purchasesLoaded = true;
    }
  }

  /// Check if a book is purchased
  Future<bool> isBookPurchased(String bookId) async {
    await initializePurchases();
    return _purchasedBooks.contains(bookId);
  }

  /// Purchase a book
  Future<bool> purchaseBook({
    required BookModel book,
    required String userId,
    String? paymentMethod,
  }) async {
    try {
      // Check if already purchased
      if (await isBookPurchased(book.id)) {
        print('⚠️ Book already purchased: ${book.title}');
        return false;
      }

      // Simulate payment processing
      await _processPayment(
        amount: book.price,
        bookId: book.id,
        userId: userId,
        paymentMethod: paymentMethod,
      );

      // Add to purchased books
      _purchasedBooks.add(book.id);

      // Save to local storage
      await _savePurchasesToLocal(userId);

      // Save to Firestore
      await _savePurchaseToFirestore(book, userId);

      print('💰 Book purchased successfully: ${book.title}');
      return true;
    } catch (e) {
      print('❌ Error purchasing book: $e');
      return false;
    }
  }

  /// Process payment (simulation)
  Future<void> _processPayment({
    required double amount,
    required String bookId,
    required String userId,
    String? paymentMethod,
  }) async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real implementation, integrate with payment provider:
    // - Stripe, PayPal, Apple Pay, Google Pay, etc.
    // - Handle payment validation
    // - Process refunds
    // - Manage payment history

    print('💳 Payment processed: ₺$amount for book $bookId');
  }

  /// Save purchase to Firestore
  Future<void> _savePurchaseToFirestore(BookModel book, String userId) async {
    try {
      // Add to user's purchases collection
      await _firestore.collection('userPurchases').doc(userId).set({
        'purchasedBooks': _purchasedBooks.toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add to individual purchase record
      await _firestore.collection('purchases').add({
        'userId': userId,
        'bookId': book.id,
        'bookTitle': book.title,
        'bookAuthor': book.author,
        'price': book.price,
        'purchaseDate': FieldValue.serverTimestamp(),
        'paymentStatus': 'completed',
      });

      print('💰 Purchase saved to Firestore: ${book.title}');
    } catch (e) {
      print('❌ Error saving purchase to Firestore: $e');
    }
  }

  /// Save purchases to local storage
  Future<void> _savePurchasesToLocal(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'purchased_books_$userId',
        _purchasedBooks.toList(),
      );
      print('💰 Purchases saved to local storage');
    } catch (e) {
      print('❌ Error saving purchases to local storage: $e');
    }
  }

  /// Get user's purchased books
  Future<List<String>> getPurchasedBooks() async {
    await initializePurchases();
    return _purchasedBooks.toList();
  }

  /// Get purchase history with details
  Future<List<Map<String, dynamic>>> getPurchaseHistory() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('purchases')
          .where('userId', isEqualTo: userId)
          .orderBy('purchaseDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'bookId': data['bookId'],
          'bookTitle': data['bookTitle'],
          'bookAuthor': data['bookAuthor'],
          'price': data['price'],
          'purchaseDate': data['purchaseDate'],
          'paymentStatus': data['paymentStatus'],
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting purchase history: $e');
      return [];
    }
  }

  /// Clear purchases cache (for logout)
  void clearCache() async {
    _purchasedBooks.clear();
    _purchasesLoaded = false;

    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('purchased_books_$userId');
      }
    } catch (e) {
      print('❌ Error clearing purchases cache: $e');
    }
  }

  /// Validate purchase (useful for security)
  Future<bool> validatePurchase(String bookId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return false;

    try {
      final purchaseQuery = await _firestore
          .collection('purchases')
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .where('paymentStatus', isEqualTo: 'completed')
          .get();

      return purchaseQuery.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error validating purchase: $e');
      return false;
    }
  }

  /// Check if user has purchased a book (alias for isBookPurchased)
  Future<bool> hasUserPurchasedBook(String userId, String bookId) async {
    // First ensure cache is loaded for this user
    await initializePurchases();

    // Check if book is in the purchased set
    final isPurchased = _purchasedBooks.contains(bookId);

    if (kDebugMode) {
      print(
        '💰 PurchaseService: Checking if user $userId purchased book $bookId: $isPurchased',
      );
      print(
        '💰 PurchaseService: Current purchased books cache: ${_purchasedBooks.length}',
      );
    }

    return isPurchased;
  }

  /// Purchase book with Turkish Lira (alias for purchaseBook)
  Future<bool> purchaseWithTL({
    required BookModel book,
    required String userId,
  }) async {
    return await purchaseBook(book: book, userId: userId, paymentMethod: 'TL');
  }

  /// Clear purchase cache for a specific user (call after purchase)
  Future<void> clearPurchaseCache() async {
    _purchasedBooks.clear();
    _purchasesLoaded = false;
    print('💰 Purchase cache cleared - will reload on next check');
  }

  /// Add book to purchased cache immediately (call after successful purchase)
  void addToPurchasedCache(String bookId) {
    _purchasedBooks.add(bookId);
    print('💰 Added $bookId to purchased cache immediately');
  }
}
