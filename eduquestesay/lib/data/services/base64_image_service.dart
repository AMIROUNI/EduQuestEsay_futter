import 'dart:io';
import 'dart:convert';
import 'dart:typed_data'; // Add this import
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class Base64ImageService {
  final ImagePicker _imagePicker = ImagePicker();

  // Pick image and convert to Base64
  Future<String?> pickAndConvertImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,  // Reduce size for Base64
        maxHeight: 300,
        imageQuality: 70, // Lower quality for smaller Base64 string
      );
      
      if (image != null) {
        // Read file as bytes
        final File imageFile = File(image.path);
        final Uint8List imageBytes = await imageFile.readAsBytes(); // Changed to Uint8List
        
        // Optional: Compress image further
        final compressedBytes = await _compressImage(imageBytes);
        
        // Convert to Base64
        String base64String = base64Encode(compressedBytes);
        
        // Add data URL prefix for web compatibility
        String dataUrl = 'data:image/jpeg;base64,$base64String';
        
        return dataUrl;
      }
      return null;
    } catch (e) {
      print('Error converting image to Base64: $e');
      return null;
    }
  }

  // Compress image to reduce Base64 size
  Future<Uint8List> _compressImage(Uint8List imageBytes) async { // Changed return type to Uint8List
    try {
      // Decode image
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return imageBytes;
      
      // Resize to maximum 200x200 pixels
      final resizedImage = img.copyResize(originalImage, width: 200, height: 200);
      
      // Encode as JPEG with quality 70
      final List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 70);
      
      // Convert List<int> to Uint8List
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      print('Error compressing image: $e');
      return imageBytes; // Return original if compression fails
    }
  }

  // Convert Base64 back to Image widget
  Widget base64ToImage(String base64String) {
    try {
      // Remove data URL prefix if present
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }
      
      final Uint8List bytes = base64Decode(cleanBase64); // This already returns Uint8List
      return Image.memory(
        bytes, // Now it's Uint8List
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } catch (e) {
      print('Error decoding Base64 image: $e');
      return const Icon(Icons.person, size: 60, color: Colors.grey);
    }
  }

  // Check if Base64 string is valid
  bool isValidBase64(String base64String) {
    try {
      if (base64String.isEmpty) return false;
      
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }
      
      base64Decode(cleanBase64);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get image size in KB
  double getBase64SizeKB(String base64String) {
    try {
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }
      
      final Uint8List bytes = base64Decode(cleanBase64);
      return bytes.length / 1024; // Convert to KB
    } catch (e) {
      return 0;
    }
  }

  // Alternative method: Convert Base64 to Uint8List
  Uint8List? base64ToUint8List(String base64String) {
    try {
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }
      
      return base64Decode(cleanBase64);
    } catch (e) {
      print('Error converting Base64 to Uint8List: $e');
      return null;
    }
  }

  // Alternative method: Create Image from Base64 with error handling
  Widget buildBase64Image(String base64String, {double width = 120, double height = 120}) {
    final Uint8List? bytes = base64ToUint8List(base64String);
    
    if (bytes != null) {
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderIcon(width, height);
        },
      );
    } else {
      return _buildPlaceholderIcon(width, height);
    }
  }

  Widget _buildPlaceholderIcon(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: width * 0.5,
        color: Colors.grey[500],
      ),
    );
  }
}