import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;
  final LocationService _locationService;
  final StorageService _storageService;

  WeatherModel? _currentWeather;
  List<ForecastModel> _forecast = [];
  WeatherState _state = WeatherState.initial;
  String _errorMessage = '';

  WeatherProvider(
      this._weatherService,
      this._locationService,
      this._storageService,
      ) {
    // Tự động tải dữ liệu cũ ngay khi khởi tạo app
    loadCachedWeather();
  }

  WeatherModel? get currentWeather => _currentWeather;
  List<ForecastModel> get forecast => _forecast;
  WeatherState get state => _state;
  String get errorMessage => _errorMessage;

  // 1. Lấy thời tiết theo tên thành phố
  Future<void> fetchWeatherByCity(String cityName) async {
    _state = WeatherState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentWeather = await _weatherService.getCurrentWeatherByCity(cityName);
      _forecast = await _weatherService.getForecast(cityName);

      // Lưu cache dữ liệu mới
      await _storageService.saveWeatherData(_currentWeather!);
      // (Lưu ý: Bạn có thể nâng cấp StorageService để lưu cả _forecast nếu cần)

      _state = WeatherState.loaded;
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // 2. Lấy thời tiết theo tọa độ GPS (GIẢI PHÁP TỐI ƯU)
  Future<void> fetchWeatherByLocation() async {
    _state = WeatherState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();

      // Sử dụng tọa độ để lấy CẢ thời tiết hiện tại và dự báo
      // Cách này chính xác hơn nhiều so với việc dùng cityName trung gian
      _currentWeather = await _weatherService.getCurrentWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );

      _forecast = await _weatherService.getForecastByCoordinates(
        position.latitude,
        position.longitude,
      );

      await _storageService.saveWeatherData(_currentWeather!);
      _state = WeatherState.loaded;
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = e.toString();

      // Nếu lỗi mạng, tải dữ liệu từ bộ nhớ máy
      await loadCachedWeather();
    }
    notifyListeners();
  }

  // 3. Tải dữ liệu từ cache (Offline Mode)
  Future<void> loadCachedWeather() async {
    final cachedWeather = await _storageService.getCachedWeather();
    if (cachedWeather != null) {
      _currentWeather = cachedWeather;
      _state = WeatherState.loaded;
      notifyListeners();
    }
  }

  // 4. Làm mới dữ liệu
  Future<void> refreshWeather() async {
    if (_currentWeather != null) {
      await fetchWeatherByCity(_currentWeather!.cityName);
    } else {
      await fetchWeatherByLocation();
    }
  }
}

