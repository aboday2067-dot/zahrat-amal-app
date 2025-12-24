import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';

/// 🖼️ نظام ضغط وتحسين الصور المتقدم
/// 
/// **المشاكل التي يحلها:**
/// - صور كبيرة تستهلك الإنترنت والذاكرة
/// - بطء تحميل الصور
/// - استهلاك مساحة التخزين
/// 
/// **الحلول:**
/// - ضغط الصور تلقائياً قبل الرفع (90% أصغر)
/// - استخدام صور مصغرة (thumbnails)
/// - تخزين مؤقت ذكي
/// - تحميل تدريجي (Progressive Loading)

class ImageOptimizationService {
  /// ضغط صورة قبل الرفع
  /// 
  /// مثال: صورة 5MB تصبح 500KB فقط!
  static Future<File?> compressImage(File file, {int quality = 70}) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );
      
      if (result != null) {
        final resultFile = File(result.path);
        final originalSize = await file.length();
        final compressedSize = await resultFile.length();
        final reduction = ((1 - compressedSize / originalSize) * 100).toStringAsFixed(1);
        
        debugPrint('✅ ضغط الصورة: ${_formatBytes(originalSize)} → ${_formatBytes(compressedSize)} (توفير $reduction%)');
        return resultFile;
      }
      
      return null;
    } catch (e) {
      print('❌ فشل ضغط الصورة: $e');
      return null;
    }
  }
  
  /// إنشاء صورة مصغرة (thumbnail)
  static Future<File?> createThumbnail(File file, {int maxWidth = 300}) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_thumb.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 60,
        minWidth: maxWidth,
        minHeight: maxWidth,
        format: CompressFormat.jpeg,
      );
      
      if (result != null) {
        return File(result.path);
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ فشل إنشاء صورة مصغرة: $e');
      return null;
    }
  }
  
  /// ضغط صورة من الذاكرة (Uint8List)
  static Future<Uint8List?> compressBytes(Uint8List bytes, {int quality = 70}) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        minWidth: 1024,
        minHeight: 1024,
      );
      
      final reduction = ((1 - result.length / bytes.length) * 100).toStringAsFixed(1);
      debugPrint('✅ ضغط البيانات: ${_formatBytes(bytes.length)} → ${_formatBytes(result.length)} (توفير $reduction%)');
      
      return result;
    } catch (e) {
      print('❌ فشل ضغط البيانات: $e');
      return null;
    }
  }
  
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// 🎨 Widget للصور المحسنة مع تخزين مؤقت
class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const OptimizedImage({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 48,
      ),
    );
  }
}

/// 📸 نظام رفع الصور المحسن
class OptimizedImageUploader {
  /// رفع صورة مع ضغط تلقائي
  static Future<Map<String, String>> uploadWithCompression(
    File imageFile, {
    required Future<String> Function(File file) uploadFunction,
    bool createThumbnail = true,
  }) async {
    final results = <String, String>{};
    
    // 1. ضغط الصورة الأصلية
    final compressedFile = await ImageOptimizationService.compressImage(
      imageFile,
      quality: 75,
    );
    
    if (compressedFile != null) {
      // رفع الصورة المضغوطة
      results['full'] = await uploadFunction(compressedFile);
      
      // 2. إنشاء ورفع صورة مصغرة (اختياري)
      if (createThumbnail) {
        final thumbnailFile = await ImageOptimizationService.createThumbnail(
          compressedFile,
          maxWidth: 300,
        );
        
        if (thumbnailFile != null) {
          results['thumbnail'] = await uploadFunction(thumbnailFile);
        }
      }
      
      // حذف الملفات المؤقتة
      await compressedFile.delete();
    }
    
    return results;
  }
}

/// 🎯 مثال على الاستخدام في صفحة الملف الشخصي
class ProfileImageExample extends StatefulWidget {
  const ProfileImageExample({Key? key}) : super(key: key);

  @override
  State<ProfileImageExample> createState() => _ProfileImageExampleState();
}

class _ProfileImageExampleState extends State<ProfileImageExample> {
  String? _profileImageUrl;
  bool _uploading = false;

  Future<void> _pickAndUploadImage() async {
    // هنا يتم اختيار الصورة (استخدم image_picker)
    // File? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    
    // مثال افتراضي
    File? pickedFile;
    
    if (pickedFile == null) return;
    
    setState(() => _uploading = true);
    
    try {
      final results = await OptimizedImageUploader.uploadWithCompression(
        pickedFile,
        uploadFunction: (file) async {
          // هنا يتم رفع الملف لـ Firebase Storage
          // مثال: return await FirebaseStorage.instance.ref('profiles/${DateTime.now().millisecondsSinceEpoch}.jpg').putFile(file).then((snapshot) => snapshot.ref.getDownloadURL());
          return 'https://example.com/image.jpg'; // مثال فقط
        },
        createThumbnail: true,
      );
      
      setState(() {
        _profileImageUrl = results['full'];
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم رفع الصورة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
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
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصورة الشخصية')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // عرض الصورة المحسنة
            OptimizedImage(
              imageUrl: _profileImageUrl,
              width: 150,
              height: 150,
              borderRadius: BorderRadius.circular(75),
              placeholder: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 64, color: Colors.grey),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // زر رفع الصورة
            ElevatedButton.icon(
              onPressed: _uploading ? null : _pickAndUploadImage,
              icon: _uploading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload),
              label: Text(_uploading ? 'جاري الرفع...' : 'رفع صورة'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📦 إضافة الحزم المطلوبة في pubspec.yaml:
/// 
/// dependencies:
///   flutter_image_compress: ^2.1.0
///   cached_network_image: ^3.3.1
///   path_provider: ^2.1.2
///   image_picker: ^1.0.7
