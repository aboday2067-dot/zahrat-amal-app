// ============================================
// نظام رفع الصور المحسن v6.0
// Optimized Image Upload System
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'main.dart';

// 🚀 Performance Systems
import 'image_optimization.dart';

/// 📸 Widget لرفع صورة الملف الشخصي مع ضغط تلقائي
class OptimizedProfileImageUploader extends StatefulWidget {
  final String userId;
  final String? currentImageUrl;
  final Function(String fullUrl, String? thumbnailUrl) onImageUploaded;
  final double size;

  const OptimizedProfileImageUploader({
    Key? key,
    required this.userId,
    this.currentImageUrl,
    required this.onImageUploaded,
    this.size = 120,
  }) : super(key: key);

  @override
  State<OptimizedProfileImageUploader> createState() => _OptimizedProfileImageUploaderState();
}

class _OptimizedProfileImageUploaderState extends State<OptimizedProfileImageUploader> {
  bool _uploading = false;
  double _uploadProgress = 0;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    
    if (pickedFile == null) return;
    
    setState(() {
      _uploading = true;
      _uploadProgress = 0;
    });
    
    try {
      // 🖼️ رفع الصورة مع ضغط تلقائي
      final results = await OptimizedImageUploader.uploadWithCompression(
        File(pickedFile.path),
        uploadFunction: (file) async {
          final ref = FirebaseStorage.instance.ref(
            'profile_images/${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg'
          );
          
          // Upload with progress tracking
          final uploadTask = ref.putFile(file);
          
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            setState(() {
              _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
            });
          });
          
          await uploadTask;
          return await ref.getDownloadURL();
        },
        createThumbnail: true,
      );
      
      // استخدام الصورة الكاملة والمصغرة
      if (results.containsKey('full')) {
        widget.onImageUploaded(
          results['full']!,
          results['thumbnail'],
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '✅ تم رفع الصورة بنجاح',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (results.containsKey('thumbnail'))
                          const Text(
                            'تم إنشاء صورة مصغرة للتحميل السريع',
                            style: TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ فشل رفع الصورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _uploading = false;
        _uploadProgress = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // عرض الصورة المحسنة
        Stack(
          children: [
            OptimizedImage(
              imageUrl: widget.currentImageUrl,
              width: widget.size,
              height: widget.size,
              borderRadius: BorderRadius.circular(widget.size / 2),
              placeholder: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: widget.size * 0.5,
                  color: Colors.grey,
                ),
              ),
            ),
            
            // مؤشر التحميل
            if (_uploading)
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            
            // زر الكاميرا
            if (!_uploading)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B9AC4),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: _pickAndUploadImage,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // زر رفع الصورة (اختياري)
        if (!_uploading)
          TextButton.icon(
            onPressed: _pickAndUploadImage,
            icon: const Icon(Icons.upload, size: 18),
            label: Text(lang.translate('تحديث الصورة', 'Update Photo')),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B9AC4),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  '${(_uploadProgress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B9AC4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lang.translate('جاري رفع الصورة...', 'Uploading...'),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// 🎯 دالة مساعدة لرفع صورة مع ضغط
Future<Map<String, String>> uploadCompressedImage({
  required File imageFile,
  required String storagePath,
  bool createThumbnail = true,
}) async {
  return await OptimizedImageUploader.uploadWithCompression(
    imageFile,
    uploadFunction: (file) async {
      final ref = FirebaseStorage.instance.ref(storagePath);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    },
    createThumbnail: createThumbnail,
  );
}

/// 📦 نموذج بيانات الصورة
class ImageData {
  final String fullUrl;
  final String? thumbnailUrl;
  final DateTime uploadedAt;
  final int? fileSizeBytes;

  ImageData({
    required this.fullUrl,
    this.thumbnailUrl,
    required this.uploadedAt,
    this.fileSizeBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      'full_url': fullUrl,
      'thumbnail_url': thumbnailUrl,
      'uploaded_at': uploadedAt.toIso8601String(),
      'file_size_bytes': fileSizeBytes,
    };
  }

  factory ImageData.fromMap(Map<String, dynamic> map) {
    return ImageData(
      fullUrl: map['full_url'] ?? '',
      thumbnailUrl: map['thumbnail_url'],
      uploadedAt: DateTime.parse(map['uploaded_at'] ?? DateTime.now().toIso8601String()),
      fileSizeBytes: map['file_size_bytes'],
    );
  }
}
