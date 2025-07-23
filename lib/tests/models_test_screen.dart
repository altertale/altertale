import 'package:flutter/material.dart';
import 'dart:math';

// Models
import '../models/user_model.dart';
import '../models/story_model.dart';
import '../models/purchase_model.dart';
import '../models/comment_model.dart';
import '../models/bookmark_model.dart';
import '../models/notification_model.dart';

/// Comprehensive Models Test Screen
///
/// Test interface for all data models in the Altertale application:
/// - UserModel, StoryModel, PurchaseModel
/// - CommentModel, BookmarkModel, NotificationModel
/// - CRUD operations simulation
/// - Serialization/Deserialization testing
/// - Factory constructor testing
/// - Helper methods demonstration
class ModelsTestScreen extends StatefulWidget {
  const ModelsTestScreen({super.key});

  @override
  State<ModelsTestScreen> createState() => _ModelsTestScreenState();
}

class _ModelsTestScreenState extends State<ModelsTestScreen>
    with TickerProviderStateMixin {
  // ==================== STATE & CONTROLLERS ====================

  late TabController _tabController;
  final Random _random = Random();
  final List<String> _testLogs = [];

  // Test instances
  UserModel? _testUser;
  StoryModel? _testStory;
  PurchaseModel? _testPurchase;
  CommentModel? _testComment;
  BookmarkModel? _testBookmark;
  NotificationModel? _testNotification;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _addLog('🚀 Models Test Screen başlatıldı');
    _initializeTestData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==================== LOGGING ====================

  void _addLog(String message) {
    setState(() {
      _testLogs.insert(
        0,
        '${DateTime.now().toIso8601String().substring(11, 19)} - $message',
      );
      if (_testLogs.length > 100) {
        _testLogs.removeLast();
      }
    });
  }

  void _clearLogs() {
    setState(() {
      _testLogs.clear();
    });
  }

  // ==================== TEST DATA INITIALIZATION ====================

  void _initializeTestData() {
    _createTestUser();
    _createTestStory();
    _createTestPurchase();
    _createTestComment();
    _createTestBookmark();
    _createTestNotification();
  }

  // ==================== USER MODEL TESTS ====================

  void _createTestUser() {
    try {
      _testUser = UserModel.create(
        uid: 'user_${_random.nextInt(10000)}',
        email: 'test${_random.nextInt(1000)}@altertale.com',
        name: 'Test Kullanıcı ${_random.nextInt(100)}',
        profileImageUrl:
            'https://example.com/avatar_${_random.nextInt(10)}.jpg',
      );
      _addLog('✅ UserModel oluşturuldu: ${_testUser!.name}');
    } catch (e) {
      _addLog('❌ UserModel oluşturma hatası: $e');
    }
  }

  void _testUserSerialization() {
    if (_testUser == null) return;

    try {
      // toMap test
      final userMap = _testUser!.toMap();
      _addLog('📤 UserModel.toMap(): ${userMap.keys.length} alan');

      // fromMap test
      final reconstructedUser = UserModel.fromMap(userMap);
      _addLog('📥 UserModel.fromMap(): ${reconstructedUser.name}');

      // Equality test
      final isEqual =
          _testUser!.uid == reconstructedUser.uid &&
          _testUser!.email == reconstructedUser.email;
      _addLog(
        '🔍 Serialization test: ${isEqual ? "✅ Başarılı" : "❌ Başarısız"}',
      );
    } catch (e) {
      _addLog('❌ UserModel serialization hatası: $e');
    }
  }

  void _testUserHelperMethods() {
    if (_testUser == null) return;

    try {
      _addLog('👤 User Helper Methods:');
      _addLog('  • isPremiumActive: ${_testUser!.isPremiumActive}');
      _addLog('  • roleDisplayName: ${_testUser!.roleDisplayName}');
      _addLog('  • firstName: ${_testUser!.firstName}');
      _addLog('  • initials: ${_testUser!.initials}');
      _addLog('  • isProfileComplete: ${_testUser!.isProfileComplete}');
      _addLog('  • activityLevel: ${_testUser!.activityLevel}');
    } catch (e) {
      _addLog('❌ UserModel helper methods hatası: $e');
    }
  }

  void _updateTestUser() {
    if (_testUser == null) return;

    try {
      _testUser = _testUser!.copyWith(
        name: 'Güncellenmiş ${_testUser!.firstName}',
        totalPoints: _testUser!.totalPoints + _random.nextInt(100),
        booksRead: _testUser!.booksRead + 1,
        isPremiumUser: !_testUser!.isPremiumUser,
        updatedAt: DateTime.now(),
      );
      _addLog('🔄 UserModel güncellendi: ${_testUser!.name}');
    } catch (e) {
      _addLog('❌ UserModel güncelleme hatası: $e');
    }
  }

  // ==================== STORY MODEL TESTS ====================

  void _createTestStory() {
    try {
      _testStory = StoryModel.create(
        id: 'story_${_random.nextInt(10000)}',
        title: 'Test Hikayesi ${_random.nextInt(100)}',
        description: 'Bu bir test hikayesidir. İçeriği test amaçlıdır.',
        authorId: _testUser?.uid ?? 'author_${_random.nextInt(1000)}',
        authorName: _testUser?.name ?? 'Test Yazar',
        category: [
          'roman',
          'fantastik',
          'gerilim',
          'romantik',
        ][_random.nextInt(4)],
      );
      _addLog('✅ StoryModel oluşturuldu: ${_testStory!.title}');
    } catch (e) {
      _addLog('❌ StoryModel oluşturma hatası: $e');
    }
  }

  void _testStorySerialization() {
    if (_testStory == null) return;

    try {
      final storyMap = _testStory!.toMap();
      _addLog('📤 StoryModel.toMap(): ${storyMap.keys.length} alan');

      final reconstructedStory = StoryModel.fromMap(storyMap);
      _addLog('📥 StoryModel.fromMap(): ${reconstructedStory.title}');

      final isEqual =
          _testStory!.id == reconstructedStory.id &&
          _testStory!.title == reconstructedStory.title;
      _addLog(
        '🔍 Story serialization: ${isEqual ? "✅ Başarılı" : "❌ Başarısız"}',
      );
    } catch (e) {
      _addLog('❌ StoryModel serialization hatası: $e');
    }
  }

  void _testStoryHelperMethods() {
    if (_testStory == null) return;

    try {
      _addLog('📚 Story Helper Methods:');
      _addLog('  • isPublished: ${_testStory!.isPublished}');
      _addLog('  • requiresPayment: ${_testStory!.requiresPayment}');
      _addLog('  • categoryDisplayName: ${_testStory!.categoryDisplayName}');
      _addLog(
        '  • contentRatingDisplayName: ${_testStory!.contentRatingDisplayName}',
      );
      _addLog('  • readingTimeText: ${_testStory!.readingTimeText}');
      _addLog(
        '  • popularityScore: ${_testStory!.popularityScore.toStringAsFixed(2)}',
      );
    } catch (e) {
      _addLog('❌ StoryModel helper methods hatası: $e');
    }
  }

  void _updateTestStory() {
    if (_testStory == null) return;

    try {
      _testStory = _testStory!.copyWith(
        viewCount: _testStory!.viewCount + _random.nextInt(50),
        likeCount: _testStory!.likeCount + _random.nextInt(10),
        commentCount: _testStory!.commentCount + _random.nextInt(5),
        wordCount: _testStory!.wordCount + _random.nextInt(1000),
        lastUpdatedAt: DateTime.now(),
      );
      _addLog('🔄 StoryModel güncellendi: Views=${_testStory!.viewCount}');
    } catch (e) {
      _addLog('❌ StoryModel güncelleme hatası: $e');
    }
  }

  // ==================== PURCHASE MODEL TESTS ====================

  void _createTestPurchase() {
    try {
      _testPurchase = PurchaseModel.create(
        id: 'purchase_${_random.nextInt(10000)}',
        userId: _testUser?.uid ?? 'user_${_random.nextInt(1000)}',
        userName: _testUser?.name ?? 'Test Kullanıcı',
        purchaseType: ['story', 'subscription', 'points'][_random.nextInt(3)],
        contentId: _testStory?.id,
        contentTitle: _testStory?.title ?? 'Test İçerik',
        amount: (_random.nextDouble() * 50).roundToDouble(),
        paymentMethod: [
          'card',
          'paypal',
          'appstore',
          'points',
        ][_random.nextInt(4)],
        currency: 'USD',
      );
      _addLog('✅ PurchaseModel oluşturuldu: ${_testPurchase!.formattedAmount}');
    } catch (e) {
      _addLog('❌ PurchaseModel oluşturma hatası: $e');
    }
  }

  void _testPurchaseSerialization() {
    if (_testPurchase == null) return;

    try {
      final purchaseMap = _testPurchase!.toMap();
      _addLog('📤 PurchaseModel.toMap(): ${purchaseMap.keys.length} alan');

      final reconstructedPurchase = PurchaseModel.fromMap(purchaseMap);
      _addLog(
        '📥 PurchaseModel.fromMap(): ${reconstructedPurchase.contentTitle}',
      );

      final isEqual = _testPurchase!.id == reconstructedPurchase.id;
      _addLog(
        '🔍 Purchase serialization: ${isEqual ? "✅ Başarılı" : "❌ Başarısız"}',
      );
    } catch (e) {
      _addLog('❌ PurchaseModel serialization hatası: $e');
    }
  }

  void _testPurchaseHelperMethods() {
    if (_testPurchase == null) return;

    try {
      _addLog('💳 Purchase Helper Methods:');
      _addLog('  • isCompleted: ${_testPurchase!.isCompleted}');
      _addLog('  • isPending: ${_testPurchase!.isPending}');
      _addLog(
        '  • purchaseTypeDisplayName: ${_testPurchase!.purchaseTypeDisplayName}',
      );
      _addLog(
        '  • paymentMethodDisplayName: ${_testPurchase!.paymentMethodDisplayName}',
      );
      _addLog('  • statusDisplayName: ${_testPurchase!.statusDisplayName}');
      _addLog('  • formattedAmount: ${_testPurchase!.formattedAmount}');
    } catch (e) {
      _addLog('❌ PurchaseModel helper methods hatası: $e');
    }
  }

  // ==================== COMMENT MODEL TESTS ====================

  void _createTestComment() {
    try {
      _testComment = CommentModel.create(
        id: 'comment_${_random.nextInt(10000)}',
        contentId: _testStory?.id ?? 'story_${_random.nextInt(1000)}',
        userId: _testUser?.uid ?? 'user_${_random.nextInt(1000)}',
        userName: _testUser?.name ?? 'Test Kullanıcı',
        content: 'Bu harika bir hikaye! Test yorumu ${_random.nextInt(100)}.',
        userAvatarUrl: _testUser?.profileImageUrl,
        isAuthorComment: _random.nextBool(),
      );
      _addLog('✅ CommentModel oluşturuldu: ${_testComment!.preview}');
    } catch (e) {
      _addLog('❌ CommentModel oluşturma hatası: $e');
    }
  }

  void _testCommentSerialization() {
    if (_testComment == null) return;

    try {
      final commentMap = _testComment!.toMap();
      _addLog('📤 CommentModel.toMap(): ${commentMap.keys.length} alan');

      final reconstructedComment = CommentModel.fromMap(commentMap);
      _addLog('📥 CommentModel.fromMap(): ${reconstructedComment.userName}');

      final isEqual = _testComment!.id == reconstructedComment.id;
      _addLog(
        '🔍 Comment serialization: ${isEqual ? "✅ Başarılı" : "❌ Başarısız"}',
      );
    } catch (e) {
      _addLog('❌ CommentModel serialization hatası: $e');
    }
  }

  void _testCommentHelperMethods() {
    if (_testComment == null) return;

    try {
      _addLog('💬 Comment Helper Methods:');
      _addLog('  • isVisible: ${_testComment!.isVisible}');
      _addLog('  • isTopLevel: ${_testComment!.isTopLevel}');
      _addLog('  • netLikes: ${_testComment!.netLikes}');
      _addLog(
        '  • likePercentage: ${_testComment!.likePercentage.toStringAsFixed(1)}%',
      );
      _addLog('  • statusDisplayName: ${_testComment!.statusDisplayName}');
      _addLog('  • timeAgo: ${_testComment!.timeAgo}');
    } catch (e) {
      _addLog('❌ CommentModel helper methods hatası: $e');
    }
  }

  // ==================== BOOKMARK MODEL TESTS ====================

  void _createTestBookmark() {
    try {
      _testBookmark = BookmarkModel.create(
        id: 'bookmark_${_random.nextInt(10000)}',
        userId: _testUser?.uid ?? 'user_${_random.nextInt(1000)}',
        contentId: _testStory?.id ?? 'story_${_random.nextInt(1000)}',
        contentTitle: _testStory?.title ?? 'Test Hikayesi',
        contentAuthor: _testStory?.authorName ?? 'Test Yazar',
        isPrivate: _random.nextBool(),
      );
      _addLog('✅ BookmarkModel oluşturuldu: ${_testBookmark!.displayTitle}');
    } catch (e) {
      _addLog('❌ BookmarkModel oluşturma hatası: $e');
    }
  }

  void _testBookmarkSerialization() {
    if (_testBookmark == null) return;

    try {
      final bookmarkMap = _testBookmark!.toMap();
      _addLog('📤 BookmarkModel.toMap(): ${bookmarkMap.keys.length} alan');

      final reconstructedBookmark = BookmarkModel.fromMap(bookmarkMap);
      _addLog(
        '📥 BookmarkModel.fromMap(): ${reconstructedBookmark.contentTitle}',
      );

      final isEqual = _testBookmark!.id == reconstructedBookmark.id;
      _addLog(
        '🔍 Bookmark serialization: ${isEqual ? "✅ Başarılı" : "❌ Başarısız"}',
      );
    } catch (e) {
      _addLog('❌ BookmarkModel serialization hatası: $e');
    }
  }

  void _testBookmarkHelperMethods() {
    if (_testBookmark == null) return;

    try {
      _addLog('🔖 Bookmark Helper Methods:');
      _addLog('  • displayTitle: ${_testBookmark!.displayTitle}');
      _addLog('  • isActivelyReading: ${_testBookmark!.isActivelyReading}');
      _addLog(
        '  • readingStatusDisplayName: ${_testBookmark!.readingStatusDisplayName}',
      );
      _addLog('  • priorityDisplayName: ${_testBookmark!.priorityDisplayName}');
      _addLog('  • progressText: ${_testBookmark!.progressText}');
      _addLog(
        '  • contentTypeDisplayName: ${_testBookmark!.contentTypeDisplayName}',
      );
    } catch (e) {
      _addLog('❌ BookmarkModel helper methods hatası: $e');
    }
  }

  // ==================== NOTIFICATION MODEL TESTS ====================

  void _createTestNotification() {
    try {
      final types = ['like', 'comment', 'follow', 'story_update', 'system'];
      _testNotification = NotificationModel.create(
        id: 'notification_${_random.nextInt(10000)}',
        userId: _testUser?.uid ?? 'user_${_random.nextInt(1000)}',
        type: types[_random.nextInt(types.length)],
        title: 'Test Bildirimi',
        message: 'Bu bir test bildirimidir ${_random.nextInt(100)}.',
        triggeredByUserId: _random.nextBool() ? _testUser?.uid : null,
        relatedContentId: _testStory?.id,
        priority: ['low', 'normal', 'high'][_random.nextInt(3)],
      );
      _addLog('✅ NotificationModel oluşturuldu: ${_testNotification!.title}');
    } catch (e) {
      _addLog('❌ NotificationModel oluşturma hatası: $e');
    }
  }

  void _testNotificationSerialization() {
    if (_testNotification == null) return;

    try {
      final notificationMap = _testNotification!.toMap();
      _addLog(
        '📤 NotificationModel.toMap(): ${notificationMap.keys.length} alan',
      );

      final reconstructedNotification = NotificationModel.fromMap(
        notificationMap,
      );
      _addLog(
        '📥 NotificationModel.fromMap(): ${reconstructedNotification.title}',
      );

      final isEqual = _testNotification!.id == reconstructedNotification.id;
      _addLog(
        '🔍 Notification serialization: ${isEqual ? "✅ Başarılı" : "❌ Başarısız"}',
      );
    } catch (e) {
      _addLog('❌ NotificationModel serialization hatası: $e');
    }
  }

  void _testNotificationHelperMethods() {
    if (_testNotification == null) return;

    try {
      _addLog('🔔 Notification Helper Methods:');
      _addLog('  • isUnread: ${_testNotification!.isUnread}');
      _addLog('  • isDelivered: ${_testNotification!.isDelivered}');
      _addLog('  • typeDisplayName: ${_testNotification!.typeDisplayName}');
      _addLog(
        '  • priorityDisplayName: ${_testNotification!.priorityDisplayName}',
      );
      _addLog('  • statusDisplayName: ${_testNotification!.statusDisplayName}');
      _addLog('  • timeAgo: ${_testNotification!.timeAgo}');
    } catch (e) {
      _addLog('❌ NotificationModel helper methods hatası: $e');
    }
  }

  // ==================== UI BUILD ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Models Test Screen'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'User', icon: Icon(Icons.person, size: 16)),
            Tab(text: 'Story', icon: Icon(Icons.book, size: 16)),
            Tab(text: 'Purchase', icon: Icon(Icons.payment, size: 16)),
            Tab(text: 'Comment', icon: Icon(Icons.comment, size: 16)),
            Tab(text: 'Bookmark', icon: Icon(Icons.bookmark, size: 16)),
            Tab(
              text: 'Notification',
              icon: Icon(Icons.notifications, size: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _initializeTestData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
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
          // Test Results Panel
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withAlpha(128),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.terminal,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Test Logları (${_testLogs.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _testLogs.length,
                    itemBuilder: (context, index) {
                      final log = _testLogs[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: log.contains('❌')
                              ? theme.colorScheme.errorContainer.withAlpha(128)
                              : log.contains('✅')
                              ? theme.colorScheme.primaryContainer.withAlpha(
                                  128,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          log,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserModelTab(theme),
                _buildStoryModelTab(theme),
                _buildPurchaseModelTab(theme),
                _buildCommentModelTab(theme),
                _buildBookmarkModelTab(theme),
                _buildNotificationModelTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserModelTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModelCard(
            'UserModel Test',
            Icons.person,
            [
              _buildModelInfo('UID', _testUser?.uid ?? 'N/A'),
              _buildModelInfo('Name', _testUser?.name ?? 'N/A'),
              _buildModelInfo('Email', _testUser?.email ?? 'N/A'),
              _buildModelInfo(
                'Premium',
                _testUser?.isPremiumUser.toString() ?? 'N/A',
              ),
              _buildModelInfo(
                'Points',
                _testUser?.totalPoints.toString() ?? 'N/A',
              ),
              _buildModelInfo(
                'Books Read',
                _testUser?.booksRead.toString() ?? 'N/A',
              ),
            ],
            [
              ElevatedButton.icon(
                onPressed: _createTestUser,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Yeni User'),
              ),
              ElevatedButton.icon(
                onPressed: _updateTestUser,
                icon: const Icon(Icons.update, size: 16),
                label: const Text('Güncelle'),
              ),
              ElevatedButton.icon(
                onPressed: _testUserSerialization,
                icon: const Icon(Icons.data_object, size: 16),
                label: const Text('Serialization'),
              ),
              ElevatedButton.icon(
                onPressed: _testUserHelperMethods,
                icon: const Icon(Icons.functions, size: 16),
                label: const Text('Helper Methods'),
              ),
            ],
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryModelTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModelCard(
            'StoryModel Test',
            Icons.book,
            [
              _buildModelInfo('ID', _testStory?.id ?? 'N/A'),
              _buildModelInfo('Title', _testStory?.title ?? 'N/A'),
              _buildModelInfo('Author', _testStory?.authorName ?? 'N/A'),
              _buildModelInfo(
                'Category',
                _testStory?.categoryDisplayName ?? 'N/A',
              ),
              _buildModelInfo(
                'Views',
                _testStory?.viewCount.toString() ?? 'N/A',
              ),
              _buildModelInfo(
                'Likes',
                _testStory?.likeCount.toString() ?? 'N/A',
              ),
            ],
            [
              ElevatedButton.icon(
                onPressed: _createTestStory,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Yeni Story'),
              ),
              ElevatedButton.icon(
                onPressed: _updateTestStory,
                icon: const Icon(Icons.update, size: 16),
                label: const Text('Güncelle'),
              ),
              ElevatedButton.icon(
                onPressed: _testStorySerialization,
                icon: const Icon(Icons.data_object, size: 16),
                label: const Text('Serialization'),
              ),
              ElevatedButton.icon(
                onPressed: _testStoryHelperMethods,
                icon: const Icon(Icons.functions, size: 16),
                label: const Text('Helper Methods'),
              ),
            ],
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseModelTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModelCard(
            'PurchaseModel Test',
            Icons.payment,
            [
              _buildModelInfo('ID', _testPurchase?.id ?? 'N/A'),
              _buildModelInfo('User', _testPurchase?.userName ?? 'N/A'),
              _buildModelInfo(
                'Type',
                _testPurchase?.purchaseTypeDisplayName ?? 'N/A',
              ),
              _buildModelInfo(
                'Amount',
                _testPurchase?.formattedAmount ?? 'N/A',
              ),
              _buildModelInfo(
                'Method',
                _testPurchase?.paymentMethodDisplayName ?? 'N/A',
              ),
              _buildModelInfo(
                'Status',
                _testPurchase?.statusDisplayName ?? 'N/A',
              ),
            ],
            [
              ElevatedButton.icon(
                onPressed: _createTestPurchase,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Yeni Purchase'),
              ),
              ElevatedButton.icon(
                onPressed: _testPurchaseSerialization,
                icon: const Icon(Icons.data_object, size: 16),
                label: const Text('Serialization'),
              ),
              ElevatedButton.icon(
                onPressed: _testPurchaseHelperMethods,
                icon: const Icon(Icons.functions, size: 16),
                label: const Text('Helper Methods'),
              ),
            ],
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentModelTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModelCard(
            'CommentModel Test',
            Icons.comment,
            [
              _buildModelInfo('ID', _testComment?.id ?? 'N/A'),
              _buildModelInfo('User', _testComment?.userName ?? 'N/A'),
              _buildModelInfo('Content', _testComment?.preview ?? 'N/A'),
              _buildModelInfo(
                'Likes',
                _testComment?.likeCount.toString() ?? 'N/A',
              ),
              _buildModelInfo(
                'Status',
                _testComment?.statusDisplayName ?? 'N/A',
              ),
              _buildModelInfo('Time', _testComment?.timeAgo ?? 'N/A'),
            ],
            [
              ElevatedButton.icon(
                onPressed: _createTestComment,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Yeni Comment'),
              ),
              ElevatedButton.icon(
                onPressed: _testCommentSerialization,
                icon: const Icon(Icons.data_object, size: 16),
                label: const Text('Serialization'),
              ),
              ElevatedButton.icon(
                onPressed: _testCommentHelperMethods,
                icon: const Icon(Icons.functions, size: 16),
                label: const Text('Helper Methods'),
              ),
            ],
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkModelTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModelCard(
            'BookmarkModel Test',
            Icons.bookmark,
            [
              _buildModelInfo('ID', _testBookmark?.id ?? 'N/A'),
              _buildModelInfo('Content', _testBookmark?.displayTitle ?? 'N/A'),
              _buildModelInfo('Author', _testBookmark?.contentAuthor ?? 'N/A'),
              _buildModelInfo('Progress', _testBookmark?.progressText ?? 'N/A'),
              _buildModelInfo(
                'Status',
                _testBookmark?.readingStatusDisplayName ?? 'N/A',
              ),
              _buildModelInfo(
                'Priority',
                _testBookmark?.priorityDisplayName ?? 'N/A',
              ),
            ],
            [
              ElevatedButton.icon(
                onPressed: _createTestBookmark,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Yeni Bookmark'),
              ),
              ElevatedButton.icon(
                onPressed: _testBookmarkSerialization,
                icon: const Icon(Icons.data_object, size: 16),
                label: const Text('Serialization'),
              ),
              ElevatedButton.icon(
                onPressed: _testBookmarkHelperMethods,
                icon: const Icon(Icons.functions, size: 16),
                label: const Text('Helper Methods'),
              ),
            ],
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationModelTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModelCard(
            'NotificationModel Test',
            Icons.notifications,
            [
              _buildModelInfo('ID', _testNotification?.id ?? 'N/A'),
              _buildModelInfo(
                'Type',
                _testNotification?.typeDisplayName ?? 'N/A',
              ),
              _buildModelInfo('Title', _testNotification?.title ?? 'N/A'),
              _buildModelInfo(
                'Priority',
                _testNotification?.priorityDisplayName ?? 'N/A',
              ),
              _buildModelInfo(
                'Status',
                _testNotification?.statusDisplayName ?? 'N/A',
              ),
              _buildModelInfo('Time', _testNotification?.timeAgo ?? 'N/A'),
            ],
            [
              ElevatedButton.icon(
                onPressed: _createTestNotification,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Yeni Notification'),
              ),
              ElevatedButton.icon(
                onPressed: _testNotificationSerialization,
                icon: const Icon(Icons.data_object, size: 16),
                label: const Text('Serialization'),
              ),
              ElevatedButton.icon(
                onPressed: _testNotificationHelperMethods,
                icon: const Icon(Icons.functions, size: 16),
                label: const Text('Helper Methods'),
              ),
            ],
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildModelCard(
    String title,
    IconData icon,
    List<Widget> infoItems,
    List<Widget> actions,
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
                Icon(icon, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ...infoItems,

            const SizedBox(height: 16),

            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ),
      ),
    );
  }

  Widget _buildModelInfo(String label, String value) {
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
