// ============================================
// نظام رفع صورة البروفايل
// Profile Image Upload System with Firebase Storage
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class ProfileImageUploadService {
  final ImagePicker _picker = ImagePicker();
  
  // اختيار صورة من الكاميرا أو المعرض
  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      return null;
    }
  }
  
  // رفع الصورة إلى Firebase Storage
  Future<String?> uploadToFirebase(File imageFile, String userId) async {
    try {
      // إنشاء reference في Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');
      
      // رفع الصورة
      final uploadTask = storageRef.putFile(imageFile);
      
      // انتظار اكتمال الرفع
      final snapshot = await uploadTask;
      
      // الحصول على رابط التحميل
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading to Firebase: $e');
      return null;
    }
  }
  
  // حفظ رابط الصورة في SharedPreferences
  Future<void> saveImageUrl(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImage', imageUrl);
  }
  
  // عرض خيارات اختيار الصورة
  Future<File?> showImageSourceDialog(BuildContext context, LanguageProvider lang) async {
    return showDialog<File?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate('اختر مصدر الصورة', 'Choose Image Source')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF6B9AC4)),
              title: Text(lang.translate('التقاط صورة', 'Take Photo')),
              onTap: () async {
                Navigator.pop(context);
                final image = await pickImage(ImageSource.camera);
                if (context.mounted && image != null) {
                  Navigator.pop(context, image);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF6B9AC4)),
              title: Text(lang.translate('اختيار من المعرض', 'Choose from Gallery')),
              onTap: () async {
                Navigator.pop(context);
                final image = await pickImage(ImageSource.gallery);
                if (context.mounted && image != null) {
                  Navigator.pop(context, image);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate('إلغاء', 'Cancel')),
          ),
        ],
      ),
    );
  }
  
  // عملية رفع كاملة مع واجهة مستخدم
  Future<String?> uploadProfileImage(
    BuildContext context,
    LanguageProvider lang,
    String userId,
  ) async {
    try {
      // عرض خيارات اختيار الصورة
      File? imageFile;
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(lang.translate('اختر مصدر الصورة', 'Choose Image Source')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF6B9AC4)),
                title: Text(lang.translate('التقاط صورة', 'Take Photo')),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  imageFile = await pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF6B9AC4)),
                title: Text(lang.translate('اختيار من المعرض', 'Choose from Gallery')),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  imageFile = await pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(lang.translate('إلغاء', 'Cancel')),
            ),
          ],
        ),
      );
      
      if (imageFile == null || !context.mounted) return null;
      
      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(lang.translate('جاري رفع الصورة...', 'Uploading image...')),
            ],
          ),
        ),
      );
      
      // رفع الصورة
      final imageUrl = await uploadToFirebase(imageFile!, userId);
      
      if (context.mounted) {
        Navigator.pop(context); // إغلاق مؤشر التحميل
      }
      
      if (imageUrl != null) {
        // حفظ رابط الصورة
        await saveImageUrl(imageUrl);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lang.translate('تم رفع الصورة بنجاح', 'Image uploaded successfully')),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        return imageUrl;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lang.translate('فشل رفع الصورة', 'Failed to upload image')),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error in uploadProfileImage: $e');
      if (context.mounted) {
        Navigator.pop(context); // إغلاق مؤشر التحميل في حالة الخطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.translate('حدث خطأ أثناء رفع الصورة', 'Error uploading image')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }
}

// Widget لعرض صورة البروفايل مع خيار الرفع
class ProfileImageWidget extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onImageChanged;
  
  const ProfileImageWidget({
    super.key,
    this.imageUrl,
    this.radius = 60,
    this.onImageChanged,
  });

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  final ProfileImageUploadService _uploadService = ProfileImageUploadService();
  bool _isUploading = false;

  Future<void> _handleImageUpload() async {
    if (_isUploading) return;
    
    setState(() => _isUploading = true);
    
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userEmail') ?? 'user';
    
    final imageUrl = await _uploadService.uploadProfileImage(
      context,
      lang,
      userId.replaceAll('@', '_').replaceAll('.', '_'),
    );
    
    setState(() => _isUploading = false);
    
    if (imageUrl != null && widget.onImageChanged != null) {
      widget.onImageChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: const Color(0xFF6B9AC4),
          backgroundImage: widget.imageUrl != null
              ? NetworkImage(widget.imageUrl!)
              : null,
          child: widget.imageUrl == null
              ? Icon(Icons.person, size: widget.radius, color: Colors.white)
              : null,
        ),
        if (!_isUploading)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _handleImageUpload,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B9AC4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        if (_isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ========== تحديث CompleteProfileScreen لاستخدام ProfileImageWidget ==========

Widget buildProfileHeaderWithImageUpload(
  BuildContext context,
  dynamic userData,
  LanguageProvider lang,
  VoidCallback onImageChanged,
) {
  return Center(
    child: Column(
      children: [
        ProfileImageWidget(
          imageUrl: userData.profileImage,
          radius: 60,
          onImageChanged: onImageChanged,
        ),
        const SizedBox(height: 16),
        Text(
          userData.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user, size: 16, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                userData.role,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
