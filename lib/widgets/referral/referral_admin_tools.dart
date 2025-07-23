import 'package:flutter/material.dart';
import '../../models/referral/referral_model.dart';
import '../../services/referral/referral_service.dart';

/// Referans admin araçları widget'ı
class ReferralAdminTools extends StatefulWidget {
  const ReferralAdminTools({super.key});

  @override
  State<ReferralAdminTools> createState() => _ReferralAdminToolsState();
}

class _ReferralAdminToolsState extends State<ReferralAdminTools> {
  final ReferralService _referralService = ReferralService();
  
  ReferralStats? _stats;
  List<ReferralModel> _fraudulentReferrals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referans Admin Araçları'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // İstatistikler
                if (_stats != null) _buildStatsCard(theme),
                
                const SizedBox(height: 24),
                
                // Sahte referanslar
                _buildFraudulentReferralsCard(theme),
                
                const SizedBox(height: 24),
                
                // Admin işlemleri
                _buildAdminActionsCard(theme),
              ],
            ),
    );
  }

  /// İstatistikler kartı
  Widget _buildStatsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Genel İstatistikler',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // İstatistik grid'i
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatItem(
                  theme,
                  'Toplam Referans',
                  _stats!.totalReferrals.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatItem(
                  theme,
                  'Tamamlanan',
                  _stats!.completedReferrals.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  theme,
                  'İptal Edilen',
                  _stats!.cancelledReferrals.toString(),
                  Icons.cancel,
                  Colors.orange,
                ),
                _buildStatItem(
                  theme,
                  'Sahte',
                  _stats!.fraudulentReferrals.toString(),
                  Icons.warning,
                  Colors.red,
                ),
                _buildStatItem(
                  theme,
                  'Toplam Puan',
                  _stats!.totalPointsEarned.toString(),
                  Icons.stars,
                  Colors.amber,
                ),
                _buildStatItem(
                  theme,
                  'Başarı Oranı',
                  '${(_stats!.successRate * 100).toInt()}%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Son güncelleme: ${_formatDate(_stats!.lastUpdated)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sahte referanslar kartı
  Widget _buildFraudulentReferralsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sahte Referanslar',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                Text(
                  '${_fraudulentReferrals.length} adet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (_fraudulentReferrals.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sahte referans tespit edilmedi',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _fraudulentReferrals.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final referral = _fraudulentReferrals[index];
                  return _FraudulentReferralCard(
                    referral: referral,
                    onMarkAsFraudulent: () => _markAsFraudulent(referral.id),
                    onCancel: () => _cancelReferral(referral.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Admin işlemleri kartı
  Widget _buildAdminActionsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Admin İşlemleri',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  theme,
                  'Sahte Referansları Tespit Et',
                  Icons.search,
                  Colors.blue,
                  _detectFraudulentReferrals,
                ),
                _buildActionButton(
                  theme,
                  'İstatistikleri Yenile',
                  Icons.refresh,
                  Colors.green,
                  _loadData,
                ),
                _buildActionButton(
                  theme,
                  'Tüm Referansları Listele',
                  Icons.list,
                  Colors.orange,
                  _showAllReferrals,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// İstatistik öğesi oluştur
  Widget _buildStatItem(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Aksiyon butonu oluştur
  Widget _buildActionButton(
    ThemeData theme,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Verileri yükle
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _referralService.getReferralStats();
      final fraudulentReferrals = await _referralService.detectFraudulentReferrals();
      
      setState(() {
        _stats = stats;
        _fraudulentReferrals = fraudulentReferrals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veriler yüklenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Sahte referansları tespit et
  Future<void> _detectFraudulentReferrals() async {
    try {
      final fraudulentReferrals = await _referralService.detectFraudulentReferrals();
      
      setState(() {
        _fraudulentReferrals = fraudulentReferrals;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${fraudulentReferrals.length} sahte referans tespit edildi'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sahte referanslar tespit edilirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Referansı sahte olarak işaretle
  Future<void> _markAsFraudulent(String referralId) async {
    try {
      await _referralService.markReferralAsFraudulent(referralId);
      
      // Listeyi güncelle
      setState(() {
        _fraudulentReferrals.removeWhere((r) => r.id == referralId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Referans sahte olarak işaretlendi'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Referans işaretlenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Referansı iptal et
  Future<void> _cancelReferral(String referralId) async {
    try {
      await _referralService.cancelReferral(referralId);
      
      // Listeyi güncelle
      setState(() {
        _fraudulentReferrals.removeWhere((r) => r.id == referralId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Referans iptal edildi'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Referans iptal edilirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Tüm referansları göster
  void _showAllReferrals() {
    // Bu fonksiyon tüm referansları listeleyen bir ekran açabilir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tüm referanslar listesi yakında eklenecek'),
      ),
    );
  }

  /// Tarih formatla
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

/// Sahte referans kartı
class _FraudulentReferralCard extends StatelessWidget {
  final ReferralModel referral;
  final VoidCallback onMarkAsFraudulent;
  final VoidCallback onCancel;

  const _FraudulentReferralCard({
    required this.referral,
    required this.onMarkAsFraudulent,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst kısım
          Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Şüpheli Referans',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
              Text(
                _formatDate(referral.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Detaylar
          Text(
            'Davet Eden: ${referral.referrerId.substring(0, 8)}...',
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            'Davet Edilen: ${referral.referredId.substring(0, 8)}...',
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            'Kod: ${referral.referralCode}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          
          if (referral.deviceId != null)
            Text(
              'Cihaz: ${referral.deviceId}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          
          if (referral.ipAddress != null)
            Text(
              'IP: ${referral.ipAddress}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Butonlar
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                  child: const Text('İptal Et'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onMarkAsFraudulent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Sahte Olarak İşaretle'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tarih formatla
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
