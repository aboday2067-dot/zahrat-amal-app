import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

/// نظام التحقق من الاتصال بالإنترنت و Firebase
/// يعرض رسالة واضحة للمستخدم إذا كان هناك مشكلة في الاتصال

class ConnectionChecker extends StatefulWidget {
  final Widget child;

  const ConnectionChecker({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ConnectionChecker> createState() => _ConnectionCheckerState();
}

class _ConnectionCheckerState extends State<ConnectionChecker> {
  bool _isConnected = true;
  bool _isChecking = true;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _startConnectionCheck();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  void _startConnectionCheck() {
    // التحقق الأولي
    _checkConnection();
    
    // التحقق كل 10 ثواني
    _checkTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkConnection(),
    );
  }

  Future<void> _checkConnection() async {
    try {
      // محاولة الاتصال بـ Firestore
      final result = await FirebaseFirestore.instance
          .collection('connection_test')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      
      if (mounted) {
        setState(() {
          _isConnected = true;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        // رسالة التحذير إذا كان الاتصال مفقود
        if (!_isConnected && !_isChecking)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[800],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'لا يوجد اتصال بالإنترنت',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'يرجى التحقق من اتصالك بالإنترنت',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isChecking = true;
                        });
                        _checkConnection();
                      },
                      tooltip: 'إعادة المحاولة',
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// شاشة عرض حالة الاتصال (للتشخيص)
class ConnectionStatusScreen extends StatefulWidget {
  const ConnectionStatusScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionStatusScreen> createState() => _ConnectionStatusScreenState();
}

class _ConnectionStatusScreenState extends State<ConnectionStatusScreen> {
  bool _isChecking = false;
  String _status = 'لم يتم الفحص بعد';
  Color _statusColor = Colors.grey;

  Future<void> _checkFirebaseConnection() async {
    setState(() {
      _isChecking = true;
      _status = 'جاري الفحص...';
      _statusColor = Colors.blue;
    });

    try {
      // محاولة قراءة البيانات من Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      
      setState(() {
        _status = '✅ الاتصال بـ Firebase يعمل بنجاح';
        _statusColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _status = '❌ فشل الاتصال: ${e.toString()}';
        _statusColor = Colors.red;
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة الاتصال'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // أيقونة الحالة
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: _isChecking
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Icon(
                        _statusColor == Colors.green
                            ? Icons.cloud_done
                            : _statusColor == Colors.red
                                ? Icons.cloud_off
                                : Icons.cloud_queue,
                        size: 60,
                        color: _statusColor,
                      ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // رسالة الحالة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor),
              ),
              child: Text(
                _status,
                style: TextStyle(
                  fontSize: 16,
                  color: _statusColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // معلومات مفيدة
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      'إذا استمرت المشكلة:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _InfoItem(
                      icon: Icons.wifi,
                      text: 'تأكد من اتصال الإنترنت',
                    ),
                    SizedBox(height: 8),
                    _InfoItem(
                      icon: Icons.router,
                      text: 'جرب إعادة تشغيل الراوتر',
                    ),
                    SizedBox(height: 8),
                    _InfoItem(
                      icon: Icons.refresh,
                      text: 'أعد تشغيل التطبيق',
                    ),
                    SizedBox(height: 8),
                    _InfoItem(
                      icon: Icons.vpn_key,
                      text: 'تأكد من عدم استخدام VPN',
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // زر إعادة المحاولة
            ElevatedButton.icon(
              onPressed: _isChecking ? null : _checkFirebaseConnection,
              icon: const Icon(Icons.refresh),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 20, color: Colors.blue[700]),
      ],
    );
  }
}
