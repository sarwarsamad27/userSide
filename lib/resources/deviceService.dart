// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';

// class DeviceIdService {
//   static const String _deviceIdKey = 'device_id';

//   // ✅ Get or Generate Device ID
//   static Future<String> getDeviceId() async {
//     final prefs = await SharedPreferences.getInstance();
    
//     String? deviceId = prefs.getString(_deviceIdKey);
    
//     if (deviceId != null && deviceId.isNotEmpty) {
//       print("✅ Existing Device ID: $deviceId");
//       return deviceId;
//     }

//     // Generate new UUID
//     deviceId = const Uuid().v4();
//     await prefs.setString(_deviceIdKey, deviceId);
    
//     print("✅ New Device ID generated: $deviceId");
//     return deviceId;
//   }
// }