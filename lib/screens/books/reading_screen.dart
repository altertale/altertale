import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import "dart:async";
import "package:shared_preferences/shared_preferences.dart";

/// Reading Screen - Kitap okuma ekranı
class ReadingScreen extends StatefulWidget {
  final BookModel book;
  final List<String> pages; // Kitabın tüm sayfa içerikleri

  const ReadingScreen({super.key, required this.book, required this.pages});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  // Okuma ayarları
  double _fontSize = 16.0;
  double _lineHeight = 1.5;
  bool _isDarkMode = false;
  String _language = "tr";

  // Otomatik kaydetme için timer
  Timer? _autoSaveTimer;
  int _currentPage = 0;
  bool _showSettings = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeReader();
  }

  Future<void> _initializeReader() async {
    try {
      // Validate book and pages data
      if (widget.book == null) {
        throw Exception('Kitap bilgisi bulunamadı');
      }

      if (widget.pages == null || widget.pages.isEmpty) {
        throw Exception('Kitap içeriği bulunamadı');
      }

      // Android için ekran görüntüsü engelle
      await _setFlagSecure();

      // Load saved progress if any
      await _loadReadingProgress();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReadingProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPage = prefs.getInt('reading_progress_${widget.book.id}') ?? 0;

      if (savedPage < widget.pages.length) {
        setState(() {
          _currentPage = savedPage;
        });
      }
    } catch (e) {
      print('Error loading reading progress: $e');
      // Continue with default page 0
    }
  }

  Widget _buildProgressIndicator() {
    if (widget.pages.isEmpty) return const SizedBox.shrink();

    final progress = (_currentPage + 1) / widget.pages.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
      child: Row(
        children: [
          Text(
            'Sayfa ${_currentPage + 1} / ${widget.pages.length}',
            style: TextStyle(
              color: _isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: _isDarkMode
                  ? Colors.grey[700]
                  : Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _isDarkMode ? Colors.blue[300]! : Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              color: _isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingContent() {
    if (widget.pages.isEmpty) {
      return const Center(child: Text('İçerik bulunamadı'));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Text(
          widget.pages[_currentPage],
          style: TextStyle(
            fontSize: _fontSize,
            height: _lineHeight,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _currentPage > 0 ? _previousPage : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Önceki'),
          ),
          Text(
            '${_currentPage + 1} / ${widget.pages.length}',
            style: TextStyle(
              color: _isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _currentPage < widget.pages.length - 1
                ? _nextPage
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Sonraki'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Okuma Ayarları',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  // Font size slider
                  Row(
                    children: [
                      const Text('Font Boyutu:'),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 12,
                          max: 24,
                          divisions: 12,
                          onChanged: (value) {
                            setState(() {
                              _fontSize = value;
                            });
                          },
                        ),
                      ),
                      Text('${_fontSize.toInt()}'),
                    ],
                  ),
                  // Dark mode toggle
                  SwitchListTile(
                    title: const Text('Karanlık Mod'),
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showSettings = false;
                      });
                    },
                    child: const Text('Kapat'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < widget.pages.length - 1) {
      setState(() {
        _currentPage++;
      });
      _saveProgress();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reading_progress_${widget.book.id}', _currentPage);
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  Future<void> _setFlagSecure() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.top],
      );
    } catch (e) {
      print('Error setting flag secure: $e');
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    // _readingProgressService.updateReadingProgress(widget.book.id, page);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Kitap yükleniyor...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Kitap Yüklenemedi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Geri Dön'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Validate current page bounds
    if (_currentPage >= widget.pages.length) {
      _currentPage = 0;
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.book.title,
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
        ),
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
        iconTheme: IconThemeData(
          color: _isDarkMode ? Colors.white : Colors.black,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main reading content
          Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),

              // Reading content
              Expanded(child: _buildReadingContent()),

              // Navigation controls
              _buildNavigationControls(),
            ],
          ),

          // Settings overlay
          if (_showSettings) _buildSettingsOverlay(),
        ],
      ),
    );
  }
}
