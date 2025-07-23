import 'package:flutter/foundation.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import '../models/book.dart';

/// Cart Provider - Manages cart state with instant feedback
class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  // State variables
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  // Getters
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cartItems.length;
  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  bool get hasItems => _cartItems.isNotEmpty;

  /// Initialize cart for user
  Future<void> initializeCart(String userId) async {
    if (_currentUserId == userId && _cartItems.isNotEmpty) {
      return; // Already initialized for this user
    }

    _currentUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cartItems = await _cartService.getCartItems(userId);

      if (kDebugMode) {
        print(
          '🛒 CartProvider: Initialized ${_cartItems.length} cart items for user: $userId',
        );
      }
    } catch (e) {
      _error = 'Sepet yüklenirken hata oluştu: $e';
      if (kDebugMode) {
        print('❌ CartProvider: Error initializing cart: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add book to cart with instant feedback
  Future<bool> addToCart(String userId, Book book) async {
    try {
      // Check if already in cart - proper duplicate prevention
      final isAlreadyInCart = _cartItems.any((item) => item.bookId == book.id);

      if (isAlreadyInCart) {
        // Already in cart - set error and return false
        _error = 'Bu kitap zaten sepete eklendi!';
        notifyListeners();

        if (kDebugMode) {
          print(
            '🛒 CartProvider: Duplicate prevented - Book already in cart: ${book.title}',
          );
        }

        return false;
      }

      // Add to cart service first
      await _cartService.addToCart(book: book, userId: userId);

      // Update local state immediately after successful service call
      final newCartItem = CartItem.fromBook(
        bookId: book.id,
        title: book.title,
        author: book.author,
        imageUrl: book.coverImageUrl,
        price: book.price,
        userId: userId,
        quantity: 1,
      );

      _cartItems.add(newCartItem);
      _error = null;

      // Notify listeners for instant UI update
      notifyListeners();

      if (kDebugMode) {
        print(
          '🛒 CartProvider: Added to cart with instant feedback: ${book.title}',
        );
      }

      return true;
    } catch (e) {
      // Service-level duplicate check
      if (e.toString().contains('zaten sepete eklendi')) {
        _error = 'Bu kitap zaten sepete eklendi!';
      } else {
        _error = e.toString();
      }

      if (kDebugMode) {
        print('❌ CartProvider: Error adding to cart: $e');
      }
      notifyListeners();
      return false;
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _cartService.removeFromCart(cartItemId);

      // Update local state immediately
      _cartItems.removeWhere((item) => item.id == cartItemId);
      _error = null;

      // Notify listeners for instant UI update
      notifyListeners();

      if (kDebugMode) {
        print(
          '🛒 CartProvider: Removed from cart with instant feedback: $cartItemId',
        );
      }
    } catch (e) {
      _error = 'Sepetten çıkarılırken hata oluştu: $e';
      if (kDebugMode) {
        print('❌ CartProvider: Error removing from cart: $e');
      }
      notifyListeners();
    }
  }

  /// Clear entire cart
  Future<void> clearCart(String userId) async {
    try {
      await _cartService.clearCart(userId);

      // Update local state immediately
      _cartItems.clear();
      _error = null;

      // Notify listeners for instant UI update
      notifyListeners();

      if (kDebugMode) {
        print('🛒 CartProvider: Cleared cart with instant feedback');
      }
    } catch (e) {
      _error = 'Sepet temizlenirken hata oluştu: $e';
      if (kDebugMode) {
        print('❌ CartProvider: Error clearing cart: $e');
      }
      notifyListeners();
    }
  }

  /// Check if book is in cart
  bool isBookInCart(String bookId) {
    return _cartItems.any((item) => item.bookId == bookId);
  }

  /// Refresh cart from service
  Future<void> refreshCart(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cartItems = await _cartService.getCartItems(userId);

      if (kDebugMode) {
        print('🛒 CartProvider: Refreshed ${_cartItems.length} cart items');
      }
    } catch (e) {
      _error = 'Sepet yenilenirken hata oluştu: $e';
      if (kDebugMode) {
        print('❌ CartProvider: Error refreshing cart: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all state (for logout)
  void clearState() {
    _cartItems.clear();
    _currentUserId = null;
    _error = null;
    _isLoading = false;
    notifyListeners();

    if (kDebugMode) {
      print('🛒 CartProvider: Cleared all state');
    }
  }

  /// Get cart item count for badge
  int getItemCount() {
    return _cartItems.length;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
