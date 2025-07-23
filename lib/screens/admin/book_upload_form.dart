import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../models/book_model.dart';
import '../../services/book_service.dart';

/// Kitap yükleme formu
class BookUploadForm extends StatefulWidget {
  const BookUploadForm({super.key});

  @override
  State<BookUploadForm> createState() => _BookUploadFormState();
}

class _BookUploadFormState extends State<BookUploadForm> {
  final _formKey = GlobalKey<FormState>();
  final BookService _bookService = BookService();

  // Form alanları
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _pointsController = TextEditingController();
  final _previewStartController = TextEditingController();
  final _previewEndController = TextEditingController();
  final _contentController = TextEditingController();

  // Seçimler
  String _selectedCategory = '';
  final List<String> _selectedTags = [];
  bool _isPublished = false;
  bool _isLoading = false;

  // Dosya seçimi
  File? _coverImageFile;
  String? _coverImageUrl;

  // Kategoriler ve etiketler
  final List<String> _categories = [
    'Roman',
    'Bilim Kurgu',
    'Fantastik',
    'Tarih',
    'Bilim',
    'Felsefe',
    'Psikoloji',
    'Kişisel Gelişim',
    'Çocuk',
    'Gençlik',
    'Diğer',
  ];

  final List<String> _availableTags = [
    'Aşk',
    'Macera',
    'Gizem',
    'Gerilim',
    'Komedi',
    'Drama',
    'Tarihi',
    'Modern',
    'Klasik',
    'Çağdaş',
    'Popüler',
    'Ödüllü',
    'Çok Satan',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _pointsController.dispose();
    _previewStartController.dispose();
    _previewEndController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kitap Ekle'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _saveBook, child: const Text('Kaydet')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Temel bilgiler
              _buildSectionTitle(theme, 'Temel Bilgiler'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Kitap Adı *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Kitap adı gereklidir';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(
                        labelText: 'Yazar *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Yazar adı gereklidir';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Açıklama gereklidir';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Kategori ve etiketler
              _buildSectionTitle(theme, 'Kategori ve Etiketler'),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
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
                    _selectedCategory = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori seçimi gereklidir';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Etiket seçimi
              Text(
                'Etiketler',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
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

              const SizedBox(height: 24),

              // Kapak görseli
              _buildSectionTitle(theme, 'Kapak Görseli'),
              const SizedBox(height: 16),

              Row(
                children: [
                  // Kapak görseli önizleme
                  Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _coverImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _coverImageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _coverImageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _coverImageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 32,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kapak Ekle',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(width: 16),

                  // Dosya seçimi butonları
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickCoverImage,
                          icon: const Icon(Icons.upload),
                          label: const Text('Dosya Seç'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Önerilen boyut: 400x600px\nMaksimum dosya boyutu: 5MB',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Fiyatlandırma
              _buildSectionTitle(theme, 'Fiyatlandırma'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Fiyat (TL)',
                        border: OutlineInputBorder(),
                        prefixText: '₺',
                      ),
                      keyboardType: TextInputType.number,
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _pointsController,
                      decoration: const InputDecoration(
                        labelText: 'Puan',
                        border: OutlineInputBorder(),
                        prefixText: '⭐',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final points = int.tryParse(value);
                          if (points == null || points < 0) {
                            return 'Geçerli bir puan girin';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Önizleme ayarları
              _buildSectionTitle(theme, 'Önizleme Ayarları'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _previewStartController,
                      decoration: const InputDecoration(
                        labelText: 'Önizleme Başlangıç Sayfası',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final page = int.tryParse(value);
                          if (page == null || page < 1) {
                            return 'Geçerli bir sayfa numarası girin';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _previewEndController,
                      decoration: const InputDecoration(
                        labelText: 'Önizleme Bitiş Sayfası',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final page = int.tryParse(value);
                          if (page == null || page < 1) {
                            return 'Geçerli bir sayfa numarası girin';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Kitap içeriği
              _buildSectionTitle(theme, 'Kitap İçeriği'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Kitap İçeriği *',
                  border: OutlineInputBorder(),
                  hintText: 'Kitabın tam içeriğini buraya yazın...',
                ),
                maxLines: 20,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kitap içeriği gereklidir';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Yayın durumu
              _buildSectionTitle(theme, 'Yayın Durumu'),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Hemen Yayınla'),
                subtitle: const Text('Kitabı yayın durumuna al'),
                value: _isPublished,
                onChanged: (value) {
                  setState(() {
                    _isPublished = value;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Kaydet butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kitabı Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bölüm başlığı
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  /// Kapak görseli seç
  Future<void> _pickCoverImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _coverImageFile = File(result.files.first.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Dosya seçilirken hata: $e')));
    }
  }

  /// Kapak görselini yükle
  Future<String?> _uploadCoverImage() async {
    if (_coverImageFile == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('book_covers')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(_coverImageFile!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Kapak görseli yüklenirken hata: $e');
    }
  }

  /// Kitabı kaydet
  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Kapak görselini yükle
      String? coverImageUrl;
      if (_coverImageFile != null) {
        coverImageUrl = await _uploadCoverImage();
      }

      // Kitap modelini oluştur
      final book = BookModel(
        id: '', // Firestore otomatik ID verecek
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        tags: _selectedTags,
        coverImageUrl: coverImageUrl,
        price: double.tryParse(_priceController.text) ?? 0.0,
        points: int.tryParse(_pointsController.text) ?? 0,
        content: _contentController.text.trim(),
        previewStartPage: int.tryParse(_previewStartController.text) ?? 1,
        previewEndPage: int.tryParse(_previewEndController.text) ?? 10,
        isPublished: _isPublished,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Kitabı kaydet
      await _bookService.addBook(book);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isPublished
                ? 'Kitap yayınlandı!'
                : 'Kitap taslak olarak kaydedildi!',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kitap kaydedilirken hata: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
