import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/points_service.dart';

/// Puan gösterim widget'ı
class PointsDisplayWidget extends StatefulWidget {
  final double? size;
  final Color? textColor;
  final bool showIcon;
  final bool showLabel;

  const PointsDisplayWidget({
    super.key,
    this.size,
    this.textColor,
    this.showIcon = true,
    this.showLabel = true,
  });

  @override
  State<PointsDisplayWidget> createState() => _PointsDisplayWidgetState();
}

class _PointsDisplayWidgetState extends State<PointsDisplayWidget> {
  final PointsService _pointsService = PointsService();
  int _points = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showIcon)
            SizedBox(
              width: widget.size ?? 16,
              height: widget.size ?? 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.textColor ?? theme.colorScheme.primary,
                ),
              ),
            ),
          if (widget.showIcon && widget.showLabel)
            const SizedBox(width: 8),
          if (widget.showLabel)
            Text(
              'Yükleniyor...',
              style: TextStyle(
                fontSize: widget.size ?? 14,
                color: widget.textColor ?? theme.textTheme.bodyMedium?.color,
              ),
            ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showIcon)
          Icon(
            Icons.stars,
            size: widget.size ?? 16,
            color: widget.textColor ?? theme.colorScheme.primary,
          ),
        if (widget.showIcon && widget.showLabel)
          const SizedBox(width: 4),
        if (widget.showLabel)
          Text(
            '$_points puan',
            style: TextStyle(
              fontSize: widget.size ?? 14,
              fontWeight: FontWeight.bold,
              color: widget.textColor ?? theme.textTheme.bodyMedium?.color,
            ),
          ),
      ],
    );
  }

  /// Puanları yükle
  Future<void> _loadPoints() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final points = await _pointsService.getUserPoints(currentUser.uid);
      
      setState(() {
        _points = points;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Puanları yenile
  void refresh() {
    _loadPoints();
  }
}
