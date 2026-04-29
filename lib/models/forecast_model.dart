class ForecastModel {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;

  ForecastModel({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
  });

  // 1. Hàm fromJson đã được sửa lỗi ép kiểu an toàn
  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      // Chuyển đổi an toàn: ép kiểu về num trước khi toDouble để tránh lỗi int/double
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'] != null && json['weather'].isNotEmpty
          ? json['weather'][0]['description']
          : "No description",
      icon: json['weather'] != null && json['weather'].isNotEmpty
          ? json['weather'][0]['icon']
          : "01d",
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }

  // 2. BẮT BUỘC THÊM: Hàm toJson để lưu vào StorageService
  Map<String, dynamic> toJson() {
    return {
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'main': {
        'temp': temperature,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'humidity': humidity,
      },
      'weather': [
        {
          'description': description,
          'icon': icon,
        }
      ],
      'wind': {
        'speed': windSpeed,
      },
    };
  }
}