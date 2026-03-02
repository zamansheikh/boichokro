import 'dart:io';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/cloudinary_config.dart';

/// Cloudinary Service - Singleton providing access to Cloudinary for image uploads
@lazySingleton
class CloudinaryService {
  
  CloudinaryService() {
    // Initialize Cloudinary with your cloud name
    CloudinaryContext.cloudinary = CloudinaryObject.fromCloudName(
      cloudName: CloudinaryConfig.cloudName,
    );
  }

  /// Upload an image to Cloudinary and return the URL
  /// 
  /// [file] - The image file to upload
  /// [folder] - Optional folder name in Cloudinary (e.g., 'book_covers', 'profile_photos')
  /// [publicId] - Optional custom public ID for the image
  /// 
  /// Returns the secure URL of the uploaded image
  /// 
  /// NOTE: This uses unsigned upload which requires an upload preset 
  /// configured in your Cloudinary dashboard (Settings > Upload > Upload presets)
  Future<String> uploadImage({
    required File file,
    String folder = 'book_covers',
    String? publicId,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = publicId ?? 'img_$timestamp';
      
      // Use HTTP multipart request for unsigned upload
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload'
      );
      
      final request = http.MultipartRequest('POST', url);
      
      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );
      
      // Add upload parameters (only params allowed for unsigned upload)
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      request.fields['folder'] = folder;
      if (publicId != null) {
        request.fields['public_id'] = fileName;
      }
      // Note: use_filename and unique_filename are NOT allowed in unsigned uploads
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final secureUrl = responseData['secure_url'] as String;
        return secureUrl;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to upload image: ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error uploading to Cloudinary: $e');
    }
  }

  /// Get the Cloudinary URL for an uploaded image
  /// 
  /// [url] - The secure URL returned from upload
  String getImageUrl(String url) {
    return url;
  }
}