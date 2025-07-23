import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../controllers/purchase_controller.dart';

/// Puan geçmişi ekranı
class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({super.key});

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  final PurchaseController _purchaseController = PurchaseController();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Puan Geçmişi')),
        body: const Center(child: Text('Giriş yapmanız gerekiyor')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puan Geçmişi'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget(theme)
          : _history.isEmpty
          ? _buildEmptyWidget(theme)
          : _buildHistoryList(theme),
    );
  }

  /// Hata widget'ı
  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Bir hata oluştu', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadHistory,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  /// Boş durum widget'ı
  Widget _buildEmptyWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz puan geçmişiniz yok',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Puan kazandığınızda veya harcadığınızda burada görünecek',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Geçmiş listesi
  Widget _buildHistoryList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return _buildHistoryItem(theme, item);
      },
    );
  }

  /// Geçmiş öğesi
  Widget _buildHistoryItem(ThemeData theme, Map<String, dynamic> item) {
    final points = item['points'] as int;
    final type = item['type'] as String;
    final reason = item['reason'] as String;
    final createdAt = item['createdAt'] as DateTime;
    final isEarned = type == 'earned';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isEarned ? Colors.green : Colors.red).withValues(
            alpha: 0.1,
          ),
          child: Icon(
            isEarned ? Icons.add : Icons.remove,
            color: isEarned ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          reason,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isEarned ? Colors.green : Colors.red,
          ),
        ),
        subtitle: Text(
          _formatTimestamp(createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isEarned ? Colors.green : Colors.red).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${isEarned ? '+' : '-'}$points puan',
            style: TextStyle(
              color: isEarned ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Tarih formatla
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  /// Geçmişi yükle
  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        setState(() {
          _error = 'Kullanıcı bilgisi bulunamadı';
          _isLoading = false;
        });
        return;
      }

      final history = await _purchaseController.getPointsHistory(
        userId: currentUser.uid,
        limit: 50,
      );

      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}
