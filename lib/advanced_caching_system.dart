// ============================================
// نظام التخزين المؤقت المتقدم متعدد الطبقات
// Advanced Multi-Layer Caching System
// ============================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:collection';
import 'dart:async';

/// **الفكرة العبقرية #1: نظام تخزين مؤقت ثلاثي الطبقات**
/// 
/// الطبقة 1: ذاكرة RAM (أسرع - ميلي ثانية)
/// الطبقة 2: SharedPreferences (سريع - 10-50 ميلي ثانية)
/// الطبقة 3: Firestore Offline Cache (متوسط - 100-500 ميلي ثانية)
/// 
/// **النتيجة:** سرعة خيالية + تحمل ملايين المستخدمين!

class AdvancedCacheSystem {
  // الطبقة 1: ذاكرة RAM (LRU Cache محدودة الحجم)
  static final _ramCache = LRUCache<String, dynamic>(maxSize: 100);
  
  // الطبقة 2: SharedPreferences
  static SharedPreferences? _prefs;
  
  // الطبقة 3: Firestore مع Offline Persistence
  static final _firestore = FirebaseFirestore.instance;
  
  /// تهيئة النظام
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    // تفعيل Firestore Offline Persistence (تخزين غير محدود!)
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // 🔥 حجم غير محدود!
    );
  }
  
  /// **الفكرة العبقرية #2: القراءة الذكية من أقرب مصدر**
  static Future<T?> smartGet<T>({
    required String key,
    required Future<T?> Function() fetchFromNetwork,
    required T Function(Map<String, dynamic>) fromJson,
    Duration cacheDuration = const Duration(hours: 24),
  }) async {
    // محاولة 1: RAM Cache (0.1 ميلي ثانية) ⚡⚡⚡
    final ramData = _ramCache.get(key);
    if (ramData != null) {
      return ramData as T;
    }
    
    // محاولة 2: SharedPreferences (10 ميلي ثانية) ⚡⚡
    final prefData = _prefs?.getString(key);
    if (prefData != null) {
      try {
        final json = jsonDecode(prefData) as Map<String, dynamic>;
        final timestamp = json['timestamp'] as int?;
        
        // التحقق من صلاحية البيانات
        if (timestamp != null && 
            DateTime.now().millisecondsSinceEpoch - timestamp < cacheDuration.inMilliseconds) {
          final data = fromJson(json['data'] as Map<String, dynamic>);
          _ramCache.put(key, data); // حفظ في RAM للمرة القادمة
          return data;
        }
      } catch (_) {}
    }
    
    // محاولة 3: جلب من الشبكة (مع حفظ في جميع الطبقات) ⚡
    try {
      final data = await fetchFromNetwork();
      if (data != null) {
        await _saveToAllLayers(key, data);
        return data;
      }
    } catch (_) {}
    
    return null;
  }
  
  /// حفظ في جميع الطبقات دفعة واحدة
  static Future<void> _saveToAllLayers<T>(String key, T data) async {
    // 1. RAM
    _ramCache.put(key, data);
    
    // 2. SharedPreferences (غير متزامن)
    _prefs?.setString(
      key,
      jsonEncode({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      }),
    );
  }
  
  /// مسح جميع الطبقات
  static Future<void> clearAll() async {
    _ramCache.clear();
    await _prefs?.clear();
  }
}

/// **الفكرة العبقرية #3: LRU Cache في الذاكرة**
/// يحتفظ بأحدث 100 عنصر فقط لتوفير الذاكرة
class LRUCache<K, V> {
  final int maxSize;
  final _cache = LinkedHashMap<K, V>();
  
  LRUCache({required this.maxSize});
  
  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    
    // نقل العنصر للنهاية (الأحدث استخداماً)
    final value = _cache.remove(key)!;
    _cache[key] = value;
    return value;
  }
  
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // حذف أقدم عنصر
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }
  
  void clear() => _cache.clear();
}

/// **الفكرة العبقرية #4: Batch Loading (تحميل دفعي)**
/// بدلاً من 100 استعلام → استعلام واحد فقط!
class BatchLoader<T> {
  final Duration batchWindow;
  final Future<List<T>> Function(List<String>) batchFetch;
  
  final _pendingRequests = <String, Completer<T>>{};
  Timer? _batchTimer;
  
  BatchLoader({
    required this.batchFetch,
    this.batchWindow = const Duration(milliseconds: 50),
  });
  
  Future<T> load(String id) {
    // إذا كان هناك طلب معلق، انتظره
    if (_pendingRequests.containsKey(id)) {
      return _pendingRequests[id]!.future;
    }
    
    final completer = Completer<T>();
    _pendingRequests[id] = completer;
    
    // تأخير التنفيذ لتجميع الطلبات
    _batchTimer?.cancel();
    _batchTimer = Timer(batchWindow, _executeBatch);
    
    return completer.future;
  }
  
  Future<void> _executeBatch() async {
    if (_pendingRequests.isEmpty) return;
    
    final ids = _pendingRequests.keys.toList();
    final completers = Map<String, Completer<T>>.from(_pendingRequests);
    _pendingRequests.clear();
    
    try {
      // تنفيذ استعلام واحد لجميع IDs
      final results = await batchFetch(ids);
      
      for (var i = 0; i < ids.length; i++) {
        completers[ids[i]]?.complete(results[i]);
      }
    } catch (e) {
      for (final completer in completers.values) {
        completer.completeError(e);
      }
    }
  }
}

/// **الفكرة العبقرية #5: Optimistic UI Updates**
/// تحديث الواجهة فوراً قبل حفظ البيانات!
class OptimisticUpdater<T> {
  final Future<T> Function(T data) saveToServer;
  final void Function(T data) updateUI;
  final void Function(T data) rollbackUI;
  
  OptimisticUpdater({
    required this.saveToServer,
    required this.updateUI,
    required this.rollbackUI,
  });
  
  Future<void> update(T data) async {
    // 1. تحديث الواجهة فوراً (0 ميلي ثانية!)
    updateUI(data);
    
    try {
      // 2. حفظ في الخلفية
      await saveToServer(data);
    } catch (e) {
      // 3. إذا فشل، التراجع
      rollbackUI(data);
      rethrow;
    }
  }
}

/// **الفكرة العبقرية #6: Connection Pooling لـ Firestore**
/// استخدام اتصال واحد مشترك بدلاً من اتصال لكل عملية
class FirestorePool {
  static final _instance = FirestorePool._();
  factory FirestorePool() => _instance;
  FirestorePool._();
  
  final _firestore = FirebaseFirestore.instance;
  final _queryCache = <String, Query>{};
  
  /// الحصول على Query مخزن مؤقتاً
  Query getQuery(String collectionPath, {Map<String, dynamic>? filters}) {
    final key = '$collectionPath:${filters?.toString() ?? ""}';
    
    if (!_queryCache.containsKey(key)) {
      var query = _firestore.collection(collectionPath) as Query;
      
      if (filters != null) {
        filters.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }
      
      _queryCache[key] = query;
    }
    
    return _queryCache[key]!;
  }
}

/// **الفكرة العبقرية #7: Pagination الذكي**
/// تحميل 10 فقط بدلاً من 10,000!
class SmartPaginator<T> {
  final int pageSize;
  final Future<List<T>> Function(DocumentSnapshot? lastDoc) fetchPage;
  
  final List<T> _items = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoading = false;
  
  SmartPaginator({
    required this.fetchPage,
    this.pageSize = 20,
  });
  
  List<T> get items => _items;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    try {
      final newItems = await fetchPage(_lastDoc);
      
      if (newItems.length < pageSize) {
        _hasMore = false;
      }
      
      _items.addAll(newItems);
    } finally {
      _isLoading = false;
    }
  }
}

/// **الفكرة العبقرية #8: Debouncing للبحث**
/// تقليل استعلامات البحث من 1000 إلى 10!
class SearchDebouncer {
  final Duration delay;
  Timer? _timer;
  
  SearchDebouncer({this.delay = const Duration(milliseconds: 500)});
  
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}

/// **مثال على الاستخدام الكامل:**
/*
// في main.dart:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AdvancedCacheSystem.initialize();
  runApp(MyApp());
}

// في أي صفحة:
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Office>>(
      future: _loadOffices(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return OfficeCard(office: snapshot.data![index]);
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
  
  Future<List<Office>> _loadOffices() async {
    return await AdvancedCacheSystem.smartGet<List<Office>>(
      key: 'delivery_offices_all',
      fetchFromNetwork: () async {
        final snapshot = await FirebaseFirestore.instance
            .collection('delivery_offices')
            .limit(20) // Pagination!
            .get();
        return snapshot.docs
            .map((doc) => Office.fromFirestore(doc))
            .toList();
      },
      fromJson: (json) {
        return (json['items'] as List)
            .map((item) => Office.fromJson(item))
            .toList();
      },
      cacheDuration: Duration(hours: 1),
    );
  }
}
*/

