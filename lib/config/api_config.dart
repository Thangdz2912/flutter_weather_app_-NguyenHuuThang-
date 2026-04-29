class ApiConfig {
  // Base URL của OpenWeatherMap
  static const String baseUrl = "https://api.openweathermap.org/data/2.5";

  // Các điểm cuối (endpoints)
  static const String currentWeather = "/weather";
  static const String forecast = "/forecast";

  // Hàm xây dựng URL hoàn chỉnh từ endpoint và các tham số
  static String buildUrl(String endpoint, Map<String, String> params) {
    // Tạo URI với các query parameters
    final uri = Uri.parse("$baseUrl$endpoint").replace(queryParameters: params);
    return uri.toString();
  }
}