import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// Services
import '../services/firestore_service.dart';

/// Firestore Service Test Screen
///
/// Comprehensive testing interface for FirestoreService:
/// - CRUD operations testing
/// - Batch operations
/// - Real-time listeners
/// - Query operations
/// - Error handling
/// - Performance monitoring
class FirestoreServiceTest extends StatefulWidget {
  const FirestoreServiceTest({super.key});

  @override
  State<FirestoreServiceTest> createState() => _FirestoreServiceTestState();
}

class _FirestoreServiceTestState extends State<FirestoreServiceTest> {
  // ==================== SERVICE & STATE ====================
  final FirestoreService _firestoreService = FirestoreService();

  // Test collection
  static const String _testCollection = 'test_collection';

  // UI State
  bool _isLoading = false;
  String? _lastResult;
  String? _errorMessage;

  // Test data
  final List<Map<String, dynamic>> _testDocuments = [];
  final List<String> _operationLogs = [];

  // Real-time listeners
  StreamSubscription? _documentListener;
  StreamSubscription? _collectionListener;
  Map<String, dynamic>? _listenedDocument;
  List<Map<String, dynamic>> _listenedCollection = [];

  // Controllers
  final _docIdController = TextEditingController();
  final _fieldController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addLog('🚀 Firestore Service Test başlatıldı');
  }

  @override
  void dispose() {
    _documentListener?.cancel();
    _collectionListener?.cancel();
    _docIdController.dispose();
    _fieldController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  // ==================== UI HELPERS ====================

  void _addLog(String message) {
    setState(() {
      _operationLogs.insert(
        0,
        '${DateTime.now().toIso8601String().substring(11, 19)} - $message',
      );
      if (_operationLogs.length > 50) {
        _operationLogs.removeLast();
      }
    });
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
      if (loading) {
        _errorMessage = null;
      }
    });
  }

  void _setResult(String result) {
    setState(() {
      _lastResult = result;
      _errorMessage = null;
    });
    _addLog('✅ $result');
  }

  void _setError(String error) {
    setState(() {
      _errorMessage = error;
      _lastResult = null;
    });
    _addLog('❌ $error');
  }

  // ==================== TEST OPERATIONS ====================

  // CREATE TESTS
  Future<void> _testCreateDocument() async {
    _setLoading(true);
    try {
      final testData = {
        'name': 'Test Document ${Random().nextInt(1000)}',
        'value': Random().nextInt(100),
        'isTest': true,
        'tags': ['test', 'firestore', 'flutter'],
        'metadata': {'createdBy': 'test_user', 'version': 1},
      };

      final docId = await _firestoreService.createDoc(
        collection: _testCollection,
        data: testData,
      );

      _setResult('Doküman oluşturuldu: $docId');
      _refreshTestData();
    } catch (e) {
      _setError('Doküman oluşturma hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _testCreateDocumentWithId() async {
    _setLoading(true);
    try {
      final customId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      final testData = {
        'name': 'Custom ID Document',
        'customId': customId,
        'isCustom': true,
      };

      final docId = await _firestoreService.createDoc(
        collection: _testCollection,
        data: testData,
        docId: customId,
      );

      _setResult('Özel ID ile doküman oluşturuldu: $docId');
      _refreshTestData();
    } catch (e) {
      _setError('Özel ID doküman oluşturma hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _testCreateBatch() async {
    _setLoading(true);
    try {
      final documents = List.generate(
        5,
        (index) => {
          'name': 'Batch Document $index',
          'batchNumber': index,
          'isBatch': true,
        },
      );

      final docIds = await _firestoreService.createDocsBatch(
        collection: _testCollection,
        documents: documents,
      );

      _setResult('Batch oluşturma: ${docIds.length} doküman');
      _refreshTestData();
    } catch (e) {
      _setError('Batch oluşturma hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  // READ TESTS
  Future<void> _testReadDocument() async {
    if (_docIdController.text.isEmpty) {
      _setError('Doküman ID giriniz');
      return;
    }

    _setLoading(true);
    try {
      final data = await _firestoreService.readDoc(
        collection: _testCollection,
        docId: _docIdController.text,
      );

      if (data != null) {
        _setResult('Doküman okundu: ${data.keys.length} alan');
      } else {
        _setResult('Doküman bulunamadı: ${_docIdController.text}');
      }
    } catch (e) {
      _setError('Doküman okuma hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _testReadCollection() async {
    _setLoading(true);
    try {
      final documents = await _firestoreService.readCollection(
        collection: _testCollection,
        limit: 10,
        orderBy: 'createdAt',
        descending: true,
      );

      _setResult('Koleksiyon okundu: ${documents.length} doküman');
      setState(() {
        _testDocuments.clear();
        _testDocuments.addAll(documents);
      });
    } catch (e) {
      _setError('Koleksiyon okuma hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _testQueryDocuments() async {
    _setLoading(true);
    try {
      final documents = await _firestoreService.queryDocuments(
        collection: _testCollection,
        field: 'isTest',
        operator: '==',
        value: true,
        limit: 5,
      );

      _setResult('Sorgu sonucu: ${documents.length} doküman');
    } catch (e) {
      _setError('Sorgu hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  // UPDATE TESTS
  Future<void> _testUpdateDocument() async {
    if (_docIdController.text.isEmpty) {
      _setError('Doküman ID giriniz');
      return;
    }

    _setLoading(true);
    try {
      final updateData = {
        'name': 'Updated Document ${DateTime.now().millisecondsSinceEpoch}',
        'lastUpdate': DateTime.now().toIso8601String(),
        'updateCount': DateTime.now().millisecondsSinceEpoch % 100,
      };

      await _firestoreService.updateDoc(
        collection: _testCollection,
        docId: _docIdController.text,
        data: updateData,
      );

      _setResult('Doküman güncellendi: ${_docIdController.text}');
      _refreshTestData();
    } catch (e) {
      _setError('Doküman güncelleme hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  // DELETE TESTS
  Future<void> _testDeleteDocument() async {
    if (_docIdController.text.isEmpty) {
      _setError('Doküman ID giriniz');
      return;
    }

    _setLoading(true);
    try {
      await _firestoreService.deleteDoc(
        collection: _testCollection,
        docId: _docIdController.text,
      );

      _setResult('Doküman silindi: ${_docIdController.text}');
      _docIdController.clear();
      _refreshTestData();
    } catch (e) {
      _setError('Doküman silme hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  // LISTENER TESTS
  void _testDocumentListener() {
    if (_docIdController.text.isEmpty) {
      _setError('Doküman ID giriniz');
      return;
    }

    _documentListener?.cancel();

    _documentListener = _firestoreService
        .listenToDoc(collection: _testCollection, docId: _docIdController.text)
        .listen(
          (data) {
            setState(() {
              _listenedDocument = data;
            });
            _addLog('🔄 Doküman listener güncellendi');
          },
          onError: (error) {
            _addLog('❌ Doküman listener hatası: $error');
          },
        );

    _addLog('👂 Doküman listener başlatıldı: ${_docIdController.text}');
  }

  void _testCollectionListener() {
    _collectionListener?.cancel();

    _collectionListener = _firestoreService
        .listenToCollection(
          collection: _testCollection,
          limit: 5,
          orderBy: 'createdAt',
          descending: true,
        )
        .listen(
          (documents) {
            setState(() {
              _listenedCollection = documents;
            });
            _addLog(
              '🔄 Koleksiyon listener güncellendi: ${documents.length} doküman',
            );
          },
          onError: (error) {
            _addLog('❌ Koleksiyon listener hatası: $error');
          },
        );

    _addLog('👂 Koleksiyon listener başlatıldı');
  }

  // UTILITY TESTS
  Future<void> _testDocumentExists() async {
    if (_docIdController.text.isEmpty) {
      _setError('Doküman ID giriniz');
      return;
    }

    _setLoading(true);
    try {
      final exists = await _firestoreService.docExists(
        collection: _testCollection,
        docId: _docIdController.text,
      );

      _setResult(
        'Doküman ${exists ? 'mevcut' : 'mevcut değil'}: ${_docIdController.text}',
      );
    } catch (e) {
      _setError('Doküman kontrol hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _testCollectionCount() async {
    _setLoading(true);
    try {
      final count = await _firestoreService.getCollectionCount(
        collection: _testCollection,
      );

      _setResult('Koleksiyon doküman sayısı: $count');
    } catch (e) {
      _setError('Koleksiyon sayım hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _refreshTestData() async {
    await _testReadCollection();
  }

  void _clearLogs() {
    setState(() {
      _operationLogs.clear();
    });
  }

  void _stopListeners() {
    _documentListener?.cancel();
    _collectionListener?.cancel();
    setState(() {
      _listenedDocument = null;
      _listenedCollection.clear();
    });
    _addLog('🛑 Tüm listener\'lar durduruldu');
  }

  // ==================== UI BUILD ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Service Test'),
        actions: [
          IconButton(
            onPressed: _refreshTestData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Verileri Yenile',
          ),
          IconButton(
            onPressed: _clearLogs,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Logları Temizle',
          ),
        ],
      ),

      body: Column(
        children: [
          // Status Bar
          _buildStatusBar(theme),

          // Main Content
          Expanded(
            child: Row(
              children: [
                // Left Panel - Controls
                Expanded(flex: 2, child: _buildControlPanel(theme)),

                // Right Panel - Results
                Expanded(flex: 3, child: _buildResultPanel(theme)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
      child: Row(
        children: [
          Icon(
            Icons.storage_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Collection: $_testCollection',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          if (_isLoading) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text('İşlem devam ediyor...', style: theme.textTheme.bodySmall),
          ] else if (_lastResult != null) ...[
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              _lastResult!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ] else if (_errorMessage != null) ...[
            Icon(Icons.error, color: theme.colorScheme.error, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlPanel(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Section
          _buildInputSection(theme),

          const SizedBox(height: 24),

          // CREATE Operations
          _buildOperationSection('CREATE İşlemleri', Icons.add_circle, [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testCreateDocument,
              icon: const Icon(Icons.create, size: 18),
              label: const Text('Doküman Oluştur'),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testCreateDocumentWithId,
              icon: const Icon(Icons.create_outlined, size: 18),
              label: const Text('Özel ID ile Oluştur'),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testCreateBatch,
              icon: const Icon(Icons.library_add, size: 18),
              label: const Text('Batch Oluştur (5)'),
            ),
          ], theme),

          const SizedBox(height: 16),

          // READ Operations
          _buildOperationSection('READ İşlemleri', Icons.visibility, [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testReadDocument,
              icon: const Icon(Icons.description, size: 18),
              label: const Text('Doküman Oku'),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testReadCollection,
              icon: const Icon(Icons.list, size: 18),
              label: const Text('Koleksiyon Oku'),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testQueryDocuments,
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Sorgu (isTest=true)'),
            ),
          ], theme),

          const SizedBox(height: 16),

          // UPDATE Operations
          _buildOperationSection('UPDATE İşlemleri', Icons.edit, [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testUpdateDocument,
              icon: const Icon(Icons.update, size: 18),
              label: const Text('Doküman Güncelle'),
            ),
          ], theme),

          const SizedBox(height: 16),

          // DELETE Operations
          _buildOperationSection('DELETE İşlemleri', Icons.delete, [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testDeleteDocument,
              icon: const Icon(Icons.delete_forever, size: 18),
              label: const Text('Doküman Sil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ),
          ], theme),

          const SizedBox(height: 16),

          // LISTENER Operations
          _buildOperationSection('LISTENER İşlemleri', Icons.hearing, [
            ElevatedButton.icon(
              onPressed: _testDocumentListener,
              icon: const Icon(Icons.radio_button_checked, size: 18),
              label: const Text('Doküman Dinle'),
            ),
            ElevatedButton.icon(
              onPressed: _testCollectionListener,
              icon: const Icon(Icons.playlist_play, size: 18),
              label: const Text('Koleksiyon Dinle'),
            ),
            ElevatedButton.icon(
              onPressed: _stopListeners,
              icon: const Icon(Icons.stop, size: 18),
              label: const Text('Listener\'ları Durdur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
              ),
            ),
          ], theme),

          const SizedBox(height: 16),

          // UTILITY Operations
          _buildOperationSection('UTILITY İşlemleri', Icons.build, [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testDocumentExists,
              icon: const Icon(Icons.check_box, size: 18),
              label: const Text('Doküman Var mı?'),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testCollectionCount,
              icon: const Icon(Icons.numbers, size: 18),
              label: const Text('Doküman Sayısı'),
            ),
          ], theme),
        ],
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.input_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test Parametreleri',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _docIdController,
              decoration: const InputDecoration(
                labelText: 'Doküman ID',
                hintText: 'Test için doküman ID giriniz',
                prefixIcon: Icon(Icons.fingerprint),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fieldController,
                    decoration: const InputDecoration(
                      labelText: 'Alan Adı',
                      hintText: 'field name',
                      prefixIcon: Icon(Icons.label),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    decoration: const InputDecoration(
                      labelText: 'Değer',
                      hintText: 'value',
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationSection(
    String title,
    IconData icon,
    List<Widget> buttons,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(spacing: 8, runSpacing: 8, children: buttons),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPanel(ThemeData theme) {
    return Column(
      children: [
        // Tabs
        Container(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
          child: TabBar(
            controller: TabController(length: 4, vsync: Scaffold.of(context)),
            tabs: const [
              Tab(text: 'Dokümanlar', icon: Icon(Icons.list, size: 16)),
              Tab(text: 'Listeners', icon: Icon(Icons.hearing, size: 16)),
              Tab(text: 'Loglar', icon: Icon(Icons.terminal, size: 16)),
              Tab(text: 'JSON', icon: Icon(Icons.code, size: 16)),
            ],
            labelStyle: theme.textTheme.bodySmall,
            unselectedLabelStyle: theme.textTheme.bodySmall,
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: TabController(length: 4, vsync: Scaffold.of(context)),
            children: [
              _buildDocumentsTab(theme),
              _buildListenersTab(theme),
              _buildLogsTab(theme),
              _buildJsonTab(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _testDocuments.length,
      itemBuilder: (context, index) {
        final doc = _testDocuments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text('${index + 1}'),
            ),
            title: Text(doc['name'] ?? 'Unnamed'),
            subtitle: Text('ID: ${doc['id']}'),
            trailing: IconButton(
              onPressed: () {
                _docIdController.text = doc['id'];
              },
              icon: const Icon(Icons.edit),
            ),
            onTap: () {
              // Show document details
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Doküman Detayları'),
                  content: SingleChildScrollView(child: Text(doc.toString())),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kapat'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildListenersTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Listener
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doküman Listener',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_listenedDocument != null)
                    Text(_listenedDocument.toString())
                  else
                    Text(
                      'Doküman listener aktif değil',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Collection Listener
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Koleksiyon Listener (${_listenedCollection.length} doküman)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._listenedCollection.map(
                    (doc) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '• ${doc['name'] ?? 'Unnamed'} (${doc['id']})',
                      ),
                    ),
                  ),
                  if (_listenedCollection.isEmpty)
                    Text(
                      'Koleksiyon listener aktif değil',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _operationLogs.length,
      itemBuilder: (context, index) {
        final log = _operationLogs[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: log.contains('❌')
                ? theme.colorScheme.errorContainer.withAlpha(128)
                : log.contains('✅')
                ? theme.colorScheme.primaryContainer.withAlpha(128)
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            log,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: log.contains('❌')
                  ? theme.colorScheme.onErrorContainer
                  : log.contains('✅')
                  ? theme.colorScheme.onPrimaryContainer
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildJsonTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Dokümanları JSON',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(128),
              ),
            ),
            child: SelectableText(
              _testDocuments.isEmpty
                  ? 'Henüz doküman yok'
                  : _testDocuments.map((doc) => '${doc.toString()}\n\n').join(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
