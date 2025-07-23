import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Comprehensive caching service for app data
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Timer> _expiryTimers = {};

  /// Cache configuration
  static const Duration defaultExpiry = Duration(hours: 1);
  static const Duration shortExpiry = Duration(minutes: 15);
  static const Duration longExpiry = Duration(days: 1);
  static const int maxMemoryCacheSize = 100;

  /// Initialize the cache service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadCacheTimestamps();
    await _cleanExpiredEntries();
    print('💾 Cache service initialized');
  }

  /// Ensure initialization
  Future<SharedPreferences> get prefs async {
    await init();
    return _prefs!;
  }

  // ==================== MEMORY CACHE ====================

  /// Store data in memory cache
  void setMemory<T>(String key, T value, {Duration? expiry}) {
    // Manage cache size
    if (_memoryCache.length >= maxMemoryCacheSize) {
      _evictOldestMemoryEntry();
    }

    _memoryCache[key] = value;
    _cacheTimestamps[key] = DateTime.now();

    // Set expiry timer
    if (expiry != null) {
      _setExpiryTimer(key, expiry);
    }

    print('💭 Cached in memory: $key');
  }

  /// Get data from memory cache
  T? getMemory<T>(String key) {
    if (!_memoryCache.containsKey(key)) return null;

    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) {
      _memoryCache.remove(key);
      return null;
    }

    print('✅ Memory cache hit: $key');
    return _memoryCache[key] as T?;
  }

  /// Check if key exists in memory cache
  bool hasMemory(String key) {
    return _memoryCache.containsKey(key);
  }

  // ==================== PERSISTENT CACHE ====================

  /// Store data in persistent cache
  Future<bool> set<T>(String key, T value, {Duration? expiry}) async {
    try {
      final preferences = await prefs;
      String jsonValue;

      if (value is String) {
        jsonValue = value;
      } else if (value is Map || value is List) {
        jsonValue = jsonEncode(value);
      } else {
        jsonValue = jsonEncode(value.toString());
      }

      final success = await preferences.setString(key, jsonValue);

      if (success) {
        final now = DateTime.now();
        _cacheTimestamps[key] = now;

        // Store expiry info
        if (expiry != null) {
          final expiryTime = now.add(expiry);
          await preferences.setString(
            '${key}_expiry',
            expiryTime.toIso8601String(),
          );
          _setExpiryTimer(key, expiry);
        }

        print('💾 Cached persistently: $key');
      }

      return success;
    } catch (e) {
      print('❌ Error caching $key: $e');
      return false;
    }
  }

  /// Get data from persistent cache
  Future<T?> get<T>(String key) async {
    try {
      final preferences = await prefs;

      // Check if expired
      if (await _isExpired(key)) {
        await remove(key);
        return null;
      }

      final jsonValue = preferences.getString(key);
      if (jsonValue == null) return null;

      print('✅ Persistent cache hit: $key');

      // Try to decode based on expected type
      if (T == String) {
        return jsonValue as T;
      } else {
        try {
          final decoded = jsonDecode(jsonValue);
          return decoded as T;
        } catch (e) {
          return jsonValue as T;
        }
      }
    } catch (e) {
      print('❌ Error reading cache $key: $e');
      return null;
    }
  }

  /// Check if key exists in persistent cache
  Future<bool> has(String key) async {
    final preferences = await prefs;
    final exists = preferences.containsKey(key);

    if (exists && await _isExpired(key)) {
      await remove(key);
      return false;
    }

    return exists;
  }

  // ==================== SMART CACHING ====================

  /// Get data with fallback to fetcher function
  Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? expiry,
    bool useMemoryCache = true,
  }) async {
    // Try memory cache first
    if (useMemoryCache) {
      final memoryValue = getMemory<T>(key);
      if (memoryValue != null) return memoryValue;
    }

    // Try persistent cache
    final cachedValue = await get<T>(key);
    if (cachedValue != null) {
      // Store in memory cache for faster access
      if (useMemoryCache) {
        setMemory(key, cachedValue, expiry: expiry);
      }
      return cachedValue;
    }

    // Fetch from source
    print('🔄 Cache miss, fetching: $key');
    final freshValue = await fetcher();

    // Cache the result
    await set(key, freshValue, expiry: expiry ?? defaultExpiry);
    if (useMemoryCache) {
      setMemory(key, freshValue, expiry: expiry);
    }

    return freshValue;
  }

  /// Cache with automatic refresh
  Future<T> getWithAutoRefresh<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? cacheExpiry,
    Duration? refreshThreshold,
  }) async {
    final threshold = refreshThreshold ?? Duration(minutes: 5);
    final expiry = cacheExpiry ?? defaultExpiry;

    // Check if data exists and when it was cached
    final cachedValue = await get<T>(key);
    final timestamp = _cacheTimestamps[key];

    if (cachedValue != null && timestamp != null) {
      final age = DateTime.now().difference(timestamp);

      // If data is fresh enough, return it
      if (age < threshold) {
        return cachedValue;
      }

      // If data is getting old but not expired, refresh in background
      if (age < expiry) {
        unawaited(_backgroundRefresh(key, fetcher, expiry));
        return cachedValue;
      }
    }

    // Data is expired or doesn't exist, fetch immediately
    return await getOrFetch(key, fetcher, expiry: expiry);
  }

  /// Background refresh for auto-refresh mechanism
  Future<void> _backgroundRefresh<T>(
    String key,
    Future<T> Function() fetcher,
    Duration expiry,
  ) async {
    try {
      print('🔄 Background refreshing: $key');
      final freshValue = await fetcher();
      await set(key, freshValue, expiry: expiry);
      setMemory(key, freshValue, expiry: expiry);
    } catch (e) {
      print('❌ Background refresh failed for $key: $e');
    }
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Remove specific cache entry
  Future<bool> remove(String key) async {
    try {
      final preferences = await prefs;

      // Remove from persistent cache
      await preferences.remove(key);
      await preferences.remove('${key}_expiry');

      // Remove from memory cache
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);

      // Cancel expiry timer
      _expiryTimers[key]?.cancel();
      _expiryTimers.remove(key);

      print('🗑️ Removed from cache: $key');
      return true;
    } catch (e) {
      print('❌ Error removing cache $key: $e');
      return false;
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    try {
      final preferences = await prefs;

      // Get all cache keys
      final allKeys = preferences
          .getKeys()
          .where(
            (key) =>
                !key.endsWith('_expiry') && !key.startsWith('reading_settings'),
          )
          .toList();

      // Remove cache entries
      for (final key in allKeys) {
        await preferences.remove(key);
        await preferences.remove('${key}_expiry');
      }

      // Clear memory cache
      _memoryCache.clear();
      _cacheTimestamps.clear();

      // Cancel all timers
      for (final timer in _expiryTimers.values) {
        timer.cancel();
      }
      _expiryTimers.clear();

      print('🧹 Cleared all cache');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// Clear expired entries
  Future<void> clearExpired() async {
    await _cleanExpiredEntries();
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getStats() async {
    final preferences = await prefs;
    final allKeys = preferences.getKeys();

    final cacheKeys = allKeys.where((key) => !key.endsWith('_expiry')).toList();
    final expiredCount = await _countExpiredEntries();

    return {
      'total_entries': cacheKeys.length,
      'memory_entries': _memoryCache.length,
      'expired_entries': expiredCount,
      'memory_cache_size': _memoryCache.length,
      'active_timers': _expiryTimers.length,
      'cache_size_estimate_kb': await _estimateCacheSize(),
    };
  }

  // ==================== HELPER METHODS ====================

  /// Check if cache entry is expired
  Future<bool> _isExpired(String key) async {
    final preferences = await prefs;
    final expiryString = preferences.getString('${key}_expiry');

    if (expiryString == null) return false;

    try {
      final expiryTime = DateTime.parse(expiryString);
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      return false;
    }
  }

  /// Load cache timestamps from persistent storage
  Future<void> _loadCacheTimestamps() async {
    final preferences = await prefs;
    final allKeys = preferences.getKeys();

    for (final key in allKeys) {
      if (key.endsWith('_timestamp')) {
        final baseKey = key.replaceAll('_timestamp', '');
        final timestampString = preferences.getString(key);

        if (timestampString != null) {
          try {
            _cacheTimestamps[baseKey] = DateTime.parse(timestampString);
          } catch (e) {
            await preferences.remove(key);
          }
        }
      }
    }
  }

  /// Clean expired entries
  Future<void> _cleanExpiredEntries() async {
    final preferences = await prefs;
    final allKeys = preferences.getKeys().toList();
    final expiredKeys = <String>[];

    for (final key in allKeys) {
      if (!key.endsWith('_expiry') && await _isExpired(key)) {
        expiredKeys.add(key);
      }
    }

    for (final key in expiredKeys) {
      await remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      print('🧹 Cleaned ${expiredKeys.length} expired cache entries');
    }
  }

  /// Count expired entries
  Future<int> _countExpiredEntries() async {
    final preferences = await prefs;
    final allKeys = preferences.getKeys();
    int expiredCount = 0;

    for (final key in allKeys) {
      if (!key.endsWith('_expiry') && await _isExpired(key)) {
        expiredCount++;
      }
    }

    return expiredCount;
  }

  /// Estimate cache size
  Future<double> _estimateCacheSize() async {
    final preferences = await prefs;
    final allKeys = preferences.getKeys();
    double totalSize = 0;

    for (final key in allKeys) {
      final value = preferences.getString(key);
      if (value != null) {
        totalSize += value.length;
      }
    }

    return totalSize / 1024; // Convert to KB
  }

  /// Evict oldest memory cache entry
  void _evictOldestMemoryEntry() {
    if (_memoryCache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cacheTimestamps.entries) {
      if (_memoryCache.containsKey(entry.key)) {
        if (oldestTime == null || entry.value.isBefore(oldestTime)) {
          oldestTime = entry.value;
          oldestKey = entry.key;
        }
      }
    }

    if (oldestKey != null) {
      _memoryCache.remove(oldestKey);
      print('🗑️ Evicted from memory cache: $oldestKey');
    }
  }

  /// Set expiry timer for automatic cleanup
  void _setExpiryTimer(String key, Duration expiry) {
    _expiryTimers[key]?.cancel();

    _expiryTimers[key] = Timer(expiry, () {
      remove(key);
      _expiryTimers.remove(key);
    });
  }

  /// Dispose the cache service
  void dispose() {
    for (final timer in _expiryTimers.values) {
      timer.cancel();
    }
    _expiryTimers.clear();
    _memoryCache.clear();
    _cacheTimestamps.clear();
    print('🗑️ Cache service disposed');
  }
}

/// Cache keys constants
class CacheKeys {
  static const String books = 'books';
  static const String favorites = 'favorites';
  static const String userProfile = 'user_profile';
  static const String bookDetails = 'book_details';
  static const String searchResults = 'search_results';
  static const String categories = 'categories';
  static const String featuredBooks = 'featured_books';
  static const String popularBooks = 'popular_books';
  static const String recentBooks = 'recent_books';
  static const String userStats = 'user_stats';
  static const String readingProgress = 'reading_progress';

  /// Generate dynamic cache key
  static String userSpecific(String key, String userId) => '${key}_$userId';
  static String bookSpecific(String key, String bookId) => '${key}_$bookId';
  static String searchSpecific(String query) => 'search_${query.hashCode}';
}
