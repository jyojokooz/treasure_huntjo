// lib/services/image_upload_service.dart

import 'dart:convert';
// FIX: Added this import to use 'debugPrint'.
import 'package:flutter/foundation.dart';
// FIX: Corrected the import statements to use ':' instead of '.'.
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  // Your Cloudinary details provided in the prompt
  final String _cloudName = 'dp6xq4ytv';
  final String _uploadPreset = 'treasurehunt';

  Future<String?> uploadImage(XFile imageFile) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);
        // Return the secure URL of the uploaded image
        return decodedData['secure_url'];
      } else {
        // FIX: Replaced 'print' with 'debugPrint'.
        debugPrint('Image upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // FIX: Replaced 'print' with 'debugPrint'.
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
