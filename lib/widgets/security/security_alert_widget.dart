import 'package:flutter/material.dart';
import '../../models/security/security_model.dart';

/// Güvenlik uyarı widget'ı
class SecurityAlertWidget extends StatelessWidget {
  final SecurityEvent securityEvent;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const SecurityAlertWidget({
    super.key,
    required this.securityEvent,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: _getAlertColor(theme),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Icon(
                  _getAlertIcon(),
                  color: _getIconColor(theme),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getAlertTitle(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(theme),
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: Icon(
                      Icons.close,
                      color: _getTextColor(theme),
                    ),
                    iconSize: 20,
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Açıklama
            Text(
              securityEvent.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getTextColor(theme),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Detaylar
            _buildEventDetails(theme),
            
            // Butonlar
            if (onAction != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onAction,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _getTextColor(theme),
                        side: BorderSide(color: _getTextColor(theme)),
                      ),
                      child: const Text('Detayları Gör'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Uyarı rengini al
  Color _getAlertColor(ThemeData theme) {
    switch (securityEvent.severity) {
      case 'critical':
        return Colors.red.shade50;
      case 'high':
        return Colors.orange.shade50;
      case 'medium':
        return Colors.yellow.shade50;
      case 'low':
        return Colors.blue.shade50;
      default:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  /// İkon rengini al
  Color _getIconColor(ThemeData theme) {
    switch (securityEvent.severity) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow.shade700;
      case 'low':
        return Colors.blue;
      default:
        return theme.colorScheme.primary;
    }
  }

  /// Metin rengini al
  Color _getTextColor(ThemeData theme) {
    switch (securityEvent.severity) {
      case 'critical':
        return Colors.red.shade900;
      case 'high':
        return Colors.orange.shade900;
      case 'medium':
        return Colors.yellow.shade900;
      case 'low':
        return Colors.blue.shade900;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  /// Uyarı ikonunu al
  IconData _getAlertIcon() {
    switch (securityEvent.eventType) {
      case 'failed_login_attempt':
        return Icons.security;
      case 'suspicious_activity':
        return Icons.warning;
      case 'multiple_sessions':
        return Icons.devices;
      case 'unusual_location':
        return Icons.location_on;
      case 'abuse_report':
        return Icons.report;
      default:
        return Icons.info;
    }
  }

  /// Uyarı başlığını al
  String _getAlertTitle() {
    switch (securityEvent.eventType) {
      case 'failed_login_attempt':
        return 'Başarısız Giriş Denemesi';
      case 'suspicious_activity':
        return 'Şüpheli Aktivite';
      case 'multiple_sessions':
        return 'Çoklu Oturum';
      case 'unusual_location':
        return 'Olağandışı Konum';
      case 'abuse_report':
        return 'Kötüye Kullanım Raporu';
      default:
        return 'Güvenlik Uyarısı';
    }
  }

  /// Olay detaylarını oluştur
  Widget _buildEventDetails(ThemeData theme) {
    return Column(
      children: [
        _buildDetailRow('Tarih', _formatDate(securityEvent.timestamp)),
        _buildDetailRow('IP Adresi', securityEvent.ipAddress),
        if (securityEvent.metadata.isNotEmpty) ...[
          _buildDetailRow('Detaylar', _formatMetadata(securityEvent.metadata)),
        ],
      ],
    );
  }

  /// Detay satırı oluştur
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Tarih formatla
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  /// Metadata formatla
  String _formatMetadata(Map<String, dynamic> metadata) {
    return metadata.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
}

/// Güvenlik durumu widget'ı
class SecurityStatusWidget extends StatelessWidget {
  final UserSecurityProfile securityProfile;
  final VoidCallback? onViewDetails;

  const SecurityStatusWidget({
    super.key,
    required this.securityProfile,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(theme),
                ),
                const SizedBox(width: 8),
                Text(
                  'Güvenlik Durumu',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onViewDetails != null)
                  TextButton(
                    onPressed: onViewDetails,
                    child: const Text('Detaylar'),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Durum bilgileri
            _buildStatusInfo(theme),
            
            // Uyarılar
            if (!securityProfile.isSecure) ...[
              const SizedBox(height: 12),
              _buildSecurityWarnings(theme),
            ],
          ],
        ),
      ),
    );
  }

  /// Durum ikonunu al
  IconData _getStatusIcon() {
    if (securityProfile.isBanned) {
      return Icons.block;
    } else if (securityProfile.isFlagged) {
      return Icons.flag;
    } else if (securityProfile.isSuspicious) {
      return Icons.warning;
    } else if (securityProfile.isLocked) {
      return Icons.lock;
    } else {
      return Icons.security;
    }
  }

  /// Durum rengini al
  Color _getStatusColor(ThemeData theme) {
    if (securityProfile.isBanned) {
      return Colors.red;
    } else if (securityProfile.isFlagged) {
      return Colors.orange;
    } else if (securityProfile.isSuspicious) {
      return Colors.yellow.shade700;
    } else if (securityProfile.isLocked) {
      return Colors.grey;
    } else {
      return Colors.green;
    }
  }

  /// Durum bilgilerini oluştur
  Widget _buildStatusInfo(ThemeData theme) {
    return Column(
      children: [
        _buildInfoRow('Durum', securityProfile.status.displayName),
        _buildInfoRow('Rol', securityProfile.role.displayName),
        if (securityProfile.failedLoginAttempts > 0)
          _buildInfoRow('Başarısız Giriş', '${securityProfile.failedLoginAttempts} deneme'),
        if (securityProfile.isLocked)
          _buildInfoRow('Kilit', '${_getLockoutRemainingTime()} dakika kaldı'),
      ],
    );
  }

  /// Güvenlik uyarılarını oluştur
  Widget _buildSecurityWarnings(ThemeData theme) {
    final warnings = <String>[];

    if (securityProfile.isBanned) {
      warnings.add('Hesabınız yasaklanmış');
    }
    if (securityProfile.isFlagged) {
      warnings.add('Hesabınız işaretlenmiş');
    }
    if (securityProfile.isSuspicious) {
      warnings.add('Şüpheli aktivite tespit edildi');
    }
    if (securityProfile.isLocked) {
      warnings.add('Hesabınız kilitli');
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Güvenlik Uyarıları',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 8),
          ...warnings.map((warning) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  size: 16,
                  color: Colors.red.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warning,
                    style: TextStyle(
                      color: Colors.red.shade900,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// Bilgi satırı oluştur
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Kalan kilit süresini al
  String _getLockoutRemainingTime() {
    if (securityProfile.lockoutUntil == null) return '0';
    
    final remaining = securityProfile.lockoutUntil!.difference(DateTime.now());
    if (remaining.isNegative) return '0';
    
    return (remaining.inMinutes + 1).toString();
  }
}

/// Oturum listesi widget'ı
class SessionListWidget extends StatelessWidget {
  final List<UserSession> sessions;
  final Function(String)? onEndSession;

  const SessionListWidget({
    super.key,
    required this.sessions,
    this.onEndSession,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktif Oturumlar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        if (sessions.isEmpty)
          const Text('Aktif oturum bulunmuyor')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _SessionCard(
                session: session,
                onEndSession: onEndSession,
              );
            },
          ),
      ],
    );
  }
}

/// Oturum kartı widget'ı
class _SessionCard extends StatelessWidget {
  final UserSession session;
  final Function(String)? onEndSession;

  const _SessionCard({
    required this.session,
    this.onEndSession,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getDeviceIcon(session.deviceType),
          color: session.isCurrentSession 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        title: Text(
          session.deviceName,
          style: TextStyle(
            fontWeight: session.isCurrentSession ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.location),
            Text('${session.ipAddress} • ${_formatDate(session.loginTime)}'),
            if (session.isCurrentSession)
              Text(
                'Mevcut Oturum',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        trailing: session.isCurrentSession
            ? null
            : IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => onEndSession?.call(session.id),
                tooltip: 'Oturumu Sonlandır',
              ),
      ),
    );
  }

  /// Cihaz ikonunu al
  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType) {
      case 'mobile':
        return Icons.phone_android;
      case 'tablet':
        return Icons.tablet_android;
      case 'desktop':
        return Icons.desktop_windows;
      case 'web':
        return Icons.web;
      default:
        return Icons.devices;
    }
  }

  /// Tarih formatla
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
