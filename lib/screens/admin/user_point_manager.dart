import 'package:flutter/material.dart';
import '../../services/points_service.dart';
import '../../models/user_model.dart';

/// Kullanıcı puan yönetimi ekranı
class UserPointManager extends StatefulWidget {
  const UserPointManager({super.key});

  @override
  State<UserPointManager> createState() => _UserPointManagerState();
}

class _UserPointManagerState extends State<UserPointManager> {
  final PointsService _pointsService = PointsService();
  final _searchController = TextEditingController();
  final _pointsController = TextEditingController();
  final _reasonController = TextEditingController();

  UserModel? _selectedUser;
  bool _isLoading = false;
  bool _isSearching = false;
  String _operationType = 'add'; // 'add' veya 'remove'

  @override
  void dispose() {
    _searchController.dispose();
    _pointsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Text(
            'Puan Yönetimi',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kullanıcı puanlarını manuel olarak yönetin',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 32),

          // Kullanıcı arama
          _buildUserSearch(theme),

          const SizedBox(height: 24),

          // Seçili kullanıcı bilgileri
          if (_selectedUser != null) _buildUserInfo(theme),

          const SizedBox(height: 24),

          // Puan işlemi formu
          if (_selectedUser != null) _buildPointOperationForm(theme),
        ],
      ),
    );
  }

  /// Kullanıcı arama bölümü
  Widget _buildUserSearch(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kullanıcı Ara',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Kullanıcı UID veya E-posta',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchUser(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSearching ? null : _searchUser,
                  child: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ara'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Kullanıcı bilgileri
  Widget _buildUserInfo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kullanıcı Bilgileri',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    _selectedUser!.name.isNotEmpty
                        ? _selectedUser!.name[0].toUpperCase()
                        : 'U',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedUser!.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedUser!.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'UID: ${_selectedUser!.uid}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${_selectedUser!.totalPoints} puan',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Puan işlemi formu
  Widget _buildPointOperationForm(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Puan İşlemi',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // İşlem türü seçimi
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Puan Ekle'),
                    value: 'add',
                    groupValue: _operationType,
                    onChanged: (value) {
                      setState(() {
                        _operationType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Puan Çıkar'),
                    value: 'remove',
                    groupValue: _operationType,
                    onChanged: (value) {
                      setState(() {
                        _operationType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Puan miktarı
            TextFormField(
              controller: _pointsController,
              decoration: const InputDecoration(
                labelText: 'Puan Miktarı *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.stars),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Puan miktarı gereklidir';
                }
                final points = int.tryParse(value);
                if (points == null || points <= 0) {
                  return 'Geçerli bir puan miktarı girin';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Sebep
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'İşlem Sebebi *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: 'Örn: Admin manuel puan ekleme',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'İşlem sebebi gereklidir';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // İşlem önizlemesi
            if (_pointsController.text.isNotEmpty)
              _buildOperationPreview(theme),

            const SizedBox(height: 24),

            // İşlem butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _performPointOperation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _operationType == 'add'
                      ? Colors.green
                      : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _operationType == 'add' ? 'Puan Ekle' : 'Puan Çıkar',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// İşlem önizlemesi
  Widget _buildOperationPreview(ThemeData theme) {
    final points = int.tryParse(_pointsController.text) ?? 0;
    final currentPoints = _selectedUser!.totalPoints;
    final newPoints = _operationType == 'add'
        ? currentPoints + points
        : currentPoints - points;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İşlem Önizlemesi',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Mevcut puan: ', style: theme.textTheme.bodyMedium),
              Text(
                '$currentPoints',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text('İşlem: ', style: theme.textTheme.bodyMedium),
              Text(
                '${_operationType == 'add' ? '+' : '-'}$points',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _operationType == 'add' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Text(
                'Yeni puan: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$newPoints',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Kullanıcı ara
  Future<void> _searchUser() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen UID veya e-posta girin')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final user = await _pointsService.getUserByQuery(query);

      setState(() {
        _selectedUser = user;
        _isSearching = false;
      });

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kullanıcı bulunamadı')));
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kullanıcı aranırken hata: $e')));
    }
  }

  /// Puan işlemini gerçekleştir
  Future<void> _performPointOperation() async {
    if (_selectedUser == null) return;

    final points = int.tryParse(_pointsController.text);
    final reason = _reasonController.text.trim();

    if (points == null || points <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir puan miktarı girin')),
      );
      return;
    }

    if (reason.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('İşlem sebebi gereklidir')));
      return;
    }

    // Çıkarma işlemi için yeterli puan kontrolü
    if (_operationType == 'remove' && _selectedUser!.totalPoints < points) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcının yeterli puanı yok')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_operationType == 'add') {
        _pointsService.addPoints(
          userId: _selectedUser!.uid,
          points: points,
          reason: reason,
        );
      } else {
        await _pointsService.deductPoints(
          userId: _selectedUser!.uid,
          points: points,
          reason: reason,
        );
      }

      // Kullanıcı bilgilerini güncelle
      setState(() {
        _selectedUser = _selectedUser!.copyWith(
          totalPoints: _operationType == 'add'
              ? _selectedUser!.totalPoints + points
              : _selectedUser!.totalPoints - points,
        );
        _isLoading = false;
      });

      // Formu temizle
      _pointsController.clear();
      _reasonController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _operationType == 'add'
                ? '$points puan eklendi'
                : '$points puan çıkarıldı',
          ),
          backgroundColor: _operationType == 'add'
              ? Colors.green
              : Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Puan işlemi başarısız: $e')));
    }
  }
}
