import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mybooks_provider.dart';
import '../../providers/book_provider.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../services/payment_service.dart';
import '../../models/cart_item.dart';
import '../../models/book_model.dart';
import '../../models/order.dart';
import '../../widgets/widgets.dart';
import '../../services/purchase_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();

  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ödeme')),
        body: const Center(child: Text('Ödeme yapmak için giriş yapmalısınız')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const TitleText('Ödeme', size: TitleSize.large),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Demo mode banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'DEMO MOD: Tüm ödemeler otomatik olarak başarılı olacaktır',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: StreamBuilder<List<CartItem>>(
              stream: _cartService.getCartItemsStream(authProvider.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        TitleText('Hata', color: Colors.red),
                        SubtitleText('${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final cartItems = snapshot.data ?? [];

                if (cartItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 64),
                        const SizedBox(height: 16),
                        const TitleText('Sepet Boş'),
                        const SubtitleText('Ödeme yapacak ürün bulunamadı'),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Alışverişe Devam Et',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                }

                return _buildCheckoutForm(
                  context,
                  theme,
                  cartItems,
                  authProvider.userId,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutForm(
    BuildContext context,
    ThemeData theme,
    List<CartItem> cartItems,
    String userId,
  ) {
    final subtotal = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    final tax = subtotal * 0.18;
    final shipping = subtotal > 100 ? 0.0 : 9.99;
    final total = subtotal + tax + shipping;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            _buildOrderSummary(
              theme,
              cartItems,
              subtotal,
              tax,
              shipping,
              total,
            ),

            const SizedBox(height: 24),

            // Payment Method Selection
            _buildPaymentMethodSelection(theme),

            const SizedBox(height: 24),

            // Payment Details
            if (_selectedPaymentMethod == PaymentMethod.creditCard ||
                _selectedPaymentMethod == PaymentMethod.debitCard)
              _buildCardPaymentForm(theme),

            const SizedBox(height: 24),

            // Shipping Address
            _buildShippingAddressForm(theme),

            const SizedBox(height: 24),

            // Notes
            _buildNotesForm(theme),

            const SizedBox(height: 32),

            // Checkout Button
            _buildCheckoutButton(theme, total, userId),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
    ThemeData theme,
    List<CartItem> cartItems,
    double subtotal,
    double tax,
    double shipping,
    double total,
  ) {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Sipariş Özeti', size: TitleSize.medium),
          const SizedBox(height: 16),

          // Items
          ...cartItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SubtitleText('${item.title} x ${item.quantity}'),
                  ),
                  SubtitleText(item.formattedTotalPrice),
                ],
              ),
            ),
          ),

          const Divider(),

          // Totals
          _buildSummaryRow('Ara Toplam', '${subtotal.toStringAsFixed(2)} TL'),
          _buildSummaryRow('KDV (%18)', '${tax.toStringAsFixed(2)} TL'),
          _buildSummaryRow(
            'Kargo',
            shipping == 0 ? 'Ücretsiz' : '${shipping.toStringAsFixed(2)} TL',
          ),

          const Divider(),

          Row(
            children: [
              const Expanded(
                child: TitleText('Toplam', size: TitleSize.medium),
              ),
              TitleText(
                '${total.toStringAsFixed(2)} TL',
                size: TitleSize.medium,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: SubtitleText(label)),
          SubtitleText(value),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection(ThemeData theme) {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Ödeme Yöntemi', size: TitleSize.medium),
          const SizedBox(height: 16),

          ...PaymentMethod.values.map(
            (method) => RadioListTile<PaymentMethod>(
              title: SubtitleText(method.displayName),
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPaymentForm(ThemeData theme) {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Kart Bilgileri', size: TitleSize.medium),
          const SizedBox(height: 16),

          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Kart Numarası',
              hintText: '1234 5678 9012 3456',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            maxLength: 19, // 16 digits + 3 spaces
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kart numarası gerekli';
              }
              final cleanValue = value.replaceAll(' ', '');
              if (cleanValue.length < 13) {
                return 'Geçersiz kart numarası';
              }
              return null;
            },
            onChanged: (value) {
              // Remove all non-digits
              final cleanValue = value.replaceAll(RegExp(r'\D'), '');

              // Format with spaces every 4 digits
              String formattedValue = '';
              for (int i = 0; i < cleanValue.length; i++) {
                if (i > 0 && i % 4 == 0) {
                  formattedValue += ' ';
                }
                formattedValue += cleanValue[i];
              }

              // Update controller without triggering onChanged again
              if (formattedValue != value) {
                _cardNumberController.value = TextEditingValue(
                  text: formattedValue,
                  selection: TextSelection.collapsed(
                    offset: formattedValue.length,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _cardHolderController,
            decoration: const InputDecoration(
              labelText: 'Kart Sahibi',
              hintText: 'Ad Soyad',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kart sahibi adı gerekli';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: const InputDecoration(
                    labelText: 'Son Kullanma',
                    hintText: 'MM/YY',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 5, // MM/YY format
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Son kullanma tarihi gerekli';
                    }
                    if (value.length < 5) {
                      return 'MM/YY formatında giriniz';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Remove all non-digits
                    final cleanValue = value.replaceAll(RegExp(r'\D'), '');

                    // Format as MM/YY
                    String formattedValue = '';
                    for (int i = 0; i < cleanValue.length && i < 4; i++) {
                      if (i == 2) {
                        formattedValue += '/';
                      }
                      formattedValue += cleanValue[i];
                    }

                    // Update controller without triggering onChanged again
                    if (formattedValue != value) {
                      _expiryController.value = TextEditingValue(
                        text: formattedValue,
                        selection: TextSelection.collapsed(
                          offset: formattedValue.length,
                        ),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'CVV gerekli';
                    }
                    if (value.length < 3) {
                      return 'Geçersiz CVV';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressForm(ThemeData theme) {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Teslimat Adresi', size: TitleSize.medium),
          const SizedBox(height: 16),

          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Adres',
              hintText: 'Mahalle, Sokak, Bina No, Daire...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Teslimat adresi gerekli';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesForm(ThemeData theme) {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Sipariş Notları', size: TitleSize.medium),
          const SizedBox(height: 8),
          const SubtitleText('İsteğe bağlı', size: SubtitleSize.small),
          const SizedBox(height: 16),

          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Not',
              hintText: 'Özel taleplerinizi buraya yazabilirsiniz...',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(ThemeData theme, double total, String userId) {
    return Column(
      children: [
        // Demo payment button (always succeeds)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          child: CustomButton(
            text: 'DEMO ÖDEME - Hızlı Test (${total.toStringAsFixed(2)} TL)',
            onPressed: _isProcessing
                ? null
                : () => _processDemoCheckout(userId, total),
            isLoading: _isProcessing,
            type: ButtonType.secondary,
          ),
        ),

        // Regular payment button
        CustomButton(
          text: _isProcessing
              ? 'İşleniyor...'
              : 'Ödemeyi Tamamla (${total.toStringAsFixed(2)} TL)',
          onPressed: _isProcessing ? null : () => _processCheckout(userId),
          isLoading: _isProcessing,
        ),
      ],
    );
  }

  Future<void> _processCheckout(String userId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Show processing dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Ödeme işleniyor...'),
                    SizedBox(height: 8),
                    Text(
                      'Lütfen bekleyin, bu işlem birkaç saniye sürebilir.',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    try {
      // Add shorter timeout to prevent infinite processing
      final order = await _orderService
          .createOrderFromCart(
            userId: userId,
            paymentMethod: _selectedPaymentMethod,
            shippingAddress: _addressController.text.trim(),
            billingAddress: _addressController.text.trim(),
            notes: _notesController.text.trim(),
            cardNumber: _cardNumberController.text.trim().replaceAll(' ', ''),
            cardHolderName: _cardHolderController.text.trim(),
            expiryDate: _expiryController.text.trim(),
            cvv: _cvvController.text.trim(),
          )
          .timeout(
            const Duration(seconds: 20), // Increased from 10 to 20 seconds
            onTimeout: () {
              throw Exception(
                'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.',
              );
            },
          );

      // Close processing dialog
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Update MyBooksProvider with instant sync
      if (mounted) {
        try {
          final myBooksProvider = context.read<MyBooksProvider>();
          final bookProvider = context.read<BookProvider>();

          // Add purchased books to MyBooks with instant feedback
          for (final item in order.items) {
            final book = bookProvider.books.firstWhere(
              (b) => b.id == item.bookId,
              orElse: () => BookModel(
                id: item.bookId,
                title: item.title,
                author: item.author,
                description: 'Satın alınan kitap',
                coverImageUrl:
                    item.imageUrl ?? 'https://via.placeholder.com/150x200',
                categories: ['Satın Alınan'],
                tags: [],
                price: item.price,
                points: 0,
                averageRating: 0,
                ratingCount: 0,
                readCount: 0,
                pageCount: 0,
                language: 'tr',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isPublished: true,
                isFeatured: false,
                isPopular: false,
                previewStart: 0,
                previewEnd: 0,
                pointPrice: 0,
              ),
            );

            await myBooksProvider.addPurchasedBookInstant(book, order);

            // Clear purchase cache to ensure immediate UI updates
            final purchaseService = PurchaseService();
            purchaseService.addToPurchasedCache(item.bookId);
          }

          // Clear purchase service cache to ensure fresh state
          final purchaseService = PurchaseService();
          await purchaseService.clearPurchaseCache();

          print(
            '📚 CheckoutScreen: Updated MyBooksProvider with ${order.items.length} purchased books',
          );
        } catch (e) {
          print('❌ CheckoutScreen: Error updating MyBooksProvider: $e');
        }
      }

      // Show success and navigate to orders
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Siparişiniz başarıyla oluşturuldu! ${order.orderNumber}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Navigate to orders screen
        Navigator.of(context).pushReplacementNamed('/orders');
      }
    } catch (e) {
      // Close processing dialog
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme başarısız: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processDemoCheckout(String userId, double total) async {
    setState(() {
      _isProcessing = true;
    });

    // Show processing dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Ödeme işleniyor...'),
                    SizedBox(height: 8),
                    Text(
                      'Lütfen bekleyin, bu işlem birkaç saniye sürebilir.',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    try {
      // Simulate a successful payment with timeout
      final order = await _orderService
          .createOrderFromCart(
            userId: userId,
            paymentMethod:
                PaymentMethod.creditCard, // Always credit card for demo
            shippingAddress: _addressController.text.isNotEmpty
                ? _addressController.text.trim()
                : 'Demo Teslimat Adresi',
            billingAddress: _addressController.text.isNotEmpty
                ? _addressController.text.trim()
                : 'Demo Fatura Adresi',
            notes: _notesController.text.trim(),
            cardNumber: '1234567890123456', // Demo card
            cardHolderName: 'Demo User',
            expiryDate: '12/25',
            cvv: '123',
          )
          .timeout(
            const Duration(
              seconds: 15,
            ), // Increased from 8 to 15 seconds for demo
            onTimeout: () {
              throw Exception(
                'Demo ödeme zaman aşımına uğradı. Lütfen tekrar deneyin.',
              );
            },
          );

      // Close processing dialog
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show success and navigate to orders
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Siparişiniz başarıyla oluşturuldu! ${order.orderNumber}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Navigate to orders screen
        Navigator.of(context).pushReplacementNamed('/orders');
      }
    } catch (e) {
      // Close processing dialog
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme başarısız: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
