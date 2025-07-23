import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../controllers/purchase_controller.dart';

/// Puan ile satın alma butonu
class PurchaseWithPointsButton extends StatefulWidget {
  final BookModel book;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const PurchaseWithPointsButton({
    super.key,
    required this.book,
    this.onSuccess,
    this.onError,
  });

  @override
  State<PurchaseWithPointsButton> createState() => _PurchaseWithPointsButtonState();
}

class _PurchaseWithPointsButtonState extends State<PurchaseWithPointsButton> {
  final PurchaseController _purchaseController = PurchaseController();
  bool _canPurchase = false;
  int _userPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPurchaseAbility();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Kontrol ediliyor...'),
            ],
          ),
        ),
      );
    }

    if (!_canPurchase) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.error),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Yeterli puanınız yok',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Bu kitabı satın almak için ${widget.book.points} puan gerekiyor. Mevcut puanınız: $_userPoints',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Puan bilgisi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kitap Fiyatı:',
                style: theme.textTheme.bodyMedium,
              ),
              Row(
                children: [
                  Icon(
                    Icons.stars,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.book.points} puan',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Satın alma butonu
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _purchaseController.isLoading ? null : _purchaseBook,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: _purchaseController.isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Satın Alınıyor...'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart),
                      const SizedBox(width: 8),
                      Text(
                        'Puan ile Satın Al',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        // Hata mesajı
        if (_purchaseController.error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.error),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _purchaseController.error!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _purchaseController.clearError,
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.error,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

        // Başarı mesajı
        if (_purchaseController.successMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _purchaseController.successMessage!,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _purchaseController.clearSuccessMessage,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.green,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Satın alma yeteneğini kontrol et
  Future<void> _checkPurchaseAbility() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final canPurchase = await _purchaseController.canPurchaseWithPoints(
        userId: currentUser.uid,
        book: widget.book,
      );

      final userPoints = await _purchaseController.getUserPoints(currentUser.uid);

      setState(() {
        _canPurchase = canPurchase;
        _userPoints = userPoints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Kitabı satın al
  Future<void> _purchaseBook() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      
      if (currentUser == null) {
        widget.onError?.call();
        return;
      }

      final success = await _purchaseController.purchaseBookWithPoints(
        userId: currentUser.uid,
        book: widget.book,
      );

      if (success) {
        // Satın alma yeteneğini yeniden kontrol et
        await _checkPurchaseAbility();
        widget.onSuccess?.call();
      } else {
        widget.onError?.call();
      }
    } catch (e) {
      widget.onError?.call();
    }
  }
}
