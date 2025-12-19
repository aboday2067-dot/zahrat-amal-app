import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DeliveryAgentsScreen extends StatefulWidget {
  const DeliveryAgentsScreen({super.key});

  @override
  State<DeliveryAgentsScreen> createState() => _DeliveryAgentsScreenState();
}

class _DeliveryAgentsScreenState extends State<DeliveryAgentsScreen> {
  List<Map<String, dynamic>> _agents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final String? agentsData = prefs.getString('delivery_agents');
    
    if (agentsData != null) {
      final List<dynamic> decoded = jsonDecode(agentsData);
      setState(() {
        _agents = decoded.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } else {
      // بيانات تجريبية
      setState(() {
        _agents = [
          {
            'id': '1',
            'name': 'محمد أحمد',
            'phone': '0911234567',
            'vehicle': 'دراجة نارية',
            'status': 'متاح',
            'deliveries': 45,
            'rating': 4.8,
          },
          {
            'id': '2',
            'name': 'أحمد علي',
            'phone': '0922345678',
            'vehicle': 'سيارة صغيرة',
            'status': 'مشغول',
            'deliveries': 38,
            'rating': 4.6,
          },
          {
            'id': '3',
            'name': 'عمر محمود',
            'phone': '0933456789',
            'vehicle': 'دراجة نارية',
            'status': 'متاح',
            'deliveries': 52,
            'rating': 4.9,
          },
        ];
        _isLoading = false;
      });
      await _saveAgents();
    }
  }

  Future<void> _saveAgents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('delivery_agents', jsonEncode(_agents));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.green[700],
          title: const Text(
            'إدارة العمال',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ميزة البحث ستكون متاحة قريباً')),
                );
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _agents.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      _buildSummaryCards(),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _agents.length,
                          itemBuilder: (context, index) {
                            return _buildAgentCard(_agents[index]);
                          },
                        ),
                      ),
                    ],
                  ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddAgentDialog(),
          backgroundColor: Colors.green[700],
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'إضافة عامل',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    int totalAgents = _agents.length;
    int availableAgents = _agents.where((a) => a['status'] == 'متاح').length;
    int busyAgents = _agents.where((a) => a['status'] == 'مشغول').length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              title: 'الإجمالي',
              value: totalAgents.toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              title: 'المتاحون',
              value: availableAgents.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              title: 'المشغولون',
              value: busyAgents.toString(),
              icon: Icons.local_shipping,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    final bool isAvailable = agent['status'] == 'متاح';
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isAvailable ? Colors.green[100] : Colors.orange[100],
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: isAvailable ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            agent['phone'],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    agent['status'],
                    style: TextStyle(
                      color: isAvailable ? Colors.green[700] : Colors.orange[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  icon: Icons.two_wheeler,
                  label: agent['vehicle'],
                  color: Colors.blue,
                ),
                _buildInfoChip(
                  icon: Icons.local_shipping,
                  label: '${agent['deliveries']} توصيلة',
                  color: Colors.purple,
                ),
                _buildInfoChip(
                  icon: Icons.star,
                  label: agent['rating'].toString(),
                  color: Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditAgentDialog(agent),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('تعديل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleAgentStatus(agent),
                    icon: Icon(
                      isAvailable ? Icons.pause : Icons.play_arrow,
                      size: 18,
                    ),
                    label: Text(isAvailable ? 'إيقاف' : 'تفعيل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAvailable ? Colors.orange[600] : Colors.green[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _deleteAgent(agent['id']),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد عمال',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة عمال التوصيل لديك',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showAddAgentDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedVehicle = 'دراجة نارية';

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إضافة عامل جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedVehicle,
                  decoration: const InputDecoration(
                    labelText: 'نوع المركبة',
                    border: OutlineInputBorder(),
                  ),
                  items: ['دراجة نارية', 'سيارة صغيرة', 'شاحنة صغيرة']
                      .map((vehicle) => DropdownMenuItem(
                            value: vehicle,
                            child: Text(vehicle),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedVehicle = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى إدخال جميع البيانات')),
                  );
                  return;
                }

                setState(() {
                  _agents.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'vehicle': selectedVehicle,
                    'status': 'متاح',
                    'deliveries': 0,
                    'rating': 5.0,
                  });
                });
                _saveAgents();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إضافة العامل بنجاح')),
                );
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAgentDialog(Map<String, dynamic> agent) {
    final nameController = TextEditingController(text: agent['name']);
    final phoneController = TextEditingController(text: agent['phone']);
    String selectedVehicle = agent['vehicle'];

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل بيانات العامل'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedVehicle,
                  decoration: const InputDecoration(
                    labelText: 'نوع المركبة',
                    border: OutlineInputBorder(),
                  ),
                  items: ['دراجة نارية', 'سيارة صغيرة', 'شاحنة صغيرة']
                      .map((vehicle) => DropdownMenuItem(
                            value: vehicle,
                            child: Text(vehicle),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedVehicle = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  agent['name'] = nameController.text;
                  agent['phone'] = phoneController.text;
                  agent['vehicle'] = selectedVehicle;
                });
                _saveAgents();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAgentStatus(Map<String, dynamic> agent) {
    setState(() {
      agent['status'] = agent['status'] == 'متاح' ? 'مشغول' : 'متاح';
    });
    _saveAgents();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث حالة ${agent['name']}'),
      ),
    );
  }

  void _deleteAgent(String agentId) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من حذف هذا العامل؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _agents.removeWhere((agent) => agent['id'] == agentId);
                });
                _saveAgents();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف العامل بنجاح')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }
}
