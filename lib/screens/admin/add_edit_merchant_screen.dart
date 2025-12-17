import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AddEditMerchantScreen extends StatefulWidget {
  final Map<String, dynamic>? merchant;

  const AddEditMerchantScreen({super.key, this.merchant});

  @override
  State<AddEditMerchantScreen> createState() => _AddEditMerchantScreenState();
}

class _AddEditMerchantScreenState extends State<AddEditMerchantScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _descriptionController;
  
  String _selectedCategory = 'إلكترونيات';
  bool _isVerified = false;
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'إلكترونيات',
    'ملابس',
    'أغذية',
    'أثاث',
    'كتب',
    'مجوهرات',
    'رياضة',
    'ألعاب',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.merchant?['name'] ?? '');
    _emailController = TextEditingController(text: widget.merchant?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.merchant?['phone'] ?? '');
    _addressController = TextEditingController(text: widget.merchant?['address'] ?? '');
    _cityController = TextEditingController(text: widget.merchant?['city'] ?? 'الخرطوم');
    _descriptionController = TextEditingController(text: widget.merchant?['description'] ?? '');
    
    if (widget.merchant != null) {
      _selectedCategory = widget.merchant!['category'] ?? 'إلكترونيات';
      _isVerified = widget.merchant!['verified'] ?? false;
      _isActive = widget.merchant!['active'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveMerchant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Load existing data
      final String jsonString = await rootBundle.loadString('assets/data/merchants.json');
      final List<dynamic> merchants = json.decode(jsonString);

      if (widget.merchant == null) {
        // Add new merchant
        final newMerchant = {
          'id': 'merchant_${DateTime.now().millisecondsSinceEpoch}',
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'category': _selectedCategory,
          'description': _descriptionController.text,
          'verified': _isVerified,
          'active': _isActive,
          'rating': 0.0,
          'total_sales': 0,
          'join_date': DateTime.now().toIso8601String(),
          'payment_methods': ['نقداً'],
        };
        merchants.add(newMerchant);
      } else {
        // Edit existing merchant
        final index = merchants.indexWhere((m) => m['id'] == widget.merchant!['id']);
        if (index != -1) {
          merchants[index] = {
            ...merchants[index],
            'name': _nameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
            'city': _cityController.text,
            'category': _selectedCategory,
            'description': _descriptionController.text,
            'verified': _isVerified,
            'active': _isActive,
          };
        }
      }

      // In a real app, save to file or API
      // For now, just show success message
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.merchant == null ? 'تم إضافة التاجر بنجاح' : 'تم تحديث بيانات التاجر',
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
    final isEdit = widget.merchant != null;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'تعديل بيانات التاجر' : 'إضافة تاجر جديد'),
          backgroundColor: Colors.teal,
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
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم التاجر/المتجر',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.store),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الاسم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
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

                      // Phone Field
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

                      // City Field
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

                      // Address Field
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

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'التصنيف',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value!);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'الوصف',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Verified Switch
                      Card(
                        child: SwitchListTile(
                          title: const Text('تاجر موثوق'),
                          subtitle: const Text('منح علامة التوثيق للتاجر'),
                          value: _isVerified,
                          onChanged: (value) {
                            setState(() => _isVerified = value);
                          },
                          secondary: Icon(
                            _isVerified ? Icons.verified : Icons.verified_outlined,
                            color: _isVerified ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Active Switch
                      Card(
                        child: SwitchListTile(
                          title: const Text('الحساب نشط'),
                          subtitle: const Text('تفعيل/إيقاف حساب التاجر'),
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

                      // Save Button
                      ElevatedButton.icon(
                        onPressed: _saveMerchant,
                        icon: const Icon(Icons.save),
                        label: Text(isEdit ? 'حفظ التعديلات' : 'إضافة التاجر'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
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
