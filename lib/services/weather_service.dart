import 'dart:convert';
import 'dart:io'; // Thêm để bắt lỗi SocketException
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../config/api_config.dart';

class WeatherService {
  final String apiKey;

  WeatherService({required this.apiKey});

  // 1. Hàm tạo tham số chuẩn
  Map<String, String> _buildParams(Map<String, String> extraParams) {
    return {
      ...extraParams,
      'appid': apiKey,
      'units': 'metric',
      'lang': 'vi',
    };
  }

  // 2. Hàm xử lý phản hồi an toàn
  dynamic _handleResponse(http.Response response) {
    try {
      // Giải mã UTF-8 để hỗ trợ tiếng Việt
      final String body = utf8.decode(response.bodyBytes);
      final dynamic decodedData = json.decode(body);

      if (response.statusCode == 200) {
        return decodedData;
      } else if (response.statusCode == 401) {
        throw 'API Key không hợp lệ. Hãy kiểm tra file .env';
      } else if (response.statusCode == 404) {
        throw 'Không tìm thấy thông tin thời tiết tại đây';
      } else {
        // Lấy message từ API nếu có, không thì báo lỗi chung
        final String msg = (decodedData is Map && decodedData.containsKey('message'))
            ? decodedData['message']
            : 'Lỗi không xác định';
        throw 'Lỗi máy chủ ($msg)';
      }
    } on FormatException {
      throw 'Dữ liệu từ máy chủ bị lỗi định dạng';
    } catch (e) {
      rethrow; // Đẩy lỗi tiếp tục lên tầng Provider
    }
  }

  // 3. Lấy thời tiết theo thành phố (Đã sửa lỗi khoảng trắng trong tên)
  Future<WeatherModel> getCurrentWeatherByCity(String cityName) async {
    try {
      final url = ApiConfig.buildUrl(
        ApiConfig.currentWeather,
        _buildParams({'q': cityName}),
      );

      // Sửa lỗi quan trọng: Encode URL để xử lý khoảng trắng/ký tự đặc biệt
      final safeUri = Uri.parse(Uri.encodeFull(url));
      final response = await http.get(safeUri);

      final data = _handleResponse(response);
      return WeatherModel.fromJson(data);
    } on SocketException {
      throw 'Không có kết nối Internet';
    } catch (e) {
      throw e.toString();
    }
  }

  // 4. Lấy thời tiết theo GPS
  Future<WeatherModel> getCurrentWeatherByCoordinates(double lat, double lon) async {
    try {
      final url = ApiConfig.buildUrl(
        ApiConfig.currentWeather,
        _buildParams({'lat': lat.toString(), 'lon': lon.toString()}),
      );

      final response = await http.get(Uri.parse(url));
      final data = _handleResponse(response);
      return WeatherModel.fromJson(data);
    } on SocketException {
      throw 'Không có kết nối Internet';
    } catch (e) {
      throw e.toString();
    }
  }

  // 5. Lấy dự báo 5 ngày theo thành phố
  Future<List<ForecastModel>> getForecast(String cityName) async {
    try {
      final url = ApiConfig.buildUrl(
        ApiConfig.forecast,
        _buildParams({'q': cityName}),
      );

      final safeUri = Uri.parse(Uri.encodeFull(url));
      final response = await http.get(safeUri);

      final data = _handleResponse(response);
      final List<dynamic> forecastList = data['list'];

      return forecastList.map((item) => ForecastModel.fromJson(item)).toList();
    } on SocketException {
      throw 'Lỗi mạng: Kiểm tra kết nối wifi/4G';
    } catch (e) {
      throw e.toString();
    }
  }

  // 6. Lấy dự báo 5 ngày theo GPS
  Future<List<ForecastModel>> getForecastByCoordinates(double lat, double lon) async {
    try {
      final url = ApiConfig.buildUrl(
        ApiConfig.forecast,
        _buildParams({
          'lat': lat.toString(),
          'lon': lon.toString(),
        }),
      );

      final response = await http.get(Uri.parse(url));
      final data = _handleResponse(response);
      final List<dynamic> forecastList = data['list'];

      return forecastList.map((item) => ForecastModel.fromJson(item)).toList();
    } on SocketException {
      throw 'Lỗi mạng: Không thể tải dự báo';
    } catch (e) {
      throw e.toString();
    }
  }
}