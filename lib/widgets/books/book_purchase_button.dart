import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/purchase_service.dart';
import '../../utils/alerts.dart';

/// Kitap satın alma butonu (TL veya puan ile)
class BookPurchaseButton extends StatefulWidget {
  final BookModel book;
  final bool isPurchased;
  final VoidCallback? onPurchased;

  const BookPurchaseButton({
    super.key,
    required this.book,
    required this.isPurchased,
    this.onPurchased,
  });

  @override
  State<BookPurchaseButton> createState() => _BookPurchaseButtonState();
}

class _BookPurchaseButtonState extends State<BookPurchaseButton> {
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    final isWeb =
        Theme.of(context).platform == TargetPlatform.fuchsia ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows;

    if (widget.isPurchased) {
      return ElevatedButton.icon(
        onPressed: widget.onPurchased,
        icon: const Icon(Icons.book),
        label: const Text('Okumaya Başla'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Row(
          children: [
            // TL ile satın alma (web için sahte ödeme, mobilde placeholder)
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() => _isLoading = true);
                        try {
                          // First check if book is already purchased
                          final purchaseService = PurchaseService();
                          final alreadyPurchased = await purchaseService
                              .hasUserPurchasedBook(
                                userId: user!.uid,
                                bookId: widget.book.id,
                              );

                          if (alreadyPurchased) {
                            setState(
                              () => _error = 'Bu kitabı zaten satın aldınız.',
                            );
                            Alerts.showError(
                              context,
                              'Bu kitabı zaten satın aldınız.',
                            );
                            return;
                          }

                          if (isWeb) {
                            // Web için sahte ödeme
                            await PurchaseService().purchaseWithTL(
                              userId: user.uid,
                              book: widget.book,
                              amount: widget.book.price,
                              paymentProvider: 'test',
                            );
                            Alerts.showSuccess(
                              context,
                              'Kitap başarıyla satın alındı!',
                            );
                            if (widget.onPurchased != null)
                              widget.onPurchased!();
                          } else {
                            // Mobilde ödeme altyapısı hazır, şimdilik pasif
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Mobil ödeme yakında aktif olacak.',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() => _error = e.toString());
                          Alerts.showError(context, 'Satın alma başarısız: $e');
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Satın Al (${widget.book.formattedPrice})'),
              ),
            ),
            const SizedBox(width: 12),
            // Puanla satın alma
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : (user != null &&
                          user.totalPoints >= widget.book.pointPrice)
                    ? () async {
                        setState(() => _isLoading = true);
                        try {
                          // First check if book is already purchased
                          final purchaseService = PurchaseService();
                          final alreadyPurchased = await purchaseService
                              .hasUserPurchasedBook(
                                userId: user.uid,
                                bookId: widget.book.id,
                              );

                          if (alreadyPurchased) {
                            setState(
                              () => _error = 'Bu kitabı zaten satın aldınız.',
                            );
                            Alerts.showError(
                              context,
                              'Bu kitabı zaten satın aldınız.',
                            );
                            return;
                          }

                          await PurchaseService().purchaseWithPoints(
                            userId: user.uid,
                            book: widget.book,
                            userPoints: user.totalPoints,
                            // pointPrice kullanılacak
                          );
                          Alerts.showSuccess(
                            context,
                            'Kitap başarıyla puanla satın alındı!',
                          );
                          if (widget.onPurchased != null) widget.onPurchased!();
                        } catch (e) {
                          setState(() => _error = e.toString());
                          Alerts.showError(context, 'Satın alma başarısız: $e');
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      }
                    : () {
                        Alerts.showError(context, 'Yeterli puanınız yok.');
                      },
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Puanla Al (${widget.book.pointPrice} puan)'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
