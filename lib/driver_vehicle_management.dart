// ============================================
// نظام إدارة السائقين والمركبات المتقدم
// Advanced Driver & Vehicle Management System
// ============================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'main.dart';

// ========== نموذج بيانات السائق ==========
class DriverData {
  final String id;
  final String officeId;
  final String fullName;
  final String phone;
  final String emergencyPhone;
  final String licenseNumber;
  final String licenseExpiry;
  final String? profileImage;
  final bool isActive;
  final double rating;
  final int totalDeliveries;
  final String vehicleId;
  
  DriverData({
    required this.id,
    required this.officeId,
    required this.fullName,
    required this.phone,
    required this.emergencyPhone,
    required this.licenseNumber,
    required this.licenseExpiry,
    this.profileImage,
    this.isActive = true,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    required this.vehicleId,
  });
  
  factory DriverData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DriverData(
      id: doc.id,
      officeId: data['office_id'] ?? '',
      fullName: data['full_name'] ?? '',
      phone: data['phone'] ?? '',
      emergencyPhone: data['emergency_phone'] ?? '',
      licenseNumber: data['license_number'] ?? '',
      licenseExpiry: data['license_expiry'] ?? '',
      profileImage: data['profile_image'],
      isActive: data['is_active'] ?? true,
      rating: (data['rating'] ?? 0).toDouble(),
      totalDeliveries: data['total_deliveries'] ?? 0,
      vehicleId: data['vehicle_id'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'office_id': officeId,
    'full_name': fullName,
    'phone': phone,
    'emergency_phone': emergencyPhone,
    'license_number': licenseNumber,
    'license_expiry': licenseExpiry,
    'profile_image': profileImage,
    'is_active': isActive,
    'rating': rating,
    'total_deliveries': totalDeliveries,
    'vehicle_id': vehicleId,
  };
}

// ========== نموذج بيانات المركبة ==========
class VehicleData {
  final String id;
  final String officeId;
  final String type; // دراجة نارية، سيارة صغيرة، شاحنة صغيرة
  final String brand;
  final String model;
  final String plateNumber;
  final String color;
  final int capacity; // بالكيلوجرام
  final String? image;
  final bool isActive;
  final String insuranceExpiry;
  
  VehicleData({
    required this.id,
    required this.officeId,
    required this.type,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.color,
    required this.capacity,
    this.image,
    this.isActive = true,
    required this.insuranceExpiry,
  });
  
  factory VehicleData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleData(
      id: doc.id,
      officeId: data['office_id'] ?? '',
      type: data['type'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      plateNumber: data['plate_number'] ?? '',
      color: data['color'] ?? '',
      capacity: data['capacity'] ?? 0,
      image: data['image'],
      isActive: data['is_active'] ?? true,
      insuranceExpiry: data['insurance_expiry'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'office_id': officeId,
    'type': type,
    'brand': brand,
    'model': model,
    'plate_number': plateNumber,
    'color': color,
    'capacity': capacity,
    'image': image,
    'is_active': isActive,
    'insurance_expiry': insuranceExpiry,
  };
  
  IconData getVehicleIcon() {
    switch (type) {
      case 'دراجة نارية':
      case 'Motorcycle':
        return Icons.two_wheeler;
      case 'سيارة صغيرة':
      case 'Car':
        return Icons.directions_car;
      case 'شاحنة صغيرة':
      case 'Truck':
        return Icons.local_shipping;
      default:
        return Icons.delivery_dining;
    }
  }
}

// ========== صفحة إدارة السائقين ==========
class DriversManagementScreen extends StatelessWidget {
  final String officeId;
  
  const DriversManagementScreen({super.key, required this.officeId});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('إدارة السائقين', 'Manage Drivers')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('drivers')
            .where('office_id', isEqualTo: officeId)
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
                    lang.translate('لا يوجد سائقين', 'No drivers yet'),
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
              final driver = drivers[index];
              return _buildDriverCard(context, driver, lang);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDriverScreen(officeId: officeId),
            ),
          );
        },
        backgroundColor: const Color(0xFF6B9AC4),
        icon: const Icon(Icons.add),
        label: Text(lang.translate('إضافة سائق', 'Add Driver')),
      ),
    );
  }
  
  Widget _buildDriverCard(BuildContext context, DriverData driver, LanguageProvider lang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
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
            if (driver.isActive)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          driver.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                const Icon(Icons.card_membership, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${lang.translate('رخصة', 'License')}: ${driver.licenseNumber}',
                  style: const TextStyle(fontSize: 12),
                ),
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
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            _showDriverOptions(context, driver, lang);
          },
        ),
      ),
    );
  }
  
  void _showDriverOptions(BuildContext context, DriverData driver, LanguageProvider lang) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFF6B9AC4)),
            title: Text(lang.translate('تعديل', 'Edit')),
            onTap: () {
              Navigator.pop(context);
              // تعديل السائق
            },
          ),
          ListTile(
            leading: Icon(
              driver.isActive ? Icons.block : Icons.check_circle,
              color: driver.isActive ? Colors.red : Colors.green,
            ),
            title: Text(
              driver.isActive
                  ? lang.translate('تعطيل', 'Deactivate')
                  : lang.translate('تفعيل', 'Activate'),
            ),
            onTap: () async {
              await FirebaseFirestore.instance
                  .collection('drivers')
                  .doc(driver.id)
                  .update({'is_active': !driver.isActive});
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: Text(lang.translate('اتصال', 'Call')),
            onTap: () {
              Navigator.pop(context);
              // الاتصال بالسائق
            },
          ),
        ],
      ),
    );
  }
}

// ========== صفحة إضافة سائق ==========
class AddDriverScreen extends StatefulWidget {
  final String officeId;
  
  const AddDriverScreen({super.key, required this.officeId});

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _expiryController = TextEditingController();
  String _selectedVehicle = '';
  List<VehicleData> _vehicles = [];
  
  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }
  
  Future<void> _loadVehicles() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vehicles')
        .where('office_id', isEqualTo: widget.officeId)
        .where('is_active', isEqualTo: true)
        .get();
    
    setState(() {
      _vehicles = snapshot.docs.map((doc) => VehicleData.fromFirestore(doc)).toList();
      if (_vehicles.isNotEmpty) {
        _selectedVehicle = _vehicles.first.id;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('إضافة سائق', 'Add Driver')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: lang.translate('الاسم الكامل', 'Full Name'),
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true
                  ? lang.translate('مطلوب', 'Required')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: lang.translate('رقم الهاتف', 'Phone Number'),
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true
                  ? lang.translate('مطلوب', 'Required')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emergencyPhoneController,
              decoration: InputDecoration(
                labelText: lang.translate('هاتف الطوارئ', 'Emergency Phone'),
                prefixIcon: const Icon(Icons.emergency),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _licenseController,
              decoration: InputDecoration(
                labelText: lang.translate('رقم الرخصة', 'License Number'),
                prefixIcon: const Icon(Icons.card_membership),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true
                  ? lang.translate('مطلوب', 'Required')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _expiryController,
              decoration: InputDecoration(
                labelText: lang.translate('تاريخ انتهاء الرخصة', 'License Expiry'),
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) {
                  _expiryController.text = date.toString().split(' ')[0];
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedVehicle.isEmpty ? null : _selectedVehicle,
              decoration: InputDecoration(
                labelText: lang.translate('المركبة', 'Vehicle'),
                prefixIcon: const Icon(Icons.directions_car),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _vehicles.map((vehicle) {
                return DropdownMenuItem(
                  value: vehicle.id,
                  child: Text('${vehicle.brand} ${vehicle.model} - ${vehicle.plateNumber}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicle = value ?? '';
                });
              },
              validator: (value) => value?.isEmpty ?? true
                  ? lang.translate('مطلوب', 'Required')
                  : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveDriver,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B9AC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                lang.translate('حفظ', 'Save'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveDriver() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      final driver = DriverData(
        id: '',
        officeId: widget.officeId,
        fullName: _nameController.text,
        phone: _phoneController.text,
        emergencyPhone: _emergencyPhoneController.text,
        licenseNumber: _licenseController.text,
        licenseExpiry: _expiryController.text,
        vehicleId: _selectedVehicle,
      );
      
      await FirebaseFirestore.instance.collection('drivers').add(driver.toJson());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم إضافة السائق بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyPhoneController.dispose();
    _licenseController.dispose();
    _expiryController.dispose();
    super.dispose();
  }
}

// ========== صفحة إدارة المركبات ==========
class VehiclesManagementScreen extends StatelessWidget {
  final String officeId;
  
  const VehiclesManagementScreen({super.key, required this.officeId});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('إدارة المركبات', 'Manage Vehicles')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .where('office_id', isEqualTo: officeId)
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
                    lang.translate('لا توجد مركبات', 'No vehicles yet'),
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
              childAspectRatio: 0.85,
            ),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return _buildVehicleCard(context, vehicle, lang);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVehicleScreen(officeId: officeId),
            ),
          );
        },
        backgroundColor: const Color(0xFF6B9AC4),
        icon: const Icon(Icons.add),
        label: Text(lang.translate('إضافة مركبة', 'Add Vehicle')),
      ),
    );
  }
  
  Widget _buildVehicleCard(BuildContext context, VehicleData vehicle, LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // عرض تفاصيل المركبة
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              vehicle.getVehicleIcon(),
              size: 48,
              color: vehicle.isActive ? const Color(0xFF6B9AC4) : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              '${vehicle.brand} ${vehicle.model}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vehicle.plateNumber,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              vehicle.type,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '${vehicle.capacity} ${lang.translate('كجم', 'kg')}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: vehicle.isActive
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                vehicle.isActive
                    ? lang.translate('نشط', 'Active')
                    : lang.translate('غير نشط', 'Inactive'),
                style: TextStyle(
                  fontSize: 10,
                  color: vehicle.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== صفحة إضافة مركبة ==========
class AddVehicleScreen extends StatefulWidget {
  final String officeId;
  
  const AddVehicleScreen({super.key, required this.officeId});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  final _capacityController = TextEditingController();
  final _insuranceController = TextEditingController();
  String _selectedType = 'سيارة صغيرة';
  
  final List<String> _vehicleTypes = [
    'دراجة نارية',
    'سيارة صغيرة',
    'شاحنة صغيرة',
  ];
  
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('إضافة مركبة', 'Add Vehicle')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: lang.translate('نوع المركبة', 'Vehicle Type'),
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _vehicleTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: lang.translate('الماركة', 'Brand'),
                prefixIcon: const Icon(Icons.branding_watermark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true ? lang.translate('مطلوب', 'Required') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: lang.translate('الموديل', 'Model'),
                prefixIcon: const Icon(Icons.model_training),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true ? lang.translate('مطلوب', 'Required') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _plateController,
              decoration: InputDecoration(
                labelText: lang.translate('رقم اللوحة', 'Plate Number'),
                prefixIcon: const Icon(Icons.confirmation_number),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true ? lang.translate('مطلوب', 'Required') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _colorController,
              decoration: InputDecoration(
                labelText: lang.translate('اللون', 'Color'),
                prefixIcon: const Icon(Icons.palette),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: InputDecoration(
                labelText: lang.translate('السعة (كجم)', 'Capacity (kg)'),
                prefixIcon: const Icon(Icons.scale),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? lang.translate('مطلوب', 'Required') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _insuranceController,
              decoration: InputDecoration(
                labelText: lang.translate('تاريخ انتهاء التأمين', 'Insurance Expiry'),
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) {
                  _insuranceController.text = date.toString().split(' ')[0];
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveVehicle,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B9AC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                lang.translate('حفظ', 'Save'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      final vehicle = VehicleData(
        id: '',
        officeId: widget.officeId,
        type: _selectedType,
        brand: _brandController.text,
        model: _modelController.text,
        plateNumber: _plateController.text,
        color: _colorController.text,
        capacity: int.parse(_capacityController.text),
        insuranceExpiry: _insuranceController.text,
      );
      
      await FirebaseFirestore.instance.collection('vehicles').add(vehicle.toJson());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تمت إضافة المركبة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _capacityController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }
}
