import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/referral_service.dart';

/// Profilde puan ve referans kodu gösteren kart
class ProfileReferralCard extends StatefulWidget {
  const ProfileReferralCard({super.key});

  @override
  State<ProfileReferralCard> createState() => _ProfileReferralCardState();
}

class _ProfileReferralCardState extends State<ProfileReferralCard> {
  String? _referCode;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReferCode();
  }

  Future<void> _loadReferCode() async {
    setState(() { _isLoading = true; });
    final user = context.read<AuthProvider>().userModel;
    if (user == null) return;
    try {
      final code = await ReferralService().getOrCreateReferralCode(user.uid, username: user.name);
      setState(() { _referCode = code; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final theme = Theme.of(context);
    if (user == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Puanım:', style: theme.textTheme.titleMedium),
                const SizedBox(width: 8),
                Text('${user.totalPoints}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.code, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text('Referans Kodum:', style: theme.textTheme.bodyMedium),
                const SizedBox(width: 8),
                if (_isLoading)
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                else if (_referCode != null)
                  SelectableText(_referCode!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (_referCode != null)
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Kopyala',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _referCode!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kod kopyalandı!')));
                    },
                  ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Bir arkadaşımı davet et'),
                    onPressed: _referCode == null ? null : () {
                      // Paylaşma altyapısı (örn: Share package) eklenebilir
                      Clipboard.setData(ClipboardData(text: _referCode!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kod kopyalandı!')));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 