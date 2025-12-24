// ============================================
// نظام تحسين الأداء للشبكات الضعيفة
// Performance Optimization for Poor Network Conditions
// ============================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

// ========== مدير التخزين المؤقت (Caching Manager) ==========
class CacheManager {
  static const String _cachePrefix = 'cache_';
  static const Duration _defaultCacheDuration = Duration(hours: 1);
  
  /// حفظ البيانات في الذاكرة المؤقتة
  static Future<void> saveToCache(String key, dynamic data, {Duration? duration}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expires_at': DateTime.now().add(duration ?? _defaultCacheDuration).millisecondsSinceEpoch,
    };
    await prefs.setString('$_cachePrefix$key', jsonEncode(cacheData));
  }
  
  /// قراءة البيانات من الذاكرة المؤقتة
  static Future<dynamic> getFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString('$_cachePrefix$key');
    
    if (cacheString == null) return null;
    
    try {
      final cacheData = jsonDecode(cacheString);
      final expiresAt = cacheData['expires_at'] as int;
      
      // التحقق من صلاحية البيانات
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        // البيانات منتهية الصلاحية
        await clearCache(key);
        return null;
      }
      
      return cacheData['data'];
    } catch (e) {
      return null;
    }
  }
  
  /// مسح ذاكرة التخزين المؤقت لمفتاح معين
  static Future<void> clearCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cachePrefix$key');
  }
  
  /// مسح جميع البيانات المؤقتة
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
  
  /// التحقق من وجود بيانات صالحة في الذاكرة المؤقتة
  static Future<bool> hasValidCache(String key) async {
    final data = await getFromCache(key);
    return data != null;
  }
}

// ========== مدير الشبكة (Network Manager) ==========
class NetworkManager {
  static bool _hasConnection = true;
  static final List<VoidCallback> _listeners = [];
  
  /// الحالة الحالية للشبكة
  static bool get hasConnection => _hasConnection;
  
  /// تحديث حالة الشبكة
  static void updateConnectionStatus(bool status) {
    if (_hasConnection != status) {
      _hasConnection = status;
      _notifyListeners();
    }
  }
  
  /// الاشتراك في تغييرات حالة الشبكة
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }
  
  /// إلغاء الاشتراك
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
  
  /// إشعار المستمعين بالتغيير
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

// ========== مدير جلب البيانات الذكي (Smart Data Fetcher) ==========
class SmartDataFetcher<T> {
  final String cacheKey;
  final Future<T> Function() fetchFunction;
  final T Function(Map<String, dynamic>) fromJsonFunction;
  final Map<String, dynamic> Function(T) toJsonFunction;
  final Duration cacheDuration;
  
  SmartDataFetcher({
    required this.cacheKey,
    required this.fetchFunction,
    required this.fromJsonFunction,
    required this.toJsonFunction,
    this.cacheDuration = const Duration(hours: 1),
  });
  
  /// جلب البيانات مع التخزين المؤقت الذكي
  Future<T> fetch({bool forceRefresh = false}) async {
    // 1. إذا كان forceRefresh = true، جلب من الشبكة مباشرة
    if (forceRefresh) {
      return await _fetchFromNetwork();
    }
    
    // 2. التحقق من وجود بيانات مخزنة صالحة
    final cachedData = await CacheManager.getFromCache(cacheKey);
    if (cachedData != null) {
      try {
        return fromJsonFunction(cachedData as Map<String, dynamic>);
      } catch (e) {
        // فشل تحليل البيانات المخزنة، جلب من الشبكة
      }
    }
    
    // 3. جلب من الشبكة
    return await _fetchFromNetwork();
  }
  
  Future<T> _fetchFromNetwork() async {
    try {
      final data = await fetchFunction();
      
      // حفظ في الذاكرة المؤقتة
      await CacheManager.saveToCache(
        cacheKey,
        toJsonFunction(data),
        duration: cacheDuration,
      );
      
      NetworkManager.updateConnectionStatus(true);
      return data;
    } catch (e) {
      NetworkManager.updateConnectionStatus(false);
      
      // محاولة قراءة من الذاكرة المؤقتة حتى لو كانت منتهية الصلاحية
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString('cache_$cacheKey');
      if (cacheString != null) {
        try {
          final cacheData = jsonDecode(cacheString);
          return fromJsonFunction(cacheData['data'] as Map<String, dynamic>);
        } catch (_) {}
      }
      
      rethrow;
    }
  }
}

// ========== Firestore مع التخزين المؤقت ==========
class CachedFirestoreCollection<T> {
  final String collectionName;
  final T Function(DocumentSnapshot) fromFirestore;
  final Duration cacheDuration;
  
  CachedFirestoreCollection({
    required this.collectionName,
    required this.fromFirestore,
    this.cacheDuration = const Duration(minutes: 30),
  });
  
  /// جلب جميع المستندات مع التخزين المؤقت
  Future<List<T>> getAll({bool forceRefresh = false}) async {
    final cacheKey = '${collectionName}_all';
    
    // محاولة القراءة من الذاكرة المؤقتة
    if (!forceRefresh) {
      final cached = await CacheManager.getFromCache(cacheKey);
      if (cached != null) {
        try {
          final List<dynamic> cachedList = cached as List<dynamic>;
          // لا يمكن استرجاع الكائنات بشكل مباشر، نحتاج لحفظها كـ JSON
          // هنا نعيد جلب البيانات من Firestore لتحويلها بشكل صحيح
        } catch (e) {
          // تجاهل الخطأ والمتابعة للجلب من الشبكة
        }
      }
    }
    
    // جلب من Firestore
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .get(const GetOptions(source: Source.serverAndCache));
      
      final List<T> items = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      
      // حفظ البيانات في الذاكرة المؤقتة
      // ملاحظة: هذا يتطلب تحويل الكائنات إلى JSON أولاً
      
      NetworkManager.updateConnectionStatus(true);
      return items;
    } catch (e) {
      NetworkManager.updateConnectionStatus(false);
      
      // محاولة القراءة من Firestore Cache
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection(collectionName)
            .get(const GetOptions(source: Source.cache));
        
        return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      } catch (_) {
        rethrow;
      }
    }
  }
  
  /// جلب مستند واحد مع التخزين المؤقت
  Future<T?> getById(String docId, {bool forceRefresh = false}) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .get(GetOptions(source: forceRefresh ? Source.server : Source.serverAndCache));
      
      if (!doc.exists) return null;
      
      NetworkManager.updateConnectionStatus(true);
      return fromFirestore(doc);
    } catch (e) {
      NetworkManager.updateConnectionStatus(false);
      
      // محاولة القراءة من Cache
      try {
        final doc = await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(docId)
            .get(const GetOptions(source: Source.cache));
        
        if (!doc.exists) return null;
        return fromFirestore(doc);
      } catch (_) {
        return null;
      }
    }
  }
}

// ========== Widget لعرض حالة الشبكة ==========
class NetworkStatusWidget extends StatefulWidget {
  final Widget child;
  
  const NetworkStatusWidget({super.key, required this.child});

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget> {
  bool _showOfflineMessage = false;
  Timer? _hideTimer;
  
  @override
  void initState() {
    super.initState();
    NetworkManager.addListener(_onNetworkChange);
  }
  
  @override
  void dispose() {
    NetworkManager.removeListener(_onNetworkChange);
    _hideTimer?.cancel();
    super.dispose();
  }
  
  void _onNetworkChange() {
    if (!NetworkManager.hasConnection) {
      setState(() {
        _showOfflineMessage = true;
      });
    } else {
      // إخفاء الرسالة بعد 3 ثوانٍ من عودة الاتصال
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showOfflineMessage = false;
          });
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        // شريط حالة الاتصال
        if (_showOfflineMessage)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: NetworkManager.hasConnection ? Colors.green : Colors.orange,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        NetworkManager.hasConnection ? Icons.wifi : Icons.wifi_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          NetworkManager.hasConnection
                              ? '✅ تم استعادة الاتصال بالإنترنت'
                              : '⚠️ لا يوجد اتصال بالإنترنت - الوضع غير متصل',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ========== إعدادات Firestore للشبكة الضعيفة ==========
class FirestoreOptimizer {
  /// تفعيل إعدادات التخزين المؤقت لـ Firestore
  static void enablePersistence() {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
  
  /// تفعيل استراتيجية جلب البيانات من الخادم والذاكرة المؤقتة
  static GetOptions get smartGetOptions => const GetOptions(
    source: Source.serverAndCache,
  );
  
  /// تفعيل استراتيجية جلب البيانات من الذاكرة المؤقتة فقط
  static GetOptions get cacheOnlyOptions => const GetOptions(
    source: Source.cache,
  );
}

// ========== مثال على الاستخدام ==========
/*
// في main.dart عند التهيئة:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // تفعيل التخزين المؤقت لـ Firestore
  FirestoreOptimizer.enablePersistence();
  
  runApp(const MyApp());
}

// في أي صفحة:
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NetworkStatusWidget(
      child: Scaffold(
        body: FutureBuilder(
          future: _loadData(),
          builder: (context, snapshot) {
            // عرض البيانات
          },
        ),
      ),
    );
  }
  
  Future<List<Office>> _loadData() async {
    final fetcher = CachedFirestoreCollection<DeliveryOfficeProfileData>(
      collectionName: 'delivery_offices',
      fromFirestore: (doc) => DeliveryOfficeProfileData.fromFirestore(doc),
      cacheDuration: Duration(minutes: 30),
    );
    
    return await fetcher.getAll();
  }
}
*/
