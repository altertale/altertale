import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/book_model.dart';
import '../../services/admin/admin_service.dart';

/// Admin kitap editör ekranı
class AdminBookEditor extends StatefulWidget {
  final BookModel? book; // null ise yeni kitap, değilse düzenleme

  const AdminBookEditor({
    super.key,
    this.book,
  });

  @override
  State<AdminBookEditor> createState() => _AdminBookEditorState();
}

class _AdminBookEditorState extends State<AdminBookEditor> {
  final AdminService _adminService = AdminService();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _pointsController = TextEditingController();
  final _pageCountController = TextEditingController();
  
  // Form state
  String? _selectedCategory;
  List<String> _selectedTags = [];
  bool _isPublished = false;
  bool _canPurchaseWithPoints = false;
  File? _coverImage;
  File? _contentFile;
  String? _contentFileName;
  String? _contentType;
  
  bool _isLoading = false;
  String? _error;

  // Kategoriler
  final List<String> _categories = [
    'Roman',
    'Bilim Kurgu',
    'Fantastik',
    'Tarih',
    'Bilim',
    'Felsefe',
    'Psikoloji',
    'Ekonomi',
    'Politika',
    'Sanat',
    'Spor',
    'Çocuk',
    'Gençlik',
    'Klasik',
    'Modern',
  ];

  // Etiketler
  final List<String> _availableTags = [
    'Bestseller',
    'Yeni Çıkan',
    'Popüler',
    'Önerilen',
    'Klasik',
    'Modern',
    'Türkçe',
    'Çeviri',
    'Uzun',
    'Kısa',
    'Kolay',
    'Zor',
    'Eğitici',
    'Eğlenceli',
    'Düşündürücü',
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _pointsController.dispose();
    _pageCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.book != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Kitap Düzenle' : 'Yeni Kitap Ekle'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget(theme)
              : _buildForm(theme),
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
            'Bir hata oluştu',
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
            onPressed: () {
              setState(() {
                _error = null;
              });
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  /// Form widget'ı
  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Temel bilgiler kartı
          _buildBasicInfoCard(theme),
          const SizedBox(height: 16),
          
          // Fiyat ve puan kartı
          _buildPricingCard(theme),
          const SizedBox(height: 16),
          
          // Kategori ve etiketler kartı
          _buildCategoryCard(theme),
          const SizedBox(height: 16),
          
          // Kapak resmi kartı
          _buildCoverImageCard(theme),
          const SizedBox(height: 16),
          
          // İçerik dosyası kartı
          _buildContentFileCard(theme),
          const SizedBox(height: 16),
          
          // Durum kartı
          _buildStatusCard(theme),
          const SizedBox(height: 16),
          
          // Kaydet butonu
          _buildSaveButton(theme),
        ],
      ),
    );
  }

  /// Temel bilgiler kartı
  Widget _buildBasicInfoCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Temel Bilgiler',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Başlık
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Kitap Başlığı *',
                hintText: 'Kitabın başlığını girin',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Başlık gereklidir';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Yazar
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Yazar *',
                hintText: 'Yazarın adını girin',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Yazar adı gereklidir';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Açıklama
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                hintText: 'Kitap hakkında kısa açıklama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Sayfa sayısı
            TextFormField(
              controller: _pageCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sayfa Sayısı',
                hintText: 'Örn: 250',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final pageCount = int.tryParse(value);
                  if (pageCount == null || pageCount <= 0) {
                    return 'Geçerli bir sayfa sayısı girin';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Fiyat ve puan kartı
  Widget _buildPricingCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Fiyatlandırma',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Para ile fiyat
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fiyat (₺)',
                hintText: 'Örn: 29.99',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Geçerli bir fiyat girin';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Puan ile alınabilir mi?
            SwitchListTile(
              title: const Text('Puan ile Alınabilir'),
              subtitle: const Text('Kullanıcılar puan ile satın alabilir'),
              value: _canPurchaseWithPoints,
              onChanged: (value) {
                setState(() {
                  _canPurchaseWithPoints = value;
                });
              },
            ),
            
            // Puan fiyatı
            if (_canPurchaseWithPoints) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Puan Fiyatı *',
                  hintText: 'Örn: 100',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.stars),
                ),
                validator: (value) {
                  if (_canPurchaseWithPoints) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Puan fiyatı gereklidir';
                    }
                    final points = int.tryParse(value);
                    if (points == null || points <= 0) {
                      return 'Geçerli bir puan değeri girin';
                    }
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Kategori ve etiketler kartı
  Widget _buildCategoryCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Kategori ve Etiketler',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Kategori seçimi
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Etiketler
            Text(
              'Etiketler',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Kapak resmi kartı
  Widget _buildCoverImageCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.image, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Kapak Resmi',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_coverImage != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _coverImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickCoverImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeriden Seç'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takeCoverPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Fotoğraf Çek'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// İçerik dosyası kartı
  Widget _buildContentFileCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.file_copy, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'İçerik Dosyası',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_contentFile != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.primary),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(_contentType),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _contentFileName ?? 'Bilinmeyen dosya',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _contentType ?? 'Bilinmeyen tür',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _contentFile = null;
                          _contentFileName = null;
                          _contentType = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            ElevatedButton.icon(
              onPressed: _pickContentFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Dosya Seç'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            
            const SizedBox(height: 8),
            Text(
              'Desteklenen formatlar: PDF, HTML, Markdown, TXT',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Durum kartı
  Widget _buildStatusCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.publish, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Yayın Durumu',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Yayınla'),
              subtitle: const Text('Kitabı kullanıcılara görünür yap'),
              value: _isPublished,
              onChanged: (value) {
                setState(() {
                  _isPublished = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Kaydet butonu
  Widget _buildSaveButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveBook,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      child: Text(
        widget.book != null ? 'Güncelle' : 'Kaydet',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Formu başlat
  void _initializeForm() {
    if (widget.book != null) {
      final book = widget.book!;
      _titleController.text = book.title;
      _authorController.text = book.author;
      _descriptionController.text = book.description;
      _priceController.text = book.price.toString();
      _pointsController.text = book.points.toString();
      _pageCountController.text = book.pageCount.toString();
      _selectedCategory = book.categories.isNotEmpty ? book.categories.first : null;
      _selectedTags = List.from(book.tags);
      _isPublished = book.isPublished;
      _canPurchaseWithPoints = book.points > 0;
    }
  }

  /// Kapak resmi seç
  Future<void> _pickCoverImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _coverImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Kapak resmi seçilirken hata oluştu: $e');
    }
  }

  /// Kapak fotoğrafı çek
  Future<void> _takeCoverPhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      
      if (pickedFile != null) {
        setState(() {
          _coverImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Fotoğraf çekilirken hata oluştu: $e');
    }
  }

  /// İçerik dosyası seç
  Future<void> _pickContentFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'html', 'htm', 'md', 'markdown', 'txt'],
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final path = file.path;
        
        if (path != null) {
          setState(() {
            _contentFile = File(path);
            _contentFileName = file.name;
            _contentType = _getContentType(file.extension ?? '');
          });
        }
      }
    } catch (e) {
      _showError('Dosya seçilirken hata oluştu: $e');
    }
  }

  /// İçerik türünü belirle
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'pdf';
      case 'html':
      case 'htm':
        return 'html';
      case 'md':
      case 'markdown':
        return 'markdown';
      case 'txt':
        return 'text';
      default:
        return 'unknown';
    }
  }

  /// Dosya ikonu getir
  IconData _getFileIcon(String? contentType) {
    switch (contentType) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'html':
        return Icons.html;
      case 'markdown':
        return Icons.description;
      case 'text':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Kitabı kaydet
  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Form verilerini topla
      final bookData = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'points': _canPurchaseWithPoints ? (int.tryParse(_pointsController.text) ?? 0) : 0,
        'pageCount': int.tryParse(_pageCountController.text) ?? 0,
        'categories': _selectedCategory != null ? [_selectedCategory!] : [],
        'tags': _selectedTags,
        'isPublished': _isPublished,
        'createdAt': widget.book?.createdAt ?? DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      // Kitabı kaydet
      final bookId = widget.book?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      // Firestore'a kaydet
      await _adminService.addAdminLog(
        action: widget.book != null ? 'update_book' : 'create_book',
        details: 'Kitap ${widget.book != null ? 'güncellendi' : 'oluşturuldu'}: ${bookData['title']}',
        data: bookData,
      );

      // Başarı mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.book != null ? 'Kitap güncellendi' : 'Kitap oluşturuldu',
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Hata göster
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
