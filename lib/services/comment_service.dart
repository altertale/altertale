import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';

/// Gelişmiş yorum servisi
class CommentService {
  static final CommentService _instance = CommentService._internal();
  factory CommentService() => _instance;
  CommentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Koleksiyon isimleri
  static const String _commentsCollection = 'comments';
  static const String _votesCollection = 'commentVotes';
  static const String _reportsCollection = 'commentReports';

  /// Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  /// Kitap yorumlarını getir
  Stream<List<CommentModel>> getComments(
    String bookId, {
    CommentSortOrder sortOrder = CommentSortOrder.mostHelpful,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) {
    Query query = _firestore
        .collection(_commentsCollection)
        .where('bookId', isEqualTo: bookId)
        .where('status', isEqualTo: CommentStatus.approved.name)
        .where('isHidden', isEqualTo: false);

    // Sıralama uygula
    query = _applySortOrder(query, sortOrder);

    // Sayfalama
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    // Limit
    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommentModel.fromFirestore(doc);
      }).toList();
    });
  }

  /// Yorum ekle
  Future<CommentModel> addComment({
    required String bookId,
    required String text,
    String? parentCommentId,
    String? mentionedUserId,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      // Yorum metnini doğrula
      if (text.trim().isEmpty) {
        throw Exception('Yorum metni boş olamaz');
      }

      if (text.length > 500) {
        throw Exception('Yorum 500 karakterden uzun olamaz');
      }

      // Yorum metnini temizle
      final cleanText = _sanitizeText(text);

      // Yorum dokümanı oluştur
      final commentData = {
        'userId': user.uid,
        'bookId': bookId,
        'text': cleanText,
        'createdAt': FieldValue.serverTimestamp(),
        'status': CommentStatus.pending.name,
        'isHidden': false,
        'userDisplayName': user.displayName ?? 'Anonim',
        'userPhotoUrl': user.photoURL,
        'parentCommentId': parentCommentId,
        'mentionedUserId': mentionedUserId,
        'reportedBy': [],
        'reportCount': 0,
        'helpfulnessScore': 0.0,
        'likeCount': 0,
        'dislikeCount': 0,
        'isEdited': false,
      };

      final docRef = await _firestore
          .collection(_commentsCollection)
          .add(commentData);

      // Oluşturulan yorumu getir
      final doc = await docRef.get();
      return CommentModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Yorum eklenirken hata oluştu: $e');
    }
  }

  /// Yorumu güncelle
  Future<void> updateComment({
    required String commentId,
    required String text,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      // Yorum metnini doğrula
      if (text.trim().isEmpty) {
        throw Exception('Yorum metni boş olamaz');
      }

      if (text.length > 500) {
        throw Exception('Yorum 500 karakterden uzun olamaz');
      }

      // Yorum metnini temizle
      final cleanText = _sanitizeText(text);

      // Yorumu güncelle
      await _firestore
          .collection(_commentsCollection)
          .doc(commentId)
          .update({
        'text': cleanText,
        'updatedAt': FieldValue.serverTimestamp(),
        'isEdited': true,
      });
    } catch (e) {
      throw Exception('Yorum güncellenirken hata oluştu: $e');
    }
  }

  /// Yorumu sil
  Future<void> deleteComment(String commentId) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      // Yorumu sil
      await _firestore
          .collection(_commentsCollection)
          .doc(commentId)
          .delete();

      // İlgili oyları sil
      await _deleteCommentVotes(commentId);

      // İlgili şikayetleri sil
      await _deleteCommentReports(commentId);
    } catch (e) {
      throw Exception('Yorum silinirken hata oluştu: $e');
    }
  }

  /// Yorum oyu ver
  Future<void> voteComment({
    required String commentId,
    required VoteType voteType,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      // Mevcut oyu kontrol et
      final existingVote = await _getUserVote(commentId, user.uid);

      if (existingVote != null) {
        // Mevcut oy varsa güncelle
        if (existingVote.voteType == voteType) {
          // Aynı oy tekrar verilmişse oyu kaldır
          await _removeVote(commentId, user.uid);
        } else {
          // Farklı oy verilmişse güncelle
          await _updateVote(commentId, user.uid, voteType);
        }
      } else {
        // Yeni oy ekle
        await _addVote(commentId, user.uid, voteType);
      }

      // Yorum istatistiklerini güncelle
      await _updateCommentStats(commentId);
    } catch (e) {
      throw Exception('Oy verilirken hata oluştu: $e');
    }
  }

  /// Kullanıcının oyunu getir
  Future<VoteType?> getUserVote(String commentId) async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final vote = await _getUserVote(commentId, user.uid);
      return vote?.voteType;
    } catch (e) {
      return null;
    }
  }

  /// Yorum şikayet et
  Future<void> reportComment({
    required String commentId,
    required String reason,
    String? description,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      // Kullanıcının daha önce şikayet edip etmediğini kontrol et
      final existingReport = await _getUserReport(commentId, user.uid);
      if (existingReport != null) {
        throw Exception('Bu yorumu zaten şikayet ettiniz');
      }

      // Şikayet ekle
      await _firestore
          .collection(_reportsCollection)
          .add({
        'commentId': commentId,
        'reporterId': user.uid,
        'reason': reason,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'isResolved': false,
      });

      // Yorum şikayet sayısını güncelle
      await _updateCommentReportCount(commentId);

      // 3 şikayet varsa otomatik gizle
      await _checkAutoHideComment(commentId);
    } catch (e) {
      throw Exception('Şikayet gönderilirken hata oluştu: $e');
    }
  }

  /// Yorum istatistiklerini getir
  Future<Map<String, dynamic>> getCommentStats(String bookId) async {
    try {
      final commentsSnapshot = await _firestore
          .collection(_commentsCollection)
          .where('bookId', isEqualTo: bookId)
          .get();

      int totalComments = 0;
      int approvedComments = 0;
      int pendingComments = 0;
      int reportedComments = 0;
      double averageHelpfulness = 0.0;

      for (final doc in commentsSnapshot.docs) {
        final comment = CommentModel.fromFirestore(doc);
        totalComments++;

        switch (comment.status) {
          case CommentStatus.approved:
            approvedComments++;
            break;
          case CommentStatus.pending:
            pendingComments++;
            break;
          case CommentStatus.rejected:
          case CommentStatus.hidden:
            break;
        }

        if (comment.isReported) {
          reportedComments++;
        }

        averageHelpfulness += comment.helpfulnessScore;
      }

      if (approvedComments > 0) {
        averageHelpfulness /= approvedComments;
      }

      return {
        'totalComments': totalComments,
        'approvedComments': approvedComments,
        'pendingComments': pendingComments,
        'reportedComments': reportedComments,
        'averageHelpfulness': averageHelpfulness,
      };
    } catch (e) {
      throw Exception('İstatistikler alınırken hata oluştu: $e');
    }
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Sıralama uygula
  Query _applySortOrder(Query query, CommentSortOrder sortOrder) {
    switch (sortOrder) {
      case CommentSortOrder.newest:
        return query.orderBy('createdAt', descending: true);
      case CommentSortOrder.mostLiked:
        return query.orderBy('likeCount', descending: true);
      case CommentSortOrder.mostHelpful:
        return query.orderBy('helpfulnessScore', descending: true);
      case CommentSortOrder.mostControversial:
        return query.orderBy('dislikeCount', descending: true);
    }
  }

  /// Metin temizleme
  String _sanitizeText(String text) {
    // HTML etiketlerini kaldır
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Fazla boşlukları temizle
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Özel karakterleri kontrol et
    text = text.replaceAll(RegExp(r'[^\w\s\u00C7\u00E7\u011E\u011F\u0130\u0131\u00D6\u00F6\u015E\u015F\u00DC\u00FC.,!?;:()]'), '');
    
    return text;
  }

  /// Kullanıcının oyunu getir
  Future<CommentVote?> _getUserVote(String commentId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_votesCollection)
          .where('commentId', isEqualTo: commentId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return CommentVote.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Oy ekle
  Future<void> _addVote(String commentId, String userId, VoteType voteType) async {
    await _firestore
        .collection(_votesCollection)
        .add({
      'commentId': commentId,
      'userId': userId,
      'voteType': voteType.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Oy güncelle
  Future<void> _updateVote(String commentId, String userId, VoteType voteType) async {
    final querySnapshot = await _firestore
        .collection(_votesCollection)
        .where('commentId', isEqualTo: commentId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update({
        'voteType': voteType.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Oy kaldır
  Future<void> _removeVote(String commentId, String userId) async {
    final querySnapshot = await _firestore
        .collection(_votesCollection)
        .where('commentId', isEqualTo: commentId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.delete();
    }
  }

  /// Yorum istatistiklerini güncelle
  Future<void> _updateCommentStats(String commentId) async {
    try {
      // Beğeni sayısını hesapla
      final likesSnapshot = await _firestore
          .collection(_votesCollection)
          .where('commentId', isEqualTo: commentId)
          .where('voteType', isEqualTo: VoteType.like.name)
          .get();

      // Beğenmeme sayısını hesapla
      final dislikesSnapshot = await _firestore
          .collection(_votesCollection)
          .where('commentId', isEqualTo: commentId)
          .where('voteType', isEqualTo: VoteType.dislike.name)
          .get();

      final likeCount = likesSnapshot.docs.length;
      final dislikeCount = dislikesSnapshot.docs.length;

      // Faydalılık puanını hesapla
      double helpfulnessScore = 0.0;
      if (likeCount + dislikeCount > 0) {
        final ratio = likeCount / (likeCount + dislikeCount);
        helpfulnessScore = ratio * 10.0; // 0-10 arası puan
      }

      // Yorumu güncelle
      await _firestore
          .collection(_commentsCollection)
          .doc(commentId)
          .update({
        'likeCount': likeCount,
        'dislikeCount': dislikeCount,
        'helpfulnessScore': helpfulnessScore,
      });
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Kullanıcının şikayetini getir
  Future<CommentReport?> _getUserReport(String commentId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_reportsCollection)
          .where('commentId', isEqualTo: commentId)
          .where('reporterId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return CommentReport.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Yorum şikayet sayısını güncelle
  Future<void> _updateCommentReportCount(String commentId) async {
    try {
      final reportsSnapshot = await _firestore
          .collection(_reportsCollection)
          .where('commentId', isEqualTo: commentId)
          .where('isResolved', isEqualTo: false)
          .get();

      final reportCount = reportsSnapshot.docs.length;

      await _firestore
          .collection(_commentsCollection)
          .doc(commentId)
          .update({
        'reportCount': reportCount,
      });
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Otomatik gizleme kontrolü
  Future<void> _checkAutoHideComment(String commentId) async {
    try {
      final commentDoc = await _firestore
          .collection(_commentsCollection)
          .doc(commentId)
          .get();

      if (commentDoc.exists) {
        final comment = CommentModel.fromFirestore(commentDoc);
        if (comment.shouldAutoHide) {
          await _firestore
              .collection(_commentsCollection)
              .doc(commentId)
              .update({
            'isHidden': true,
          });
        }
      }
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Yorum oylarını sil
  Future<void> _deleteCommentVotes(String commentId) async {
    try {
      final votesSnapshot = await _firestore
          .collection(_votesCollection)
          .where('commentId', isEqualTo: commentId)
          .get();

      final batch = _firestore.batch();
      for (final doc in votesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Yorum şikayetlerini sil
  Future<void> _deleteCommentReports(String commentId) async {
    try {
      final reportsSnapshot = await _firestore
          .collection(_reportsCollection)
          .where('commentId', isEqualTo: commentId)
          .get();

      final batch = _firestore.batch();
      for (final doc in reportsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }
}
