import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/book_model.dart';
import '../services/cart_service.dart';

/// Cart Provider - Manages cart state with instant feedback
class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  // State variables
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cartItems.length;
  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get hasItems => _cartItems.isNotEmpty;

  /// Add book to cart
  Future<void> addToCart(BookModel book, String userId) async {
    try {
      _setLoading(true);
      await _cartService.addToCart(book: book, userId: userId);

      // Add to local state if not already exists
      if (!_cartItems.any((item) => item.bookId == book.id)) {
        final newCartItem = CartItem.fromBookModel(
          book: book,
          userId: userId,
          quantity: 1,
        );
        _cartItems.add(newCartItem);
      }

      _clearError();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      _setLoading(true);
      await _cartService.removeFromCart(cartItemId);
      _cartItems.removeWhere((item) => item.id == cartItemId);
      _clearError();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      _setLoading(true);

      if (quantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      await _cartService.updateCartItemQuantity(cartItemId, quantity);

      final index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      }

      _clearError();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Load cart items for user
  Future<void> loadCartItems(String userId) async {
    try {
      _setLoading(true);
      _cartItems = await _cartService.getCartItems(userId);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all cart items
  Future<void> clearCart(String userId) async {
    try {
      _setLoading(true);
      await _cartService.clearCart(userId);
      _cartItems.clear();
      _clearError();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if book is in cart
  bool isBookInCart(String bookId) {
    return _cartItems.any((item) => item.bookId == bookId);
  }

  /// Get cart item by book ID
  CartItem? getCartItemByBookId(String bookId) {
    try {
      return _cartItems.firstWhere((item) => item.bookId == bookId);
    } catch (e) {
      return null;
    }
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data (for logout)
  void clear() {
    _cartItems.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
