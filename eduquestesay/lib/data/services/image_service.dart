import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  // Upload image to Firebase Storage
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      // Create a reference to the location you want to upload to in firebase storage
      String fileName = 'profile_$userId${path.extension(imageFile.path)}';
      Reference storageRef = _storage.ref().child('profile_images/$fileName');
      
      // Upload the file to firebase
      UploadTask uploadTask = storageRef.putFile(imageFile);
      
      // Wait for the upload to complete
      TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Delete old profile image
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        Reference storageRef = _storage.refFromURL(imageUrl);
        await storageRef.delete();
      }
    } catch (e) {
      print('Error deleting old image: $e');
    }
  }
}