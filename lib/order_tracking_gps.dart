// ============================================
// نظام تتبع الطلبات مع GPS
// Order Tracking System with GPS & Maps
// ============================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'firebase_orders_system.dart';

// ========== نموذج موقع التوصيل ==========
class DeliveryLocation {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? driverName;
  final String? driverPhone;
  
  DeliveryLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.driverName,
    this.driverPhone,
  });
  
  factory DeliveryLocation.fromJson(Map<String, dynamic> json) => DeliveryLocation(
    latitude: (json['latitude'] ?? 0).toDouble(),
    longitude: (json['longitude'] ?? 0).toDouble(),
    timestamp: (json['timestamp'] as Timestamp).toDate(),
    driverName: json['driver_name'],
    driverPhone: json['driver_phone'],
  );
  
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': Timestamp.fromDate(timestamp),
    'driver_name': driverName,
    'driver_phone': driverPhone,
  };
}

// ========== خدمة تتبع التوصيل ==========
class DeliveryTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // تحديث موقع السائق (للسائقين)
  Future<bool> updateDriverLocation(String orderId, Position position) async {
    try {
      await _firestore.collection('delivery_tracking').doc(orderId).set({
        'order_id': orderId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'speed': position.speed,
        'heading': position.heading,
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('❌ Error updating driver location: $e');
      return false;
    }
  }
  
  // الاستماع لموقع السائق (للمشترين)
  Stream<DeliveryLocation?> trackDelivery(String orderId) {
    return _firestore
        .collection('delivery_tracking')
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return DeliveryLocation.fromJson(snapshot.data()!);
        });
  }
  
  // حساب المسافة بين نقطتين (بالكيلومترات)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    ) / 1000; // تحويل من متر إلى كيلومتر
  }
  
  // تقدير وقت الوصول (بالدقائق)
  int estimateArrivalTime(double distanceKm, double averageSpeedKmh) {
    if (averageSpeedKmh <= 0) return 0;
    final hours = distanceKm / averageSpeedKmh;
    return (hours * 60).round(); // تحويل إلى دقائق
  }
}

// ========== صفحة تتبع الطلب ==========
class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;
  
  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final DeliveryTrackingService _trackingService = DeliveryTrackingService();
  Position? _userPosition;
  StreamSubscription<Position>? _positionSubscription;
  
  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }
  
  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _getUserLocation() async {
    try {
      // التحقق من الصلاحيات
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied) {
          return;
        }
      }
      
      // الحصول على الموقع الحالي
      final position = await Geolocator.getCurrentPosition();
      setState(() => _userPosition = position);
      
      // الاستماع لتحديثات الموقع
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((position) {
        setState(() => _userPosition = position);
      });
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('تتبع الطلب', 'Track Order')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DeliveryLocation?>(
        stream: _trackingService.trackDelivery(widget.order.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final deliveryLocation = snapshot.data;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات الطلب
                _buildOrderInfoCard(lang),
                const SizedBox(height: 16),
                
                // حالة التتبع
                _buildTrackingStatusCard(lang, deliveryLocation),
                const SizedBox(height: 16),
                
                // معلومات التوصيل
                if (deliveryLocation != null) ...[
                  _buildDeliveryInfoCard(lang, deliveryLocation),
                  const SizedBox(height: 16),
                ],
                
                // معلومات المسافة والوقت
                if (_userPosition != null && deliveryLocation != null)
                  _buildDistanceCard(lang, deliveryLocation),
                
                const SizedBox(height: 16),
                
                // مراحل التوصيل
                _buildDeliverySteps(lang),
                
                const SizedBox(height: 24),
                
                // زر الاتصال بالسائق
                if (deliveryLocation?.driverPhone != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // الاتصال بالسائق
                      },
                      icon: const Icon(Icons.phone),
                      label: Text(
                        lang.translate('الاتصال بالسائق', 'Call Driver'),
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B9AC4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildOrderInfoCard(LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Color(0xFF6B9AC4)),
                const SizedBox(width: 8),
                Text(
                  lang.translate('معلومات الطلب', 'Order Information'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              lang.translate('رقم الطلب', 'Order ID'),
              '#${widget.order.id.substring(0, 8)}',
            ),
            _buildInfoRow(
              lang.translate('التاريخ', 'Date'),
              DateFormat('yyyy-MM-dd').format(widget.order.orderDate),
            ),
            _buildInfoRow(
              lang.translate('الحالة', 'Status'),
              widget.order.getStatusText(lang),
            ),
            _buildInfoRow(
              lang.translate('الإجمالي', 'Total'),
              '${widget.order.totalAmount.toStringAsFixed(0)} ${lang.translate('ج', 'SDG')}',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrackingStatusCard(LanguageProvider lang, DeliveryLocation? location) {
    final hasTracking = location != null;
    
    return Card(
      elevation: 2,
      color: hasTracking ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              hasTracking ? Icons.check_circle : Icons.pending,
              color: hasTracking ? Colors.green : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasTracking
                        ? lang.translate('التتبع مفعّل', 'Tracking Active')
                        : lang.translate('في انتظار التتبع', 'Waiting for Tracking'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasTracking ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasTracking
                        ? lang.translate('يمكنك تتبع موقع السائق الآن', 'You can track driver location now')
                        : lang.translate('سيبدأ التتبع عند خروج الطلب للتوصيل', 'Tracking will start when out for delivery'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDeliveryInfoCard(LanguageProvider lang, DeliveryLocation location) {
    final timeFormat = DateFormat('HH:mm');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, color: Color(0xFF6B9AC4)),
                const SizedBox(width: 8),
                Text(
                  lang.translate('معلومات التوصيل', 'Delivery Information'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (location.driverName != null)
              _buildInfoRow(
                lang.translate('السائق', 'Driver'),
                location.driverName!,
              ),
            _buildInfoRow(
              lang.translate('آخر تحديث', 'Last Update'),
              timeFormat.format(location.timestamp),
            ),
            _buildInfoRow(
              lang.translate('الموقع', 'Location'),
              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDistanceCard(LanguageProvider lang, DeliveryLocation location) {
    final distance = _trackingService.calculateDistance(
      _userPosition!.latitude,
      _userPosition!.longitude,
      location.latitude,
      location.longitude,
    );
    
    final estimatedTime = _trackingService.estimateArrivalTime(distance, 40); // متوسط سرعة 40 كم/ساعة
    
    return Card(
      elevation: 2,
      color: Colors.blue.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Icon(Icons.straighten, color: Colors.blue, size: 32),
                const SizedBox(height: 8),
                Text(
                  '${distance.toStringAsFixed(1)} ${lang.translate('كم', 'km')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  lang.translate('المسافة', 'Distance'),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 60,
              color: Colors.grey[300],
            ),
            Column(
              children: [
                const Icon(Icons.access_time, color: Colors.blue, size: 32),
                const SizedBox(height: 8),
                Text(
                  '~$estimatedTime ${lang.translate('دقيقة', 'min')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  lang.translate('الوصول المتوقع', 'Estimated Arrival'),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDeliverySteps(LanguageProvider lang) {
    final steps = [
      {'title': lang.translate('تم استلام الطلب', 'Order Received'), 'completed': true},
      {'title': lang.translate('قيد التحضير', 'Preparing'), 'completed': widget.order.status != 'pending'},
      {'title': lang.translate('خرج للتوصيل', 'Out for Delivery'), 'completed': widget.order.status == 'in_delivery' || widget.order.status == 'delivered'},
      {'title': lang.translate('تم التوصيل', 'Delivered'), 'completed': widget.order.status == 'delivered'},
    ];
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.translate('مراحل التوصيل', 'Delivery Steps'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(steps.length, (index) {
              final step = steps[index];
              final isLast = index == steps.length - 1;
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: step['completed'] as bool
                              ? Colors.green
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: step['completed'] as bool
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: step['completed'] as bool
                              ? Colors.green
                              : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Text(
                        step['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: step['completed'] as bool
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: step['completed'] as bool
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
