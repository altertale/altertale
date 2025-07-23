import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/book_model.dart';
import 'purchase_service.dart';

/// Cart Service for Firestore Operations
///
/// Handles all cart-related database operations including:
/// - Adding/removing items from cart
/// - Real-time cart updates
/// - Quantity management
/// - Price calculations
/// - User-specific cart operations
/// - Prevention of duplicate purchases
class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PurchaseService _purchaseService = PurchaseService();
  static const String _cartCollection = 'carts';

  // ==================== REAL-TIME CART STREAMS ====================

  /// Get real-time stream of user's cart items
  Stream<List<CartItem>> getCartItemsStream(String userId) {
    try {
      if (kDebugMode) {
        print('🛒 CartService: Starting cart stream for user: $userId');
      }

      return _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('addedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final cartItems = snapshot.docs
                .map((doc) => CartItem.fromFirestore(doc))
                .toList();

            if (kDebugMode) {
              print(
                '🛒 CartService: Loaded ${cartItems.length} cart items for user $userId',
              );
            }

            return cartItems;
          });
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error in getCartItemsStream: $e');
      }
      throw 'Sepet verileri yüklenirken hata oluştu: $e';
    }
  }

  /// Get real-time cart summary (total items, total price)
  Stream<CartSummary> getCartSummaryStream(String userId) {
    try {
      return getCartItemsStream(userId).map((cartItems) {
        return CartSummary.fromCartItems(cartItems);
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error in getCartSummaryStream: $e');
      }
      throw 'Sepet özeti yüklenirken hata oluştu: $e';
    }
  }

  // ==================== CART ITEM OPERATIONS ====================

  /// Add book to cart or show message if already exists
  Future<void> addToCart({
    required BookModel book,
    required String userId,
    int quantity = 1,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '🛒 CartService: Adding book to cart: ${book.title} (qty: $quantity)',
        );
      }

      // Check if book is already purchased
      final isPurchased = await _purchaseService.isBookPurchased(book.id);
      if (isPurchased) {
        if (kDebugMode) {
          print('🛒 CartService: Book already purchased: ${book.title}');
        }
        throw 'Bu kitap zaten satın alınmış! Kütüphanenizden okuyabilirsiniz.';
      }

      // Check if book already exists in cart
      final existingItem = await _getExistingCartItem(book.id, userId);

      if (existingItem != null) {
        // For digital books, don't allow duplicates - throw error with message
        if (kDebugMode) {
          print('🛒 CartService: Digital book already in cart: ${book.title}');
        }
        throw 'Bu kitap zaten sepete eklendi!';
      } else {
        // Add new item to cart with quantity 1 for digital books
        final cartItem = CartItem.fromBookModel(
          book: book,
          userId: userId,
          quantity: 1, // Always 1 for digital books
        );

        await _firestore.collection(_cartCollection).add(cartItem.toMap());

        if (kDebugMode) {
          print(
            '🛒 CartService: Added new digital book to cart: ${book.title}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error adding to cart: $e');
      }
      throw e is String ? e : 'Kitap sepete eklenirken hata oluştu: $e';
    }
  }

  /// Remove item from cart completely
  Future<void> removeFromCart(String cartItemId) async {
    try {
      if (kDebugMode) {
        print('🛒 CartService: Removing cart item: $cartItemId');
      }

      await _firestore.collection(_cartCollection).doc(cartItemId).delete();

      if (kDebugMode) {
        print('✅ CartService: Cart item removed: $cartItemId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error removing from cart: $e');
      }
      throw 'Sepetten çıkarma sırasında hata oluştu: $e';
    }
  }

  /// Update cart item quantity
  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      if (quantity <= 0) {
        // If quantity is 0 or negative, remove the item
        await removeFromCart(cartItemId);
        return;
      }

      await _updateCartItemQuantity(cartItemId, quantity);
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error updating quantity: $e');
      }
      throw 'Adet güncellenirken hata oluştu: $e';
    }
  }

  /// Clear entire cart for user
  Future<void> clearCart(String userId) async {
    try {
      if (kDebugMode) {
        print('🛒 CartService: Clearing cart for user: $userId');
      }

      final cartItems = await _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in cartItems.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ CartService: Cart cleared for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error clearing cart: $e');
      }
      throw 'Sepet temizlenirken hata oluştu: $e';
    }
  }

  // ==================== CART QUERIES ====================

  /// Get cart items as a one-time fetch
  Future<List<CartItem>> getCartItems(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error getting cart items: $e');
      }
      throw 'Sepet öğeleri alınırken hata oluştu: $e';
    }
  }

  /// Check if a book is already in cart
  Future<bool> isBookInCart(String bookId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_cartCollection)
          .where('bookId', isEqualTo: bookId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error checking if book in cart: $e');
      }
      return false;
    }
  }

  /// Get cart item count for user
  Future<int> getCartItemCount(String userId) async {
    try {
      final cartItems = await getCartItems(userId);
      return cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error getting cart count: $e');
      }
      return 0;
    }
  }

  /// Get cart total price
  Future<double> getCartTotalPrice(String userId) async {
    try {
      final cartItems = await getCartItems(userId);
      return cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error getting cart total: $e');
      }
      return 0.0;
    }
  }

  // ==================== PRIVATE HELPER METHODS ====================

  /// Get existing cart item for a book and user
  Future<CartItem?> _getExistingCartItem(String bookId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_cartCollection)
          .where('bookId', isEqualTo: bookId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return CartItem.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error getting existing cart item: $e');
      }
      return null;
    }
  }

  /// Update cart item quantity in Firestore
  Future<void> _updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      if (kDebugMode) {
        print(
          '🛒 CartService: Updating cart item quantity: $cartItemId -> $quantity',
        );
      }

      await _firestore.collection(_cartCollection).doc(cartItemId).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ CartService: Cart item quantity updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error updating cart item quantity: $e');
      }
      throw 'Adet güncellenirken hata oluştu: $e';
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Check if user has items in cart
  Future<bool> hasCartItems(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService: Error checking cart items: $e');
      }
      return false;
    }
  }

  /// Get formatted cart summary text
  Future<String> getCartSummaryText(String userId) async {
    try {
      final cartItems = await getCartItems(userId);
      if (cartItems.isEmpty) {
        return 'Sepetiniz boş';
      }

      final totalItems = cartItems.fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      );
      final totalPrice = cartItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      return '$totalItems ürün - ${totalPrice.toStringAsFixed(2)} ₺';
    } catch (e) {
      return 'Sepet bilgisi alınamadı';
    }
  }
}

/// Cart Summary Model
///
/// Contains aggregated cart information for UI display
class CartSummary {
  final int totalItems;
  final int uniqueItems;
  final double totalPrice;
  final bool isEmpty;

  const CartSummary({
    required this.totalItems,
    required this.uniqueItems,
    required this.totalPrice,
    required this.isEmpty,
  });

  factory CartSummary.fromCartItems(List<CartItem> cartItems) {
    final totalItems = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final totalPrice = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    return CartSummary(
      totalItems: totalItems,
      uniqueItems: cartItems.length,
      totalPrice: totalPrice,
      isEmpty: cartItems.isEmpty,
    );
  }

  factory CartSummary.empty() {
    return const CartSummary(
      totalItems: 0,
      uniqueItems: 0,
      totalPrice: 0.0,
      isEmpty: true,
    );
  }

  String get formattedTotalPrice {
    if (totalPrice == 0) {
      return 'Ücretsiz';
    }
    return '${totalPrice.toStringAsFixed(2)} ₺';
  }

  String get summaryText {
    if (isEmpty) {
      return 'Sepetiniz boş';
    }
    return '$totalItems ürün - $formattedTotalPrice';
  }

  String get itemCountText {
    if (isEmpty) {
      return 'Boş';
    }
    if (totalItems == 1) {
      return '1 ürün';
    }
    return '$totalItems ürün';
  }

  @override
  String toString() {
    return 'CartSummary(totalItems: $totalItems, uniqueItems: $uniqueItems, totalPrice: $totalPrice, isEmpty: $isEmpty)';
  }
}
