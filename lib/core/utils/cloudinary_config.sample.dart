/// Cloudinary Configuration (SAMPLE)
///
/// IMPORTANT: Add your Cloudinary credentials here
/// You can find these in your Cloudinary Dashboard: https://console.cloudinary.com/
/// REMOVE THIS .sample EXTENSION to use this file.
class CloudinaryConfig {
  // Your Cloudinary Cloud Name
  static const String cloudName = 'YOUR_CLOUD_NAME';

  // Your Cloudinary API Key
  static const String apiKey = 'YOUR_API_KEY';

  // Your Cloudinary API Secret
  static const String apiSecret = 'YOUR_API_SECRET';

  // Upload Preset (create an unsigned preset in Cloudinary dashboard)
  static const String uploadPreset = 'YOUR_UNSIGNED_PRESET_NAME';

  // Base URL format: cloudinary://API_KEY:API_SECRET@CLOUD_NAME
  static String get cloudinaryUrl =>
      'cloudinary://$apiKey:$apiSecret@$cloudName';

  //API ENVIRONMENT VARIABLES
  static const String cloudinaryEnv =
      'CLOUDINARY_URL=cloudinary://YOUR_API_KEY:YOUR_API_SECRET@YOUR_CLOUD_NAME';
}
