import 'package:eduquestesay/data/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:eduquestesay/data/services/base64_image_service.dart';
import 'package:eduquestesay/data/models/user_model.dart';

class ProfileProvider with ChangeNotifier {
  final Base64ImageService _base64ImageService = Base64ImageService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String _error = '';
  String _uploadProgress = '';

  bool get isLoading => _isLoading;
  String get error => _error;
  String get uploadProgress => _uploadProgress;

  // Upload profile image as Base64
  Future<String?> uploadProfileImageBase64(String userId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      _uploadProgress = 'Selecting image...';
      notifyListeners();

      // Pick and convert image to Base64
      final String? base64Image = await _base64ImageService.pickAndConvertImage();
      
      if (base64Image == null) {
        _isLoading = false;
        _uploadProgress = '';
        notifyListeners();
        return null;
      }

      // Check image size (Firestore has 1MB document limit)
      final double imageSizeKB = _base64ImageService.getBase64SizeKB(base64Image);
      if (imageSizeKB > 500) { // 500KB limit
        _error = 'Image too large (${imageSizeKB.toStringAsFixed(1)}KB). Please choose a smaller image.';
        _isLoading = false;
        _uploadProgress = '';
        notifyListeners();
        return null;
      }

      _uploadProgress = 'Uploading image (${imageSizeKB.toStringAsFixed(1)}KB)...';
      notifyListeners();

      // Update user profile in Firestore
      await _authService.updateProfileImageBase64(userId, base64Image);
      
      _uploadProgress = 'Profile image updated successfully!';
      notifyListeners();
      
      return base64Image;
    } catch (e) {
      _error = 'Error uploading image: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      _uploadProgress = '';
      notifyListeners();
    }
  }

  // Update user profile info
  Future<bool> updateUserProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _authService.updateUserProfileWithBase64(
        userId: userId,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error updating profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void clearProgress() {
    _uploadProgress = '';
    notifyListeners();
  }
}