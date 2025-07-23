import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Production-Ready Firestore Service
///
/// Generic CRUD operations for Firebase Firestore:
/// - Collection-agnostic operations
/// - Comprehensive error handling
/// - Type-safe data operations
/// - Batch operations support
/// - Real-time listeners
/// - Performance optimized
/// - Debug logging
class FirestoreService {
  // ==================== SINGLETON PATTERN ====================
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  // ==================== FIRESTORE INSTANCE ====================
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== ERROR MESSAGES ====================
  static const String _createErrorMessage = 'Doküman oluşturulamadı';
  static const String _readErrorMessage = 'Doküman okunamadı';
  static const String _updateErrorMessage = 'Doküman güncellenemedi';
  static const String _deleteErrorMessage = 'Doküman silinemedi';
  static const String _queryErrorMessage = 'Sorgu gerçekleştirilemedi';

  // ==================== CREATE OPERATIONS ====================

  /// Create a new document in specified collection
  ///
  /// [collection] - Collection name
  /// [data] - Data to be stored
  /// [docId] - Optional document ID (if null, auto-generated)
  ///
  /// Returns: Document ID of created document
  /// Throws: FirebaseException on failure
  Future<String> createDoc({
    required String collection,
    required Map<String, dynamic> data,
    String? docId,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '🔥 FirestoreService.createDoc: Starting creation in $collection',
        );
      }

      // Add server timestamp for creation tracking
      final dataWithTimestamp = {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      DocumentReference docRef;

      if (docId != null) {
        // Use provided document ID
        docRef = _firestore.collection(collection).doc(docId);
        await docRef.set(dataWithTimestamp);

        if (kDebugMode) {
          print(
            '🔥 FirestoreService.createDoc: Document created with custom ID: $docId',
          );
        }
      } else {
        // Auto-generate document ID
        docRef = await _firestore.collection(collection).add(dataWithTimestamp);

        if (kDebugMode) {
          print(
            '🔥 FirestoreService.createDoc: Document created with auto ID: ${docRef.id}',
          );
        }
      }

      if (kDebugMode) {
        print(
          '✅ FirestoreService.createDoc: Success - ${docRef.id} in $collection',
        );
      }

      return docRef.id;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
          '❌ FirestoreService.createDoc: Firebase error - ${e.code}: ${e.message}',
        );
      }
      throw FirebaseException(
        plugin: 'firestore',
        code: e.code,
        message: '$_createErrorMessage: ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ FirestoreService.createDoc: Unexpected error - $e');
      }
      throw Exception('$_createErrorMessage: $e');
    }
  }

  /// Create multiple documents in a batch
  ///
  /// [collection] - Collection name
  /// [documents] - List of data maps to be created
  /// [docIds] - Optional list of document IDs (must match documents length)
  ///
  /// Returns: List of document IDs
  /// Throws: FirebaseException on failure
  Future<List<String>> createDocsBatch({
    required String collection,
    required List<Map<String, dynamic>> documents,
    List<String>? docIds,
  }) async {
    if (docIds != null && docIds.length != documents.length) {
      throw ArgumentError('Document IDs length must match documents length');
    }

    try {
      if (kDebugMode) {
        print(
          '🔥 FirestoreService.createDocsBatch: Creating ${documents.length} documents in $collection',
        );
      }

      final batch = _firestore.batch();
      final List<String> createdIds = [];
      final timestamp = FieldValue.serverTimestamp();

      for (int i = 0; i < documents.length; i++) {
        final data = {
          ...documents[i],
          'createdAt': timestamp,
          'updatedAt': timestamp,
        };

        final DocumentReference docRef;
        if (docIds != null) {
          docRef = _firestore.collection(collection).doc(docIds[i]);
          createdIds.add(docIds[i]);
        } else {
          docRef = _firestore.collection(collection).doc();
          createdIds.add(docRef.id);
        }

        batch.set(docRef, data);
      }

      await batch.commit();

      if (kDebugMode) {
        print(
          '✅ FirestoreService.createDocsBatch: Success - ${createdIds.length} documents created',
        );
      }

      return createdIds;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
          '❌ FirestoreService.createDocsBatch: Firebase error - ${e.code}: ${e.message}',
        );
      }
      throw FirebaseException(
        plugin: 'firestore',
        code: e.code,
        message: '$_createErrorMessage (batch): ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ FirestoreService.createDocsBatch: Unexpected error - $e');
      }
      throw Exception('$_createErrorMessage (batch): $e');
    }
  }

  // ==================== READ OPERATIONS ====================

  /// Read a single document by ID
  ///
  /// [collection] - Collection name
  /// [docId] - Document ID
  ///
  /// Returns: Document data as Map or null if not found
  /// Throws: FirebaseException on failure
  Future<Map<String, dynamic>?> readDoc({
    required String collection,
    required String docId,
  }) async {
    try {
      if (kDebugMode) {
        print('🔥 FirestoreService.readDoc: Reading $docId from $collection');
      }

      final docSnapshot = await _firestore
          .collection(collection)
          .doc(docId)
          .get();

      if (!docSnapshot.exists) {
        if (kDebugMode) {
          print(
            '⚠️ FirestoreService.readDoc: Document not found - $docId in $collection',
          );
        }
        return null;
      }

      final data = docSnapshot.data();
      if (kDebugMode) {
        print(
          '✅ FirestoreService.readDoc: Success - $docId found with ${data?.keys.length ?? 0} fields',
        );
      }

      return data;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
          '❌ FirestoreService.readDoc: Firebase error - ${e.code}: ${e.message}',
        );
      }
      throw FirebaseException(
        plugin: 'firestore',
        code: e.code,
        message: '$_readErrorMessage: ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ FirestoreService.readDoc: Unexpected error - $e');
      }
      throw Exception('$_readErrorMessage: $e');
    }
  }

  /// Read multiple documents by IDs
  ///
  /// [collection] - Collection name
  /// [docIds] - List of document IDs
  ///
  /// Returns: Map of document ID to data (null for non-existent docs)
  /// Throws: FirebaseException on failure
  Future<Map<String, Map<String, dynamic>?>> readDocsBatch({
    required String collection,
    required List<String> docIds,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '🔥 FirestoreService.readDocsBatch: Reading ${docIds.length} documents from $collection',
        );
      }

      final Map<String, Map<String, dynamic>?> results = {};

      // Firestore has a limit of 10 documents per batch get
      const batchSize = 10;

      for (int i = 0; i < docIds.length; i += batchSize) {
        final end = (i + batchSize < docIds.length)
            ? i + batchSize
            : docIds.length;
        final batchIds = docIds.sublist(i, end);

        final List<DocumentSnapshot> snapshots = await Future.wait(
          batchIds.map((id) => _firestore.collection(collection).doc(id).get()),
        );

        for (int j = 0; j < snapshots.length; j++) {
          final snapshot = snapshots[j];
          results[batchIds[j]] = snapshot.exists
              ? snapshot.data() as Map<String, dynamic>?
              : null;
        }
      }

      if (kDebugMode) {
        final foundCount = results.values.where((data) => data != null).length;
        print(
          '✅ FirestoreService.readDocsBatch: Success - $foundCount/${docIds.length} documents found',
        );
      }

      return results;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
          '❌ FirestoreService.readDocsBatch: Firebase error - ${e.code}: ${e.message}',
        );
      }
      throw FirebaseException(
        plugin: 'firestore',
        code: e.code,
        message: '$_readErrorMessage (batch): ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ FirestoreService.readDocsBatch: Unexpected error - $e');
      }
      throw Exception('$_readErrorMessage (batch): $e');
    }
  }

  /// Read all documents from a collection
  ///
  /// [collection] - Collection name
  /// [limit] - Optional limit for number of documents
  /// [orderBy] - Optional field to order by
  /// [descending] - Whether to order in descending order
  ///
  /// Returns: List of documents with their IDs
  /// Throws: FirebaseException on failure
  Future<List<Map<String, dynamic>>> readCollection({
    required String collection,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '🔥 FirestoreService.readCollection: Reading from $collection (limit: $limit, orderBy: $orderBy)',
        );
      }

      Query query = _firestore.collection(collection);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      final List<Map<String, dynamic>> documents = querySnapshot.docs.map((
        doc,
      ) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include document ID in the data
        return data;
      }).toList();

      if (kDebugMode) {
        print(
          '✅ FirestoreService.readCollection: Success - ${documents.length} documents found',
        );
      }

      return documents;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
          '❌ FirestoreService.readCollection: Firebase error - ${e.code}: ${e.message}',
        );
      }
      throw FirebaseException(
        plugin: 'firestore',
        code: e.code,
        message: '$_queryErrorMessage: ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ FirestoreService.readCollection: Unexpected error - $e');
      }
      throw Exception('$_queryErrorMessage: $e');
    }
  }

  // ==================== UPDATE OPERATIONS ====================

  /// Update an existing document
  ///
  /// [collection] - Collection name
  /// [docId] - Document ID
  /// [data] - Data to update (will be merged with existing data)
  /// [merge] - Whether to merge with existing data or overwrite
  ///
  /// Returns: void
  /// Throws: FirebaseException on failure
  Future<void> updateDoc({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '🔥 FirestoreService.updateDoc: Updating $docId in $collection (merge: $merge)',
        );
      }

      // Add update timestamp
      final dataWithTimestamp = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = _firestore.collection(collection).doc(docId);

      if (merge) {
        await docRef.update(dataWithTimestamp);
      } else {
        await docRef.set(dataWithTimestamp, SetOptions(merge: false));
      }

      if (kDebugMode) {
        print(
          '✅ FirestoreService.updateDoc: Success - $docId updated with ${data.keys.length} fields',
        );
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
          '❌ FirestoreService.updateDoc: Firebase error - ${e.code}: ${e.message}',
        );
      }
      throw FirebaseException(
        plugin: 'firestore',
        code: e.code,
        message: '$_updateErrorMessage: ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ FirestoreService.updateDoc: Unexpected error - $e');
      }
      throw Exception('$_updateErrorMessage: $e');
    }
  }

  /// Update multiple documents in a batch
  ///
  /// [collection] - Collection name
  /// [updates] - Map of document ID to update data
  ///
  /// Returns: void
  /// Throws: FirebaseException on failure
  Future<void> updateDocsBatch({
    required String collection,
    required Map<String, Map<String, dynamic>> updates,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '🔥 FirestoreService.updateDocsBatch: Updating ${updates.length} documents in $collection',
        );
      }

      final batch = _firestore.batch();
      final timestamp = FieldValue.serverTimestamp();

      for (final entry in updates.entries) {
        final docId = entry.key;
        final data = {...entry.value, 'updatedAt': timestamp};

        final docRef = _firestore.collection(collection).doc(docId);
        batch.update(docRef, data);
      }

      await batch.commit();

      if (kDebugMode) {
        print(
          '✅ FirestoreService.updateDocsBatch: Success - ${updates.length} documents updated',
        );
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
          '❌ FirestoreService.updateDocsBatch: Firebase error - ${e.code}: ${e.message}',
        );
      }
      throw FirebaseException(
        plugin: 'firestore',
        code: e.code,
        message: '$_updateErrorMessage (batch): ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ FirestoreService.updateDocsBatch: Unexpected error - $e');
      }
      throw Exception('$_updateErrorMessage (batch): $e');
    }
  }

  // ==================== DELETE OPERATIONS ====================

  /// Delete a document by ID
  ///
  /// [collection] - Collection name
  /// [docId] - Document ID
  ///
  /// Returns: void
  /// Throws: FirebaseException on failure
  Future<void> deleteDoc({
    required String collection,
    required String docId,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '🔥 FirestoreService.deleteDoc: Deleting $docId from $collection',
        );
      }

      await _firestore.collection(collection).doc(docId).delete();

      if (kDebugMode) {
        print(
          '✅ FirestoreService.deleteDoc: Success - $docId deleted from $collection',
        );
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
          '❌ FirestoreService.deleteDoc: Firebase error - ${e.code}: ${e.message}',
        );
      }
      throw FirebaseException(
        plugin: 'firestore',
        code: e.code,
        message: '$_deleteErrorMessage: ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ FirestoreService.deleteDoc: Unexpected error - $e');
      }
      throw Exception('$_deleteErrorMessage: $e');
    }
  }

  /// Delete multiple documents in a batch
  ///
  /// [collection] - Collection name
  /// [docIds] - List of document IDs to delete
  ///
  /// Returns: void
  /// Throws: FirebaseException on failure
  Future<void> deleteDocsBatch({
    required String collection,
    required List<String> docIds,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '🔥 FirestoreService.deleteDocsBatch: Deleting ${docIds.length} documents from $collection',
        );
      }

      final batch = _firestore.batch();

      for (final docId in docIds) {
        final docRef = _firestore.collection(collection).doc(docId);
        batch.delete(docRef);
      }

      await batch.commit();

      if (kDebugMode) {
        print(
          '✅ FirestoreService.deleteDocsBatch: Success - ${docIds.length} documents deleted',
        );
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
          '❌ FirestoreService.deleteDocsBatch: Firebase error - ${e.code}: ${e.message}',
        );
      }
      throw FirebaseException(
        plugin: 'firestore',
        code: e.code,
        message: '$_deleteErrorMessage (batch): ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ FirestoreService.deleteDocsBatch: Unexpected error - $e');
      }
      throw Exception('$_deleteErrorMessage (batch): $e');
    }
  }

  // ==================== REAL-TIME LISTENERS ====================

  /// Listen to a single document changes
  ///
  /// [collection] - Collection name
  /// [docId] - Document ID
  ///
  /// Returns: Stream of document data
  Stream<Map<String, dynamic>?> listenToDoc({
    required String collection,
    required String docId,
  }) {
    if (kDebugMode) {
      print(
        '🔥 FirestoreService.listenToDoc: Starting listener for $docId in $collection',
      );
    }

    return _firestore
        .collection(collection)
        .doc(docId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            if (kDebugMode) {
              print(
                '🔄 FirestoreService.listenToDoc: Document not found - $docId',
              );
            }
            return null;
          }

          if (kDebugMode) {
            print('🔄 FirestoreService.listenToDoc: Data received for $docId');
          }

          return snapshot.data();
        })
        .handleError((error) {
          if (kDebugMode) {
            print('❌ FirestoreService.listenToDoc: Stream error - $error');
          }
        });
  }

  /// Listen to collection changes
  ///
  /// [collection] - Collection name
  /// [limit] - Optional limit for number of documents
  /// [orderBy] - Optional field to order by
  /// [descending] - Whether to order in descending order
  ///
  /// Returns: Stream of document list
  Stream<List<Map<String, dynamic>>> listenToCollection({
    required String collection,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) {
    if (kDebugMode) {
      print(
        '🔥 FirestoreService.listenToCollection: Starting listener for $collection',
      );
    }

    Query query = _firestore.collection(collection);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query
        .snapshots()
        .map((snapshot) {
          final documents = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();

          if (kDebugMode) {
            print(
              '🔄 FirestoreService.listenToCollection: ${documents.length} documents received',
            );
          }

          return documents;
        })
        .handleError((error) {
          if (kDebugMode) {
            print(
              '❌ FirestoreService.listenToCollection: Stream error - $error',
            );
          }
        });
  }

  // ==================== UTILITY METHODS ====================

  /// Check if a document exists
  ///
  /// [collection] - Collection name
  /// [docId] - Document ID
  ///
  /// Returns: true if document exists, false otherwise
  /// Throws: FirebaseException on failure
  Future<bool> docExists({
    required String collection,
    required String docId,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '🔥 FirestoreService.docExists: Checking existence of $docId in $collection',
        );
      }

      final doc = await _firestore.collection(collection).doc(docId).get();
      final exists = doc.exists;

      if (kDebugMode) {
        print(
          '✅ FirestoreService.docExists: $docId ${exists ? "exists" : "does not exist"}',
        );
      }

      return exists;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
          '❌ FirestoreService.docExists: Firebase error - ${e.code}: ${e.message}',
        );
      }
      throw FirebaseException(
        plugin: 'firestore',
        code: e.code,
        message: 'Doküman varlık kontrolü başarısız: ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ FirestoreService.docExists: Unexpected error - $e');
      }
      throw Exception('Doküman varlık kontrolü başarısız: $e');
    }
  }

  /// Generate a new document ID
  ///
  /// [collection] - Collection name
  ///
  /// Returns: New document ID
  String generateDocId({required String collection}) {
    final docId = _firestore.collection(collection).doc().id;

    if (kDebugMode) {
      print(
        '🔥 FirestoreService.generateDocId: Generated ID $docId for $collection',
      );
    }

    return docId;
  }
}
