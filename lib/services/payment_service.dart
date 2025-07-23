import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/order.dart';

/// Payment Method Enum
enum PaymentMethod {
  creditCard('Kredi Kartı'),
  debitCard('Banka Kartı'),
  applePay('Apple Pay'),
  googlePay('Google Pay'),
  paypal('PayPal'),
  bankTransfer('Havale/EFT');

  const PaymentMethod(this.displayName);
  final String displayName;
}

/// Payment Result
class PaymentResult {
  final bool isSuccess;
  final String? transactionId;
  final String? errorMessage;
  final PaymentMethod? method;
  final double? amount;
  final DateTime timestamp;

  const PaymentResult({
    required this.isSuccess,
    this.transactionId,
    this.errorMessage,
    this.method,
    this.amount,
    required this.timestamp,
  });

  PaymentResult.success({
    required String transactionId,
    required PaymentMethod method,
    required double amount,
  }) : this(
         isSuccess: true,
         transactionId: transactionId,
         method: method,
         amount: amount,
         timestamp: DateTime.now(),
       );

  PaymentResult.failure({
    required String errorMessage,
    PaymentMethod? method,
    double? amount,
  }) : this(
         isSuccess: false,
         errorMessage: errorMessage,
         method: method,
         amount: amount,
         timestamp: DateTime.now(),
       );
}

/// Payment Service
///
/// Simulates payment processing for testing purposes
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final Random _random = Random();

  /// Simulate payment processing
  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod method,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
  }) async {
    if (kDebugMode) {
      print(
        '💳 PaymentService: Processing payment - Amount: $amount, Method: ${method.displayName}',
      );
    }

    // Simulate network delay
    await Future.delayed(Duration(seconds: 2 + _random.nextInt(3)));

    // Simulate payment validation
    if (amount <= 0) {
      if (kDebugMode) {
        print('❌ PaymentService: Invalid amount: $amount');
      }
      return PaymentResult.failure(
        errorMessage: 'Geçersiz ödeme tutarı',
        method: method,
        amount: amount,
      );
    }

    // Simulate card validation for card payments
    if (method == PaymentMethod.creditCard ||
        method == PaymentMethod.debitCard) {
      if (cardNumber == null || cardNumber.isEmpty) {
        if (kDebugMode) {
          print('❌ PaymentService: Missing card number');
        }
        return PaymentResult.failure(
          errorMessage: 'Kart numarası gerekli',
          method: method,
          amount: amount,
        );
      }

      if (cardHolderName == null || cardHolderName.isEmpty) {
        if (kDebugMode) {
          print('❌ PaymentService: Missing card holder name');
        }
        return PaymentResult.failure(
          errorMessage: 'Kart sahibi adı gerekli',
          method: method,
          amount: amount,
        );
      }

      // Simulate invalid card number
      if (cardNumber.startsWith('4000')) {
        if (kDebugMode) {
          print('❌ PaymentService: Invalid card number: $cardNumber');
        }
        return PaymentResult.failure(
          errorMessage: 'Kart numarası geçersiz',
          method: method,
          amount: amount,
        );
      }

      // Test cards that always succeed
      if (cardNumber.startsWith('4242') ||
          cardNumber.startsWith('1234') ||
          cardNumber.startsWith('5555')) {
        if (kDebugMode) {
          print(
            '✅ PaymentService: Using test card that always succeeds: $cardNumber',
          );
        }
        final transactionId = _generateTransactionId();
        return PaymentResult.success(
          transactionId: transactionId,
          method: method,
          amount: amount,
        );
      }

      // Simulate insufficient funds
      if (cardNumber.endsWith('0002')) {
        if (kDebugMode) {
          print('❌ PaymentService: Insufficient funds for card: $cardNumber');
        }
        return PaymentResult.failure(
          errorMessage: 'Yetersiz bakiye',
          method: method,
          amount: amount,
        );
      }

      // Simulate expired card
      if (cardNumber.endsWith('0003')) {
        if (kDebugMode) {
          print('❌ PaymentService: Expired card: $cardNumber');
        }
        return PaymentResult.failure(
          errorMessage: 'Kartın süresi dolmuş',
          method: method,
          amount: amount,
        );
      }
    }

    // Simulate random payment failures (2% chance for better testing)
    if (_random.nextDouble() < 0.02) {
      final errors = [
        'Banka tarafından reddedildi',
        'Ağ hatası oluştu',
        'İşlem zaman aşımına uğradı',
        'Kart limiti aşıldı',
        'Güvenlik kontrolü başarısız',
      ];
      final errorMessage = errors[_random.nextInt(errors.length)];

      if (kDebugMode) {
        print('❌ PaymentService: Random failure: $errorMessage');
      }

      return PaymentResult.failure(
        errorMessage: errorMessage,
        method: method,
        amount: amount,
      );
    }

    // Successful payment
    final transactionId = _generateTransactionId();

    if (kDebugMode) {
      print(
        '✅ PaymentService: Payment successful - Transaction ID: $transactionId',
      );
    }

    return PaymentResult.success(
      transactionId: transactionId,
      method: method,
      amount: amount,
    );
  }

  /// Process refund
  Future<PaymentResult> processRefund({
    required String transactionId,
    required double amount,
    required PaymentMethod method,
    String? reason,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1 + _random.nextInt(2)));

    // Simulate refund validation
    if (transactionId.isEmpty) {
      return PaymentResult.failure(
        errorMessage: 'Geçersiz işlem ID',
        method: method,
        amount: amount,
      );
    }

    if (amount <= 0) {
      return PaymentResult.failure(
        errorMessage: 'Geçersiz iade tutarı',
        method: method,
        amount: amount,
      );
    }

    // Simulate random refund failures (5% chance)
    if (_random.nextDouble() < 0.05) {
      return PaymentResult.failure(
        errorMessage: 'İade işlemi başarısız oldu',
        method: method,
        amount: amount,
      );
    }

    // Successful refund
    final refundTransactionId = _generateTransactionId();
    return PaymentResult.success(
      transactionId: refundTransactionId,
      method: method,
      amount: amount,
    );
  }

  /// Validate payment method availability
  bool isPaymentMethodAvailable(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return true; // Always available
      case PaymentMethod.applePay:
        return _random.nextBool(); // Simulate device support
      case PaymentMethod.googlePay:
        return _random.nextBool(); // Simulate device support
      case PaymentMethod.paypal:
        return true; // Always available
      case PaymentMethod.bankTransfer:
        return true; // Always available
    }
  }

  /// Get available payment methods
  List<PaymentMethod> getAvailablePaymentMethods() {
    return PaymentMethod.values
        .where((method) => isPaymentMethodAvailable(method))
        .toList();
  }

  /// Calculate processing fee
  double calculateProcessingFee(double amount, PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return amount * 0.025; // 2.5% fee
      case PaymentMethod.debitCard:
        return amount * 0.015; // 1.5% fee
      case PaymentMethod.applePay:
      case PaymentMethod.googlePay:
        return amount * 0.02; // 2% fee
      case PaymentMethod.paypal:
        return amount * 0.035; // 3.5% fee
      case PaymentMethod.bankTransfer:
        return 2.50; // Fixed fee
    }
  }

  /// Generate mock transaction ID
  String _generateTransactionId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      12,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  /// Validate card number using Luhn algorithm (simplified)
  bool validateCardNumber(String cardNumber) {
    cardNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cardNumber.length < 13 || cardNumber.length > 19) {
      return false;
    }

    // Basic validation (not full Luhn algorithm for simplicity)
    return cardNumber.length >= 15;
  }

  /// Get card type from number
  String getCardType(String cardNumber) {
    cardNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cardNumber.startsWith('4')) {
      return 'Visa';
    } else if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) {
      return 'Mastercard';
    } else if (cardNumber.startsWith('3')) {
      return 'American Express';
    } else {
      return 'Bilinmeyen';
    }
  }

  /// Format card number for display
  String formatCardNumber(String cardNumber) {
    cardNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cardNumber.length <= 4) return cardNumber;

    final buffer = StringBuffer();
    for (int i = 0; i < cardNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cardNumber[i]);
    }

    return buffer.toString();
  }

  /// Simple demo payment that always succeeds (for testing)
  Future<PaymentResult> processDemoPayment({
    required double amount,
    required PaymentMethod method,
  }) async {
    if (kDebugMode) {
      print('🎯 PaymentService: Processing DEMO payment - Amount: $amount');
    }

    // Quick success for demo
    await Future.delayed(const Duration(milliseconds: 500));

    final transactionId = _generateTransactionId();

    if (kDebugMode) {
      print(
        '✅ PaymentService: Demo payment successful - Transaction ID: $transactionId',
      );
    }

    return PaymentResult.success(
      transactionId: transactionId,
      method: method,
      amount: amount,
    );
  }

  /// Mock payment methods for demo
  static List<PaymentMethod> get demoPaymentMethods => [
    PaymentMethod.creditCard,
    PaymentMethod.debitCard,
    PaymentMethod.applePay,
    PaymentMethod.googlePay,
  ];
}
