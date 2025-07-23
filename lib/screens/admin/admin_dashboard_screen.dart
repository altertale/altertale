import 'package:flutter/material.dart';
import '../../services/admin/admin_service.dart';
import '../../widgets/offline/connection_status_bar.dart';

/// Admin dashboard ekranı
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _systemStatus;
  bool _isLoading = true;
  String? _error;

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
        title: const Text('Admin Dashboard'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Bağlantı durumu çubuğu
          ConnectionStatusBar(),
          
          // Ana içerik
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorWidget(theme)
                    : _buildDashboardContent(theme),
          ),
        ],
      ),
    );
  }

  /// Hata widget'ı
  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Veriler yüklenemedi',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  /// Dashboard içeriği
  Widget _buildDashboardContent(ThemeData theme) {
    if (_statistics == null || _systemStatus == null) {
      return const Center(child: Text('Veri bulunamadı'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sistem durumu kartı
          _buildSystemStatusCard(theme),
          const SizedBox(height: 16),
          
          // Genel istatistikler
          _buildGeneralStatsCard(theme),
          const SizedBox(height: 16),
          
          // En çok okunan kitaplar
          _buildTopBooksCard(theme),
          const SizedBox(height: 16),
          
          // En çok puan kazanan kullanıcılar
          _buildTopUsersCard(theme),
          const SizedBox(height: 16),
          
          // En çok davet eden kullanıcılar
          _buildTopReferrersCard(theme),
        ],
      ),
    );
  }

  /// Sistem durumu kartı
  Widget _buildSystemStatusCard(ThemeData theme) {
    final firestoreStatus = _systemStatus!['firestore'] as String;
    final isConnected = firestoreStatus == 'connected';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sistem Durumu',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Firestore durumu
            Row(
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.error,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Firestore: ${isConnected ? 'Bağlı' : 'Bağlantı Hatası'}',
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            // Son admin aktivitesi
            if (_systemStatus!['lastAdminActivity'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Son Aktivite: ${_systemStatus!['lastAdminActivity']['admin']} - ${_systemStatus!['lastAdminActivity']['action']}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Genel istatistikler kartı
  Widget _buildGeneralStatsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Genel İstatistikler',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // İstatistik grid'i
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildStatItem(
                  theme,
                  'Toplam Kullanıcı',
                  '${_statistics!['totalUsers']}',
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatItem(
                  theme,
                  'Toplam Kitap',
                  '${_statistics!['totalBooks']}',
                  Icons.book,
                  Colors.green,
                ),
                _buildStatItem(
                  theme,
                  'Toplam Yorum',
                  '${_statistics!['totalComments']}',
                  Icons.comment,
                  Colors.orange,
                ),
                _buildStatItem(
                  theme,
                  'Bekleyen Yorum',
                  '${_statistics!['pendingComments']}',
                  Icons.pending,
                  Colors.red,
                ),
                _buildStatItem(
                  theme,
                  'Aktif Kullanıcı (24s)',
                  '${_statistics!['activeUsersToday']}',
                  Icons.online_prediction,
                  Colors.purple,
                ),
                _buildStatItem(
                  theme,
                  'Admin Sayısı',
                  '${_systemStatus!['adminCount']}',
                  Icons.admin_panel_settings,
                  Colors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// İstatistik öğesi
  Widget _buildStatItem(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// En çok okunan kitaplar kartı
  Widget _buildTopBooksCard(ThemeData theme) {
    final topBooks = _statistics!['topBooks'] as List<dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'En Çok Okunan Kitaplar',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (topBooks.isEmpty)
              Text(
                'Henüz okuma verisi yok',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              )
            else
              Column(
                children: topBooks.take(5).map((book) {
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        '${topBooks.indexOf(book) + 1}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      book['title'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      book['author'],
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${book['readCount']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// En çok puan kazanan kullanıcılar kartı
  Widget _buildTopUsersCard(ThemeData theme) {
    final topUsers = _statistics!['topUsers'] as List<dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.stars,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'En Çok Puan Kazanan Kullanıcılar',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (topUsers.isEmpty)
              Text(
                'Henüz puan verisi yok',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              )
            else
              Column(
                children: topUsers.take(5).map((user) {
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.stars,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                    title: Text(
                      user['name'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      user['email'],
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${user['totalPoints']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// En çok davet eden kullanıcılar kartı
  Widget _buildTopReferrersCard(ThemeData theme) {
    final topReferrers = _statistics!['topReferrers'] as List<dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.share,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'En Çok Davet Eden Kullanıcılar',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (topReferrers.isEmpty)
              Text(
                'Henüz davet verisi yok',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              )
            else
              Column(
                children: topReferrers.take(5).map((referrer) {
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.share,
                        color: Colors.green,
                        size: 16,
                      ),
                    ),
                    title: Text(
                      referrer['name'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      referrer['email'],
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${referrer['referralCount']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== VERİ YÖNETİMİ ====================

  /// Verileri yükle
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // İstatistikleri ve sistem durumunu paralel olarak yükle
      final results = await Future.wait([
        _adminService.getStatistics(),
        _adminService.getSystemStatus(),
      ]);

      setState(() {
        _statistics = results[0];
        _systemStatus = results[1];
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
