import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AddEditDeliveryScreen extends StatefulWidget {
  final Map<String, dynamic>? delivery;

  const AddEditDeliveryScreen({super.key, this.delivery});

  @override
  State<AddEditDeliveryScreen> createState() => _AddEditDeliveryScreenState();
}

class _AddEditDeliveryScreenState extends State<AddEditDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _coverageAreasController;
  
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.delivery?['name'] ?? '');
    _emailController = TextEditingController(text: widget.delivery?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.delivery?['phone'] ?? '');
    _addressController = TextEditingController(text: widget.delivery?['address'] ?? '');
    _cityController = TextEditingController(text: widget.delivery?['city'] ?? 'الخرطوم');
    
    // Convert coverage areas list to string
    String coverageAreas = '';
    if (widget.delivery?['coverage_areas'] != null) {
      coverageAreas = (widget.delivery!['coverage_areas'] as List).join(', ');
    }
    _coverageAreasController = TextEditingController(text: coverageAreas);
    
    if (widget.delivery != null) {
      _isActive = widget.delivery!['active'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _coverageAreasController.dispose();
    super.dispose();
  }

  Future<void> _saveDelivery() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String jsonString = await rootBundle.loadString('assets/data/delivery_offices.json');
      final List<dynamic> deliveries = json.decode(jsonString);

      // Parse coverage areas
      final coverageAreas = _coverageAreasController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (widget.delivery == null) {
        // Add new delivery office
        final newDelivery = {
          'id': 'delivery_${DateTime.now().millisecondsSinceEpoch}',
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'coverage_areas': coverageAreas,
          'active': _isActive,
          'join_date': DateTime.now().toIso8601String(),
          'total_deliveries': 0,
          'rating': 0.0,
          'agents_count': 0,
        };
        deliveries.add(newDelivery);
      } else {
        // Edit existing delivery office
        final index = deliveries.indexWhere((d) => d['id'] == widget.delivery!['id']);
        if (index != -1) {
          deliveries[index] = {
            ...deliveries[index],
            'name': _nameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
            'city': _cityController.text,
            'coverage_areas': coverageAreas,
            'active': _isActive,
          };
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.delivery == null ? 'تم إضافة مكتب التوصيل بنجاح' : 'تم تحديث بيانات المكتب',
              style: const TextStyle(fontFamily: 'Arial'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.delivery != null;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'تعديل بيانات مكتب التوصيل' : 'إضافة مكتب توصيل جديد'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم مكتب التوصيل',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_shipping),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الاسم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال البريد الإلكتروني';
                          }
                          if (!value.contains('@')) {
                            return 'الرجاء إدخال بريد إلكتروني صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'المدينة',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال المدينة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'العنوان',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال العنوان';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _coverageAreasController,
                        decoration: const InputDecoration(
                          labelText: 'مناطق التغطية (افصل بفاصلة)',
                          hintText: 'مثال: الخرطوم, بحري, أم درمان',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.map),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال مناطق التغطية';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Card(
                        child: SwitchListTile(
                          title: const Text('المكتب نشط'),
                          subtitle: const Text('تفعيل/إيقاف مكتب التوصيل'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() => _isActive = value);
                          },
                          secondary: Icon(
                            _isActive ? Icons.check_circle : Icons.cancel,
                            color: _isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: _saveDelivery,
                        icon: const Icon(Icons.save),
                        label: Text(isEdit ? 'حفظ التعديلات' : 'إضافة المكتب'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
