import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Base service sınıfı
/// Ortak servis operasyonları ve hata yönetimi sağlar
abstract class BaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Mevcut kullanıcı ID'sini getirir
  String? get currentUserId => auth.currentUser?.uid;

  /// Mevcut kullanıcının giriş yapıp yapmadığını kontrol eder
  bool get isUserSignedIn => auth.currentUser != null;

  /// Firestore operasyonu wrapper'ı
  /// Ortak hata yönetimi sağlar
  Future<T> executeFirestoreOperation<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } on FirebaseException catch (e) {
      throw Exception(
        errorMessage ?? 'Firestore hatası: ${e.message ?? e.code}',
      );
    } catch (e) {
      throw Exception(errorMessage ?? 'Beklenmeyen hata: $e');
    }
  }

  /// Batch operasyonu wrapper'ı
  Future<void> executeBatchOperation(
    void Function(WriteBatch batch) operations, {
    String? errorMessage,
  }) async {
    final batch = firestore.batch();

    try {
      operations(batch);
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(
        errorMessage ?? 'Batch operasyon hatası: ${e.message ?? e.code}',
      );
    } catch (e) {
      throw Exception(errorMessage ?? 'Batch operasyon hatası: $e');
    }
  }

  /// Transaction operasyonu wrapper'ı
  Future<T> executeTransaction<T>(
    Future<T> Function(Transaction transaction) operations, {
    String? errorMessage,
  }) async {
    try {
      return await firestore.runTransaction<T>(operations);
    } on FirebaseException catch (e) {
      throw Exception(
        errorMessage ?? 'Transaction hatası: ${e.message ?? e.code}',
      );
    } catch (e) {
      throw Exception(errorMessage ?? 'Transaction hatası: $e');
    }
  }

  /// Kullanıcı doğrulama kontrolü
  void requireAuthentication() {
    if (!isUserSignedIn) {
      throw Exception('Bu işlem için giriş yapmanız gerekiyor');
    }
  }

  /// Collection referansı alımı
  CollectionReference getCollection(String collectionName) {
    return firestore.collection(collectionName);
  }

  /// Document referansı alımı
  DocumentReference getDocument(String collectionName, String documentId) {
    return firestore.collection(collectionName).doc(documentId);
  }

  /// Timestamp oluştur
  Timestamp createTimestamp() => Timestamp.now();

  /// Server timestamp oluştur
  FieldValue createServerTimestamp() => FieldValue.serverTimestamp();
}
