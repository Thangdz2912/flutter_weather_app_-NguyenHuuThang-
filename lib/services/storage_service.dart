import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class StorageService {
  static const String _weatherKey = 'cached_weather';
  static const String _lastUpdateKey = 'last_update';

  // 1. Lưu dữ liệu thời tiết vào máy
  Future<void> saveWeatherData(WeatherModel weather) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Chuyển object thành string JSON và lưu
      final String jsonString = json.encode(weather.toJson());
      await prefs.setString(_weatherKey, jsonString);

      // Lưu thời điểm cập nhật
      await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Lỗi khi lưu cache: $e');
    }
  }

  // 2. Đọc dữ liệu thời tiết đã lưu (Đã thêm xử lý lỗi)
  Future<WeatherModel?> getCachedWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weatherJson = prefs.getString(_weatherKey);

      if (weatherJson != null) {
        // Giải mã JSON an toàn với ép kiểu rõ ràng
        final Map<String, dynamic> decodedData =
        json.decode(weatherJson) as Map<String, dynamic>;

        return WeatherModel.fromJson(decodedData);
      }
    } catch (e) {
      // Nếu dữ liệu cũ bị lỗi cấu trúc, xóa nó đi để lần sau không bị lỗi tiếp
      print('Lỗi khi đọc cache: $e');
      await clearCache();
    }
    return null;
  }

  // 3. Kiểm tra xem dữ liệu cũ có còn hiệu lực không (< 30 phút)
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getInt(_lastUpdateKey);

      if (lastUpdate == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      final difference = now - lastUpdate;

      // 30 phút = 30 * 60 giây * 1000 miligiây
      return difference < (30 * 60 * 1000);
    } catch (e) {
      return false;
    }
  }

  // 4. Bổ sung: Xóa cache khi cần (Ví dụ khi Logout hoặc Clear Data)
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_weatherKey);
    await prefs.remove(_lastUpdateKey);
  }
}
