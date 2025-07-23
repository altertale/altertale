import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

/// Firebase Services Test Screen
///
/// Comprehensive testing interface for Firebase services:
/// - Firestore CRUD operations testing
/// - Authentication flow testing
/// - Real-time logging and feedback
/// - Error handling validation
/// - Performance monitoring
class FirebaseServicesTestScreen extends StatefulWidget {
  const FirebaseServicesTestScreen({super.key});

  @override
  State<FirebaseServicesTestScreen> createState() =>
      _FirebaseServicesTestScreenState();
}

class _FirebaseServicesTestScreenState extends State<FirebaseServicesTestScreen>
    with TickerProviderStateMixin {
  // ==================== SERVICES ====================
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();

  // ==================== CONTROLLERS ====================
  late TabController _tabController;
  final ScrollController _logController = ScrollController();

  // ==================== STATE ====================
  final List<String> _logs = [];
  bool _isLoading = false;

  // ==================== TEST DATA ====================
  final String _testCollection = 'test_documents';
  final Map<String, dynamic> _testData = {
    'title': 'Test Document',
    'description': 'This is a test document for Firebase services',
    'count': 42,
    'isActive': true,
    'tags': ['test', 'firebase', 'flutter'],
    'metadata': {'version': '1.0.0', 'author': 'Test User'},
  };

  // ==================== FORM CONTROLLERS ====================
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _addLog('🔥 Firebase Services Test Screen initialized');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _logController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ==================== LOGGING METHODS ====================

  void _addLog(String message) {
    if (mounted) {
      setState(() {
        _logs.add(
          '${DateTime.now().toLocal().toString().substring(11, 19)} - $message',
        );
      });

      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_logController.hasClients) {
          _logController.animateTo(
            _logController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    if (kDebugMode) {
      print(message);
    }
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
    _addLog('📝 Logs cleared');
  }

  // ==================== FIRESTORE TEST METHODS ====================

  Future<void> _testFirestoreCreate() async {
    setState(() => _isLoading = true);

    try {
      _addLog('🔥 Testing Firestore CREATE operation...');

      final docId = await _firestore.createDoc(
        collection: _testCollection,
        data: _testData,
      );

      _addLog('✅ CREATE Success: Document created with ID: $docId');
    } catch (e) {
      _addLog('❌ CREATE Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testFirestoreRead() async {
    setState(() => _isLoading = true);

    try {
      _addLog('🔥 Testing Firestore READ operation...');

      // First, get all documents to find one to read
      final documents = await _firestore.readCollection(
        collection: _testCollection,
        limit: 1,
      );

      if (documents.isEmpty) {
        _addLog('⚠️ READ Warning: No documents found. Create one first.');
        return;
      }

      final docId = documents.first['id'];
      final data = await _firestore.readDoc(
        collection: _testCollection,
        docId: docId,
      );

      if (data != null) {
        _addLog(
          '✅ READ Success: Document found with ${data.keys.length} fields',
        );
        _addLog('📄 Data: ${data.toString().substring(0, 100)}...');
      } else {
        _addLog('⚠️ READ Warning: Document not found');
      }
    } catch (e) {
      _addLog('❌ READ Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testFirestoreUpdate() async {
    setState(() => _isLoading = true);

    try {
      _addLog('🔥 Testing Firestore UPDATE operation...');

      // Get a document to update
      final documents = await _firestore.readCollection(
        collection: _testCollection,
        limit: 1,
      );

      if (documents.isEmpty) {
        _addLog('⚠️ UPDATE Warning: No documents found. Create one first.');
        return;
      }

      final docId = documents.first['id'];
      final updateData = {
        'count': 100,
        'lastUpdated': DateTime.now().toIso8601String(),
        'status': 'updated',
      };

      await _firestore.updateDoc(
        collection: _testCollection,
        docId: docId,
        data: updateData,
      );

      _addLog('✅ UPDATE Success: Document $docId updated');
    } catch (e) {
      _addLog('❌ UPDATE Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testFirestoreDelete() async {
    setState(() => _isLoading = true);

    try {
      _addLog('🔥 Testing Firestore DELETE operation...');

      // Get a document to delete
      final documents = await _firestore.readCollection(
        collection: _testCollection,
        limit: 1,
      );

      if (documents.isEmpty) {
        _addLog('⚠️ DELETE Warning: No documents found. Create one first.');
        return;
      }

      final docId = documents.first['id'];

      await _firestore.deleteDoc(collection: _testCollection, docId: docId);

      _addLog('✅ DELETE Success: Document $docId deleted');
    } catch (e) {
      _addLog('❌ DELETE Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testFirestoreBatch() async {
    setState(() => _isLoading = true);

    try {
      _addLog('🔥 Testing Firestore BATCH operations...');

      // Create batch
      final batchData = List.generate(
        3,
        (index) => {
          ..._testData,
          'batchIndex': index,
          'batchId': 'batch_${DateTime.now().millisecondsSinceEpoch}_$index',
        },
      );

      final docIds = await _firestore.createDocsBatch(
        collection: _testCollection,
        documents: batchData,
      );

      _addLog('✅ BATCH CREATE Success: ${docIds.length} documents created');

      // Read batch
      final readData = await _firestore.readDocsBatch(
        collection: _testCollection,
        docIds: docIds,
      );

      final foundCount = readData.values.where((data) => data != null).length;
      _addLog(
        '✅ BATCH READ Success: $foundCount/${docIds.length} documents found',
      );
    } catch (e) {
      _addLog('❌ BATCH Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==================== AUTH TEST METHODS ====================

  Future<void> _testAuthSignUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      _addLog('❌ SIGNUP Failed: Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      _addLog('🔐 Testing Auth SIGNUP operation...');

      final credential = await _auth.signUpWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
      );

      _addLog('✅ SIGNUP Success: User created - ${credential.user?.uid}');
      _addLog('📧 Email verification sent');
    } catch (e) {
      _addLog('❌ SIGNUP Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testAuthSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _addLog('❌ SIGNIN Failed: Please fill email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      _addLog('🔐 Testing Auth SIGNIN operation...');

      final credential = await _auth.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      _addLog('✅ SIGNIN Success: User signed in - ${credential.user?.uid}');
    } catch (e) {
      _addLog('❌ SIGNIN Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testAuthSignOut() async {
    setState(() => _isLoading = true);

    try {
      _addLog('🔐 Testing Auth SIGNOUT operation...');

      await _auth.signOut();

      _addLog('✅ SIGNOUT Success: User signed out');
    } catch (e) {
      _addLog('❌ SIGNOUT Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testPasswordReset() async {
    if (_emailController.text.isEmpty) {
      _addLog('❌ PASSWORD RESET Failed: Please enter email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      _addLog('🔐 Testing PASSWORD RESET operation...');

      await _auth.resetPassword(email: _emailController.text.trim());

      _addLog('✅ PASSWORD RESET Success: Reset email sent');
    } catch (e) {
      _addLog('❌ PASSWORD RESET Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _checkAuthState() {
    _addLog('🔐 Checking Auth State...');

    final user = _auth.currentUser;
    if (user != null) {
      _addLog('✅ User is signed in: ${user.email} (${user.uid})');
      _addLog('📧 Email verified: ${user.emailVerified}');
    } else {
      _addLog('⚠️ No user signed in');
    }
  }

  // ==================== UI BUILD METHODS ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Services Test'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.storage), text: 'Firestore'),
            Tab(icon: Icon(Icons.security), text: 'Auth'),
            Tab(icon: Icon(Icons.list_alt), text: 'Logs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFirestoreTab(theme),
          _buildAuthTab(theme),
          _buildLogsTab(theme),
        ],
      ),
    );
  }

  Widget _buildFirestoreTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.storage,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Firestore CRUD Operations',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Test all Firestore operations: Create, Read, Update, Delete, and Batch operations',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // CRUD Operations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic CRUD Operations',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 3,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testFirestoreCreate,
                        icon: const Icon(Icons.add),
                        label: const Text('CREATE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade700,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testFirestoreRead,
                        icon: const Icon(Icons.visibility),
                        label: const Text('READ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testFirestoreUpdate,
                        icon: const Icon(Icons.edit),
                        label: const Text('UPDATE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade700,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testFirestoreDelete,
                        icon: const Icon(Icons.delete),
                        label: const Text('DELETE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Batch Operations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Batch Operations',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testFirestoreBatch,
                      icon: const Icon(Icons.dynamic_feed),
                      label: const Text('Test Batch Operations'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        foregroundColor: theme.colorScheme.onSecondaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
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

  Widget _buildAuthTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Firebase Authentication',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Test authentication operations: Sign up, Sign in, Sign out, Password reset',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Form Fields
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Credentials',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Auth Operations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Authentication Operations',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.5,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testAuthSignUp,
                        icon: const Icon(Icons.person_add),
                        label: const Text('SIGN UP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade700,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testAuthSignIn,
                        icon: const Icon(Icons.login),
                        label: const Text('SIGN IN'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testAuthSignOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('SIGN OUT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade700,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testPasswordReset,
                        icon: const Icon(Icons.refresh),
                        label: const Text('RESET'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _checkAuthState,
                      icon: const Icon(Icons.info),
                      label: const Text('Check Auth State'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        foregroundColor: theme.colorScheme.onSecondaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
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
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.list_alt, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Test Logs (${_logs.length} entries)',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _clearLogs,
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),

        // Logs List
        Expanded(
          child: _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No logs yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Run some tests to see logs here',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  controller: _logController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _logs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = _logs[index];

                    Color? bgColor;
                    IconData icon = Icons.info;

                    if (log.contains('✅')) {
                      bgColor = Colors.green.shade50;
                      icon = Icons.check_circle;
                    } else if (log.contains('❌')) {
                      bgColor = Colors.red.shade50;
                      icon = Icons.error;
                    } else if (log.contains('⚠️')) {
                      bgColor = Colors.orange.shade50;
                      icon = Icons.warning;
                    } else if (log.contains('🔥') || log.contains('🔐')) {
                      bgColor = Colors.blue.shade50;
                      icon = Icons.play_arrow;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            icon,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              log,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Loading Indicator
        if (_isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Running test...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
