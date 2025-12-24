// ============================================
// نظام اختيار مكاتب التوصيل المتقدم v6.0
// Advanced Delivery Office Selection System with Smart Loading
// ============================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'main.dart';
import 'specialized_profiles.dart';
import 'driver_vehicle_management.dart';

// 🚀 Performance Systems - NEW
import 'smart_data_loading.dart';
import 'offline_first_database.dart';
import 'image_optimization.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ========== صفحة اختيار مكتب التوصيل (محسنة) ==========
class DeliveryOfficeSelectionScreen extends StatefulWidget {
  final String userRole; // 'buyer' أو 'merchant'
  final String? userCity; // مدينة المستخدم لفرز الأقرب
  
  const DeliveryOfficeSelectionScreen({
    super.key,
    required this.userRole,
    this.userCity,
  });

  @override
  State<DeliveryOfficeSelectionScreen> createState() => _DeliveryOfficeSelectionScreenState();
}

class _DeliveryOfficeSelectionScreenState extends State<DeliveryOfficeSelectionScreen> {
  String _selectedCity = 'الكل';
  String _sortBy = 'الأفضل'; // الأفضل، الأقرب، التقييم، السعر
  List<String> _cities = ['الكل'];
  
  // 🚀 Smart Data Loader - NEW
  late SmartDataLoader<Map<String, dynamic>> _dataLoader;
  final _officesRepo = OfflineFirstRepository<Map<String, dynamic>>(
    collectionName: 'delivery_offices',
    boxName: LocalDatabaseManager.DELIVERY_OFFICES_BOX,
    fromMap: (data) => data,
    toMap: (item) => item,
  );
  
  bool _isInitializing = true;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    // 🔄 Sync offline data first
    await _syncOfflineData();
    
    // 📊 Initialize smart data loader
    _dataLoader = SmartDataLoader<Map<String, dynamic>>(
      collectionName: 'delivery_offices',
      fromMap: (data, id) => {'id': id, ...data},
      pageSize: 15, // تحميل 15 مكتب فقط في كل مرة
    );
    
    // تحميل المدن
    await _loadCities();
    
    setState(() => _isInitializing = false);
  }
  
  Future<void> _syncOfflineData() async {
    try {
      await SmartSyncManager().syncCollection(
        'delivery_offices',
        LocalDatabaseManager.DELIVERY_OFFICES_BOX,
      );
      debugPrint('✅ Delivery offices synced');
    } catch (e) {
      debugPrint('⚠️ Sync failed, using cached data: $e');
    }
  }
  
  Future<void> _loadCities() async {
    // 📦 Load from shared_preferences first
    final prefs = await SharedPreferences.getInstance();
    final cachedCitiesJson = prefs.getStringList('delivery_cities');
    
    if (cachedCitiesJson != null && cachedCitiesJson.isNotEmpty) {
      setState(() {
        _cities = ['الكل', ...cachedCitiesJson];
        if (widget.userCity != null && cachedCitiesJson.contains(widget.userCity)) {
          _selectedCity = widget.userCity!;
        }
      });
      return;
    }
    
    // 🔄 Load from Firebase if cache miss
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('delivery_offices')
          .get();
      
      final Set<String> citySet = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['city'] != null) {
          citySet.add(data['city'] as String);
        }
      }
      
      final cityList = citySet.toList()..sort();
      
      // 💾 Cache for future use
      await prefs.setStringList('delivery_cities', cityList);
      
      setState(() {
        _cities = ['الكل', ...cityList];
        if (widget.userCity != null && citySet.contains(widget.userCity)) {
          _selectedCity = widget.userCity!;
        }
      });
    } catch (e) {
      debugPrint('⚠️ Failed to load cities: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          title: Text(lang.translate('مكاتب التوصيل', 'Delivery Offices')),
          backgroundColor: const Color(0xFF6B9AC4),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('🚀 جاري تحميل البيانات...'),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('مكاتب التوصيل', 'Delivery Offices')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          // زر إعادة التحميل
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _dataLoader.loadFirstPage();
              setState(() {});
            },
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط الفلترة والترتيب
          _buildFilterBar(context, lang),
          
          // قائمة مكاتب التوصيل (Smart Loading)
          Expanded(
            child: _buildSmartOfficesList(context, lang),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterBar(BuildContext context, LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // فلتر المدينة
          Row(
            children: [
              Icon(Icons.location_city, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                lang.translate('المدينة:', 'City:'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _cities.map((city) {
                      final isSelected = city == _selectedCity;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(city),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCity = city;
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: const Color(0xFF6B9AC4),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // فلتر الترتيب
          Row(
            children: [
              Icon(Icons.sort, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                lang.translate('الترتيب:', 'Sort by:'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['الأفضل', 'الأقرب', 'التقييم', 'السعر'].map((sort) {
                      final isSelected = sort == _sortBy;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getSortIcon(sort),
                                size: 16,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(sort),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _sortBy = sort;
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: const Color(0xFF6B9AC4),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  IconData _getSortIcon(String sort) {
    switch (sort) {
      case 'الأفضل': return Icons.star;
      case 'الأقرب': return Icons.near_me;
      case 'التقييم': return Icons.thumb_up;
      case 'السعر': return Icons.attach_money;
      default: return Icons.sort;
    }
  }
  
  // 🚀 Smart Infinite List View - NEW
  Widget _buildSmartOfficesList(BuildContext context, LanguageProvider lang) {
    return SmartInfiniteListView<Map<String, dynamic>>(
      dataLoader: _dataLoader,
      title: lang.translate('مكاتب التوصيل', 'Delivery Offices'),
      itemBuilder: (context, office, index) {
        // تطبيق الفلترة
        if (_selectedCity != 'الكل' && office['city'] != _selectedCity) {
          return const SizedBox.shrink();
        }
        
        return _buildOptimizedOfficeCard(context, office, index, lang);
      },
      emptyWidget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              lang.translate('لا توجد مكاتب توصيل', 'No delivery offices found'),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  // 🖼️ Optimized Office Card with Image Caching
  Widget _buildOptimizedOfficeCard(
    BuildContext context,
    Map<String, dynamic> office,
    int index,
    LanguageProvider lang,
  ) {
    final name = office['name'] ?? lang.translate('مكتب توصيل', 'Delivery Office');
    final city = office['city'] ?? '';
    final district = office['district'] ?? '';
    final rating = (office['rating'] ?? 0.0).toDouble();
    final deliveryPrice = (office['delivery_price'] ?? 0).toInt();
    final totalDeliveries = office['total_deliveries'] ?? 0;
    final activeDrivers = office['active_drivers'] ?? 0;
    
    // حساب الترتيب الذكي
    final smartScore = _calculateSmartScore(
      rating: rating,
      deliveries: totalDeliveries,
      drivers: activeDrivers,
    );
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to details screen when ready
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${office['name']} - قريباً: صفحة التفاصيل'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 🖼️ Logo with Smart Caching
              OptimizedImage(
                imageUrl: office['logo_url'],
                width: 70,
                height: 70,
                borderRadius: BorderRadius.circular(12),
                placeholder: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_shipping, size: 32, color: Colors.grey),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // معلومات المكتب
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الاسم + Badge الترتيب
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (index < 3)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getRankColor(index),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // الموقع
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$city - $district',
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // التقييم + السعر + السائقين
                    Wrap(
                      spacing: 12,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_money, size: 14, color: Colors.green[700]),
                            Text(
                              '$deliveryPrice ${lang.translate('جنيه', 'SDG')}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_shipping, size: 14, color: Colors.blue[700]),
                            const SizedBox(width: 2),
                            Text(
                              '$activeDrivers ${lang.translate('سائق', 'drivers')}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // زر الاختيار
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  double _calculateSmartScore({
    required double rating,
    required int deliveries,
    required int drivers,
  }) {
    // خوارزمية الترتيب الذكي
    return (rating * 0.5) + (deliveries / 100) + (drivers * 0.3);
  }
  
  Color _getRankColor(int index) {
    switch (index) {
      case 0: return Colors.amber; // ذهبي
      case 1: return Colors.grey; // فضي
      case 2: return Colors.brown; // برونزي
      default: return Colors.blue;
    }
  }
}
