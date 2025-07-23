import 'package:flutter/material.dart';
import '../../models/referral/referral_model.dart';
import '../../services/referral/referral_service.dart';
import '../../widgets/referral/invite_friend_widget.dart';
import '../../widgets/referral/referral_stats_widget.dart';
import '../../widgets/referral/referral_list_widget.dart';

/// Referans ekranı
class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final ReferralService _referralService = ReferralService();
  
  UserReferralInfo? _userReferralInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserReferralInfo();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkadaşlarını Davet Et'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget(theme)
              : _buildContent(theme),
    );
  }

  /// İçerik widget'ı
  Widget _buildContent(ThemeData theme) {
    if (_userReferralInfo == null) {
      return const Center(child: Text('Referans bilgileri yüklenemedi'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Davet et widget'ı
        InviteFriendWidget(
          referralCode: _userReferralInfo!.referralCode,
          onCodeCopied: _onCodeCopied,
        ),
        
        const SizedBox(height: 24),
        
        // İstatistikler
        ReferralStatsWidget(
          userReferralInfo: _userReferralInfo!,
        ),
        
        const SizedBox(height: 24),
        
        // Referans listesi
        ReferralListWidget(
          userId: _userReferralInfo!.userId,
        ),
      ],
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
            'Referans bilgileri yüklenirken hata oluştu',
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
            onPressed: _loadUserReferralInfo,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Kullanıcı referans bilgilerini yükle
  Future<void> _loadUserReferralInfo() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = _referralService.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      final userReferralInfo = await _referralService.getUserReferralInfo(user.uid);
      
      setState(() {
        _userReferralInfo = userReferralInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Verileri yenile
  void _refreshData() {
    _loadUserReferralInfo();
  }

  /// Kod kopyalandığında
  void _onCodeCopied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referans kodu panoya kopyalandı'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// Referans kodu giriş ekranı (kayıt sırasında)
class ReferralCodeInputScreen extends StatefulWidget {
  final Function(String) onCodeSubmitted;

  const ReferralCodeInputScreen({
    super.key,
    required this.onCodeSubmitted,
  });

  @override
  State<ReferralCodeInputScreen> createState() => _ReferralCodeInputScreenState();
}

class _ReferralCodeInputScreenState extends State<ReferralCodeInputScreen> {
  final ReferralService _referralService = ReferralService();
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isValidating = false;
  String? _validationMessage;
  bool _isValid = false;

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referans Kodu'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Açıklama
            Text(
              'Arkadaşınızdan aldığınız referans kodunu girin',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Bu kod ile kayıt olursanız hem siz hem de arkadaşınız puan kazanırsınız!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Kod girişi
            TextField(
              controller: _codeController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Referans Kodu',
                hintText: 'Örnek: ABC123',
                border: const OutlineInputBorder(),
                suffixIcon: _isValidating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _isValid
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
              ),
              
              onChanged: _onCodeChanged,
              onSubmitted: _onCodeSubmitted,
            ),
            
            // Doğrulama mesajı
            if (_validationMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _validationMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _isValid 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.error,
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Puan bilgileri
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referans ile kazanacağınız puanlar:',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Siz: 10 puan'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Arkadaşınız: 50 puan'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Atla'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isValid ? _submitCode : null,
                    child: const Text('Devam Et'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Kod değiştiğinde
  void _onCodeChanged(String code) {
    setState(() {
      _isValid = false;
      _validationMessage = null;
    });

    if (code.length == 6) {
      _validateCode(code);
    }
  }

  /// Kod gönderildiğinde
  void _onCodeSubmitted(String code) {
    if (code.length == 6) {
      _validateCode(code);
    }
  }

  /// Kodu doğrula
  Future<void> _validateCode(String code) async {
    setState(() {
      _isValidating = true;
      _validationMessage = null;
    });

    try {
      final userId = await _referralService.validateReferralCode(code);
      
      setState(() {
        _isValidating = false;
        if (userId != null) {
          _isValid = true;
          _validationMessage = 'Geçerli referans kodu!';
        } else {
          _isValid = false;
          _validationMessage = 'Geçersiz referans kodu';
        }
      });
    } catch (e) {
      setState(() {
        _isValidating = false;
        _isValid = false;
        _validationMessage = 'Kod doğrulanırken hata oluştu';
      });
    }
  }

  /// Kodu gönder
  void _submitCode() {
    final code = _codeController.text.trim().toUpperCase();
    if (_isValid && code.isNotEmpty) {
      widget.onCodeSubmitted(code);
      Navigator.pop(context);
    }
  }
}
