import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order.dart' as OrderModel;
import '../models/order_item.dart';
import '../models/cart_item.dart';
import 'payment_service.dart';
import 'cart_service.dart';

/// Order Statistics Model
class OrderStatistics {
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double averageOrderValue;

  const OrderStatistics({
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
  });
}

/// Order Service
///
/// Handles all order-related operations with Firestore
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PaymentService _paymentService = PaymentService();
  final CartService _cartService = CartService();

  // Demo mode for testing (always use successful payments)
  bool get isDemoMode => kDebugMode;

  // In-memory storage for demo orders
  static final List<OrderModel.Order> _demoOrders = [];

  /// Collection reference for orders
  CollectionReference get _ordersCollection => _firestore.collection('orders');

  /// Create order from cart items
  Future<OrderModel.Order> createOrderFromCart({
    required String userId,
    required PaymentMethod paymentMethod,
    String? shippingAddress,
    String? billingAddress,
    String? notes,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
  }) async {
    if (kDebugMode) {
      print('🛒 OrderService: Creating order from cart for user: $userId');
      print('💳 OrderService: Payment method: ${paymentMethod.displayName}');
      print('🏠 OrderService: Shipping address: $shippingAddress');
      print('🔧 OrderService: Demo mode: $isDemoMode');
    }

    // Demo mode - create mock order without Firestore
    if (isDemoMode && kDebugMode) {
      return _createDemoOrder(
        userId: userId,
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        notes: notes,
      );
    }

    try {
      // Get cart items
      final cartItems = await _cartService.getCartItems(userId);
      if (cartItems.isEmpty) {
        throw Exception('Sepet boş, sipariş oluşturulamaz');
      }

      if (kDebugMode) {
        print('📦 OrderService: Found ${cartItems.length} items in cart');
      }

      // Convert cart items to order items
      final orderItems = cartItems.map((cartItem) {
        return OrderItem(
          bookId: cartItem.bookId,
          title: cartItem.title,
          author: cartItem.author,
          imageUrl: cartItem.imageUrl,
          price: cartItem.price,
          quantity: cartItem.quantity,
          addedAt: DateTime.now(),
        );
      }).toList();

      // Calculate totals
      final totalPrice = orderItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      final taxAmount = totalPrice * 0.18; // 18% KDV
      final shippingFee = totalPrice > 100
          ? 0.0
          : 9.99; // Free shipping over 100 TL
      final discountAmount = 0.0; // Future: implement discounts
      final finalTotal = totalPrice + taxAmount + shippingFee - discountAmount;

      // Create order
      final orderData = {
        'userId': userId,
        'items': orderItems.map((item) => item.toMap()).toList(),
        'totalPrice': totalPrice,
        'taxAmount': taxAmount,
        'shippingFee': shippingFee,
        'discountAmount': discountAmount,
        'finalTotal': finalTotal,
        'status': OrderModel.OrderStatus.pending.name,
        'paymentStatus': OrderModel.PaymentStatus.pending.name,
        'orderDate': Timestamp.fromDate(DateTime.now()),
        'shippingAddress': shippingAddress,
        'billingAddress': billingAddress,
        'paymentMethod': paymentMethod.displayName,
        'notes': notes,
        'metadata': {
          'createdFrom': 'cart',
          'itemCount': orderItems.length,
          'platform': 'web',
        },
      };

      if (kDebugMode) {
        print('📝 OrderService: About to write order to Firestore...');
        print(
          '📊 OrderService: Order data prepared - Items: ${orderItems.length}, Total: $finalTotal',
        );
      }

      // Add to Firestore
      final docRef = await _ordersCollection
          .add(orderData)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (kDebugMode) {
                print(
                  '⏰ OrderService: Firestore write operation timed out after 10 seconds!',
                );
              }
              throw Exception('Firestore yazma işlemi zaman aşımına uğradı');
            },
          );

      if (kDebugMode) {
        print('✅ OrderService: Order created with ID: ${docRef.id}');
        print(
          '🔧 OrderService: About to process payment - Demo mode: $isDemoMode',
        );
        print('💰 OrderService: Payment amount: $finalTotal');
        print('💳 OrderService: Payment method: ${paymentMethod.displayName}');
      }

      // Process payment with appropriate timeout
      PaymentResult paymentResult;
      try {
        if (isDemoMode) {
          if (kDebugMode) {
            print('🎯 OrderService: Starting DEMO payment processing...');
          }
          paymentResult = await _paymentService
              .processDemoPayment(amount: finalTotal, method: paymentMethod)
              .timeout(
                const Duration(seconds: 10), // Longer timeout for demo
                onTimeout: () {
                  if (kDebugMode) {
                    print(
                      '⏰ OrderService: Demo payment timeout after 10 seconds',
                    );
                  }
                  return PaymentResult.failure(
                    errorMessage: 'Demo ödeme zaman aşımına uğradı',
                    method: paymentMethod,
                    amount: finalTotal,
                  );
                },
              );
        } else {
          if (kDebugMode) {
            print('💳 OrderService: Starting REAL payment processing...');
          }
          paymentResult = await _paymentService
              .processPayment(
                amount: finalTotal,
                method: paymentMethod,
                cardNumber: cardNumber,
                cardHolderName: cardHolderName,
                expiryDate: expiryDate,
                cvv: cvv,
              )
              .timeout(
                const Duration(seconds: 15), // Longer timeout for real payments
                onTimeout: () {
                  if (kDebugMode) {
                    print(
                      '⏰ OrderService: Real payment timeout after 15 seconds',
                    );
                  }
                  return PaymentResult.failure(
                    errorMessage: 'Ödeme işlemi zaman aşımına uğradı',
                    method: paymentMethod,
                    amount: finalTotal,
                  );
                },
              );
        }
      } catch (e) {
        if (kDebugMode) {
          print('💥 OrderService: Payment processing threw exception: $e');
        }
        paymentResult = PaymentResult.failure(
          errorMessage: 'Ödeme işlemi sırasında hata oluştu: $e',
          method: paymentMethod,
          amount: finalTotal,
        );
      }

      if (kDebugMode) {
        print(
          '💳 OrderService: Payment result - Success: ${paymentResult.isSuccess}, Transaction: ${paymentResult.transactionId}',
        );
        if (!paymentResult.isSuccess) {
          print(
            '❌ OrderService: Payment error - ${paymentResult.errorMessage}',
          );
        }
      }

      // Update order with payment result
      OrderModel.PaymentStatus newPaymentStatus;
      OrderModel.OrderStatus newOrderStatus;

      if (paymentResult.isSuccess) {
        newPaymentStatus = OrderModel.PaymentStatus.completed;
        newOrderStatus = OrderModel.OrderStatus.confirmed;

        // Clear cart after successful payment
        await _cartService.clearCart(userId);

        if (kDebugMode) {
          print(
            '✅ OrderService: Payment successful, cart cleared for order: ${docRef.id}',
          );
        }
      } else {
        newPaymentStatus = OrderModel.PaymentStatus.failed;
        newOrderStatus = OrderModel.OrderStatus.cancelled;

        if (kDebugMode) {
          print(
            '❌ OrderService: Payment failed for order: ${docRef.id} - ${paymentResult.errorMessage}',
          );
        }
      }

      // Update order status
      await docRef.update({
        'paymentStatus': newPaymentStatus.name,
        'status': newOrderStatus.name,
        'metadata.transactionId': paymentResult.transactionId,
        'metadata.paymentError': paymentResult.errorMessage,
        'metadata.paymentTimestamp': Timestamp.fromDate(
          paymentResult.timestamp,
        ),
      });

      // Get updated order
      final updatedDoc = await docRef.get();
      final order = OrderModel.Order.fromFirestore(updatedDoc);

      if (!paymentResult.isSuccess) {
        throw Exception('Ödeme başarısız: ${paymentResult.errorMessage}');
      }

      return order;
    } catch (e) {
      if (kDebugMode) {
        print('❌ OrderService: Error creating order: $e');
      }
      rethrow;
    }
  }

  /// Get orders for user as stream
  Stream<List<OrderModel.Order>> getOrdersForUserStream(String userId) {
    if (kDebugMode) {
      print('📊 OrderService: Starting orders stream for user: $userId');
    }

    // In demo mode, combine Firestore orders with in-memory demo orders
    if (isDemoMode && kDebugMode) {
      return _ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .snapshots()
          .map((snapshot) {
            final firestoreOrders = snapshot.docs
                .map((doc) => OrderModel.Order.fromFirestore(doc))
                .toList();

            // Get demo orders for this user
            final userDemoOrders = _demoOrders
                .where((order) => order.userId == userId)
                .toList();

            // Combine and sort by date
            final allOrders = [...firestoreOrders, ...userDemoOrders];
            allOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

            if (kDebugMode) {
              print(
                '📦 OrderService: Loaded ${firestoreOrders.length} Firestore + ${userDemoOrders.length} demo orders for user $userId',
              );
            }

            return allOrders;
          });
    }

    // Regular mode - only Firestore orders
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.Order.fromFirestore(doc))
              .toList();

          if (kDebugMode) {
            print(
              '📦 OrderService: Loaded ${orders.length} orders for user $userId',
            );
          }

          return orders;
        });
  }

  /// Get orders for user (one-time fetch)
  Future<List<OrderModel.Order>> getOrdersForUser(String userId) async {
    try {
      if (kDebugMode) {
        print('📊 OrderService: Fetching orders for user: $userId');
      }

      // Demo mode - return demo orders from memory
      if (isDemoMode) {
        final demoOrders = _demoOrders
            .where((order) => order.userId == userId)
            .toList();
        if (kDebugMode) {
          print(
            '📦 OrderService: Loaded ${_demoOrders.length} demo orders total, ${demoOrders.length} for user $userId',
          );
        }
        return demoOrders;
      }

      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .get();

      final orders = snapshot.docs
          .map((doc) => OrderModel.Order.fromFirestore(doc))
          .toList();

      if (kDebugMode) {
        print(
          '📦 OrderService: Fetched ${orders.length} orders for user $userId',
        );
      }

      return orders;
    } catch (e) {
      if (kDebugMode) {
        print('❌ OrderService: Error fetching orders: $e');
      }
      rethrow;
    }
  }

  /// Get single order by ID
  Future<OrderModel.Order?> getOrderById(String orderId) async {
    try {
      if (kDebugMode) {
        print('📊 OrderService: Fetching order by ID: $orderId');
      }

      // Demo mode - find in demo orders
      if (isDemoMode) {
        final demoOrder = _demoOrders
            .where((order) => order.orderNumber == orderId)
            .firstOrNull;
        if (kDebugMode) {
          print(
            '📦 OrderService: ${demoOrder != null ? 'Found' : 'Not found'} demo order: $orderId',
          );
        }
        return demoOrder;
      }

      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return OrderModel.Order.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ OrderService: Error fetching order $orderId: $e');
      }
      rethrow;
    }
  }

  /// Get order by ID as stream
  Stream<OrderModel.Order?> getOrderByIdStream(String orderId) {
    return _ordersCollection.doc(orderId).snapshots().map((doc) {
      if (doc.exists) {
        return OrderModel.Order.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      if (kDebugMode) {
        print('🚫 OrderService: Cancelling order: $orderId');
      }

      final orderDoc = await _ordersCollection.doc(orderId).get();
      if (!orderDoc.exists) {
        throw Exception('Sipariş bulunamadı');
      }

      final order = OrderModel.Order.fromFirestore(orderDoc);

      // Check if order can be cancelled
      if (!order.canBeCancelled) {
        throw Exception('Bu sipariş iptal edilemez');
      }

      // Update order status
      await _ordersCollection.doc(orderId).update({
        'status': OrderModel.OrderStatus.cancelled.name,
        'metadata.cancellationReason': reason,
        'metadata.cancellationDate': Timestamp.fromDate(DateTime.now()),
      });

      // Process refund if payment was completed
      if (order.paymentStatus == OrderModel.PaymentStatus.completed) {
        final paymentMethod = PaymentMethod.values.firstWhere(
          (method) => method.displayName == order.paymentMethod,
          orElse: () => PaymentMethod.creditCard,
        );

        final refundResult = await _paymentService.processRefund(
          transactionId: order.metadata?['transactionId'] ?? '',
          amount: order.finalTotal,
          method: paymentMethod,
          reason: reason,
        );

        if (refundResult.isSuccess) {
          await _ordersCollection.doc(orderId).update({
            'paymentStatus': OrderModel.PaymentStatus.refunded.name,
            'status': OrderModel.OrderStatus.refunded.name,
            'metadata.refundTransactionId': refundResult.transactionId,
            'metadata.refundDate': Timestamp.fromDate(refundResult.timestamp),
          });
        }
      }

      if (kDebugMode) {
        print('✅ OrderService: Order cancelled: $orderId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ OrderService: Error cancelling order: $e');
      }
      rethrow;
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(
    String orderId,
    OrderModel.OrderStatus newStatus,
  ) async {
    try {
      if (kDebugMode) {
        print(
          '📝 OrderService: Updating order $orderId status to ${newStatus.name}',
        );
      }

      final updates = <String, dynamic>{
        'status': newStatus.name,
        'metadata.lastStatusUpdate': Timestamp.fromDate(DateTime.now()),
      };

      // Add specific timestamps for certain statuses
      switch (newStatus) {
        case OrderModel.OrderStatus.shipped:
          updates['shippingDate'] = Timestamp.fromDate(DateTime.now());
          break;
        case OrderModel.OrderStatus.delivered:
          updates['deliveryDate'] = Timestamp.fromDate(DateTime.now());
          break;
        default:
          break;
      }

      await _ordersCollection.doc(orderId).update(updates);

      if (kDebugMode) {
        print('✅ OrderService: Order status updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ OrderService: Error updating order status: $e');
      }
      rethrow;
    }
  }

  /// Get order statistics for user
  Future<OrderStatistics> getOrderStatistics(String userId) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .get();

      final orders = snapshot.docs
          .map((doc) => OrderModel.Order.fromFirestore(doc))
          .toList();

      final totalOrders = orders.length;
      final completedOrders = orders.where((order) => order.isCompleted).length;
      final cancelledOrders = orders
          .where(
            (order) =>
                order.status == OrderModel.OrderStatus.cancelled ||
                order.status == OrderModel.OrderStatus.refunded,
          )
          .length;

      final totalRevenue = orders
          .where(
            (order) =>
                order.paymentStatus == OrderModel.PaymentStatus.completed,
          )
          .fold(0.0, (sum, order) => sum + order.finalTotal);

      final averageOrderValue = totalOrders > 0
          ? totalRevenue / totalOrders
          : 0.0;

      return OrderStatistics(
        totalOrders: totalOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
        totalRevenue: totalRevenue,
        averageOrderValue: averageOrderValue,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ OrderService: Error getting order statistics: $e');
      }
      rethrow;
    }
  }

  /// Check if user has orders
  Future<bool> hasOrders(String userId) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('❌ OrderService: Error checking if user has orders: $e');
      }
      return false;
    }
  }

  /// Get orders count for user
  Future<int> getOrdersCount(String userId) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      if (kDebugMode) {
        print('❌ OrderService: Error getting orders count: $e');
      }
      return 0;
    }
  }

  /// Add sample orders for testing
  Future<void> addSampleOrders(String userId) async {
    try {
      if (kDebugMode) {
        print('📊 OrderService: Adding sample orders for user: $userId');
      }

      final sampleOrders = [
        {
          'userId': userId,
          'items': [
            {
              'bookId': 'sample-book-1',
              'title': 'Flutter Geliştiriciler İçin Kılavuz',
              'author': 'Google Flutter Team',
              'imageUrl':
                  'https://via.placeholder.com/150x200/0066CC/FFFFFF?text=Flutter',
              'price': 59.99,
              'quantity': 1,
              'addedAt': Timestamp.fromDate(DateTime.now()),
            },
            {
              'bookId': 'sample-book-2',
              'title': 'Dart Programlama Dili',
              'author': 'Dart Team',
              'imageUrl':
                  'https://via.placeholder.com/150x200/00C4A7/FFFFFF?text=Dart',
              'price': 39.99,
              'quantity': 2,
              'addedAt': Timestamp.fromDate(DateTime.now()),
            },
          ],
          'totalPrice': 139.97,
          'taxAmount': 25.19,
          'shippingFee': 0.0,
          'discountAmount': 0.0,
          'finalTotal': 165.16,
          'status': OrderModel.OrderStatus.delivered.name,
          'paymentStatus': OrderModel.PaymentStatus.completed.name,
          'orderDate': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 7)),
          ),
          'deliveryDate': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 2)),
          ),
          'paymentMethod': 'Kredi Kartı',
          'shippingAddress': 'Örnek Mahallesi, Örnek Sokak No:1, İstanbul',
          'notes': 'Hızlı teslimat talep ediliyor',
          'metadata': {
            'createdFrom': 'sample',
            'itemCount': 2,
            'platform': 'web',
            'transactionId': 'TXN123456789',
          },
        },
        {
          'userId': userId,
          'items': [
            {
              'bookId': 'sample-book-3',
              'title': 'Firebase ile Mobil Uygulama Geliştirme',
              'author': 'Firebase Team',
              'imageUrl':
                  'https://via.placeholder.com/150x200/FF6F00/FFFFFF?text=Firebase',
              'price': 49.99,
              'quantity': 1,
              'addedAt': Timestamp.fromDate(DateTime.now()),
            },
          ],
          'totalPrice': 49.99,
          'taxAmount': 9.00,
          'shippingFee': 9.99,
          'discountAmount': 0.0,
          'finalTotal': 68.98,
          'status': OrderModel.OrderStatus.shipped.name,
          'paymentStatus': OrderModel.PaymentStatus.completed.name,
          'orderDate': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 3)),
          ),
          'shippingDate': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1)),
          ),
          'paymentMethod': 'Apple Pay',
          'trackingNumber': 'TR123456789',
          'metadata': {
            'createdFrom': 'sample',
            'itemCount': 1,
            'platform': 'web',
            'transactionId': 'TXN987654321',
          },
        },
      ];

      for (final orderData in sampleOrders) {
        await _ordersCollection.add(orderData);
      }

      if (kDebugMode) {
        print('✅ OrderService: Sample orders added');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ OrderService: Error adding sample orders: $e');
      }
      rethrow;
    }
  }

  /// Create demo order for testing without Firestore
  Future<OrderModel.Order> _createDemoOrder({
    required String userId,
    required PaymentMethod paymentMethod,
    String? shippingAddress,
    String? billingAddress,
    String? notes,
  }) async {
    if (kDebugMode) {
      print('🎯 OrderService: Creating DEMO order (no Firestore)');
    }

    try {
      // Get cart items for demo
      final cartItems = await _cartService.getCartItems(userId);
      if (cartItems.isEmpty) {
        throw Exception('Sepet boş, sipariş oluşturulamaz');
      }

      if (kDebugMode) {
        print(
          '📦 OrderService: Found ${cartItems.length} items in cart (demo)',
        );
      }

      // Convert cart items to order items
      final orderItems = cartItems.map((cartItem) {
        return OrderItem(
          bookId: cartItem.bookId,
          title: cartItem.title,
          author: cartItem.author,
          imageUrl: cartItem.imageUrl,
          price: cartItem.price,
          quantity: cartItem.quantity,
          addedAt: DateTime.now(),
        );
      }).toList();

      // Calculate totals
      final totalPrice = orderItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      final taxAmount = totalPrice * 0.18; // 18% KDV
      final shippingFee = totalPrice > 100 ? 0.0 : 9.99;
      final discountAmount = 0.0;
      final finalTotal = totalPrice + taxAmount + shippingFee - discountAmount;

      if (kDebugMode) {
        print('💰 OrderService: Demo order total: $finalTotal');
        print('🎯 OrderService: Starting DEMO payment processing...');
      }

      // Process demo payment
      final paymentResult = await _paymentService.processDemoPayment(
        amount: finalTotal,
        method: paymentMethod,
      );

      if (kDebugMode) {
        print(
          '💳 OrderService: Demo payment result - Success: ${paymentResult.isSuccess}, Transaction: ${paymentResult.transactionId}',
        );
      }

      if (!paymentResult.isSuccess) {
        throw Exception('Demo ödeme başarısız: ${paymentResult.errorMessage}');
      }

      if (kDebugMode) {
        print(
          '🎯 OrderService: About to clear cart and create order object...',
        );
      }

      // Create mock order object FIRST (before cart clearing)
      if (kDebugMode) {
        print('🔨 OrderService: Creating demo order object...');
      }

      final demoOrderId = 'demo-order-${DateTime.now().millisecondsSinceEpoch}';
      final order = OrderModel.Order(
        id: demoOrderId,
        userId: userId,
        items: orderItems,
        totalPrice: totalPrice,
        taxAmount: taxAmount,
        shippingFee: shippingFee,
        discountAmount: discountAmount,
        finalTotal: finalTotal,
        status: OrderModel.OrderStatus.confirmed,
        paymentStatus: OrderModel.PaymentStatus.completed,
        orderDate: DateTime.now(),
        shippingAddress: shippingAddress ?? 'Demo Teslimat Adresi',
        billingAddress: billingAddress ?? 'Demo Fatura Adresi',
        paymentMethod: paymentMethod.displayName,
        notes: notes,
        metadata: {
          'createdFrom': 'demo',
          'itemCount': orderItems.length,
          'platform': 'web',
          'transactionId': paymentResult.transactionId,
          'isDemoOrder': true,
        },
      );

      if (kDebugMode) {
        print(
          '🎉 OrderService: Demo order created successfully: ${order.orderNumber}',
        );
      }

      // Add to in-memory demo storage
      _demoOrders.add(order);

      if (kDebugMode) {
        print(
          '💾 OrderService: Demo order added to memory storage (${_demoOrders.length} total)',
        );
      }

      // Clear cart after successful payment (async but don't wait)
      _cartService.clearCart(userId).catchError((e) {
        if (kDebugMode) {
          print('⚠️ OrderService: Cart clearing error (non-blocking): $e');
        }
      });

      if (kDebugMode) {
        print(
          '✅ OrderService: Demo payment successful, cart clearing initiated',
        );
      }

      return order;
    } catch (e) {
      if (kDebugMode) {
        print('❌ OrderService: Error creating demo order: $e');
      }
      rethrow;
    }
  }
}
