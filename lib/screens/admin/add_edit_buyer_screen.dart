import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AddEditBuyerScreen extends StatefulWidget {
  final Map<String, dynamic>? buyer;

  const AddEditBuyerScreen({super.key, this.buyer});

  @override
  State<AddEditBuyerScreen> createState() => _AddEditBuyerScreenState();
}

class _AddEditBuyerScreenState extends State<AddEditBuyerScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.buyer?['name'] ?? '');
    _emailController = TextEditingController(text: widget.buyer?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.buyer?['phone'] ?? '');
    _addressController = TextEditingController(text: widget.buyer?['address'] ?? '');
    _cityController = TextEditingController(text: widget.buyer?['city'] ?? 'الخرطوم');
    
    if (widget.buyer != null) {
      _isActive = widget.buyer!['active'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveBuyer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String jsonString = await rootBundle.loadString('assets/data/buyers.json');
      final List<dynamic> buyers = json.decode(jsonString);

      if (widget.buyer == null) {
        // Add new buyer
        final newBuyer = {
          'id': 'buyer_${DateTime.now().millisecondsSinceEpoch}',
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'active': _isActive,
          'join_date': DateTime.now().toIso8601String(),
          'total_orders': 0,
          'total_spent': 0,
        };
        buyers.add(newBuyer);
      } else {
        // Edit existing buyer
        final index = buyers.indexWhere((b) => b['id'] == widget.buyer!['id']);
        if (index != -1) {
          buyers[index] = {
            ...buyers[index],
            'name': _nameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
            'city': _cityController.text,
            'active': _isActive,
          };
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.buyer == null ? 'تم إضافة المشتري بنجاح' : 'تم تحديث بيانات المشتري',
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
    final isEdit = widget.buyer != null;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'تعديل بيانات المشتري' : 'إضافة مشتري جديد'),
          backgroundColor: Colors.green,
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
                          labelText: 'اسم المشتري',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
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

                      Card(
                        child: SwitchListTile(
                          title: const Text('الحساب نشط'),
                          subtitle: const Text('تفعيل/إيقاف حساب المشتري'),
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
                        onPressed: _saveBuyer,
                        icon: const Icon(Icons.save),
                        label: Text(isEdit ? 'حفظ التعديلات' : 'إضافة المشتري'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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
