// ===============================
// FILE NAME: image_upload_service.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\services\image_upload_service.dart
// ===============================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// --- THE FIX: Import the new mime package ---
import 'package:mime/mime.dart';

class ImageUploadService {
  final String _cloudName = 'dp6xq4ytv';
  final String _uploadPreset = 'treasurehunt';

  Future<String?> uploadImage(XFile mediaFile) async {
    // --- THE FIX: Use the 'mime' package for reliable type detection ---
    final String? mimeType = lookupMimeType(mediaFile.path);
    final bool isVideo = mimeType?.startsWith('video/') ?? false;
    final String resourceType = isVideo ? 'video' : 'image';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
    );

    debugPrint(
      "Uploading to Cloudinary endpoint: $url (File type detected as: $resourceType)",
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', mediaFile.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        String secureUrl = decodedData['secure_url'];

        if (isVideo) {
          int lastDot = secureUrl.lastIndexOf('.');
          int lastSlash = secureUrl.lastIndexOf('/');
          if (lastDot > lastSlash) {
            secureUrl = secureUrl.substring(0, lastDot);
          }
          return '$secureUrl.mp4';
        } else {
          return secureUrl;
        }
      } else {
        debugPrint('Media upload failed with status: ${response.statusCode}');
        final error = await response.stream.bytesToString();
        debugPrint('Error response: $error');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading media: $e');
      return null;
    }
  }
}
