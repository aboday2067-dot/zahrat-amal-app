// ============================================
// نظام اختيار مكاتب التوصيل المتقدم
// Advanced Delivery Office Selection System
// ============================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'main.dart';
import 'specialized_profiles.dart';
import 'driver_vehicle_management.dart';

// ========== صفحة اختيار مكتب التوصيل (للمشترين والتجار) ==========
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
  
  @override
  void initState() {
    super.initState();
    _loadCities();
  }
  
  Future<void> _loadCities() async {
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
    
    setState(() {
      _cities = ['الكل', ...citySet.toList()..sort()];
      if (widget.userCity != null && citySet.contains(widget.userCity)) {
        _selectedCity = widget.userCity!;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('مكاتب التوصيل', 'Delivery Offices')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // شريط الفلترة والترتيب
          _buildFilterBar(context, lang),
          
          // قائمة مكاتب التوصيل
          Expanded(
            child: _buildOfficesList(context, lang),
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
                    children: [
                      _buildSortChip('الأفضل', Icons.stars, lang),
                      _buildSortChip('الأقرب', Icons.near_me, lang),
                      _buildSortChip('التقييم', Icons.star, lang),
                      _buildSortChip('السعر', Icons.attach_money, lang),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSortChip(String label, IconData icon, LanguageProvider lang) {
    final isSelected = _sortBy == label;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _sortBy = label;
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
  }
  
  Widget _buildOfficesList(BuildContext context, LanguageProvider lang) {
    return StreamBuilder<QuerySnapshot>(
      stream: _selectedCity == 'الكل'
          ? FirebaseFirestore.instance
              .collection('delivery_offices')
              .where('is_active', isEqualTo: true)
              .snapshots()
          : FirebaseFirestore.instance
              .collection('delivery_offices')
              .where('is_active', isEqualTo: true)
              .where('city', isEqualTo: _selectedCity)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  lang.translate('لا توجد مكاتب توصيل', 'No delivery offices available'),
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        
        // تحويل البيانات
        List<DeliveryOfficeProfileData> offices = snapshot.data!.docs
            .map((doc) => DeliveryOfficeProfileData.fromFirestore(doc))
            .toList();
        
        // الفرز حسب الاختيار
        offices = _sortOffices(offices);
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: offices.length,
          itemBuilder: (context, index) {
            return _buildOfficeCard(context, offices[index], lang, index);
          },
        );
      },
    );
  }
  
  List<DeliveryOfficeProfileData> _sortOffices(List<DeliveryOfficeProfileData> offices) {
    switch (_sortBy) {
      case 'الأفضل':
        // الفرز المركب: التقييم + عدد التوصيلات + السائقين النشطين
        offices.sort((a, b) {
          final scoreA = (a.rating * 0.5) + 
                         (a.totalDeliveries / 100) + 
                         (a.activeDrivers * 0.3);
          final scoreB = (b.rating * 0.5) + 
                         (b.totalDeliveries / 100) + 
                         (b.activeDrivers * 0.3);
          return scoreB.compareTo(scoreA);
        });
        break;
        
      case 'الأقرب':
        // الفرز حسب القرب من مدينة المستخدم
        if (widget.userCity != null) {
          offices.sort((a, b) {
            if (a.city == widget.userCity && b.city != widget.userCity) return -1;
            if (a.city != widget.userCity && b.city == widget.userCity) return 1;
            return b.rating.compareTo(a.rating);
          });
        } else {
          offices.sort((a, b) => b.rating.compareTo(a.rating));
        }
        break;
        
      case 'التقييم':
        offices.sort((a, b) => b.rating.compareTo(a.rating));
        break;
        
      case 'السعر':
        // الفرز حسب متوسط السعر
        offices.sort((a, b) {
          final avgA = a.deliveryPrices.values.isEmpty 
              ? 0 
              : a.deliveryPrices.values.reduce((sum, price) => sum + price) / a.deliveryPrices.length;
          final avgB = b.deliveryPrices.values.isEmpty 
              ? 0 
              : b.deliveryPrices.values.reduce((sum, price) => sum + price) / b.deliveryPrices.length;
          return avgA.compareTo(avgB);
        });
        break;
    }
    
    return offices;
  }
  
  Widget _buildOfficeCard(
    BuildContext context, 
    DeliveryOfficeProfileData office, 
    LanguageProvider lang,
    int rank,
  ) {
    final isNearUser = widget.userCity != null && office.city == widget.userCity;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeliveryOfficeDetailScreen(
                officeId: office.userId,
                userRole: widget.userRole,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة
              Row(
                children: [
                  // شارة الترتيب
                  if (_sortBy == 'الأفضل' && rank < 3)
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        color: rank == 0 ? Colors.amber : 
                               rank == 1 ? Colors.grey[400] : 
                               Colors.orange[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${rank + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  
                  // صورة المكتب
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF6B9AC4),
                    backgroundImage: office.profileImage != null
                        ? NetworkImage(office.profileImage!)
                        : null,
                    child: office.profileImage == null
                        ? const Icon(Icons.local_shipping, color: Colors.white, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // معلومات المكتب
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                office.officeName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // شارة القرب
                            if (isNearUser)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.near_me, size: 12, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text(
                                      lang.translate('قريب', 'Near'),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_city, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              office.city,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.person, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${office.activeDrivers} ${lang.translate('سائق', 'drivers')}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // الإحصائيات
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      Icons.star,
                      office.rating.toStringAsFixed(1),
                      lang.translate('التقييم', 'Rating'),
                      Colors.amber,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      Icons.local_shipping,
                      '${office.totalDeliveries}',
                      lang.translate('توصيل', 'Deliveries'),
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      Icons.location_on,
                      '${office.coverageAreas.length}',
                      lang.translate('منطقة', 'Areas'),
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // مناطق التغطية
              if (office.coverageAreas.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: office.coverageAreas.take(3).map((area) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B9AC4).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        area,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B9AC4),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 12),
              
              // السعر
              if (office.deliveryPrices.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        lang.translate('من', 'From') + ' ${office.deliveryPrices.values.reduce(math.min).toStringAsFixed(0)} ' +
                        lang.translate('ج', 'SDG'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // زر الاختيار
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeliveryOfficeDetailScreen(
                        officeId: office.userId,
                        userRole: widget.userRole,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9AC4),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(lang.translate('عرض التفاصيل', 'View Details')),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}

// ========== صفحة تفاصيل مكتب التوصيل مع السائقين والمركبات ==========
class DeliveryOfficeDetailScreen extends StatefulWidget {
  final String officeId;
  final String userRole; // 'buyer' أو 'merchant'
  
  const DeliveryOfficeDetailScreen({
    super.key,
    required this.officeId,
    required this.userRole,
  });

  @override
  State<DeliveryOfficeDetailScreen> createState() => _DeliveryOfficeDetailScreenState();
}

class _DeliveryOfficeDetailScreenState extends State<DeliveryOfficeDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('تفاصيل المكتب', 'Office Details')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.info), text: lang.translate('المعلومات', 'Info')),
            Tab(icon: const Icon(Icons.person), text: lang.translate('السائقين', 'Drivers')),
            Tab(icon: const Icon(Icons.directions_car), text: lang.translate('المركبات', 'Vehicles')),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('delivery_offices')
            .doc(widget.officeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(lang.translate('لم يتم العثور على البيانات', 'Data not found')),
                ],
              ),
            );
          }
          
          final office = DeliveryOfficeProfileData.fromFirestore(snapshot.data!);
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(context, office, lang),
              _buildDriversTab(context, lang),
              _buildVehiclesTab(context, lang),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context, lang),
    );
  }
  
  Widget _buildInfoTab(BuildContext context, DeliveryOfficeProfileData office, LanguageProvider lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس المكتب
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF6B9AC4),
                  backgroundImage: office.profileImage != null
                      ? NetworkImage(office.profileImage!)
                      : null,
                  child: office.profileImage == null
                      ? const Icon(Icons.local_shipping, color: Colors.white, size: 48)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  office.officeName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      office.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // الإحصائيات
          Row(
            children: [
              Expanded(
                child: _buildInfoStatCard(
                  Icons.local_shipping,
                  '${office.totalDeliveries}',
                  lang.translate('عمليات توصيل', 'Deliveries'),
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoStatCard(
                  Icons.person,
                  '${office.activeDrivers}',
                  lang.translate('سائقين نشطين', 'Active Drivers'),
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // معلومات الاتصال
          _buildSectionTitle(lang.translate('معلومات الاتصال', 'Contact Info'), Icons.phone),
          const SizedBox(height: 12),
          _buildInfoCard(context, office, lang),
          
          const SizedBox(height: 24),
          
          // مناطق التغطية
          _buildSectionTitle(lang.translate('مناطق التغطية', 'Coverage Areas'), Icons.location_on),
          const SizedBox(height: 12),
          _buildCoverageCard(office, lang),
          
          const SizedBox(height: 24),
          
          // أسعار التوصيل
          _buildSectionTitle(lang.translate('أسعار التوصيل', 'Delivery Prices'), Icons.attach_money),
          const SizedBox(height: 12),
          _buildPricesCard(office, lang),
          
          const SizedBox(height: 24),
          
          // ساعات العمل
          _buildSectionTitle(lang.translate('ساعات العمل', 'Working Hours'), Icons.access_time),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xFF6B9AC4)),
              title: Text(office.workingHours),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDriversTab(BuildContext context, LanguageProvider lang) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('drivers')
          .where('office_id', isEqualTo: widget.officeId)
          .where('is_active', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  lang.translate('لا يوجد سائقين متاحين', 'No drivers available'),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        
        final drivers = snapshot.data!.docs
            .map((doc) => DriverData.fromFirestore(doc))
            .toList();
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            return _buildDriverItem(drivers[index], lang);
          },
        );
      },
    );
  }
  
  Widget _buildVehiclesTab(BuildContext context, LanguageProvider lang) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .where('office_id', isEqualTo: widget.officeId)
          .where('is_active', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  lang.translate('لا توجد مركبات متاحة', 'No vehicles available'),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        
        final vehicles = snapshot.data!.docs
            .map((doc) => VehicleData.fromFirestore(doc))
            .toList();
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            return _buildVehicleItem(vehicles[index], lang);
          },
        );
      },
    );
  }
  
  Widget _buildDriverItem(DriverData driver, LanguageProvider lang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF6B9AC4),
              backgroundImage: driver.profileImage != null
                  ? NetworkImage(driver.profileImage!)
                  : null,
              child: driver.profileImage == null
                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(driver.phone, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        '${driver.rating.toStringAsFixed(1)} (${driver.totalDeliveries} ${lang.translate('توصيل', 'deliveries')})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: () {
                // الاتصال بالسائق
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${lang.translate('اتصال ب', 'Call')} ${driver.fullName}: ${driver.phone}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVehicleItem(VehicleData vehicle, LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              vehicle.getVehicleIcon(),
              size: 48,
              color: const Color(0xFF6B9AC4),
            ),
            const SizedBox(height: 12),
            Text(
              '${vehicle.brand} ${vehicle.model}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vehicle.plateNumber,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vehicle.type,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.scale, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${vehicle.capacity} ${lang.translate('كجم', 'kg')}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B9AC4), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  
  Widget _buildInfoStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(BuildContext context, DeliveryOfficeProfileData office, LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildContactRow(Icons.person, lang.translate('المدير', 'Manager'), office.managerName),
            const Divider(),
            _buildContactRow(Icons.email, lang.translate('البريد', 'Email'), office.email),
            const Divider(),
            _buildContactRow(Icons.phone, lang.translate('الهاتف', 'Phone'), office.phone),
            const Divider(),
            _buildContactRow(Icons.location_on, lang.translate('العنوان', 'Address'), office.address),
            const Divider(),
            _buildContactRow(Icons.location_city, lang.translate('المدينة', 'City'), office.city),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCoverageCard(DeliveryOfficeProfileData office, LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: office.coverageAreas.map((area) {
            return Chip(
              label: Text(area),
              avatar: const Icon(Icons.location_on, size: 16),
              backgroundColor: const Color(0xFF6B9AC4).withValues(alpha: 0.1),
              labelStyle: const TextStyle(color: Color(0xFF6B9AC4)),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildPricesCard(DeliveryOfficeProfileData office, LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: office.deliveryPrices.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 14)),
                  Text(
                    '${entry.value.toStringAsFixed(0)} ${lang.translate('ج', 'SDG')}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B9AC4),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildBottomBar(BuildContext context, LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          // حفظ اختيار المكتب
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lang.translate('✅ تم اختيار مكتب التوصيل', '✅ Delivery office selected')),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B9AC4),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          lang.translate('اختيار هذا المكتب', 'Select This Office'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
